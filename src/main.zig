const std = @import("std");
const CPU = @import("cpu.zig").CPU;

pub fn main() !void {
    var cpu = CPU{};
    //registers.b = 0b11111111;
    //registers.c = 0b11111111;
    cpu.registers.setBC(0b11110000_10101010);
    //std.debug.print("0b{b}\n0b{b}\n", .{ registers.b, registers.c });
    //const res: u8 = 0b1111_1111 & !(1 << 2);
    // const bits = 1 << 2;
    // const converted_to_bool: bool = @bitCast(bits);
    // const inverse_bool = !converted_to_bool;
    // const result = 0b1111_1111 & inverse_bool;
    // const herp = setBit(0b0000_0000, 2);
    //const derp = resetBit(0b1111_1111, 2);
    //
    cpu.registers.flags.zero = true;
    cpu.registers.flags.carry = true;

    //var flags = PackedFlagsRegister{ .zero = true, .subtract = false, .half_carry = true, .carry = true };
    // var flags2 = PackedFlagsRegister{};
    // flags2.fromInt(0b1010_0000);
    //const flagsInt: u8 = @bitCast(flags);

    std.debug.print("{b}\n", .{cpu.registers.getAF()});

    cpu.registers.setAF(0b11111111_01010000);

    std.debug.print("{b}\n", .{cpu.registers.getAF()});
}
