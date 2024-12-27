const std = @import("std");
const addr = @import("addressable_space.zig");

pub const InterruptRequest = packed struct {
    vblank: bool = false,
    lcdstat: bool = false,
};

pub const ObjectSize = enum(u1) {
    OS8X8 = 0,
    OS8X16 = 1,
};

pub const TileMapArea = enum(u1) {
    X9800 = 0,
    X9C00 = 1,
};

pub const TileDataArea = enum(u1) {
    X8800 = 0,
    X8000 = 1,
};

pub const LCDControl = packed struct {
    background_and_window_enabled: bool = false,
    object_enabled: bool = false,
    object_size: ObjectSize = ObjectSize.OS8X8,
    background_tile_map_area: TileMapArea = TileMapArea.X9800,
    background_and_window_tile_data_area: TileDataArea = TileDataArea.X8800,
    window_enabled: bool = false,
    window_tile_map_area: TileMapArea = TileMapArea.X9800,
    lcd_enabled: bool = false,

    pub fn fromByte(byte: u8) LCDControl {
        return @bitCast(byte);
    }

    pub fn toByte(self: *LCDControl) u8 {
        return @bitCast(self.*);
    }

    pub fn putByte(self: *LCDControl, byte: u8) void {
        self.* = @bitCast(byte);
    }
};

pub const Mode = enum(u2) {
    HorizontalBlank = 0,
    VerticalBlank = 1,
    OAMAccess = 2,
    VRAMAccess = 3,
};

pub const LCDStatus = packed struct {
    mode: Mode = Mode.HorizontalBlank,
    line_equals_line_check: bool = false,
    hblank_interrupt_enabled: bool = false,
    vblank_interrupt_enabled: bool = false,
    oam_interrupt_enabled: bool = false,
    line_equals_line_check_interrupt_enabled: bool = false,

    _padding: u1 = 0,

    pub fn fromByte(byte: u8) LCDStatus {
        return @bitCast(byte & 0b0111_1111);
    }

    pub fn toByte(self: *LCDStatus) u8 {
        return @bitCast(self.*);
    }

    pub fn putByte(self: *LCDStatus, byte: u8) void {
        const read_only_bits = self.toByte() & 0b0000_0111;
        const updated_bits = byte & 0b0111_1000;

        self.* = @bitCast(updated_bits | read_only_bits);
    }
};

pub const TilePixelColorID = enum(u2) {
    Zero = 0,
    One = 1,
    Two = 2,
    Three = 3,
};

pub const TileRow = packed struct {
    least_significant_byte: u8 = 0,
    most_significant_byte: u8 = 0,

    fn getPixelColorId(self: TileRow, comptime index: u7) TilePixelColorID {
        const pixel_mask: u8 = 1 << (7 - index);
        const least_significant_bit = self.least_significant_byte & pixel_mask;
        const most_significant_bit = self.most_significant_byte & pixel_mask;
        return @enumFromInt((most_significant_bit << 1) | least_significant_bit);
    }
};

pub const Color = enum(u2) {
    White = 0,
    LightGray = 1,
    DarkGray = 2,
    Black = 3,
};

pub const ColorPalette = packed struct {
    c0: Color = Color.White,
    c1: Color = Color.LightGray,
    c2: Color = Color.DarkGray,
    c3: Color = Color.Black,

    pub fn fromByte(byte: u8) ColorPalette {
        return @bitCast(byte);
    }

    pub fn toByte(self: *ColorPalette) u8 {
        return @bitCast(self.*);
    }

    pub fn putByte(self: *ColorPalette, byte: u8) void {
        self.* = @bitCast(byte);
    }
};

pub const PPU = struct {
    lcd_control: LCDControl = LCDControl{},
    lcd_status: LCDStatus = LCDStatus{},

    vram: [addr.VRAM_SIZE]u8 = std.mem.zeroes([addr.VRAM_SIZE]u8),
    oam: [addr.OAM_SIZE]u8 = std.mem.zeroes([addr.OAM_SIZE]u8),

    cycles: u16 = 0,

    line: u8 = 0,
    line_check: u8 = 0,

    viewport_x: u8 = 0,
    viewport_y: u8 = 0,

    window_x: u8 = 0,
    window_y: u8 = 0,

    background_color_palette: ColorPalette = ColorPalette{},
    object_0_color_palette: ColorPalette = ColorPalette{},
    object_1_color_palette: ColorPalette = ColorPalette{},

    fn getTiles(self: *PPU) [384][8]TileRow {
        return @bitCast(self.vram[0..0x1800].*);
    }

    pub fn step(self: *PPU, cycles: u8) InterruptRequest {
        var request = InterruptRequest{};

        if (!self.lcd_control.lcd_enabled) {
            return request;
        }

        self.cycles += cycles;

        switch (self.lcd_status.mode) {
            Mode.HorizontalBlank => {
                if (self.cycles >= 200) {
                    self.cycles = self.cycles % 200;
                    self.line += 1;

                    if (self.line >= 144) {
                        self.lcd_status.mode = Mode.VerticalBlank;
                        request.vblank = true;

                        if (self.lcd_status.vblank_interrupt_enabled) {
                            request.lcdstat = true;
                        }
                    } else {
                        self.lcd_status.mode = Mode.OAMAccess;

                        if (self.lcd_status.oam_interrupt_enabled) {
                            request.lcdstat = true;
                        }
                    }

                    self.setEqualLineCheck(&request);
                }
            },
            Mode.VerticalBlank => {
                if (self.cycles >= 456) {
                    self.cycles = self.cycles % 456;
                    self.line += 1;

                    if (self.line == 154) {
                        self.lcd_status.mode = Mode.OAMAccess;
                        self.line = 0;

                        if (self.lcd_status.oam_interrupt_enabled) {
                            request.lcdstat = true;
                        }
                    }

                    self.setEqualLineCheck(&request);
                }
            },
            Mode.OAMAccess => {
                if (self.cycles >= 80) {
                    self.cycles = self.cycles % 80;
                    self.lcd_status.mode = Mode.VRAMAccess;
                }
            },
            Mode.VRAMAccess => {
                if (self.cycles >= 172) {
                    self.cycles = self.cycles % 172;
                    if (self.lcd_status.hblank_interrupt_enabled) {
                        request.lcdstat = true;
                    }
                    self.lcd_status.mode = Mode.HorizontalBlank;
                    self.renderScanLine();
                }
            },
        }

        return request;
        // const tiles = self.getTiles();
        // for (tiles, 0..) |tile, index| {
        //     inline for (tile) |tile_row| {
        //         inline for (0..8) |pixel_index| {
        //             const pixel = tile_row.getPixelColorId(pixel_index);
        //             std.debug.print("tile: {d} {s}\n", .{ index, @tagName(pixel) });
        //         }
        //     }
        // }
        // return InterruptRequest{};
    }

    fn setEqualLineCheck(self: *PPU, request: *InterruptRequest) void {
        self.lcd_status.line_equals_line_check = self.line == self.line_check;

        if (self.lcd_status.line_equals_line_check and self.lcd_status.line_equals_line_check_interrupt_enabled) {
            request.lcdstat = true;
        }
    }

    fn renderScanLine(self: *PPU) void {
        _ = self;
    }
};
