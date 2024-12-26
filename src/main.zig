const std = @import("std");
const CPU = @import("cpu.zig").CPU;
const MemoryBus = @import("memory_bus.zig").MemoryBus;
const addr = @import("addressable_space.zig");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();
    // defer _ = gpa.deinit();

    const file = std.fs.cwd().openFile("dmg_boot.bin", .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return;
    };
    defer file.close();

    var boot_rom: [addr.BOOT_ROM_SIZE]u8 = std.mem.zeroes([addr.BOOT_ROM_SIZE]u8);
    _ = try file.readAll(&boot_rom);

    var cpu = CPU{ .memoryBus = MemoryBus.init(boot_rom) };

    _ = cpu.step();

    std.debug.print("{b}\n", .{cpu.registers.getAF()});
}
