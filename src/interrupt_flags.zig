pub const InterruptFlags = packed struct {
    vblank: bool = false,
    lcdstat: bool = false,
    timer: bool = false,
    serial: bool = false,
    joypad: bool = false,
    _padding: u3 = 0,

    fn toByte(self: *InterruptFlags) u8 {
        return @bitCast(self.*);
    }

    fn fromByte(self: *InterruptFlags, value: u8) void {
        self.* = @bitCast(value & 0b0001_1111);
    }
};
