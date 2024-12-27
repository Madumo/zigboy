pub const Frequency = enum(u2) {
    F4096 = 0b00,
    F262144 = 0b01,
    F65536 = 0b10,
    F16384 = 0b11,

    pub fn cyclesPerTick(self: Frequency) u16 {
        return switch (self) {
            Frequency.F4096 => 1024,
            Frequency.F16384 => 256,
            Frequency.F262144 => 16,
            Frequency.F65536 => 64,
        };
    }
};

pub const TimerControlFlags = packed struct {
    frequency: Frequency,
    enable: bool = true,
    _padding: u5 = 0,

    pub fn fromByte(byte: u8) TimerControlFlags {
        return @bitCast(byte & 0b0000_0111);
    }

    pub fn toByte(self: *TimerControlFlags) u8 {
        return @bitCast(self.*);
    }

    pub fn putByte(self: *TimerControlFlags, byte: u8) void {
        self.* = @bitCast(byte & 0b0000_0111);
    }
};

pub const Timer = struct {
    cycles: usize = 0,
    value: u8 = 0,
    modulo: u8 = 0,
    timerControl: TimerControlFlags,

    pub fn step(self: *Timer, cycles: u8) bool {
        if (!self.timerControl.enable) {
            return false;
        }

        self.cycles += cycles;

        const cycles_per_tick = self.timerControl.frequency.cyclesPerTick();

        if (self.cycles > cycles_per_tick) {
            self.cycles = self.cycles % cycles_per_tick;
            const new_value, const did_overflow = @addWithOverflow(self.value, 1);
            self.value = if (@bitCast(did_overflow)) self.modulo else new_value;
            return @bitCast(did_overflow);
        } else {
            return false;
        }
    }
};
