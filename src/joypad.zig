pub const ButtonState = enum(u1) {
    pressed = 0,
    released = 1,
};

pub const Joypad = packed struct {
    a_or_right: ButtonState = .released,
    b_or_left: ButtonState = .released,
    select_or_up: ButtonState = .released,
    start_or_down: ButtonState = .released,
    select_buttons: ButtonState = .released,
    select_dpads: ButtonState = .released,
    _padding: u2 = 0,

    pub fn toByte(self: *Joypad) u8 {
        return @bitCast(self.*);
    }

    pub fn putByte(self: *Joypad, byte: u8) void {
        self.* = @bitCast(byte & 0b0011_1111);
    }
};
