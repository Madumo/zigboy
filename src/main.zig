const std = @import("std");
const CPU = @import("cpu.zig").CPU;
const MemoryBus = @import("memory_bus.zig").MemoryBus;
const addr = @import("addressable_space.zig");
const boot_rom: *const [addr.BOOT_ROM_SIZE:0]u8 = @embedFile("dmg_boot.bin");

pub fn main() !void {
    var cpu = CPU{ .memoryBus = MemoryBus.init(boot_rom) };



    _ = cpu.step();

    std.debug.print("{b}\n", .{cpu.registers.getAF()});
}
