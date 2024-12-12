const std = @import("std");

const ZERO_FLAG_BYTE_POSITION: u8 = 7;
const SUBTRACT_FLAG_BYTE_POSITION: u8 = 6;
const HALF_CARRY_FLAG_BYTE_POSITION: u8 = 5;
const CARRY_FLAG_BYTE_POSITION: u8 = 4;

const FlagsRegister = struct {
    zero: bool = false,
    subtract: bool = false,
    half_carry: bool = false,
    carry: bool = false,

    fn toInt(self: *FlagsRegister) u8 {
        return @intFromBool(self.zero) << ZERO_FLAG_BYTE_POSITION |
            @intFromBool(self.subtract) << SUBTRACT_FLAG_BYTE_POSITION |
            @intFromBool(self.half_carry) << HALF_CARRY_FLAG_BYTE_POSITION |
            @intFromBool(self.carry) << CARRY_FLAG_BYTE_POSITION;
    }

    fn fromInt(self: *FlagsRegister, value: u8) void {
        self.zero = @bitCast((value >> ZERO_FLAG_BYTE_POSITION) & 0b1);
        self.subtract = @bitCast((value >> SUBTRACT_FLAG_BYTE_POSITION) & 0b1);
        self.half_carry = @bitCast((value >> HALF_CARRY_FLAG_BYTE_POSITION) & 0b1);
        self.carry = @bitCast((value >> HALF_CARRY_FLAG_BYTE_POSITION) & 0b1);
    }
};

const Registers = struct {
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

    fn getBC(self: *Registers) u16 {
        return @as(u16, self.b) << 8 | @as(u16, self.c);
    }

    fn setBC(self: *Registers, value: u16) void {
        self.b = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.c = @as(u8, @intCast(value & 0xFF));
    }
    fn getDE(self: *Registers) u16 {
        return @as(u16, self.d) << 8 | @as(u16, self.e);
    }

    fn setDE(self: *Registers, value: u16) void {
        self.d = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.e = @as(u8, @intCast(value & 0xFF));
    }

    fn getHL(self: *Registers) u16 {
        return @as(u16, self.h) << 8 | @as(u16, self.l);
    }

    fn setHL(self: *Registers, value: u16) void {
        self.h = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.l = @as(u8, @intCast(value & 0xFF));
    }
};

const MemoryBus = struct {
    memory: [0xFFFF]u8 = std.mem.zeroes([0xFFFF]u8),
};

const OpCodeType = enum {
    unprefixed,
    prefixed,
};

const UnprefixedOpCode = enum(u8) {
    noop = 0x0,

    loadToBCRegisterDataFromNextWord = 0x01,
    loadToDERegisterDataFromNextWord = 0x11,
    loadToHLRegisterDataFromNextWord = 0x21,
    loadToStackPointerRegisterDataFromNextWord = 0x31,
    loadIntoNextWordAddressDataFromStackPointerRegister = 0x08,

    loadToBCRegisterAddressDataFromAccumulatorRegister = 0x02,
    loadToDERegisterAddressDataFromAccumulatorRegister = 0x12,
    loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement = 0x22,
    loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement = 0x32,

    incrementBCRegister = 0x03,
    incrementDERegister = 0x13,
    incrementHLRegister = 0x23,
    incrementStackPointerRegister = 0x33,

    decrementBCRegister = 0x0B,
    decrementDERegister = 0x1B,
    decrementHLRegister = 0x2B,
    decrementStackPointerRegister = 0x3B,

    incrementBRegister = 0x04,
    incrementCRegister = 0x0C,
    incrementDRegister = 0x14,
    incrementERegister = 0x1C,
    incrementHRegister = 0x24,
    incrementLRegister = 0x2C,
    incrementHLRegisterAddress = 0x34,
    incrementAccumulatorRegister = 0x3C,

    decrementBRegister = 0x05,
    decrementCRegister = 0x0D,
    decrementDRegister = 0x15,
    decrementERegister = 0x1D,
    decrementHRegister = 0x25,
    decrementLRegister = 0x2D,
    decrementHLRegisterAddress = 0x35,
    decrementAccumulatorRegister = 0x3D,

    loadToBRegisterDataFromNextByte = 0x06,
    loadToCRegisterDataFromNextByte = 0x0E,
    loadToDRegisterDataFromNextByte = 0x16,
    loadToERegisterDataFromNextByte = 0x1E,
    loadToHRegisterDataFromNextByte = 0x26,
    loadToLRegisterDataFromNextByte = 0x2E,
    loadToHLRegisterAddressDataFromNextByte = 0x36,
    loadToAccumulatorRegisterDataFromNextByte = 0x3E,

    loadToBRegisterDataFromBRegister = 0x40,
    loadToBRegisterDataFromCRegister = 0x41,
    loadToBRegisterDataFromDRegister = 0x42,
    loadToBRegisterDataFromERegister = 0x43,
    loadToBRegisterDataFromHRegister = 0x44,
    loadToBRegisterDataFromLRegister = 0x45,
    loadToBRegisterDataFromHLRegisterAddress = 0x46,
    loadToBRegisterDataFromAccumulatorRegister = 0x47,

    loadToCRegisterDataFromBRegister = 0x48,
    loadToCRegisterDataFromCRegister = 0x49,
    loadToCRegisterDataFromDRegister = 0x4A,
    loadToCRegisterDataFromERegister = 0x4B,
    loadToCRegisterDataFromHRegister = 0x4C,
    loadToCRegisterDataFromLRegister = 0x4D,
    loadToCRegisterDataFromHLRegisterAddress = 0x4E,
    loadToCRegisterDataFromAccumulatorRegister = 0x4F,

    loadToDRegisterDataFromBRegister = 0x50,
    loadToDRegisterDataFromCRegister = 0x51,
    loadToDRegisterDataFromDRegister = 0x52,
    loadToDRegisterDataFromERegister = 0x53,
    loadToDRegisterDataFromHRegister = 0x54,
    loadToDRegisterDataFromLRegister = 0x55,
    loadToDRegisterDataFromHLRegisterAddress = 0x56,
    loadToDRegisterDataFromAccumulatorRegister = 0x57,

    loadToERegisterDataFromBRegister = 0x58,
    loadToERegisterDataFromCRegister = 0x59,
    loadToERegisterDataFromDRegister = 0x5A,
    loadToERegisterDataFromERegister = 0x5B,
    loadToERegisterDataFromHRegister = 0x5C,
    loadToERegisterDataFromLRegister = 0x5D,
    loadToERegisterDataFromHLRegisterAddress = 0x5E,
    loadToERegisterDataFromAccumulatorRegister = 0x5F,

    loadToHRegisterDataFromBRegister = 0x60,
    loadToHRegisterDataFromCRegister = 0x61,
    loadToHRegisterDataFromDRegister = 0x62,
    loadToHRegisterDataFromERegister = 0x63,
    loadToHRegisterDataFromHRegister = 0x64,
    loadToHRegisterDataFromLRegister = 0x65,
    loadToHRegisterDataFromHLRegisterAddress = 0x66,
    loadToHRegisterDataFromAccumulatorRegister = 0x67,

    loadToLRegisterDataFromBRegister = 0x68,
    loadToLRegisterDataFromCRegister = 0x69,
    loadToLRegisterDataFromDRegister = 0x6A,
    loadToLRegisterDataFromERegister = 0x6B,
    loadToLRegisterDataFromHRegister = 0x6C,
    loadToLRegisterDataFromLRegister = 0x6D,
    loadToLRegisterDataFromHLRegisterAddress = 0x6E,
    loadToLRegisterDataFromAccumulatorRegister = 0x6F,

    loadToHLRegisterAddressDataFromBRegister = 0x70,
    loadToHLRegisterAddressDataFromCRegister = 0x71,
    loadToHLRegisterAddressDataFromDRegister = 0x72,
    loadToHLRegisterAddressDataFromERegister = 0x73,
    loadToHLRegisterAddressDataFromHRegister = 0x74,
    loadToHLRegisterAddressDataFromLRegister = 0x75,
    loadToHLRegisterAddressDataFromAccumulatorRegister = 0x77,

    loadToAccumulatorRegisterDataFromBRegister = 0x78,
    loadToAccumulatorRegisterDataFromCRegister = 0x79,
    loadToAccumulatorRegisterDataFromDRegister = 0x7A,
    loadToAccumulatorRegisterDataFromERegister = 0x7B,
    loadToAccumulatorRegisterDataFromHRegister = 0x7C,
    loadToAccumulatorRegisterDataFromLRegister = 0x7D,
    loadToAccumulatorRegisterDataFromHLRegisterAddress = 0x7E,
    loadToAccumulatorRegisterDataFromAccumulatorRegister = 0x7F,

    addToAccumulatorRegisterDataFromBRegister = 0x80,
    addToAccumulatorRegisterDataFromCRegister = 0x81,
    addToAccumulatorRegisterDataFromDRegister = 0x82,
    addToAccumulatorRegisterDataFromERegister = 0x83,
    addToAccumulatorRegisterDataFromHRegister = 0x84,
    addToAccumulatorRegisterDataFromLRegister = 0x85,
    addToAccumulatorRegisterDataFromHLRegisterAddress = 0x86,
    addToAccumulatorRegisterDataFromAccumulatorRegister = 0x87,
    addToAccumulatorRegisterDataFromNextByte = 0xC6,

    addWithCarryToAccumulatorRegisterDataFromBRegister = 0x88,
    addWithCarryToAccumulatorRegisterDataFromCRegister = 0x89,
    addWithCarryToAccumulatorRegisterDataFromDRegister = 0x8A,
    addWithCarryToAccumulatorRegisterDataFromERegister = 0x8B,
    addWithCarryToAccumulatorRegisterDataFromHRegister = 0x8C,
    addWithCarryToAccumulatorRegisterDataFromLRegister = 0x8D,
    addWithCarryToAccumulatorRegisterDataFromHLRegisterAddress = 0x8E,
    addWithCarryToAccumulatorRegisterDataFromAccumulatorRegister = 0x8F,
    addWithCarryToAccumulatorRegisterDataFromNextByte = 0xCE,

    subToAccumulatorRegisterDataFromBRegister = 0x90,
    subToAccumulatorRegisterDataFromCRegister = 0x91,
    subToAccumulatorRegisterDataFromDRegister = 0x92,
    subToAccumulatorRegisterDataFromERegister = 0x93,
    subToAccumulatorRegisterDataFromHRegister = 0x94,
    subToAccumulatorRegisterDataFromLRegister = 0x95,
    subToAccumulatorRegisterDataFromHLRegisterAddress = 0x96,
    subToAccumulatorRegisterDataFromAccumulatorRegister = 0x97,
    subToAccumulatorRegisterDataFromNextByte = 0xD6,

    subWithCarryToAccumulatorRegisterDataFromBRegister = 0x98,
    subWithCarryToAccumulatorRegisterDataFromCRegister = 0x99,
    subWithCarryToAccumulatorRegisterDataFromDRegister = 0x9A,
    subWithCarryToAccumulatorRegisterDataFromERegister = 0x9B,
    subWithCarryToAccumulatorRegisterDataFromHRegister = 0x9C,
    subWithCarryToAccumulatorRegisterDataFromLRegister = 0x9D,
    subWithCarryToAccumulatorRegisterDataFromHLRegisterAddress = 0x9E,
    subWithCarryToAccumulatorRegisterDataFromAccumulatorRegister = 0x9F,
    subWithCarryToAccumulatorRegisterDataFromNextByte = 0xDE,

    andToAccumulatorFromBRegister = 0xA0,
    andToAccumulatorFromCRegister = 0xA1,
    andToAccumulatorFromDRegister = 0xA2,
    andToAccumulatorFromERegister = 0xA3,
    andToAccumulatorFromHRegister = 0xA4,
    andToAccumulatorFromLRegister = 0xA5,
    andToAccumulatorFromHLRegisterAddress = 0xA6,
    andToAccumulatorFromAccumulatorRegister = 0xA7,
    andToAccumulatorFromNextByte = 0xE6,

    xorToAccumulatorFromBRegister = 0xA8,
    xorToAccumulatorFromCRegister = 0xA9,
    xorToAccumulatorFromDRegister = 0xAA,
    xorToAccumulatorFromERegister = 0xAB,
    xorToAccumulatorFromHRegister = 0xAC,
    xorToAccumulatorFromLRegister = 0xAD,
    xorToAccumulatorFromHLRegisterAddress = 0xAE,
    xorToAccumulatorFromAccumulatorRegister = 0xAF,
    xorToAccumulatorFromNextByte = 0xEE,

    orToAccumulatorFromBRegister = 0xB0,
    orToAccumulatorFromCRegister = 0xB1,
    orToAccumulatorFromDRegister = 0xB2,
    orToAccumulatorFromERegister = 0xB3,
    orToAccumulatorFromHRegister = 0xB4,
    orToAccumulatorFromLRegister = 0xB5,
    orToAccumulatorFromHLRegisterAddress = 0xB6,
    orToAccumulatorFromAccumulatorRegister = 0xB7,
    orToAccumulatorFromNextByte = 0xF6,

    compareToAccumulatorFromBRegister = 0xB8,
    compareToAccumulatorFromCRegister = 0xB9,
    compareToAccumulatorFromDRegister = 0xBA,
    compareToAccumulatorFromERegister = 0xBB,
    compareToAccumulatorFromHRegister = 0xBC,
    compareToAccumulatorFromLRegister = 0xBD,
    compareToAccumulatorFromHLRegisterAddress = 0xBE,
    compareToAccumulatorFromAccumulatorRegister = 0xBF,
    compareToAccumulatorFromNextByte = 0xFE,

    rotateLeftAccumulatorRegister = 0x07,
    rotateLeftThroughCarryAccumulatorRegister = 0x17,
    rotateRightAccumulatorRegister = 0x0F,
    rotateRightThroughCarryAccumulatorRegister = 0x1F,

    addToHLRegisterDataFromBCRegister = 0x09,
    addToHLRegisterDataFromDERegister = 0x19,
    addToHLRegisterDataFromHLRegister = 0x29,
    addToHLRegisterDataFromStackPointerRegister = 0x39,

    jumpRelativeAlways = 0x18,
    jumpRelativeIfNotZero = 0x20,
    jumpRelativeIfNotCarry = 0x30,
    jumpRelativeIfZero = 0x28,
    jumpRelativeIfCarry = 0x38,

    loadToByteAddressFromAccumulatorRegister = 0xE0,
    loadToAccumulatorRegisterFromByteAddress = 0xF0,

    loadToAddressPlusCRegisterFromAccumulatorRegister = 0xE2,
    loadToAccumulatorRegisterFromAddressPlusCRegister = 0xF2,

    loadToNextWordAddressFromAccumulatorRegister = 0xEA,
    loadToAccumulatorRegisterFromNextWordAddress = 0xFA,

    loadToStackPointerDataFromHLRegister = 0xF9,
};

const PrefixedOpCode = enum(u8) {
    rotateLeftCircularBRegister = 0x0,
};

const OpCode = union(OpCodeType) {
    unprefixed: UnprefixedOpCode,
    prefixed: PrefixedOpCode,
};

const CPU = struct {
    registers: Registers = Registers{},
    memoryBus: MemoryBus = MemoryBus{},

    fn execute(self: *CPU, instruction: OpCode) void {
        self.incrementProgramCounter();

        switch (instruction) {
            .unprefixed => |*unpreficed| {
                switch (unpreficed.*) {
                    UnprefixedOpCode.noop => self.noop(),

                    UnprefixedOpCode.loadToBCRegisterDataFromNextWord => self.loadToBCRegisterDataFromNextWord(),
                    UnprefixedOpCode.loadToDERegisterDataFromNextWord => self.loadToDERegisterDataFromNextWord(),
                    UnprefixedOpCode.loadToHLRegisterDataFromNextWord => self.loadToHLRegisterDataFromNextWord(),
                    UnprefixedOpCode.loadToStackPointerRegisterDataFromNextWord => self.loadToStackPointerRegisterDataFromNextWord(),
                    UnprefixedOpCode.loadIntoNextWordAddressDataFromStackPointerRegister => self.loadIntoNextWordAddressDataFromStackPointerRegister(),

                    UnprefixedOpCode.loadToBCRegisterAddressDataFromAccumulatorRegister => self.loadToBCRegisterAddressDataFromAccumulatorRegister(),
                    UnprefixedOpCode.loadToDERegisterAddressDataFromAccumulatorRegister => self.loadToDERegisterAddressDataFromAccumulatorRegister(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement => self.loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement => self.loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement(),

                    UnprefixedOpCode.incrementBCRegister => self.incrementBCRegister(),
                    UnprefixedOpCode.incrementDERegister => self.incrementDERegister(),
                    UnprefixedOpCode.incrementHLRegister => self.incrementHLRegister(),
                    UnprefixedOpCode.incrementStackPointerRegister => self.incrementStackPointerRegister(),

                    UnprefixedOpCode.decrementBCRegister => self.decrementBCRegister(),
                    UnprefixedOpCode.decrementDERegister => self.decrementDERegister(),
                    UnprefixedOpCode.decrementHLRegister => self.decrementHLRegister(),
                    UnprefixedOpCode.decrementStackPointerRegister => self.decrementStackPointerRegister(),

                    UnprefixedOpCode.incrementBRegister => self.incrementBRegister(),
                    UnprefixedOpCode.incrementCRegister => self.incrementCRegister(),
                    UnprefixedOpCode.incrementDRegister => self.incrementDRegister(),
                    UnprefixedOpCode.incrementERegister => self.incrementERegister(),
                    UnprefixedOpCode.incrementHRegister => self.incrementHRegister(),
                    UnprefixedOpCode.incrementLRegister => self.incrementLRegister(),
                    UnprefixedOpCode.incrementHLRegisterAddress => self.incrementHLRegisterAddress(),
                    UnprefixedOpCode.incrementAccumulatorRegister => self.incrementAccumulatorRegister(),

                    UnprefixedOpCode.decrementBRegister => self.decrementBRegister(),
                    UnprefixedOpCode.decrementCRegister => self.decrementCRegister(),
                    UnprefixedOpCode.decrementDRegister => self.decrementDRegister(),
                    UnprefixedOpCode.decrementERegister => self.decrementERegister(),
                    UnprefixedOpCode.decrementHRegister => self.decrementHRegister(),
                    UnprefixedOpCode.decrementLRegister => self.decrementLRegister(),
                    UnprefixedOpCode.decrementHLRegisterAddress => self.decrementHLRegisterAddress(),
                    UnprefixedOpCode.decrementAccumulatorRegister => self.decrementAccumulatorRegister(),

                    UnprefixedOpCode.loadToBRegisterDataFromNextByte => self.loadToBRegisterDataFromNextByte(),
                    UnprefixedOpCode.loadToCRegisterDataFromNextByte => self.loadToCRegisterDataFromNextByte(),
                    UnprefixedOpCode.loadToDRegisterDataFromNextByte => self.loadToDRegisterDataFromNextByte(),
                    UnprefixedOpCode.loadToERegisterDataFromNextByte => self.loadToERegisterDataFromNextByte(),
                    UnprefixedOpCode.loadToHRegisterDataFromNextByte => self.loadToHRegisterDataFromNextByte(),
                    UnprefixedOpCode.loadToLRegisterDataFromNextByte => self.loadToLRegisterDataFromNextByte(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromNextByte => self.loadToHLRegisterAddressDataFromNextByte(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromNextByte => self.loadToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.loadToBRegisterDataFromBRegister => self.loadToBRegisterDataFromBRegister(),
                    UnprefixedOpCode.loadToBRegisterDataFromCRegister => self.loadToBRegisterDataFromCRegister(),
                    UnprefixedOpCode.loadToBRegisterDataFromDRegister => self.loadToBRegisterDataFromDRegister(),
                    UnprefixedOpCode.loadToBRegisterDataFromERegister => self.loadToBRegisterDataFromERegister(),
                    UnprefixedOpCode.loadToBRegisterDataFromHRegister => self.loadToBRegisterDataFromHRegister(),
                    UnprefixedOpCode.loadToBRegisterDataFromLRegister => self.loadToBRegisterDataFromLRegister(),
                    UnprefixedOpCode.loadToBRegisterDataFromHLRegisterAddress => self.loadToBRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.loadToBRegisterDataFromAccumulatorRegister => self.loadToBRegisterDataFromAccumulatorRegister(),

                    UnprefixedOpCode.loadToCRegisterDataFromBRegister => self.loadToCRegisterDataFromBRegister(),
                    UnprefixedOpCode.loadToCRegisterDataFromCRegister => self.loadToCRegisterDataFromCRegister(),
                    UnprefixedOpCode.loadToCRegisterDataFromDRegister => self.loadToCRegisterDataFromDRegister(),
                    UnprefixedOpCode.loadToCRegisterDataFromERegister => self.loadToCRegisterDataFromERegister(),
                    UnprefixedOpCode.loadToCRegisterDataFromHRegister => self.loadToCRegisterDataFromHRegister(),
                    UnprefixedOpCode.loadToCRegisterDataFromLRegister => self.loadToCRegisterDataFromLRegister(),
                    UnprefixedOpCode.loadToCRegisterDataFromHLRegisterAddress => self.loadToCRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.loadToCRegisterDataFromAccumulatorRegister => self.loadToCRegisterDataFromAccumulatorRegister(),

                    UnprefixedOpCode.loadToDRegisterDataFromBRegister => self.loadToDRegisterDataFromBRegister(),
                    UnprefixedOpCode.loadToDRegisterDataFromCRegister => self.loadToDRegisterDataFromCRegister(),
                    UnprefixedOpCode.loadToDRegisterDataFromDRegister => self.loadToDRegisterDataFromDRegister(),
                    UnprefixedOpCode.loadToDRegisterDataFromERegister => self.loadToDRegisterDataFromERegister(),
                    UnprefixedOpCode.loadToDRegisterDataFromHRegister => self.loadToDRegisterDataFromHRegister(),
                    UnprefixedOpCode.loadToDRegisterDataFromLRegister => self.loadToDRegisterDataFromLRegister(),
                    UnprefixedOpCode.loadToDRegisterDataFromHLRegisterAddress => self.loadToDRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.loadToDRegisterDataFromAccumulatorRegister => self.loadToDRegisterDataFromAccumulatorRegister(),

                    UnprefixedOpCode.loadToERegisterDataFromBRegister => self.loadToERegisterDataFromBRegister(),
                    UnprefixedOpCode.loadToERegisterDataFromCRegister => self.loadToERegisterDataFromCRegister(),
                    UnprefixedOpCode.loadToERegisterDataFromDRegister => self.loadToERegisterDataFromDRegister(),
                    UnprefixedOpCode.loadToERegisterDataFromERegister => self.loadToERegisterDataFromERegister(),
                    UnprefixedOpCode.loadToERegisterDataFromHRegister => self.loadToERegisterDataFromHRegister(),
                    UnprefixedOpCode.loadToERegisterDataFromLRegister => self.loadToERegisterDataFromLRegister(),
                    UnprefixedOpCode.loadToERegisterDataFromHLRegisterAddress => self.loadToERegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.loadToERegisterDataFromAccumulatorRegister => self.loadToERegisterDataFromAccumulatorRegister(),

                    UnprefixedOpCode.loadToHRegisterDataFromBRegister => self.loadToHRegisterDataFromBRegister(),
                    UnprefixedOpCode.loadToHRegisterDataFromCRegister => self.loadToHRegisterDataFromCRegister(),
                    UnprefixedOpCode.loadToHRegisterDataFromDRegister => self.loadToHRegisterDataFromDRegister(),
                    UnprefixedOpCode.loadToHRegisterDataFromERegister => self.loadToHRegisterDataFromERegister(),
                    UnprefixedOpCode.loadToHRegisterDataFromHRegister => self.loadToHRegisterDataFromHRegister(),
                    UnprefixedOpCode.loadToHRegisterDataFromLRegister => self.loadToHRegisterDataFromLRegister(),
                    UnprefixedOpCode.loadToHRegisterDataFromHLRegisterAddress => self.loadToHRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.loadToHRegisterDataFromAccumulatorRegister => self.loadToHRegisterDataFromAccumulatorRegister(),

                    UnprefixedOpCode.loadToLRegisterDataFromBRegister => self.loadToLRegisterDataFromBRegister(),
                    UnprefixedOpCode.loadToLRegisterDataFromCRegister => self.loadToLRegisterDataFromCRegister(),
                    UnprefixedOpCode.loadToLRegisterDataFromDRegister => self.loadToLRegisterDataFromDRegister(),
                    UnprefixedOpCode.loadToLRegisterDataFromERegister => self.loadToLRegisterDataFromERegister(),
                    UnprefixedOpCode.loadToLRegisterDataFromHRegister => self.loadToLRegisterDataFromHRegister(),
                    UnprefixedOpCode.loadToLRegisterDataFromLRegister => self.loadToLRegisterDataFromLRegister(),
                    UnprefixedOpCode.loadToLRegisterDataFromHLRegisterAddress => self.loadToLRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.loadToLRegisterDataFromAccumulatorRegister => self.loadToLRegisterDataFromAccumulatorRegister(),

                    UnprefixedOpCode.loadToHLRegisterAddressDataFromBRegister => self.loadToHLRegisterAddressDataFromBRegister(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromCRegister => self.loadToHLRegisterAddressDataFromCRegister(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromDRegister => self.loadToHLRegisterAddressDataFromDRegister(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromERegister => self.loadToHLRegisterAddressDataFromERegister(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromHRegister => self.loadToHLRegisterAddressDataFromHRegister(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromLRegister => self.loadToHLRegisterAddressDataFromLRegister(),
                    UnprefixedOpCode.loadToHLRegisterAddressDataFromAccumulatorRegister => self.loadToHLRegisterAddressDataFromAccumulatorRegister(),

                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromBRegister => self.loadToAccumulatorRegisterDataFromBRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromCRegister => self.loadToAccumulatorRegisterDataFromCRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromDRegister => self.loadToAccumulatorRegisterDataFromDRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromERegister => self.loadToAccumulatorRegisterDataFromERegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromHRegister => self.loadToAccumulatorRegisterDataFromHRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromLRegister => self.loadToAccumulatorRegisterDataFromLRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromHLRegisterAddress => self.loadToAccumulatorRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.loadToAccumulatorRegisterDataFromAccumulatorRegister => self.loadToAccumulatorRegisterDataFromAccumulatorRegister(),

                    UnprefixedOpCode.addToAccumulatorRegisterDataFromBRegister => self.addToAccumulatorRegisterDataFromBRegister(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromCRegister => self.addToAccumulatorRegisterDataFromCRegister(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromDRegister => self.addToAccumulatorRegisterDataFromDRegister(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromERegister => self.addToAccumulatorRegisterDataFromERegister(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromHRegister => self.addToAccumulatorRegisterDataFromHRegister(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromLRegister => self.addToAccumulatorRegisterDataFromLRegister(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromHLRegisterAddress => self.addToAccumulatorRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromAccumulatorRegister => self.addToAccumulatorRegisterDataFromAccumulatorRegister(),
                    UnprefixedOpCode.addToAccumulatorRegisterDataFromNextByte => self.addToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromBRegister => self.addWithCarryToAccumulatorRegisterDataFromBRegister(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromCRegister => self.addWithCarryToAccumulatorRegisterDataFromCRegister(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromDRegister => self.addWithCarryToAccumulatorRegisterDataFromDRegister(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromERegister => self.addWithCarryToAccumulatorRegisterDataFromERegister(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromHRegister => self.addWithCarryToAccumulatorRegisterDataFromHRegister(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromLRegister => self.addWithCarryToAccumulatorRegisterDataFromLRegister(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromHLRegisterAddress => self.addWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromAccumulatorRegister => self.addWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(),
                    UnprefixedOpCode.addWithCarryToAccumulatorRegisterDataFromNextByte => self.addWithCarryToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.subToAccumulatorRegisterDataFromBRegister => self.subToAccumulatorRegisterDataFromBRegister(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromCRegister => self.subToAccumulatorRegisterDataFromCRegister(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromDRegister => self.subToAccumulatorRegisterDataFromDRegister(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromERegister => self.subToAccumulatorRegisterDataFromERegister(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromHRegister => self.subToAccumulatorRegisterDataFromHRegister(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromLRegister => self.subToAccumulatorRegisterDataFromLRegister(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromHLRegisterAddress => self.subToAccumulatorRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromAccumulatorRegister => self.subToAccumulatorRegisterDataFromAccumulatorRegister(),
                    UnprefixedOpCode.subToAccumulatorRegisterDataFromNextByte => self.subToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromBRegister => self.subWithCarryToAccumulatorRegisterDataFromBRegister(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromCRegister => self.subWithCarryToAccumulatorRegisterDataFromCRegister(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromDRegister => self.subWithCarryToAccumulatorRegisterDataFromDRegister(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromERegister => self.subWithCarryToAccumulatorRegisterDataFromERegister(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromHRegister => self.subWithCarryToAccumulatorRegisterDataFromHRegister(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromLRegister => self.subWithCarryToAccumulatorRegisterDataFromLRegister(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromHLRegisterAddress => self.subWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromAccumulatorRegister => self.subWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(),
                    UnprefixedOpCode.subWithCarryToAccumulatorRegisterDataFromNextByte => self.subWithCarryToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.andToAccumulatorFromBRegister => self.andToAccumulatorFromBRegister(),
                    UnprefixedOpCode.andToAccumulatorFromCRegister => self.andToAccumulatorFromCRegister(),
                    UnprefixedOpCode.andToAccumulatorFromDRegister => self.andToAccumulatorFromDRegister(),
                    UnprefixedOpCode.andToAccumulatorFromERegister => self.andToAccumulatorFromERegister(),
                    UnprefixedOpCode.andToAccumulatorFromHRegister => self.andToAccumulatorFromHRegister(),
                    UnprefixedOpCode.andToAccumulatorFromLRegister => self.andToAccumulatorFromLRegister(),
                    UnprefixedOpCode.andToAccumulatorFromHLRegisterAddress => self.andToAccumulatorFromHLRegisterAddress(),
                    UnprefixedOpCode.andToAccumulatorFromAccumulatorRegister => self.andToAccumulatorFromAccumulatorRegister(),
                    UnprefixedOpCode.andToAccumulatorFromNextByte => self.andToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.xorToAccumulatorFromBRegister => self.xorToAccumulatorFromBRegister(),
                    UnprefixedOpCode.xorToAccumulatorFromCRegister => self.xorToAccumulatorFromCRegister(),
                    UnprefixedOpCode.xorToAccumulatorFromDRegister => self.xorToAccumulatorFromDRegister(),
                    UnprefixedOpCode.xorToAccumulatorFromERegister => self.xorToAccumulatorFromERegister(),
                    UnprefixedOpCode.xorToAccumulatorFromHRegister => self.xorToAccumulatorFromHRegister(),
                    UnprefixedOpCode.xorToAccumulatorFromLRegister => self.xorToAccumulatorFromLRegister(),
                    UnprefixedOpCode.xorToAccumulatorFromHLRegisterAddress => self.xorToAccumulatorFromHLRegisterAddress(),
                    UnprefixedOpCode.xorToAccumulatorFromAccumulatorRegister => self.xorToAccumulatorFromAccumulatorRegister(),
                    UnprefixedOpCode.xorToAccumulatorFromNextByte => self.xorToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.orToAccumulatorFromBRegister => self.orToAccumulatorFromBRegister(),
                    UnprefixedOpCode.orToAccumulatorFromCRegister => self.orToAccumulatorFromCRegister(),
                    UnprefixedOpCode.orToAccumulatorFromDRegister => self.orToAccumulatorFromDRegister(),
                    UnprefixedOpCode.orToAccumulatorFromERegister => self.orToAccumulatorFromERegister(),
                    UnprefixedOpCode.orToAccumulatorFromHRegister => self.orToAccumulatorFromHRegister(),
                    UnprefixedOpCode.orToAccumulatorFromLRegister => self.orToAccumulatorFromLRegister(),
                    UnprefixedOpCode.orToAccumulatorFromHLRegisterAddress => self.orToAccumulatorFromHLRegisterAddress(),
                    UnprefixedOpCode.orToAccumulatorFromAccumulatorRegister => self.orToAccumulatorFromAccumulatorRegister(),
                    UnprefixedOpCode.orToAccumulatorFromNextByte => self.orToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.compareToAccumulatorFromBRegister => self.compareToAccumulatorFromBRegister(),
                    UnprefixedOpCode.compareToAccumulatorFromCRegister => self.compareToAccumulatorFromCRegister(),
                    UnprefixedOpCode.compareToAccumulatorFromDRegister => self.compareToAccumulatorFromDRegister(),
                    UnprefixedOpCode.compareToAccumulatorFromERegister => self.compareToAccumulatorFromERegister(),
                    UnprefixedOpCode.compareToAccumulatorFromHRegister => self.compareToAccumulatorFromHRegister(),
                    UnprefixedOpCode.compareToAccumulatorFromLRegister => self.compareToAccumulatorFromLRegister(),
                    UnprefixedOpCode.compareToAccumulatorFromHLRegisterAddress => self.compareToAccumulatorFromHLRegisterAddress(),
                    UnprefixedOpCode.compareToAccumulatorFromAccumulatorRegister => self.compareToAccumulatorFromAccumulatorRegister(),
                    UnprefixedOpCode.compareToAccumulatorFromNextByte => self.compareToAccumulatorRegisterDataFromNextByte(),

                    UnprefixedOpCode.rotateLeftAccumulatorRegister => self.rotateLeftAccumulatorRegister(),
                    UnprefixedOpCode.rotateLeftThroughCarryAccumulatorRegister => self.rotateLeftThroughCarryAccumulatorRegister(),
                    UnprefixedOpCode.rotateRightAccumulatorRegister => self.rotateRightAccumulatorRegister(),
                    UnprefixedOpCode.rotateRightThroughCarryAccumulatorRegister => self.rotateRightThroughCarryAccumulatorRegister(),

                    UnprefixedOpCode.addToHLRegisterDataFromBCRegister => self.addToHLRegisterDataFromBCRegister(),
                    UnprefixedOpCode.addToHLRegisterDataFromDERegister => self.addToHLRegisterDataFromDERegister(),
                    UnprefixedOpCode.addToHLRegisterDataFromHLRegister => self.addToHLRegisterDataFromHLRegister(),
                    UnprefixedOpCode.addToHLRegisterDataFromStackPointerRegister => self.addToHLRegisterDataFromStackPointerRegister(),

                    UnprefixedOpCode.jumpRelativeAlways => self.jumpRelativeAlways(),
                    UnprefixedOpCode.jumpRelativeIfNotZero => self.jumpRelativeIfNotZero(),
                    UnprefixedOpCode.jumpRelativeIfNotCarry => self.jumpRelativeIfNotCarry(),
                    UnprefixedOpCode.jumpRelativeIfZero => self.jumpRelativeIfZero(),
                    UnprefixedOpCode.jumpRelativeIfCarry => self.jumpRelativeIfCarry(),

                    UnprefixedOpCode.loadToByteAddressFromAccumulatorRegister => self.loadToByteAddressFromAccumulatorRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterFromByteAddress => self.loadToAccumulatorRegisterFromByteAddress(),

                    UnprefixedOpCode.loadToAddressPlusCRegisterFromAccumulatorRegister => self.loadToAddressPlusCRegisterFromAccumulatorRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterFromAddressPlusCRegister => self.loadToAccumulatorRegisterFromAddressPlusCRegister(),

                    UnprefixedOpCode.loadToNextWordAddressFromAccumulatorRegister => self.loadToNextWordAddressFromAccumulatorRegister(),
                    UnprefixedOpCode.loadToAccumulatorRegisterFromNextWordAddress => self.loadToAccumulatorRegisterFromNextWordAddress(),
                }
            },
            .prefixed => |*prefixed| {
                switch (prefixed.*) {
                    PrefixedOpCode.rotateLeftCircularBRegister => self.rotateLeftCircularBRegister(),
                }
            },
        }
    }

    fn incrementProgramCounter(self: *CPU) void {
        self.registers.program_counter +%= 1;
    }

    fn readByteFromMemory(self: *CPU, address: u16) u8 {
        return self.memoryBus.memory[address];
    }

    fn readNextByte(self: *CPU) u8 {
        const byte = self.readByteFromMemory(self.registers.program_counter);
        self.incrementProgramCounter();
        return byte;
    }

    fn writeByteToMemory(self: *CPU, address: u16, byte: u8) void {
        self.memoryBus.memory[address] = byte;
    }

    fn readNextWord(self: *CPU) u16 {
        const least_significant_byte: u16 = self.readNextByte();
        const most_significant_byte: u16 = self.readNextByte();
        return (most_significant_byte << 8) | least_significant_byte;
    }

    fn getFlags(self: *CPU) FlagsRegister {
        const flags = FlagsRegister{};
        flags.fromInt(self.registers.flags);
        return flags;
    }

    fn noop() void {}

    fn loadToBCRegisterDataFromNextWord(self: *CPU) void {
        self.registers.setBC(self.readNextWord());
    }

    fn loadToDERegisterDataFromNextWord(self: *CPU) void {
        self.registers.setDE(self.readNextWord());
    }

    fn loadToHLRegisterDataFromNextWord(self: *CPU) void {
        self.registers.setHL(self.readNextWord());
    }

    fn loadIntoNextWordAddressDataFromStackPointerRegister(self: *CPU) void {
        const address = self.readNextWord();
        const stack_pointer = self.registers.stack_pointer;

        self.writeByteToMemory(address, @as(u8, @intCast(stack_pointer & 0xFF)));
        self.writeByteToMemory(address +% 1, @as(u8, @intCast((stack_pointer & 0xFF00) >> 8)));
    }

    fn loadToStackPointerRegisterDataFromNextWord(self: *CPU) void {
        self.registers.stack_pointer = self.readNextWord();
    }

    fn loadToBCRegisterAddressDataFromAccumulatorRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getBC(), self.registers.accumulator);
    }

    fn loadToDERegisterAddressDataFromAccumulatorRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getDE(), self.registers.accumulator);
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement(self: *CPU) void {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.registers.accumulator);
        self.registers.setHL(address +% 1);
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement(self: *CPU) void {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.registers.accumulator);
        self.registers.setHL(address -% 1);
    }

    fn incrementBCRegister(self: *CPU) void {
        self.registers.setBC(self.registers.getBC() +% 1);
    }

    fn incrementDERegister(self: *CPU) void {
        self.registers.setDE(self.registers.getDE() +% 1);
    }

    fn incrementHLRegister(self: *CPU) void {
        self.registers.setHL(self.registers.getHL() +% 1);
    }

    fn incrementStackPointerRegister(self: *CPU) void {
        self.registers.stack_pointer +%= 1;
    }

    fn decrementBCRegister(self: *CPU) void {
        self.registers.setBC(self.registers.getBC() -% 1);
    }

    fn decrementDERegister(self: *CPU) void {
        self.registers.setDE(self.registers.getDE() -% 1);
    }

    fn decrementHLRegister(self: *CPU) void {
        self.registers.setHL(self.registers.getHL() -% 1);
    }

    fn decrementStackPointerRegister(self: *CPU) void {
        self.registers.stack_pointer -%= 1;
    }

    fn incrementBRegister(self: *CPU) void {
        self.registers.b = self.increment(self.registers.b);
    }

    fn incrementCRegister(self: *CPU) void {
        self.registers.c = self.increment(self.registers.c);
    }

    fn incrementDRegister(self: *CPU) void {
        self.registers.d = self.increment(self.registers.d);
    }

    fn incrementERegister(self: *CPU) void {
        self.registers.e = self.increment(self.registers.e);
    }

    fn incrementHRegister(self: *CPU) void {
        self.registers.h = self.increment(self.registers.h);
    }

    fn incrementLRegister(self: *CPU) void {
        self.registers.l = self.increment(self.registers.l);
    }

    fn incrementHLRegisterAddress(self: *CPU) void {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.increment(self.readByteFromMemory(address)));
    }

    fn incrementAccumulatorRegister(self: *CPU) void {
        self.registers.accumulator = self.increment(self.registers.accumulator);
    }

    fn increment(self: *CPU, value: u8) u8 {
        const new_value = value +% 1;
        var flags = self.getFlags();

        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.half_carry = value & 0xF == 0xF;

        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn decrementBRegister(self: *CPU) void {
        self.registers.b = self.decrement(self.registers.b);
    }

    fn decrementCRegister(self: *CPU) void {
        self.registers.c = self.decrement(self.registers.c);
    }

    fn decrementDRegister(self: *CPU) void {
        self.registers.d = self.decrement(self.registers.d);
    }

    fn decrementERegister(self: *CPU) void {
        self.registers.e = self.decrement(self.registers.e);
    }

    fn decrementHRegister(self: *CPU) void {
        self.registers.h = self.decrement(self.registers.h);
    }

    fn decrementLRegister(self: *CPU) void {
        self.registers.l = self.decrement(self.registers.l);
    }

    fn decrementHLRegisterAddress(self: *CPU) void {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.decrement(self.readByteFromMemory(address)));
    }

    fn decrementAccumulatorRegister(self: *CPU) void {
        self.registers.accumulator = self.decrement(self.registers.accumulator);
    }

    fn decrement(self: *CPU, value: u8) u8 {
        const new_value = value -% 1;
        var flags = self.getFlags();

        flags.zero = new_value == 0;
        flags.subtract = true;
        flags.half_carry = value & 0xF == 0x0;

        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn loadToBRegisterDataFromNextByte(self: *CPU) void {
        self.registers.b = self.readNextByte();
    }
    fn loadToCRegisterDataFromNextByte(self: *CPU) void {
        self.registers.c = self.readNextByte();
    }

    fn loadToDRegisterDataFromNextByte(self: *CPU) void {
        self.registers.d = self.readNextByte();
    }

    fn loadToERegisterDataFromNextByte(self: *CPU) void {
        self.registers.e = self.readNextByte();
    }

    fn loadToHRegisterDataFromNextByte(self: *CPU) void {
        self.registers.h = self.readNextByte();
    }

    fn loadToLRegisterDataFromNextByte(self: *CPU) void {
        self.registers.l = self.readNextByte();
    }

    fn loadToHLRegisterAddressDataFromNextByte(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.readNextByte());
    }

    fn loadToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.registers.accumulator = self.readNextByte();
    }

    fn loadToBRegisterDataFromBRegister(self: *CPU) void {
        self.registers.b = self.registers.b;
    }

    fn loadToBRegisterDataFromCRegister(self: *CPU) void {
        self.registers.b = self.registers.c;
    }

    fn loadToBRegisterDataFromDRegister(self: *CPU) void {
        self.registers.b = self.registers.d;
    }

    fn loadToBRegisterDataFromERegister(self: *CPU) void {
        self.registers.b = self.registers.e;
    }

    fn loadToBRegisterDataFromHRegister(self: *CPU) void {
        self.registers.b = self.registers.h;
    }

    fn loadToBRegisterDataFromLRegister(self: *CPU) void {
        self.registers.b = self.registers.l;
    }

    fn loadToBRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.registers.b = self.readByteFromMemory(self.registers.getHL());
    }

    fn loadToBRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.registers.b = self.registers.accumulator;
    }

    fn loadToCRegisterDataFromBRegister(self: *CPU) void {
        self.registers.c = self.registers.b;
    }

    fn loadToCRegisterDataFromCRegister(self: *CPU) void {
        self.registers.c = self.registers.c;
    }

    fn loadToCRegisterDataFromDRegister(self: *CPU) void {
        self.registers.c = self.registers.d;
    }

    fn loadToCRegisterDataFromERegister(self: *CPU) void {
        self.registers.c = self.registers.e;
    }

    fn loadToCRegisterDataFromHRegister(self: *CPU) void {
        self.registers.c = self.registers.h;
    }

    fn loadToCRegisterDataFromLRegister(self: *CPU) void {
        self.registers.c = self.registers.l;
    }

    fn loadToCRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.registers.c = self.readByteFromMemory(self.registers.getHL());
    }

    fn loadToCRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.registers.c = self.registers.accumulator;
    }

    fn loadToDRegisterDataFromBRegister(self: *CPU) void {
        self.registers.d = self.registers.b;
    }

    fn loadToDRegisterDataFromCRegister(self: *CPU) void {
        self.registers.d = self.registers.c;
    }

    fn loadToDRegisterDataFromDRegister(self: *CPU) void {
        self.registers.d = self.registers.d;
    }

    fn loadToDRegisterDataFromERegister(self: *CPU) void {
        self.registers.d = self.registers.e;
    }

    fn loadToDRegisterDataFromHRegister(self: *CPU) void {
        self.registers.d = self.registers.h;
    }

    fn loadToDRegisterDataFromLRegister(self: *CPU) void {
        self.registers.d = self.registers.l;
    }

    fn loadToDRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.registers.d = self.readByteFromMemory(self.registers.getHL());
    }

    fn loadToDRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.registers.d = self.registers.accumulator;
    }

    fn loadToERegisterDataFromBRegister(self: *CPU) void {
        self.registers.e = self.registers.b;
    }

    fn loadToERegisterDataFromCRegister(self: *CPU) void {
        self.registers.e = self.registers.c;
    }

    fn loadToERegisterDataFromDRegister(self: *CPU) void {
        self.registers.e = self.registers.d;
    }

    fn loadToERegisterDataFromERegister(self: *CPU) void {
        self.registers.e = self.registers.e;
    }

    fn loadToERegisterDataFromHRegister(self: *CPU) void {
        self.registers.e = self.registers.h;
    }

    fn loadToERegisterDataFromLRegister(self: *CPU) void {
        self.registers.e = self.registers.l;
    }

    fn loadToERegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.registers.e = self.readByteFromMemory(self.registers.getHL());
    }

    fn loadToERegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.registers.e = self.registers.accumulator;
    }

    fn loadToHRegisterDataFromBRegister(self: *CPU) void {
        self.registers.h = self.registers.b;
    }

    fn loadToHRegisterDataFromCRegister(self: *CPU) void {
        self.registers.h = self.registers.c;
    }

    fn loadToHRegisterDataFromDRegister(self: *CPU) void {
        self.registers.h = self.registers.d;
    }

    fn loadToHRegisterDataFromERegister(self: *CPU) void {
        self.registers.h = self.registers.e;
    }

    fn loadToHRegisterDataFromHRegister(self: *CPU) void {
        self.registers.h = self.registers.h;
    }

    fn loadToHRegisterDataFromLRegister(self: *CPU) void {
        self.registers.h = self.registers.l;
    }

    fn loadToHRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.registers.h = self.readByteFromMemory(self.registers.getHL());
    }

    fn loadToHRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.registers.h = self.registers.accumulator;
    }

    fn loadToLRegisterDataFromBRegister(self: *CPU) void {
        self.registers.l = self.registers.b;
    }

    fn loadToLRegisterDataFromCRegister(self: *CPU) void {
        self.registers.l = self.registers.c;
    }

    fn loadToLRegisterDataFromDRegister(self: *CPU) void {
        self.registers.l = self.registers.d;
    }

    fn loadToLRegisterDataFromERegister(self: *CPU) void {
        self.registers.l = self.registers.e;
    }

    fn loadToLRegisterDataFromHRegister(self: *CPU) void {
        self.registers.l = self.registers.h;
    }

    fn loadToLRegisterDataFromLRegister(self: *CPU) void {
        self.registers.l = self.registers.l;
    }

    fn loadToLRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.registers.l = self.readByteFromMemory(self.registers.getHL());
    }

    fn loadToLRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.registers.l = self.registers.accumulator;
    }

    fn loadToHLRegisterAddressDataFromBRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.registers.b);
    }

    fn loadToHLRegisterAddressDataFromCRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.registers.c);
    }

    fn loadToHLRegisterAddressDataFromDRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.registers.d);
    }

    fn loadToHLRegisterAddressDataFromERegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.registers.e);
    }

    fn loadToHLRegisterAddressDataFromHRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.registers.h);
    }

    fn loadToHLRegisterAddressDataFromLRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.registers.l);
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getHL(), self.registers.accumulator);
    }

    fn loadToAccumulatorRegisterDataFromBRegister(self: *CPU) void {
        self.registers.accumulator = self.registers.b;
    }

    fn loadToAccumulatorRegisterDataFromCRegister(self: *CPU) void {
        self.registers.accumulator = self.registers.c;
    }

    fn loadToAccumulatorRegisterDataFromDRegister(self: *CPU) void {
        self.registers.accumulator = self.registers.d;
    }

    fn loadToAccumulatorRegisterDataFromERegister(self: *CPU) void {
        self.registers.accumulator = self.registers.e;
    }

    fn loadToAccumulatorRegisterDataFromHRegister(self: *CPU) void {
        self.registers.accumulator = self.registers.h;
    }

    fn loadToAccumulatorRegisterDataFromLRegister(self: *CPU) void {
        self.registers.accumulator = self.registers.l;
    }

    fn loadToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.registers.accumulator = self.readByteFromMemory(self.registers.getHL());
    }

    fn loadToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.registers.accumulator = self.registers.accumulator;
    }

    fn loadToByteAddressFromAccumulatorRegister(self: *CPU) void {
        const offset: u16 = self.readNextByte();
        self.writeByteToMemory(0xFF00 + offset, self.registers.accumulator);
    }

    fn loadToAccumulatorRegisterFromByteAddress(self: *CPU) void {
        const offset: u16 = self.readNextByte();
        self.registers.accumulator = self.readByteFromMemory(0xFF00 + offset);
    }

    fn loadToAddressPlusCRegisterFromAccumulatorRegister(self: *CPU) void {
        self.writeByteToMemory(0xFF00 + @as(u16, self.registers.c), self.registers.accumulator);
    }

    fn loadToAccumulatorRegisterFromAddressPlusCRegister(self: *CPU) void {
        self.registers.accumulator = self.readByteFromMemory(0xFF00 + @as(u16, self.registers.c));
    }

    fn loadToNextWordAddressFromAccumulatorRegister(self: *CPU) void {
        self.writeByteToMemory(self.readNextWord(), self.registers.accumulator);
    }

    fn loadToAccumulatorRegisterFromNextWordAddress(self: *CPU) void {
        self.registers.accumulator = self.readByteFromMemory(self.readNextWord());
    }

    fn loadToStackPointerDataFromHLRegister(self: *CPU) void {
        self.registers.stack_pointer = self.registers.getHL();
    }

    fn addToAccumulatorRegisterDataFromBRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.b, false);
    }

    fn addToAccumulatorRegisterDataFromCRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.c, false);
    }

    fn addToAccumulatorRegisterDataFromDRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.d, false);
    }

    fn addToAccumulatorRegisterDataFromERegister(self: *CPU) void {
        self.addToAccumulator(self.registers.e, false);
    }

    fn addToAccumulatorRegisterDataFromHRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.h, false);
    }

    fn addToAccumulatorRegisterDataFromLRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.l, false);
    }

    fn addToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.addToAccumulator(self.readByteFromMemory(self.registers.getHL()), false);
    }

    fn addToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.accumulator, false);
    }

    fn addToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.addToAccumulator(self.readNextByte(), false);
    }

    fn addWithCarryToAccumulatorRegisterDataFromBRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.b, true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromCRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.c, true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromDRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.d, true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromERegister(self: *CPU) void {
        self.addToAccumulator(self.registers.e, true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromHRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.h, true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromLRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.l, true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.addToAccumulator(self.readByteFromMemory(self.registers.getHL()), true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.addToAccumulator(self.registers.accumulator, true);
    }

    fn addWithCarryToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.addToAccumulator(self.readNextByte(), true);
    }

    fn addToAccumulator(self: *CPU, value: u8, with_carry: bool) void {
        var flags = self.getFlags();
        const carry = if (with_carry) @intFromBool(flags.carry) else 0;

        const add_with_did_overflow = @addWithOverflow(self.registers.accumulator, value);
        const add = add_with_did_overflow[0];
        const add_did_overflow = add_with_did_overflow[1];

        const add_with_carry_with_did_overflow = @addWithOverflow(add, carry);
        const add_with_carry = add_with_carry_with_did_overflow[0];
        const add_with_carry_did_overflow = add_with_carry_with_did_overflow[1];

        flags.zero = add_with_carry == 0;
        flags.subtract = false;
        flags.carry = add_did_overflow || add_with_carry_did_overflow;
        flags.half_carry = ((self.registers.accumulator & 0xF) + (value & 0xF) + carry) > 0xF;

        self.registers.flags = flags.toInt();
        self.registers.accumulator = add_with_carry;
    }

    fn subToAccumulatorRegisterDataFromBRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.b, false);
    }

    fn subToAccumulatorRegisterDataFromCRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.c, false);
    }

    fn subToAccumulatorRegisterDataFromDRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.d, false);
    }

    fn subToAccumulatorRegisterDataFromERegister(self: *CPU) void {
        self.subToAccumulator(self.registers.e, false);
    }

    fn subToAccumulatorRegisterDataFromHRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.h, false);
    }

    fn subToAccumulatorRegisterDataFromLRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.l, false);
    }

    fn subToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.subToAccumulator(self.readByteFromMemory(self.registers.getHL()), false);
    }

    fn subToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.accumulator, false);
    }

    fn subToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.subToAccumulator(self.readNextByte(), false);
    }

    fn subWithCarryToAccumulatorRegisterDataFromBRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.b, true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromCRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.c, true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromDRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.d, true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromERegister(self: *CPU) void {
        self.subToAccumulator(self.registers.E, true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromHRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.h, true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromLRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.l, true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) void {
        self.subToAccumulator(self.readByteFromMemory(self.registers.getHL()), true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) void {
        self.subToAccumulator(self.registers.accumulator, true);
    }

    fn subWithCarryToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.subToAccumulator(self.readNextByte(), true);
    }

    fn subToAccumulator(self: *CPU, value: u8, with_carry: bool) void {
        var flags = self.getFlags();
        const carry = if (with_carry) @intFromBool(flags.carry) else 0;

        const sub_with_did_overflow = @subWithOverflow(self.registers.accumulator, value);
        const sub = sub_with_did_overflow[0];
        const sub_did_overflow = sub_with_did_overflow[1];

        const sub_with_carry_with_did_overflow = @subWithOverflow(sub, carry);
        const sub_with_carry = sub_with_carry_with_did_overflow[0];
        const sub_with_carry_did_overflow = sub_with_carry_with_did_overflow[1];

        flags.zero = sub_with_carry == 0;
        flags.subtract = false;
        flags.carry = sub_did_overflow || sub_with_carry_did_overflow;
        flags.half_carry = (self.registers.accumulator & 0xF) < (value & 0xF) + carry;

        self.registers.flags = flags.toInt();
        self.registers.accumulator = sub_with_carry;
    }

    fn andToAccumulatorFromBRegister(self: *CPU) void {
        self.andToAccumulator(self.registers.b);
    }

    fn andToAccumulatorFromCRegister(self: *CPU) void {
        self.andToAccumulator(self.registers.c);
    }

    fn andToAccumulatorFromDRegister(self: *CPU) void {
        self.andToAccumulator(self.registers.d);
    }

    fn andToAccumulatorFromERegister(self: *CPU) void {
        self.andToAccumulator(self.registers.e);
    }

    fn andToAccumulatorFromHRegister(self: *CPU) void {
        self.andToAccumulator(self.registers.h);
    }

    fn andToAccumulatorFromLRegister(self: *CPU) void {
        self.andToAccumulator(self.registers.l);
    }

    fn andToAccumulatorFromHLRegisterAddress(self: *CPU) void {
        self.andToAccumulator(self.readByteFromMemory(self.registers.getHL()));
    }

    fn andToAccumulatorFromAccumulatorRegister(self: *CPU) void {
        self.andToAccumulator(self.registers.accumulator);
    }

    fn andToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.andToAccumulator(self.readNextByte());
    }

    fn andToAccumulator(self: *CPU, value: u8) void {
        const new_value = self.register.accumulator & value;
        var flags = self.getFlags();

        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.carry = false;
        flags.half_carry = true;

        self.registers.flags = flags.toInt();
        self.registers.accumulator = new_value;
    }

    fn xorToAccumulatorFromBRegister(self: *CPU) void {
        self.xorToAccumulator(self.registers.b);
    }

    fn xorToAccumulatorFromCRegister(self: *CPU) void {
        self.xorToAccumulator(self.registers.c);
    }

    fn xorToAccumulatorFromDRegister(self: *CPU) void {
        self.xorToAccumulator(self.registers.d);
    }

    fn xorToAccumulatorFromERegister(self: *CPU) void {
        self.xorToAccumulator(self.registers.e);
    }

    fn xorToAccumulatorFromHRegister(self: *CPU) void {
        self.xorToAccumulator(self.registers.h);
    }

    fn xorToAccumulatorFromLRegister(self: *CPU) void {
        self.xorToAccumulator(self.registers.l);
    }

    fn xorToAccumulatorFromHLRegisterAddress(self: *CPU) void {
        self.xorToAccumulator(self.readByteFromMemory(self.registers.getHL()));
    }

    fn xorToAccumulatorFromAccumulatorRegister(self: *CPU) void {
        self.xorToAccumulator(self.registers.accumulator);
    }

    fn xorToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.xorToAccumulator(self.readNextByte());
    }

    fn xorToAccumulator(self: *CPU, value: u8) void {
        const new_value = self.register.accumulator ^ value;
        var flags = self.getFlags();

        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.carry = false;
        flags.half_carry = false;

        self.registers.flags = flags.toInt();
        self.registers.accumulator = new_value;
    }

    fn orToAccumulatorFromBRegister(self: *CPU) void {
        self.orToAccumulator(self.registers.b);
    }

    fn orToAccumulatorFromCRegister(self: *CPU) void {
        self.orToAccumulator(self.registers.c);
    }

    fn orToAccumulatorFromDRegister(self: *CPU) void {
        self.orToAccumulator(self.registers.d);
    }

    fn orToAccumulatorFromERegister(self: *CPU) void {
        self.orToAccumulator(self.registers.e);
    }

    fn orToAccumulatorFromHRegister(self: *CPU) void {
        self.orToAccumulator(self.registers.h);
    }

    fn orToAccumulatorFromLRegister(self: *CPU) void {
        self.orToAccumulator(self.registers.l);
    }

    fn orToAccumulatorFromHLRegisterAddress(self: *CPU) void {
        self.orToAccumulator(self.readByteFromMemory(self.registers.getHL()));
    }

    fn orToAccumulatorFromAccumulatorRegister(self: *CPU) void {
        self.orToAccumulator(self.registers.accumulator);
    }

    fn orToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.orToAccumulator(self.readNextByte());
    }

    fn orToAccumulator(self: *CPU, value: u8) void {
        const new_value = self.register.accumulator | value;
        var flags = self.getFlags();

        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.carry = false;
        flags.half_carry = false;

        self.registers.flags = flags.toInt();
        self.registers.accumulator = new_value;
    }

    fn compareToAccumulatorFromBRegister(self: *CPU) void {
        self.compareToAccumulator(self.registers.b);
    }

    fn compareToAccumulatorFromCRegister(self: *CPU) void {
        self.compareToAccumulator(self.registers.c);
    }

    fn compareToAccumulatorFromDRegister(self: *CPU) void {
        self.compareToAccumulator(self.registers.d);
    }

    fn compareToAccumulatorFromERegister(self: *CPU) void {
        self.compareToAccumulator(self.registers.e);
    }

    fn compareToAccumulatorFromHRegister(self: *CPU) void {
        self.compareToAccumulator(self.registers.h);
    }

    fn compareToAccumulatorFromLRegister(self: *CPU) void {
        self.compareToAccumulator(self.registers.l);
    }

    fn compareToAccumulatorFromHLRegisterAddress(self: *CPU) void {
        self.compareToAccumulator(self.readByteFromMemory(self.registers.getHL()));
    }

    fn compareToAccumulatorFromAccumulatorRegister(self: *CPU) void {
        self.compareToAccumulator(self.registers.accumulator);
    }

    fn compareToAccumulatorRegisterDataFromNextByte(self: *CPU) void {
        self.compareToAccumulator(self.readNextByte());
    }

    fn compareToAccumulator(self: *CPU, value: u8) void {
        var flags = self.getFlags();

        flags.zero = self.registers.accumulator == value;
        flags.subtract = true;
        flags.carry = self.registers.accumulator < value;
        flags.half_carry = (self.registers.accumulator & 0xF) < (value & 0xF);

        self.registers.flags = flags.toInt();
    }

    fn rotateLeftAccumulatorRegister(self: *CPU) void {
        self.registers.accumulator = self.rotateLeft(self.registers.accumulator, false);
    }

    fn rotateLeft(self: *CPU, value: u8, set_zero: bool) u8 {
        const carry: bool = @intCast((value & 0b1000_0000) >> 7);
        const new_value = std.math.rotl(u8, value, 1) | carry;

        const flags = self.getFlags();
        flags.zero = set_zero and new_value == 0;
        flags.subtract = 0;
        flags.half_carry = 0;
        flags.carry = carry;
        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn rotateLeftThroughCarryAccumulatorRegister(self: *CPU) void {
        self.registers.accumulator = self.rotateLeftThroughCarry(self.registers.accumulator, false);
    }

    fn rotateLeftThroughCarry(self: *CPU, value: u8, set_zero: bool) u8 {
        const flags = self.getFlags();
        const carry_bit = @intFromBool(flags.carry);
        const new_value = (value << 1) | carry_bit;

        flags.zero = set_zero and new_value == 0;
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = (value & 0b1000_0000) == 0b1000_0000;

        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn rotateRightAccumulatorRegister(self: *CPU) void {
        self.registers.accumulator = self.rotateRight(self.registers.accumulator, false);
    }

    fn rotateRight(self: *CPU, value: u8, set_zero: bool) u8 {
        const new_value = std.math.rotr(u8, value, 1);
        const flags = self.getFlags();

        flags.zero = set_zero and new_value == 0;
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = value & 0b1 == 0b1;

        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn rotateRightThroughCarryAccumulatorRegister(self: *CPU) void {
        self.registers.accumulator = self.rotateRightThroughCarry(self.registers.accumulator, false);
    }

    fn rotateRightThroughCarry(self: *CPU, value: u8, set_zero: bool) u8 {
        const flags = self.getFlags();
        const carry_bit = @intFromBool(flags.carry) << 7;
        const new_value = carry_bit | (value >> 1);

        flags.zero = set_zero and new_value == 0;
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = value & 0b1 == 0b1;

        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn addToHLRegisterDataFromBCRegister(self: *CPU) void {
        self.addToHLRegister(self.registers.getBC());
    }

    fn addToHLRegisterDataFromDERegister(self: *CPU) void {
        self.addToHLRegister(self.registers.getDE());
    }

    fn addToHLRegisterDataFromHLRegister(self: *CPU) void {
        self.addToHLRegister(self.registers.getHL());
    }

    fn addToHLRegisterDataFromStackPointerRegister(self: *CPU) void {
        self.addToHLRegister(self.registers.stack_pointer);
    }

    fn addToHLRegister(self: *CPU, value: u16) void {
        var flags = self.getFlags();
        const hl = self.registers.getHL();
        const new_value_with_did_overflow: u16 = @addWithOverflow(hl, value);
        const new_value = new_value_with_did_overflow[0];
        const did_overflow = new_value_with_did_overflow[1];

        flags.subtract = false;
        flags.carry = @bitCast(did_overflow);

        const mask = 0b0000_0111_1111_1111;
        flags.half_carry = (value & mask) + (hl & mask) > mask;

        self.registers.flags = flags.toInt();
        self.registers.setHL(new_value);
    }

    fn jumpRelativeAlways(self: *CPU) u3 {
        _ = self;
        return jumpRelativeWithCondition(true);
    }

    fn jumpRelativeIfZero(self: *CPU) u3 {
        return jumpRelativeWithCondition(self.getFlags().zero);
    }

    fn jumpRelativeIfCarry(self: *CPU) u3 {
        return jumpRelativeWithCondition(self.getFlags().carry);
    }

    fn jumpRelativeIfNotZero(self: *CPU) u3 {
        return jumpRelativeWithCondition(!self.getFlags().zero);
    }

    fn jumpRelativeIfNotCarry(self: *CPU) u3 {
        return jumpRelativeWithCondition(!self.getFlags().carry);
    }

    fn jumpRelativeWithCondition(self: *CPU, condition: bool) u3 {
        const byte = @as(i8, self.readNextByte());

        if (condition) {
            self.registers.program_counter +%= byte;
            return 3;
        }

        return 2;
    }
};

fn resetBit(value: u8, bit_position: comptime_int) u8 {
    return value & ~(@as(u8, 1) << bit_position);
}

fn setBit(value: u8, bit_position: comptime_int) u8 {
    return value | (@as(u8, 1) << bit_position);
}

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
    const herp = setBit(0b0000_0000, 2);
    //const derp = resetBit(0b1111_1111, 2);

    std.debug.print("{b}\n", .{herp});
}
