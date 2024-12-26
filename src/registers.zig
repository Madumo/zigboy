pub const FlagsRegister = packed struct {
    _padding: u4 = 0,

    carry: bool = false,
    half_carry: bool = false,
    subtract: bool = false,
    zero: bool = false,

    pub fn toByte(self: *FlagsRegister) u8 {
        return @bitCast(self.*);
    }

    pub fn fromByte(self: *FlagsRegister, byte: u8) void {
        self.* = @bitCast(byte & 0b1111_0000);
    }
};

pub const Registers = struct {
    accumulator: u8 = 0,
    flags: FlagsRegister = FlagsRegister{},

    b: u8 = 0,
    c: u8 = 0,

    d: u8 = 0,
    e: u8 = 0,

    h: u8 = 0,
    l: u8 = 0,

    program_counter: u16 = 0,
    stack_pointer: u16 = 0,

    pub fn getAF(self: *Registers) u16 {
        return @as(u16, self.accumulator) << 8 | @as(u16, self.flags.toByte());
    }

    pub fn setAF(self: *Registers, value: u16) void {
        self.accumulator = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.flags.fromByte(@intCast(value & 0xFF));
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
