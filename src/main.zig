const std = @import("std");
const CPU = @import("cpu.zig").CPU;
const MemoryBus = @import("memory_bus.zig").MemoryBus;
const addr = @import("addressable_space.zig");
const OpCode = @import("opcodes.zig").OpCode;
const boot_rom: *const [addr.BOOT_ROM_SIZE:0]u8 = @embedFile("dmg_boot.bin");

const CYCLES_PER_SECOND: usize = 4_194304; // 4.194304MHz
const FRAMES_PER_SECOND: f64 = 59.73;
const CYCLES_PER_FRAME = 70224;
const NANOSECONDS_PER_FRAME: f64 = std.time.ns_per_s / FRAMES_PER_SECOND;
const NANOSECONDS_PER_CYCLE: f64 = std.time.ns_per_s / CYCLES_PER_SECOND;

pub fn main() !void {
    var cpu = CPU{ .memoryBus = MemoryBus.init(boot_rom) };

    var before = try std.time.Instant.now();
    var cycles_elapsed_in_frame: usize = 0;

    while (true) {
        const now = try std.time.Instant.now();
        defer before = now;
        const elapsed_time = now.since(before);
        const cycles_to_run: usize = @intFromFloat(@trunc(@as(f64, @floatFromInt(elapsed_time)) / NANOSECONDS_PER_CYCLE));

        var cycles_elapsed: usize = 0;
        while (cycles_elapsed <= cycles_to_run) {
            var intruction_byte = cpu.memoryBus.readByte(cpu.registers.program_counter);
            const is_prefixed = intruction_byte == 0xCB;
            if (is_prefixed) {
                intruction_byte = cpu.memoryBus.readByte(cpu.registers.program_counter + 1);
            }

            const instruction = if (is_prefixed) OpCode{ .prefixed = @enumFromInt(intruction_byte) } else OpCode{ .unprefixed = @enumFromInt(intruction_byte) };

            cycles_elapsed += cpu.step();

            switch (instruction) {
                .unprefixed => |*unprefixed| {
                    std.debug.print("[unprefixed] {s}\n", .{@tagName(unprefixed.*)});
                },
                .prefixed => |*prefixed| {
                    std.debug.print("[prefixed]   {s}\n", .{@tagName(prefixed.*)});
                },
            }
        }

        cycles_elapsed_in_frame += cycles_elapsed;

        if (cycles_elapsed_in_frame >= CYCLES_PER_FRAME) {
            std.debug.print("OUTPUT FRAME", .{});
        } else {
            try std.Thread.yield();
        }
    }
}
