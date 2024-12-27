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

pub const PPUMode = enum(u2) {
    HorizontalBlank = 0,
    VerticalBlank = 1,
    OAMAccess = 2,
    VRAMAccess = 3,
};

pub const LCDStatus = packed struct {
    mode: PPUMode = PPUMode.HorizontalBlank,
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

pub const PPU = struct {
    lcd_control: LCDControl = LCDControl{},
    lcd_status: LCDStatus = LCDStatus{},

    vram: [addr.VRAM_SIZE]u8 = std.mem.zeroes([addr.VRAM_SIZE]u8),
    oam: [addr.OAM_SIZE]u8 = std.mem.zeroes([addr.OAM_SIZE]u8),

    pub fn step(self: *PPU, cycles: u8) InterruptRequest {
        _ = self;
        _ = cycles;
        return InterruptRequest{};
    }
};
