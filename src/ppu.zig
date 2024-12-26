const std = @import("std");
const addr = @import("addressable_space.zig");

pub const InterruptRequest = packed struct {
    vblank: bool = false,
    lcdstat: bool = false,
};

pub const PPU = struct {
    vram: [addr.VRAM_SIZE]u8 = std.mem.zeroes([addr.VRAM_SIZE]u8),
    oam: [addr.OAM_SIZE]u8 = std.mem.zeroes([addr.OAM_SIZE]u8),

    pub fn step(self: *PPU, cycles: u8) InterruptRequest {
        _ = self;
        _ = cycles;
        return InterruptRequest{};
    }
};
