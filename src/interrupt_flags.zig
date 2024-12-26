pub const InterruptFlags = packed struct {
    vblank: bool = false,
    lcdstat: bool = false,
    timer: bool = false,
    serial: bool = false,
    joypad: bool = false,
    _padding: u3 = 0,

    pub fn fromByte(byte: u8) InterruptFlags {
        return @bitCast(byte & 0b0001_1111);
    }

    pub fn toByte(self: *InterruptFlags) u8 {
        return @bitCast(self.*);
    }

    pub fn putByte(self: *InterruptFlags, byte: u8) void {
        self.* = @bitCast(byte & 0b0001_1111);
    }

    pub fn hasInterrupt(self: *InterruptFlags) bool {
        return self.toByte() > 0;
    }
};
