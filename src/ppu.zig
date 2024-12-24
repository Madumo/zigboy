const std = @import("std");
const addr = @import("addressable_space.zig");

pub const PPU = struct {
    vram: [addr.VRAM_SIZE]u8 = std.mem.zeroes([addr.VRAM_SIZE]u8),
    oam: [addr.OAM_SIZE]u8 = std.mem.zeroes([addr.OAM_SIZE]u8),
};
