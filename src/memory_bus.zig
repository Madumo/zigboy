const std = @import("std");

pub const MemoryBus = struct {
    memory: [0xFFFF]u8 = std.mem.zeroes([0xFFFF]u8),

    pub fn readByte(self: *MemoryBus, address: u16) u8 {
        return self.memory[address];
    }

    pub fn writeByte(self: *MemoryBus, address: u16, byte: u8) void {
        self.memory[address] = byte;
    }
};
