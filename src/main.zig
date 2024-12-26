const std = @import("std");
const CPU = @import("cpu.zig").CPU;
const MemoryBus = @import("memory_bus.zig").MemoryBus;
const addr = @import("addressable_space.zig");
const OpCode = @import("opcodes.zig").OpCode;
const boot_rom: *const [addr.BOOT_ROM_SIZE:0]u8 = @embedFile("dmg_boot.bin");

pub fn main() !void {
    var cpu = CPU{ .memoryBus = MemoryBus.init(boot_rom) };

    while (cpu.registers.program_counter < 256) {
        var intruction_byte = cpu.memoryBus.readByte(cpu.registers.program_counter);
        const is_prefixed = intruction_byte == 0xCB;
        if (is_prefixed) {
            intruction_byte = cpu.memoryBus.readByte(cpu.registers.program_counter + 1);
        }

        const instruction = if (is_prefixed) OpCode{ .prefixed = @enumFromInt(intruction_byte) } else OpCode{ .unprefixed = @enumFromInt(intruction_byte) };

        _ = cpu.step();

        switch (instruction) {
            .unprefixed => |*unprefixed| {
                std.debug.print("[unprefixed] {s}\n", .{@tagName(unprefixed.*)});
            },
            .prefixed => |*prefixed| {
                std.debug.print("[prefixed]   {s}\n", .{@tagName(prefixed.*)});
            },
        }
    }
}
