pub const Frequency = enum {
    F4096,
    F16384,
    F262144,
    F65536,
};

pub const Timer = struct {
    frequency: Frequency,
    cycles: usize = 0,
    value: u8 = 0,
    modulo: u8 = 0,
    on: bool = false,

    pub fn step(self: *Timer, cycles: u8) bool {
        if (!self.on) {
            return false;
        }

        self.cycles += cycles;

        const cycles_per_tick: u16 = switch (self.frequency) {
            Frequency.F4096 => 1024,
            Frequency.F16384 => 256,
            Frequency.F262144 => 16,
            Frequency.F65536 => 64,
        };

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
