const ZERO_FLAG_BYTE_POSITION: u8 = 7;
const SUBTRACT_FLAG_BYTE_POSITION: u8 = 6;
const HALF_CARRY_FLAG_BYTE_POSITION: u8 = 5;
const CARRY_FLAG_BYTE_POSITION: u8 = 4;

pub const FlagsRegister = struct {
    zero: bool = false,
    subtract: bool = false,
    half_carry: bool = false,
    carry: bool = false,

    pub fn toInt(self: *FlagsRegister) u8 {
        return @intFromBool(self.zero) << ZERO_FLAG_BYTE_POSITION |
            @intFromBool(self.subtract) << SUBTRACT_FLAG_BYTE_POSITION |
            @intFromBool(self.half_carry) << HALF_CARRY_FLAG_BYTE_POSITION |
            @intFromBool(self.carry) << CARRY_FLAG_BYTE_POSITION;
    }

    pub fn fromInt(self: *FlagsRegister, value: u8) void {
        self.zero = @bitCast((value >> ZERO_FLAG_BYTE_POSITION) & 0b1);
        self.subtract = @bitCast((value >> SUBTRACT_FLAG_BYTE_POSITION) & 0b1);
        self.half_carry = @bitCast((value >> HALF_CARRY_FLAG_BYTE_POSITION) & 0b1);
        self.carry = @bitCast((value >> HALF_CARRY_FLAG_BYTE_POSITION) & 0b1);
    }
};

pub const Registers = struct {
    accumulator: u8 = 0,
    flags: u8 = 0,

    b: u8 = 0,
    c: u8 = 0,

    d: u8 = 0,
    e: u8 = 0,

    h: u8 = 0,
    l: u8 = 0,

    program_counter: u16 = 0,
    stack_pointer: u16 = 0,

    pub fn getAF(self: *Registers) u16 {
        return @as(u16, self.accumulator) << 8 | @as(u16, self.flags);
    }

    pub fn setAF(self: *Registers, value: u16) void {
        self.accumulator = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.flags = @as(u8, @intCast(value & 0xFF));
    }

    pub fn getBC(self: *Registers) u16 {
        return @as(u16, self.b) << 8 | @as(u16, self.c);
    }

    pub fn setBC(self: *Registers, value: u16) void {
        self.b = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.c = @as(u8, @intCast(value & 0xFF));
    }

    pub fn getDE(self: *Registers) u16 {
        return @as(u16, self.d) << 8 | @as(u16, self.e);
    }

    pub fn setDE(self: *Registers, value: u16) void {
        self.d = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.e = @as(u8, @intCast(value & 0xFF));
    }

    pub fn getHL(self: *Registers) u16 {
        return @as(u16, self.h) << 8 | @as(u16, self.l);
    }

    pub fn setHL(self: *Registers, value: u16) void {
        self.h = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.l = @as(u8, @intCast(value & 0xFF));
    }
};
