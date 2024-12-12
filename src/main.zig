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

    fn getAF(self: *Registers) u16 {
        return @as(u16, self.accumulator) << 8 | @as(u16, self.flags);
    }

    fn setAF(self: *Registers, value: u16) void {
        self.accumulator = @as(u8, @intCast((value & 0xFF00) >> 8));
        self.flags = @as(u8, @intCast(value & 0xFF));
    }

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
    noop = 0x00,
    stop = 0x10,
    halt = 0x76,
    disableInterrupts = 0xF3,
    enableInterrupts = 0xFB,

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

    returnIfNotZero = 0xC0,
    returnIfNotCarry = 0xD0,
    returnIfZero = 0xC8,
    returnIfCarry = 0xD8,
    returnAlways = 0xC9,
    returnAlwaysWithInterrupt = 0xD9,

    jumpIfNotZero = 0xC2,
    jumpIfNotCarry = 0xD2,
    jumpIfZero = 0xCA,
    jumpIfCarry = 0xDA,
    jumpAlways = 0xC3,

    callIfNotZero = 0xC4,
    callIfNotCarry = 0xD4,
    callIfZero = 0xCC,
    callIfCarry = 0xDC,
    callAlways = 0xCD,

    popBCRegister = 0xC1,
    popDERegister = 0xD1,
    popHLRegister = 0xE1,
    popAFRegister = 0xF1,

    pushBCRegister = 0xC5,
    pushDERegister = 0xD5,
    pushHLRegister = 0xE5,
    pushAFRegister = 0xF5,

    restartX00 = 0xC7,
    restartX10 = 0xD7,
    restartX20 = 0xE7,
    restartX30 = 0xF7,
    restartX08 = 0xCF,
    restartX18 = 0xDF,
    restartX28 = 0xEF,
    restartX38 = 0xFF,

    jumpToAddressFromHL = 0xE9,

    decimalAdjustAccumulator = 0x27,
    setCarryFlag = 0x37,

    complementAccumulatorRegister = 0x2F,
    complementCarryFlag = 0x3F,
};

const PrefixedOpCode = enum(u8) {
    rotateLeftBRegister = 0x00,
    rotateLeftCRegister = 0x01,
    rotateLeftDRegister = 0x02,
    rotateLeftERegister = 0x03,
    rotateLeftHRegister = 0x04,
    rotateLeftLRegister = 0x05,
    rotateLeftHLRegisterAddress = 0x06,
    rotateLeftAccumulatorRegister = 0x07,
    rotateLeftThroughCarryBRegister = 0x10,
    rotateLeftThroughCarryCRegister = 0x11,
    rotateLeftThroughCarryDRegister = 0x12,
    rotateLeftThroughCarryERegister = 0x13,
    rotateLeftThroughCarryHRegister = 0x14,
    rotateLeftThroughCarryLRegister = 0x15,
    rotateLeftThroughCarryHLRegisterAddress = 0x16,
    rotateLeftThroughCarryAccumulatorRegister = 0x17,
    rotateRightBRegister = 0x08,
    rotateRightCRegister = 0x09,
    rotateRightDRegister = 0x0A,
    rotateRightERegister = 0x0B,
    rotateRightHRegister = 0x0C,
    rotateRightLRegister = 0x0D,
    rotateRightHLRegisterAddress = 0x0E,
    rotateRightAccumulatorRegister = 0x0F,
    rotateRightThroughCarryBRegister = 0x18,
    rotateRightThroughCarryCRegister = 0x19,
    rotateRightThroughCarryDRegister = 0x1A,
    rotateRightThroughCarryERegister = 0x1B,
    rotateRightThroughCarryHRegister = 0x1C,
    rotateRightThroughCarryLRegister = 0x1D,
    rotateRightThroughCarryHLRegisterAddress = 0x1E,
    rotateRightThroughCarryAccumulatorRegister = 0x1F,
    shiftLeftArithmeticBRegister = 0x20,
    shiftLeftArithmeticCRegister = 0x21,
    shiftLeftArithmeticDRegister = 0x22,
    shiftLeftArithmeticERegister = 0x23,
    shiftLeftArithmeticHRegister = 0x24,
    shiftLeftArithmeticLRegister = 0x25,
    shiftLeftArithmeticHLRegisterAddress = 0x26,
    shiftLeftArithmeticAccumulatorRegister = 0x27,
    shiftRightArithmeticBRegister = 0x28,
    shiftRightArithmeticCRegister = 0x29,
    shiftRightArithmeticDRegister = 0x2A,
    shiftRightArithmeticERegister = 0x2B,
    shiftRightArithmeticHRegister = 0x2C,
    shiftRightArithmeticLRegister = 0x2D,
    shiftRightArithmeticHLRegisterAddress = 0x2E,
    shiftRightArithmeticAccumulatorRegister = 0x2F,
    swapNibblesBRegister = 0x30,
    swapNibblesCRegister = 0x31,
    swapNibblesDRegister = 0x32,
    swapNibblesERegister = 0x33,
    swapNibblesHRegister = 0x34,
    swapNibblesLRegister = 0x35,
    swapNibblesHLRegisterAddress = 0x36,
    swapNibblesAccumulatorRegister = 0x37,
    shiftRightLogicalBRegister = 0x38,
    shiftRightLogicalCRegister = 0x39,
    shiftRightLogicalDRegister = 0x3A,
    shiftRightLogicalERegister = 0x3B,
    shiftRightLogicalHRegister = 0x3C,
    shiftRightLogicalLRegister = 0x3D,
    shiftRightLogicalHLRegisterAddress = 0x3E,
    shiftRightLogicalAccumulatorRegister = 0x3F,
    testBit0BRegister = 0x40,
    testBit0CRegister = 0x41,
    testBit0DRegister = 0x42,
    testBit0ERegister = 0x43,
    testBit0HRegister = 0x44,
    testBit0LRegister = 0x45,
    testBit0HLRegisterAddress = 0x46,
    testBit0AccumulatorRegister = 0x47,
    testBit1BRegister = 0x48,
    testBit1CRegister = 0x49,
    testBit1DRegister = 0x4A,
    testBit1ERegister = 0x4B,
    testBit1HRegister = 0x4C,
    testBit1LRegister = 0x4D,
    testBit1HLRegisterAddress = 0x4E,
    testBit1AccumulatorRegister = 0x4F,
    testBit2BRegister = 0x50,
    testBit2CRegister = 0x51,
    testBit2DRegister = 0x52,
    testBit2ERegister = 0x53,
    testBit2HRegister = 0x54,
    testBit2LRegister = 0x55,
    testBit2HLRegisterAddress = 0x56,
    testBit2AccumulatorRegister = 0x57,
    testBit3BRegister = 0x58,
    testBit3CRegister = 0x59,
    testBit3DRegister = 0x5A,
    testBit3ERegister = 0x5B,
    testBit3HRegister = 0x5C,
    testBit3LRegister = 0x5D,
    testBit3HLRegisterAddress = 0x5E,
    testBit3AccumulatorRegister = 0x5F,
    testBit4BRegister = 0x60,
    testBit4CRegister = 0x61,
    testBit4DRegister = 0x62,
    testBit4ERegister = 0x63,
    testBit4HRegister = 0x64,
    testBit4LRegister = 0x65,
    testBit4HLRegisterAddress = 0x66,
    testBit4AccumulatorRegister = 0x67,
    testBit5BRegister = 0x68,
    testBit5CRegister = 0x69,
    testBit5DRegister = 0x6A,
    testBit5ERegister = 0x6B,
    testBit5HRegister = 0x6C,
    testBit5LRegister = 0x6D,
    testBit5HLRegisterAddress = 0x6E,
    testBit5AccumulatorRegister = 0x6F,
    testBit6BRegister = 0x70,
    testBit6CRegister = 0x71,
    testBit6DRegister = 0x72,
    testBit6ERegister = 0x73,
    testBit6HRegister = 0x74,
    testBit6LRegister = 0x75,
    testBit6HLRegisterAddress = 0x76,
    testBit6AccumulatorRegister = 0x77,
    testBit7BRegister = 0x78,
    testBit7CRegister = 0x79,
    testBit7DRegister = 0x7A,
    testBit7ERegister = 0x7B,
    testBit7HRegister = 0x7C,
    testBit7LRegister = 0x7D,
    testBit7HLRegisterAddress = 0x7E,
    testBit7AccumulatorRegister = 0x7F,
    resetBit0BRegister = 0x80,
    resetBit0CRegister = 0x81,
    resetBit0DRegister = 0x82,
    resetBit0ERegister = 0x83,
    resetBit0HRegister = 0x84,
    resetBit0LRegister = 0x85,
    resetBit0HLRegisterAddress = 0x86,
    resetBit0AccumulatorRegister = 0x87,
    resetBit1BRegister = 0x88,
    resetBit1CRegister = 0x89,
    resetBit1DRegister = 0x8A,
    resetBit1ERegister = 0x8B,
    resetBit1HRegister = 0x8C,
    resetBit1LRegister = 0x8D,
    resetBit1HLRegisterAddress = 0x8E,
    resetBit1AccumulatorRegister = 0x8F,
    resetBit2BRegister = 0x90,
    resetBit2CRegister = 0x91,
    resetBit2DRegister = 0x92,
    resetBit2ERegister = 0x93,
    resetBit2HRegister = 0x94,
    resetBit2LRegister = 0x95,
    resetBit2HLRegisterAddress = 0x96,
    resetBit2AccumulatorRegister = 0x97,
    resetBit3BRegister = 0x98,
    resetBit3CRegister = 0x99,
    resetBit3DRegister = 0x9A,
    resetBit3ERegister = 0x9B,
    resetBit3HRegister = 0x9C,
    resetBit3LRegister = 0x9D,
    resetBit3HLRegisterAddress = 0x9E,
    resetBit3AccumulatorRegister = 0x9F,
    resetBit4BRegister = 0xA0,
    resetBit4CRegister = 0xA1,
    resetBit4DRegister = 0xA2,
    resetBit4ERegister = 0xA3,
    resetBit4HRegister = 0xA4,
    resetBit4LRegister = 0xA5,
    resetBit4HLRegisterAddress = 0xA6,
    resetBit4AccumulatorRegister = 0xA7,
    resetBit5BRegister = 0xA8,
    resetBit5CRegister = 0xA9,
    resetBit5DRegister = 0xAA,
    resetBit5ERegister = 0xAB,
    resetBit5HRegister = 0xAC,
    resetBit5LRegister = 0xAD,
    resetBit5HLRegisterAddress = 0xAE,
    resetBit5AccumulatorRegister = 0xAF,
    resetBit6BRegister = 0xB0,
    resetBit6CRegister = 0xB1,
    resetBit6DRegister = 0xB2,
    resetBit6ERegister = 0xB3,
    resetBit6HRegister = 0xB4,
    resetBit6LRegister = 0xB5,
    resetBit6HLRegisterAddress = 0xB6,
    resetBit6AccumulatorRegister = 0xB7,
    resetBit7BRegister = 0xB8,
    resetBit7CRegister = 0xB9,
    resetBit7DRegister = 0xBA,
    resetBit7ERegister = 0xBB,
    resetBit7HRegister = 0xBC,
    resetBit7LRegister = 0xBD,
    resetBit7HLRegisterAddress = 0xBE,
    resetBit7AccumulatorRegister = 0xBF,
    setBit0BRegister = 0xC0,
    setBit0CRegister = 0xC1,
    setBit0DRegister = 0xC2,
    setBit0ERegister = 0xC3,
    setBit0HRegister = 0xC4,
    setBit0LRegister = 0xC5,
    setBit0HLRegisterAddress = 0xC6,
    setBit0AccumulatorRegister = 0xC7,
    setBit1BRegister = 0xC8,
    setBit1CRegister = 0xC9,
    setBit1DRegister = 0xCA,
    setBit1ERegister = 0xCB,
    setBit1HRegister = 0xCC,
    setBit1LRegister = 0xCD,
    setBit1HLRegisterAddress = 0xCE,
    setBit1AccumulatorRegister = 0xCF,
    setBit2BRegister = 0xD0,
    setBit2CRegister = 0xD1,
    setBit2DRegister = 0xD2,
    setBit2ERegister = 0xD3,
    setBit2HRegister = 0xD4,
    setBit2LRegister = 0xD5,
    setBit2HLRegisterAddress = 0xD6,
    setBit2AccumulatorRegister = 0xD7,
    setBit3BRegister = 0xD8,
    setBit3CRegister = 0xD9,
    setBit3DRegister = 0xDA,
    setBit3ERegister = 0xDB,
    setBit3HRegister = 0xDC,
    setBit3LRegister = 0xDD,
    setBit3HLRegisterAddress = 0xDE,
    setBit3AccumulatorRegister = 0xDF,
    setBit4BRegister = 0xE0,
    setBit4CRegister = 0xE1,
    setBit4DRegister = 0xE2,
    setBit4ERegister = 0xE3,
    setBit4HRegister = 0xE4,
    setBit4LRegister = 0xE5,
    setBit4HLRegisterAddress = 0xE6,
    setBit4AccumulatorRegister = 0xE7,
    setBit5BRegister = 0xE8,
    setBit5CRegister = 0xE9,
    setBit5DRegister = 0xEA,
    setBit5ERegister = 0xEB,
    setBit5HRegister = 0xEC,
    setBit5LRegister = 0xED,
    setBit5HLRegisterAddress = 0xEE,
    setBit5AccumulatorRegister = 0xEF,
    setBit6BRegister = 0xF0,
    setBit6CRegister = 0xF1,
    setBit6DRegister = 0xF2,
    setBit6ERegister = 0xF3,
    setBit6HRegister = 0xF4,
    setBit6LRegister = 0xF5,
    setBit6HLRegisterAddress = 0xF6,
    setBit6AccumulatorRegister = 0xF7,
    setBit7BRegister = 0xF8,
    setBit7CRegister = 0xF9,
    setBit7DRegister = 0xFA,
    setBit7ERegister = 0xFB,
    setBit7HRegister = 0xFC,
    setBit7LRegister = 0xFD,
    setBit7HLRegisterAddress = 0xFE,
    setBit7AccumulatorRegister = 0xFF,
};

const OpCode = union(OpCodeType) {
    unprefixed: UnprefixedOpCode,
    prefixed: PrefixedOpCode,
};

const CPU = struct {
    registers: Registers = Registers{},
    memoryBus: MemoryBus = MemoryBus{},
    interrupts_enabled: bool = true,
    is_halted: bool = false,

    fn execute(self: *CPU, instruction: OpCode) u8 {
        self.incrementProgramCounter();

        const cycles = switch (instruction) {
            .unprefixed => |*unpreficed| {
                switch (unpreficed.*) {
                    .noop => self.noop(),
                    .stop => self.stop(),
                    .halt => self.halt(),
                    .disableInterrupts => self.disableInterrupts(),
                    .enableInterrupts => self.enableInterrupts(),

                    .loadToBCRegisterDataFromNextWord => self.loadToBCRegisterDataFromNextWord(),
                    .loadToDERegisterDataFromNextWord => self.loadToDERegisterDataFromNextWord(),
                    .loadToHLRegisterDataFromNextWord => self.loadToHLRegisterDataFromNextWord(),
                    .loadToStackPointerRegisterDataFromNextWord => self.loadToStackPointerRegisterDataFromNextWord(),
                    .loadIntoNextWordAddressDataFromStackPointerRegister => self.loadIntoNextWordAddressDataFromStackPointerRegister(),

                    .loadToBCRegisterAddressDataFromAccumulatorRegister => self.loadToBCRegisterAddressDataFromAccumulatorRegister(),
                    .loadToDERegisterAddressDataFromAccumulatorRegister => self.loadToDERegisterAddressDataFromAccumulatorRegister(),
                    .loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement => self.loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement(),
                    .loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement => self.loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement(),

                    .incrementBCRegister => self.incrementBCRegister(),
                    .incrementDERegister => self.incrementDERegister(),
                    .incrementHLRegister => self.incrementHLRegister(),
                    .incrementStackPointerRegister => self.incrementStackPointerRegister(),

                    .decrementBCRegister => self.decrementBCRegister(),
                    .decrementDERegister => self.decrementDERegister(),
                    .decrementHLRegister => self.decrementHLRegister(),
                    .decrementStackPointerRegister => self.decrementStackPointerRegister(),

                    .incrementBRegister => self.incrementBRegister(),
                    .incrementCRegister => self.incrementCRegister(),
                    .incrementDRegister => self.incrementDRegister(),
                    .incrementERegister => self.incrementERegister(),
                    .incrementHRegister => self.incrementHRegister(),
                    .incrementLRegister => self.incrementLRegister(),
                    .incrementHLRegisterAddress => self.incrementHLRegisterAddress(),
                    .incrementAccumulatorRegister => self.incrementAccumulatorRegister(),

                    .decrementBRegister => self.decrementBRegister(),
                    .decrementCRegister => self.decrementCRegister(),
                    .decrementDRegister => self.decrementDRegister(),
                    .decrementERegister => self.decrementERegister(),
                    .decrementHRegister => self.decrementHRegister(),
                    .decrementLRegister => self.decrementLRegister(),
                    .decrementHLRegisterAddress => self.decrementHLRegisterAddress(),
                    .decrementAccumulatorRegister => self.decrementAccumulatorRegister(),

                    .loadToBRegisterDataFromNextByte => self.loadToBRegisterDataFromNextByte(),
                    .loadToCRegisterDataFromNextByte => self.loadToCRegisterDataFromNextByte(),
                    .loadToDRegisterDataFromNextByte => self.loadToDRegisterDataFromNextByte(),
                    .loadToERegisterDataFromNextByte => self.loadToERegisterDataFromNextByte(),
                    .loadToHRegisterDataFromNextByte => self.loadToHRegisterDataFromNextByte(),
                    .loadToLRegisterDataFromNextByte => self.loadToLRegisterDataFromNextByte(),
                    .loadToHLRegisterAddressDataFromNextByte => self.loadToHLRegisterAddressDataFromNextByte(),
                    .loadToAccumulatorRegisterDataFromNextByte => self.loadToAccumulatorRegisterDataFromNextByte(),

                    .loadToBRegisterDataFromBRegister => self.loadToBRegisterDataFromBRegister(),
                    .loadToBRegisterDataFromCRegister => self.loadToBRegisterDataFromCRegister(),
                    .loadToBRegisterDataFromDRegister => self.loadToBRegisterDataFromDRegister(),
                    .loadToBRegisterDataFromERegister => self.loadToBRegisterDataFromERegister(),
                    .loadToBRegisterDataFromHRegister => self.loadToBRegisterDataFromHRegister(),
                    .loadToBRegisterDataFromLRegister => self.loadToBRegisterDataFromLRegister(),
                    .loadToBRegisterDataFromHLRegisterAddress => self.loadToBRegisterDataFromHLRegisterAddress(),
                    .loadToBRegisterDataFromAccumulatorRegister => self.loadToBRegisterDataFromAccumulatorRegister(),

                    .loadToCRegisterDataFromBRegister => self.loadToCRegisterDataFromBRegister(),
                    .loadToCRegisterDataFromCRegister => self.loadToCRegisterDataFromCRegister(),
                    .loadToCRegisterDataFromDRegister => self.loadToCRegisterDataFromDRegister(),
                    .loadToCRegisterDataFromERegister => self.loadToCRegisterDataFromERegister(),
                    .loadToCRegisterDataFromHRegister => self.loadToCRegisterDataFromHRegister(),
                    .loadToCRegisterDataFromLRegister => self.loadToCRegisterDataFromLRegister(),
                    .loadToCRegisterDataFromHLRegisterAddress => self.loadToCRegisterDataFromHLRegisterAddress(),
                    .loadToCRegisterDataFromAccumulatorRegister => self.loadToCRegisterDataFromAccumulatorRegister(),

                    .loadToDRegisterDataFromBRegister => self.loadToDRegisterDataFromBRegister(),
                    .loadToDRegisterDataFromCRegister => self.loadToDRegisterDataFromCRegister(),
                    .loadToDRegisterDataFromDRegister => self.loadToDRegisterDataFromDRegister(),
                    .loadToDRegisterDataFromERegister => self.loadToDRegisterDataFromERegister(),
                    .loadToDRegisterDataFromHRegister => self.loadToDRegisterDataFromHRegister(),
                    .loadToDRegisterDataFromLRegister => self.loadToDRegisterDataFromLRegister(),
                    .loadToDRegisterDataFromHLRegisterAddress => self.loadToDRegisterDataFromHLRegisterAddress(),
                    .loadToDRegisterDataFromAccumulatorRegister => self.loadToDRegisterDataFromAccumulatorRegister(),

                    .loadToERegisterDataFromBRegister => self.loadToERegisterDataFromBRegister(),
                    .loadToERegisterDataFromCRegister => self.loadToERegisterDataFromCRegister(),
                    .loadToERegisterDataFromDRegister => self.loadToERegisterDataFromDRegister(),
                    .loadToERegisterDataFromERegister => self.loadToERegisterDataFromERegister(),
                    .loadToERegisterDataFromHRegister => self.loadToERegisterDataFromHRegister(),
                    .loadToERegisterDataFromLRegister => self.loadToERegisterDataFromLRegister(),
                    .loadToERegisterDataFromHLRegisterAddress => self.loadToERegisterDataFromHLRegisterAddress(),
                    .loadToERegisterDataFromAccumulatorRegister => self.loadToERegisterDataFromAccumulatorRegister(),

                    .loadToHRegisterDataFromBRegister => self.loadToHRegisterDataFromBRegister(),
                    .loadToHRegisterDataFromCRegister => self.loadToHRegisterDataFromCRegister(),
                    .loadToHRegisterDataFromDRegister => self.loadToHRegisterDataFromDRegister(),
                    .loadToHRegisterDataFromERegister => self.loadToHRegisterDataFromERegister(),
                    .loadToHRegisterDataFromHRegister => self.loadToHRegisterDataFromHRegister(),
                    .loadToHRegisterDataFromLRegister => self.loadToHRegisterDataFromLRegister(),
                    .loadToHRegisterDataFromHLRegisterAddress => self.loadToHRegisterDataFromHLRegisterAddress(),
                    .loadToHRegisterDataFromAccumulatorRegister => self.loadToHRegisterDataFromAccumulatorRegister(),

                    .loadToLRegisterDataFromBRegister => self.loadToLRegisterDataFromBRegister(),
                    .loadToLRegisterDataFromCRegister => self.loadToLRegisterDataFromCRegister(),
                    .loadToLRegisterDataFromDRegister => self.loadToLRegisterDataFromDRegister(),
                    .loadToLRegisterDataFromERegister => self.loadToLRegisterDataFromERegister(),
                    .loadToLRegisterDataFromHRegister => self.loadToLRegisterDataFromHRegister(),
                    .loadToLRegisterDataFromLRegister => self.loadToLRegisterDataFromLRegister(),
                    .loadToLRegisterDataFromHLRegisterAddress => self.loadToLRegisterDataFromHLRegisterAddress(),
                    .loadToLRegisterDataFromAccumulatorRegister => self.loadToLRegisterDataFromAccumulatorRegister(),

                    .loadToHLRegisterAddressDataFromBRegister => self.loadToHLRegisterAddressDataFromBRegister(),
                    .loadToHLRegisterAddressDataFromCRegister => self.loadToHLRegisterAddressDataFromCRegister(),
                    .loadToHLRegisterAddressDataFromDRegister => self.loadToHLRegisterAddressDataFromDRegister(),
                    .loadToHLRegisterAddressDataFromERegister => self.loadToHLRegisterAddressDataFromERegister(),
                    .loadToHLRegisterAddressDataFromHRegister => self.loadToHLRegisterAddressDataFromHRegister(),
                    .loadToHLRegisterAddressDataFromLRegister => self.loadToHLRegisterAddressDataFromLRegister(),
                    .loadToHLRegisterAddressDataFromAccumulatorRegister => self.loadToHLRegisterAddressDataFromAccumulatorRegister(),

                    .loadToAccumulatorRegisterDataFromBRegister => self.loadToAccumulatorRegisterDataFromBRegister(),
                    .loadToAccumulatorRegisterDataFromCRegister => self.loadToAccumulatorRegisterDataFromCRegister(),
                    .loadToAccumulatorRegisterDataFromDRegister => self.loadToAccumulatorRegisterDataFromDRegister(),
                    .loadToAccumulatorRegisterDataFromERegister => self.loadToAccumulatorRegisterDataFromERegister(),
                    .loadToAccumulatorRegisterDataFromHRegister => self.loadToAccumulatorRegisterDataFromHRegister(),
                    .loadToAccumulatorRegisterDataFromLRegister => self.loadToAccumulatorRegisterDataFromLRegister(),
                    .loadToAccumulatorRegisterDataFromHLRegisterAddress => self.loadToAccumulatorRegisterDataFromHLRegisterAddress(),
                    .loadToAccumulatorRegisterDataFromAccumulatorRegister => self.loadToAccumulatorRegisterDataFromAccumulatorRegister(),

                    .addToAccumulatorRegisterDataFromBRegister => self.addToAccumulatorRegisterDataFromBRegister(),
                    .addToAccumulatorRegisterDataFromCRegister => self.addToAccumulatorRegisterDataFromCRegister(),
                    .addToAccumulatorRegisterDataFromDRegister => self.addToAccumulatorRegisterDataFromDRegister(),
                    .addToAccumulatorRegisterDataFromERegister => self.addToAccumulatorRegisterDataFromERegister(),
                    .addToAccumulatorRegisterDataFromHRegister => self.addToAccumulatorRegisterDataFromHRegister(),
                    .addToAccumulatorRegisterDataFromLRegister => self.addToAccumulatorRegisterDataFromLRegister(),
                    .addToAccumulatorRegisterDataFromHLRegisterAddress => self.addToAccumulatorRegisterDataFromHLRegisterAddress(),
                    .addToAccumulatorRegisterDataFromAccumulatorRegister => self.addToAccumulatorRegisterDataFromAccumulatorRegister(),
                    .addToAccumulatorRegisterDataFromNextByte => self.addToAccumulatorRegisterDataFromNextByte(),

                    .addWithCarryToAccumulatorRegisterDataFromBRegister => self.addWithCarryToAccumulatorRegisterDataFromBRegister(),
                    .addWithCarryToAccumulatorRegisterDataFromCRegister => self.addWithCarryToAccumulatorRegisterDataFromCRegister(),
                    .addWithCarryToAccumulatorRegisterDataFromDRegister => self.addWithCarryToAccumulatorRegisterDataFromDRegister(),
                    .addWithCarryToAccumulatorRegisterDataFromERegister => self.addWithCarryToAccumulatorRegisterDataFromERegister(),
                    .addWithCarryToAccumulatorRegisterDataFromHRegister => self.addWithCarryToAccumulatorRegisterDataFromHRegister(),
                    .addWithCarryToAccumulatorRegisterDataFromLRegister => self.addWithCarryToAccumulatorRegisterDataFromLRegister(),
                    .addWithCarryToAccumulatorRegisterDataFromHLRegisterAddress => self.addWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(),
                    .addWithCarryToAccumulatorRegisterDataFromAccumulatorRegister => self.addWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(),
                    .addWithCarryToAccumulatorRegisterDataFromNextByte => self.addWithCarryToAccumulatorRegisterDataFromNextByte(),

                    .subToAccumulatorRegisterDataFromBRegister => self.subToAccumulatorRegisterDataFromBRegister(),
                    .subToAccumulatorRegisterDataFromCRegister => self.subToAccumulatorRegisterDataFromCRegister(),
                    .subToAccumulatorRegisterDataFromDRegister => self.subToAccumulatorRegisterDataFromDRegister(),
                    .subToAccumulatorRegisterDataFromERegister => self.subToAccumulatorRegisterDataFromERegister(),
                    .subToAccumulatorRegisterDataFromHRegister => self.subToAccumulatorRegisterDataFromHRegister(),
                    .subToAccumulatorRegisterDataFromLRegister => self.subToAccumulatorRegisterDataFromLRegister(),
                    .subToAccumulatorRegisterDataFromHLRegisterAddress => self.subToAccumulatorRegisterDataFromHLRegisterAddress(),
                    .subToAccumulatorRegisterDataFromAccumulatorRegister => self.subToAccumulatorRegisterDataFromAccumulatorRegister(),
                    .subToAccumulatorRegisterDataFromNextByte => self.subToAccumulatorRegisterDataFromNextByte(),

                    .subWithCarryToAccumulatorRegisterDataFromBRegister => self.subWithCarryToAccumulatorRegisterDataFromBRegister(),
                    .subWithCarryToAccumulatorRegisterDataFromCRegister => self.subWithCarryToAccumulatorRegisterDataFromCRegister(),
                    .subWithCarryToAccumulatorRegisterDataFromDRegister => self.subWithCarryToAccumulatorRegisterDataFromDRegister(),
                    .subWithCarryToAccumulatorRegisterDataFromERegister => self.subWithCarryToAccumulatorRegisterDataFromERegister(),
                    .subWithCarryToAccumulatorRegisterDataFromHRegister => self.subWithCarryToAccumulatorRegisterDataFromHRegister(),
                    .subWithCarryToAccumulatorRegisterDataFromLRegister => self.subWithCarryToAccumulatorRegisterDataFromLRegister(),
                    .subWithCarryToAccumulatorRegisterDataFromHLRegisterAddress => self.subWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(),
                    .subWithCarryToAccumulatorRegisterDataFromAccumulatorRegister => self.subWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(),
                    .subWithCarryToAccumulatorRegisterDataFromNextByte => self.subWithCarryToAccumulatorRegisterDataFromNextByte(),

                    .andToAccumulatorFromBRegister => self.andToAccumulatorFromBRegister(),
                    .andToAccumulatorFromCRegister => self.andToAccumulatorFromCRegister(),
                    .andToAccumulatorFromDRegister => self.andToAccumulatorFromDRegister(),
                    .andToAccumulatorFromERegister => self.andToAccumulatorFromERegister(),
                    .andToAccumulatorFromHRegister => self.andToAccumulatorFromHRegister(),
                    .andToAccumulatorFromLRegister => self.andToAccumulatorFromLRegister(),
                    .andToAccumulatorFromHLRegisterAddress => self.andToAccumulatorFromHLRegisterAddress(),
                    .andToAccumulatorFromAccumulatorRegister => self.andToAccumulatorFromAccumulatorRegister(),
                    .andToAccumulatorFromNextByte => self.andToAccumulatorRegisterDataFromNextByte(),

                    .xorToAccumulatorFromBRegister => self.xorToAccumulatorFromBRegister(),
                    .xorToAccumulatorFromCRegister => self.xorToAccumulatorFromCRegister(),
                    .xorToAccumulatorFromDRegister => self.xorToAccumulatorFromDRegister(),
                    .xorToAccumulatorFromERegister => self.xorToAccumulatorFromERegister(),
                    .xorToAccumulatorFromHRegister => self.xorToAccumulatorFromHRegister(),
                    .xorToAccumulatorFromLRegister => self.xorToAccumulatorFromLRegister(),
                    .xorToAccumulatorFromHLRegisterAddress => self.xorToAccumulatorFromHLRegisterAddress(),
                    .xorToAccumulatorFromAccumulatorRegister => self.xorToAccumulatorFromAccumulatorRegister(),
                    .xorToAccumulatorFromNextByte => self.xorToAccumulatorRegisterDataFromNextByte(),

                    .orToAccumulatorFromBRegister => self.orToAccumulatorFromBRegister(),
                    .orToAccumulatorFromCRegister => self.orToAccumulatorFromCRegister(),
                    .orToAccumulatorFromDRegister => self.orToAccumulatorFromDRegister(),
                    .orToAccumulatorFromERegister => self.orToAccumulatorFromERegister(),
                    .orToAccumulatorFromHRegister => self.orToAccumulatorFromHRegister(),
                    .orToAccumulatorFromLRegister => self.orToAccumulatorFromLRegister(),
                    .orToAccumulatorFromHLRegisterAddress => self.orToAccumulatorFromHLRegisterAddress(),
                    .orToAccumulatorFromAccumulatorRegister => self.orToAccumulatorFromAccumulatorRegister(),
                    .orToAccumulatorFromNextByte => self.orToAccumulatorRegisterDataFromNextByte(),

                    .compareToAccumulatorFromBRegister => self.compareToAccumulatorFromBRegister(),
                    .compareToAccumulatorFromCRegister => self.compareToAccumulatorFromCRegister(),
                    .compareToAccumulatorFromDRegister => self.compareToAccumulatorFromDRegister(),
                    .compareToAccumulatorFromERegister => self.compareToAccumulatorFromERegister(),
                    .compareToAccumulatorFromHRegister => self.compareToAccumulatorFromHRegister(),
                    .compareToAccumulatorFromLRegister => self.compareToAccumulatorFromLRegister(),
                    .compareToAccumulatorFromHLRegisterAddress => self.compareToAccumulatorFromHLRegisterAddress(),
                    .compareToAccumulatorFromAccumulatorRegister => self.compareToAccumulatorFromAccumulatorRegister(),
                    .compareToAccumulatorFromNextByte => self.compareToAccumulatorRegisterDataFromNextByte(),

                    .rotateLeftAccumulatorRegister => self.rotateLeftAccumulatorRegister(),
                    .rotateLeftThroughCarryAccumulatorRegister => self.rotateLeftThroughCarryAccumulatorRegister(),
                    .rotateRightAccumulatorRegister => self.rotateRightAccumulatorRegister(),
                    .rotateRightThroughCarryAccumulatorRegister => self.rotateRightThroughCarryAccumulatorRegister(),

                    .addToHLRegisterDataFromBCRegister => self.addToHLRegisterDataFromBCRegister(),
                    .addToHLRegisterDataFromDERegister => self.addToHLRegisterDataFromDERegister(),
                    .addToHLRegisterDataFromHLRegister => self.addToHLRegisterDataFromHLRegister(),
                    .addToHLRegisterDataFromStackPointerRegister => self.addToHLRegisterDataFromStackPointerRegister(),

                    .jumpRelativeAlways => self.jumpRelativeAlways(),
                    .jumpRelativeIfNotZero => self.jumpRelativeIfNotZero(),
                    .jumpRelativeIfNotCarry => self.jumpRelativeIfNotCarry(),
                    .jumpRelativeIfZero => self.jumpRelativeIfZero(),
                    .jumpRelativeIfCarry => self.jumpRelativeIfCarry(),

                    .loadToByteAddressFromAccumulatorRegister => self.loadToByteAddressFromAccumulatorRegister(),
                    .loadToAccumulatorRegisterFromByteAddress => self.loadToAccumulatorRegisterFromByteAddress(),

                    .loadToAddressPlusCRegisterFromAccumulatorRegister => self.loadToAddressPlusCRegisterFromAccumulatorRegister(),
                    .loadToAccumulatorRegisterFromAddressPlusCRegister => self.loadToAccumulatorRegisterFromAddressPlusCRegister(),

                    .loadToNextWordAddressFromAccumulatorRegister => self.loadToNextWordAddressFromAccumulatorRegister(),
                    .loadToAccumulatorRegisterFromNextWordAddress => self.loadToAccumulatorRegisterFromNextWordAddress(),

                    .loadToStackPointerDataFromHLRegister => self.loadToStackPointerDataFromHLRegister(),

                    .returnIfNotZero => self.returnIfNotZero(),
                    .returnIfNotCarry => self.returnIfNotCarry(),
                    .returnIfZero => self.returnIfZero(),
                    .returnIfCarry => self.returnIfCarry(),
                    .returnAlways => self.returnAlways(),
                    .returnAlwaysWithInterrupt => self.returnAlwaysWithInterrupt(),

                    .jumpIfNotZero => self.jumpIfNotZero(),
                    .jumpIfNotCarry => self.jumpIfNotCarry(),
                    .jumpIfZero => self.jumpIfZero(),
                    .jumpIfCarry => self.jumpIfCarry(),
                    .jumpAlways => self.jumpAlways(),

                    .callIfNotZero => self.callIfNotZero(),
                    .callIfNotCarry => self.callIfNotCarry(),
                    .callIfZero => self.callIfZero(),
                    .callIfCarry => self.callIfCarry(),
                    .callAlways => self.callAlways(),

                    .popBCRegister => self.popBCRegister(),
                    .popDERegister => self.popDERegister(),
                    .popHLRegister => self.popHLRegister(),
                    .popAFRegister => self.popAFRegister(),

                    .pushBCRegister => self.pushBCRegister(),
                    .pushDERegister => self.pushDERegister(),
                    .pushHLRegister => self.pushHLRegister(),
                    .pushAFRegister => self.pushAFRegister(),

                    .restartX00 => self.restartX00(),
                    .restartX10 => self.restartX10(),
                    .restartX20 => self.restartX20(),
                    .restartX30 => self.restartX30(),
                    .restartX08 => self.restartX08(),
                    .restartX18 => self.restartX18(),
                    .restartX28 => self.restartX28(),
                    .restartX38 => self.restartX38(),

                    .jumpToAddressFromHL => self.jumpToAddressFromHL(),

                    .decimalAdjustAccumulator => self.decimalAdjustAccumulator(),
                    .setCarryFlag => self.setCarryFlag(),

                    .complementAccumulatorRegister => self.complementAccumulatorRegister(),
                    .complementCarryFlag => self.complementCarryFlag(),
                }
            },
            .prefixed => |*prefixed| {
                switch (prefixed.*) {
                    .rotateLeftBRegister => self.rotateLeftBRegister(),
                    .rotateLeftCRegister => self.rotateLeftCRegister(),
                    .rotateLeftDRegister => self.rotateLeftDRegister(),
                    .rotateLeftERegister => self.rotateLeftERegister(),
                    .rotateLeftHRegister => self.rotateLeftHRegister(),
                    .rotateLeftLRegister => self.rotateLeftLRegister(),
                    .rotateLeftHLRegisterAddress => self.rotateLeftHLRegisterAddress(),
                    .rotateLeftAccumulatorRegister => self.rotateLeftAccumulatorRegisterPrefixed(),
                    .rotateLeftThroughCarryBRegister => self.rotateLeftThroughCarryBRegister(),
                    .rotateLeftThroughCarryCRegister => self.rotateLeftThroughCarryCRegister(),
                    .rotateLeftThroughCarryDRegister => self.rotateLeftThroughCarryDRegister(),
                    .rotateLeftThroughCarryERegister => self.rotateLeftThroughCarryERegister(),
                    .rotateLeftThroughCarryHRegister => self.rotateLeftThroughCarryHRegister(),
                    .rotateLeftThroughCarryLRegister => self.rotateLeftThroughCarryLRegister(),
                    .rotateLeftThroughCarryHLRegisterAddress => self.rotateLeftThroughCarryHLRegisterAddress(),
                    .rotateLeftThroughCarryAccumulatorRegister => self.rotateLeftThroughCarryAccumulatorRegisterPrefixed(),
                    .rotateRightBRegister => self.rotateRightBRegister(),
                    .rotateRightCRegister => self.rotateRightCRegister(),
                    .rotateRightDRegister => self.rotateRightDRegister(),
                    .rotateRightERegister => self.rotateRightERegister(),
                    .rotateRightHRegister => self.rotateRightHRegister(),
                    .rotateRightLRegister => self.rotateRightLRegister(),
                    .rotateRightHLRegisterAddress => self.rotateRightHLRegisterAddress(),
                    .rotateRightAccumulatorRegister => self.rotateRightAccumulatorRegisterPrefixed(),
                    .rotateRightThroughCarryBRegister => self.rotateRightThroughCarryBRegister(),
                    .rotateRightThroughCarryCRegister => self.rotateRightThroughCarryCRegister(),
                    .rotateRightThroughCarryDRegister => self.rotateRightThroughCarryDRegister(),
                    .rotateRightThroughCarryERegister => self.rotateRightThroughCarryERegister(),
                    .rotateRightThroughCarryHRegister => self.rotateRightThroughCarryHRegister(),
                    .rotateRightThroughCarryLRegister => self.rotateRightThroughCarryLRegister(),
                    .rotateRightThroughCarryHLRegisterAddress => self.rotateRightThroughCarryHLRegisterAddress(),
                    .rotateRightThroughCarryAccumulatorRegister => self.rotateRightThroughCarryAccumulatorRegisterPrefixed(),
                    .shiftLeftArithmeticBRegister => self.shiftLeftArithmeticBRegister(),
                    .shiftLeftArithmeticCRegister => self.shiftLeftArithmeticCRegister(),
                    .shiftLeftArithmeticDRegister => self.shiftLeftArithmeticDRegister(),
                    .shiftLeftArithmeticERegister => self.shiftLeftArithmeticERegister(),
                    .shiftLeftArithmeticHRegister => self.shiftLeftArithmeticHRegister(),
                    .shiftLeftArithmeticLRegister => self.shiftLeftArithmeticLRegister(),
                    .shiftLeftArithmeticHLRegisterAddress => self.shiftLeftArithmeticHLRegisterAddress(),
                    .shiftLeftArithmeticAccumulatorRegister => self.shiftLeftArithmeticAccumulatorRegister(),
                    .shiftRightArithmeticBRegister => self.shiftRightArithmeticBRegister(),
                    .shiftRightArithmeticCRegister => self.shiftRightArithmeticCRegister(),
                    .shiftRightArithmeticDRegister => self.shiftRightArithmeticDRegister(),
                    .shiftRightArithmeticERegister => self.shiftRightArithmeticERegister(),
                    .shiftRightArithmeticHRegister => self.shiftRightArithmeticHRegister(),
                    .shiftRightArithmeticLRegister => self.shiftRightArithmeticLRegister(),
                    .shiftRightArithmeticHLRegisterAddress => self.shiftRightArithmeticHLRegisterAddress(),
                    .shiftRightArithmeticAccumulatorRegister => self.shiftRightArithmeticAccumulatorRegister(),
                    .swapNibblesBRegister => self.swapNibblesBRegister(),
                    .swapNibblesCRegister => self.swapNibblesCRegister(),
                    .swapNibblesDRegister => self.swapNibblesDRegister(),
                    .swapNibblesERegister => self.swapNibblesERegister(),
                    .swapNibblesHRegister => self.swapNibblesHRegister(),
                    .swapNibblesLRegister => self.swapNibblesLRegister(),
                    .swapNibblesHLRegisterAddress => self.swapNibblesHLRegisterAddress(),
                    .swapNibblesAccumulatorRegister => self.swapNibblesAccumulatorRegister(),
                    .shiftRightLogicalBRegister => self.shiftRightLogicalBRegister(),
                    .shiftRightLogicalCRegister => self.shiftRightLogicalCRegister(),
                    .shiftRightLogicalDRegister => self.shiftRightLogicalDRegister(),
                    .shiftRightLogicalERegister => self.shiftRightLogicalERegister(),
                    .shiftRightLogicalHRegister => self.shiftRightLogicalHRegister(),
                    .shiftRightLogicalLRegister => self.shiftRightLogicalLRegister(),
                    .shiftRightLogicalHLRegisterAddress => self.shiftRightLogicalHLRegisterAddress(),
                    .shiftRightLogicalAccumulatorRegister => self.shiftRightLogicalAccumulatorRegister(),
                    .testBit0BRegister => self.testBit0BRegister(),
                    .testBit0CRegister => self.testBit0CRegister(),
                    .testBit0DRegister => self.testBit0DRegister(),
                    .testBit0ERegister => self.testBit0ERegister(),
                    .testBit0HRegister => self.testBit0HRegister(),
                    .testBit0LRegister => self.testBit0LRegister(),
                    .testBit0HLRegisterAddress => self.testBit0HLRegisterAddress(),
                    .testBit0AccumulatorRegister => self.testBit0AccumulatorRegister(),
                    .testBit1BRegister => self.testBit1BRegister(),
                    .testBit1CRegister => self.testBit1CRegister(),
                    .testBit1DRegister => self.testBit1DRegister(),
                    .testBit1ERegister => self.testBit1ERegister(),
                    .testBit1HRegister => self.testBit1HRegister(),
                    .testBit1LRegister => self.testBit1LRegister(),
                    .testBit1HLRegisterAddress => self.testBit1HLRegisterAddress(),
                    .testBit1AccumulatorRegister => self.testBit1AccumulatorRegister(),
                    .testBit2BRegister => self.testBit2BRegister(),
                    .testBit2CRegister => self.testBit2CRegister(),
                    .testBit2DRegister => self.testBit2DRegister(),
                    .testBit2ERegister => self.testBit2ERegister(),
                    .testBit2HRegister => self.testBit2HRegister(),
                    .testBit2LRegister => self.testBit2LRegister(),
                    .testBit2HLRegisterAddress => self.testBit2HLRegisterAddress(),
                    .testBit2AccumulatorRegister => self.testBit2AccumulatorRegister(),
                    .testBit3BRegister => self.testBit3BRegister(),
                    .testBit3CRegister => self.testBit3CRegister(),
                    .testBit3DRegister => self.testBit3DRegister(),
                    .testBit3ERegister => self.testBit3ERegister(),
                    .testBit3HRegister => self.testBit3HRegister(),
                    .testBit3LRegister => self.testBit3LRegister(),
                    .testBit3HLRegisterAddress => self.testBit3HLRegisterAddress(),
                    .testBit3AccumulatorRegister => self.testBit3AccumulatorRegister(),
                    .testBit4BRegister => self.testBit4BRegister(),
                    .testBit4CRegister => self.testBit4CRegister(),
                    .testBit4DRegister => self.testBit4DRegister(),
                    .testBit4ERegister => self.testBit4ERegister(),
                    .testBit4HRegister => self.testBit4HRegister(),
                    .testBit4LRegister => self.testBit4LRegister(),
                    .testBit4HLRegisterAddress => self.testBit4HLRegisterAddress(),
                    .testBit4AccumulatorRegister => self.testBit4AccumulatorRegister(),
                    .testBit5BRegister => self.testBit5BRegister(),
                    .testBit5CRegister => self.testBit5CRegister(),
                    .testBit5DRegister => self.testBit5DRegister(),
                    .testBit5ERegister => self.testBit5ERegister(),
                    .testBit5HRegister => self.testBit5HRegister(),
                    .testBit5LRegister => self.testBit5LRegister(),
                    .testBit5HLRegisterAddress => self.testBit5HLRegisterAddress(),
                    .testBit5AccumulatorRegister => self.testBit5AccumulatorRegister(),
                    .testBit6BRegister => self.testBit6BRegister(),
                    .testBit6CRegister => self.testBit6CRegister(),
                    .testBit6DRegister => self.testBit6DRegister(),
                    .testBit6ERegister => self.testBit6ERegister(),
                    .testBit6HRegister => self.testBit6HRegister(),
                    .testBit6LRegister => self.testBit6LRegister(),
                    .testBit6HLRegisterAddress => self.testBit6HLRegisterAddress(),
                    .testBit6AccumulatorRegister => self.testBit6AccumulatorRegister(),
                    .testBit7BRegister => self.testBit7BRegister(),
                    .testBit7CRegister => self.testBit7CRegister(),
                    .testBit7DRegister => self.testBit7DRegister(),
                    .testBit7ERegister => self.testBit7ERegister(),
                    .testBit7HRegister => self.testBit7HRegister(),
                    .testBit7LRegister => self.testBit7LRegister(),
                    .testBit7HLRegisterAddress => self.testBit7HLRegisterAddress(),
                    .testBit7AccumulatorRegister => self.testBit7AccumulatorRegister(),
                    .resetBit0BRegister => self.resetBit0BRegister(),
                    .resetBit0CRegister => self.resetBit0CRegister(),
                    .resetBit0DRegister => self.resetBit0DRegister(),
                    .resetBit0ERegister => self.resetBit0ERegister(),
                    .resetBit0HRegister => self.resetBit0HRegister(),
                    .resetBit0LRegister => self.resetBit0LRegister(),
                    .resetBit0HLRegisterAddress => self.resetBit0HLRegisterAddress(),
                    .resetBit0AccumulatorRegister => self.resetBit0AccumulatorRegister(),
                    .resetBit1BRegister => self.resetBit1BRegister(),
                    .resetBit1CRegister => self.resetBit1CRegister(),
                    .resetBit1DRegister => self.resetBit1DRegister(),
                    .resetBit1ERegister => self.resetBit1ERegister(),
                    .resetBit1HRegister => self.resetBit1HRegister(),
                    .resetBit1LRegister => self.resetBit1LRegister(),
                    .resetBit1HLRegisterAddress => self.resetBit1HLRegisterAddress(),
                    .resetBit1AccumulatorRegister => self.resetBit1AccumulatorRegister(),
                    .resetBit2BRegister => self.resetBit2BRegister(),
                    .resetBit2CRegister => self.resetBit2CRegister(),
                    .resetBit2DRegister => self.resetBit2DRegister(),
                    .resetBit2ERegister => self.resetBit2ERegister(),
                    .resetBit2HRegister => self.resetBit2HRegister(),
                    .resetBit2LRegister => self.resetBit2LRegister(),
                    .resetBit2HLRegisterAddress => self.resetBit2HLRegisterAddress(),
                    .resetBit2AccumulatorRegister => self.resetBit2AccumulatorRegister(),
                    .resetBit3BRegister => self.resetBit3BRegister(),
                    .resetBit3CRegister => self.resetBit3CRegister(),
                    .resetBit3DRegister => self.resetBit3DRegister(),
                    .resetBit3ERegister => self.resetBit3ERegister(),
                    .resetBit3HRegister => self.resetBit3HRegister(),
                    .resetBit3LRegister => self.resetBit3LRegister(),
                    .resetBit3HLRegisterAddress => self.resetBit3HLRegisterAddress(),
                    .resetBit3AccumulatorRegister => self.resetBit3AccumulatorRegister(),
                    .resetBit4BRegister => self.resetBit4BRegister(),
                    .resetBit4CRegister => self.resetBit4CRegister(),
                    .resetBit4DRegister => self.resetBit4DRegister(),
                    .resetBit4ERegister => self.resetBit4ERegister(),
                    .resetBit4HRegister => self.resetBit4HRegister(),
                    .resetBit4LRegister => self.resetBit4LRegister(),
                    .resetBit4HLRegisterAddress => self.resetBit4HLRegisterAddress(),
                    .resetBit4AccumulatorRegister => self.resetBit4AccumulatorRegister(),
                    .resetBit5BRegister => self.resetBit5BRegister(),
                    .resetBit5CRegister => self.resetBit5CRegister(),
                    .resetBit5DRegister => self.resetBit5DRegister(),
                    .resetBit5ERegister => self.resetBit5ERegister(),
                    .resetBit5HRegister => self.resetBit5HRegister(),
                    .resetBit5LRegister => self.resetBit5LRegister(),
                    .resetBit5HLRegisterAddress => self.resetBit5HLRegisterAddress(),
                    .resetBit5AccumulatorRegister => self.resetBit5AccumulatorRegister(),
                    .resetBit6BRegister => self.resetBit6BRegister(),
                    .resetBit6CRegister => self.resetBit6CRegister(),
                    .resetBit6DRegister => self.resetBit6DRegister(),
                    .resetBit6ERegister => self.resetBit6ERegister(),
                    .resetBit6HRegister => self.resetBit6HRegister(),
                    .resetBit6LRegister => self.resetBit6LRegister(),
                    .resetBit6HLRegisterAddress => self.resetBit6HLRegisterAddress(),
                    .resetBit6AccumulatorRegister => self.resetBit6AccumulatorRegister(),
                    .resetBit7BRegister => self.resetBit7BRegister(),
                    .resetBit7CRegister => self.resetBit7CRegister(),
                    .resetBit7DRegister => self.resetBit7DRegister(),
                    .resetBit7ERegister => self.resetBit7ERegister(),
                    .resetBit7HRegister => self.resetBit7HRegister(),
                    .resetBit7LRegister => self.resetBit7LRegister(),
                    .resetBit7HLRegisterAddress => self.resetBit7HLRegisterAddress(),
                    .resetBit7AccumulatorRegister => self.resetBit7AccumulatorRegister(),
                    .setBit0BRegister => self.setBit0BRegister(),
                    .setBit0CRegister => self.setBit0CRegister(),
                    .setBit0DRegister => self.setBit0DRegister(),
                    .setBit0ERegister => self.setBit0ERegister(),
                    .setBit0HRegister => self.setBit0HRegister(),
                    .setBit0LRegister => self.setBit0LRegister(),
                    .setBit0HLRegisterAddress => self.setBit0HLRegisterAddress(),
                    .setBit0AccumulatorRegister => self.setBit0AccumulatorRegister(),
                    .setBit1BRegister => self.setBit1BRegister(),
                    .setBit1CRegister => self.setBit1CRegister(),
                    .setBit1DRegister => self.setBit1DRegister(),
                    .setBit1ERegister => self.setBit1ERegister(),
                    .setBit1HRegister => self.setBit1HRegister(),
                    .setBit1LRegister => self.setBit1LRegister(),
                    .setBit1HLRegisterAddress => self.setBit1HLRegisterAddress(),
                    .setBit1AccumulatorRegister => self.setBit1AccumulatorRegister(),
                    .setBit2BRegister => self.setBit2BRegister(),
                    .setBit2CRegister => self.setBit2CRegister(),
                    .setBit2DRegister => self.setBit2DRegister(),
                    .setBit2ERegister => self.setBit2ERegister(),
                    .setBit2HRegister => self.setBit2HRegister(),
                    .setBit2LRegister => self.setBit2LRegister(),
                    .setBit2HLRegisterAddress => self.setBit2HLRegisterAddress(),
                    .setBit2AccumulatorRegister => self.setBit2AccumulatorRegister(),
                    .setBit3BRegister => self.setBit3BRegister(),
                    .setBit3CRegister => self.setBit3CRegister(),
                    .setBit3DRegister => self.setBit3DRegister(),
                    .setBit3ERegister => self.setBit3ERegister(),
                    .setBit3HRegister => self.setBit3HRegister(),
                    .setBit3LRegister => self.setBit3LRegister(),
                    .setBit3HLRegisterAddress => self.setBit3HLRegisterAddress(),
                    .setBit3AccumulatorRegister => self.setBit3AccumulatorRegister(),
                    .setBit4BRegister => self.setBit4BRegister(),
                    .setBit4CRegister => self.setBit4CRegister(),
                    .setBit4DRegister => self.setBit4DRegister(),
                    .setBit4ERegister => self.setBit4ERegister(),
                    .setBit4HRegister => self.setBit4HRegister(),
                    .setBit4LRegister => self.setBit4LRegister(),
                    .setBit4HLRegisterAddress => self.setBit4HLRegisterAddress(),
                    .setBit4AccumulatorRegister => self.setBit4AccumulatorRegister(),
                    .setBit5BRegister => self.setBit5BRegister(),
                    .setBit5CRegister => self.setBit5CRegister(),
                    .setBit5DRegister => self.setBit5DRegister(),
                    .setBit5ERegister => self.setBit5ERegister(),
                    .setBit5HRegister => self.setBit5HRegister(),
                    .setBit5LRegister => self.setBit5LRegister(),
                    .setBit5HLRegisterAddress => self.setBit5HLRegisterAddress(),
                    .setBit5AccumulatorRegister => self.setBit5AccumulatorRegister(),
                    .setBit6BRegister => self.setBit6BRegister(),
                    .setBit6CRegister => self.setBit6CRegister(),
                    .setBit6DRegister => self.setBit6DRegister(),
                    .setBit6ERegister => self.setBit6ERegister(),
                    .setBit6HRegister => self.setBit6HRegister(),
                    .setBit6LRegister => self.setBit6LRegister(),
                    .setBit6HLRegisterAddress => self.setBit6HLRegisterAddress(),
                    .setBit6AccumulatorRegister => self.setBit6AccumulatorRegister(),
                    .setBit7BRegister => self.setBit7BRegister(),
                    .setBit7CRegister => self.setBit7CRegister(),
                    .setBit7DRegister => self.setBit7DRegister(),
                    .setBit7ERegister => self.setBit7ERegister(),
                    .setBit7HRegister => self.setBit7HRegister(),
                    .setBit7LRegister => self.setBit7LRegister(),
                    .setBit7HLRegisterAddress => self.setBit7HLRegisterAddress(),
                    .setBit7AccumulatorRegister => self.setBit7AccumulatorRegister(),
                }
            },
        };

        return cycles;
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

    fn popStackPointer(self: *CPU) u16 {
        const least_significant_byte: u16 = self.readByteFromMemory(self.registers.stack_pointer);
        self.registers.stack_pointer +%= 1;

        const most_significant_byte: u16 = self.readByteFromMemory(self.registers.stack_pointer);
        self.registers.stack_pointer +%= 1;

        return (most_significant_byte << 8) | least_significant_byte;
    }

    fn pushStackPointer(self: *CPU, value: u16) void {
        self.registers.stack_pointer -%= 1;
        self.writeByteToMemory(self.registers.stack_pointer, @as(u8, (value & 0xFF00) >> 8));

        self.registers.stack_pointer -%= 1;
        self.writeByteToMemory(self.registers.stack_pointer, @as(u8, value & 0xFF));
    }

    fn noop() u8 {
        return 4;
    }

    fn stop() u8 {
        return 4;
    }

    fn halt(self: *CPU) u8 {
        self.is_halted = true;
        return 4;
    }

    fn disableInterrupts(self: *CPU) u8 {
        self.interrupts_enabled = false;
        return 4;
    }

    fn enableInterrupts(self: *CPU) u8 {
        self.interrupts_enabled = true;
        return 4;
    }

    fn loadToBCRegisterDataFromNextWord(self: *CPU) u8 {
        self.registers.setBC(self.readNextWord());
        return 12;
    }

    fn loadToDERegisterDataFromNextWord(self: *CPU) u8 {
        self.registers.setDE(self.readNextWord());
        return 12;
    }

    fn loadToHLRegisterDataFromNextWord(self: *CPU) u8 {
        self.registers.setHL(self.readNextWord());
        return 12;
    }

    fn loadIntoNextWordAddressDataFromStackPointerRegister(self: *CPU) u8 {
        const address = self.readNextWord();
        const stack_pointer = self.registers.stack_pointer;

        self.writeByteToMemory(address, @as(u8, @intCast(stack_pointer & 0xFF)));
        self.writeByteToMemory(address +% 1, @as(u8, @intCast((stack_pointer & 0xFF00) >> 8)));

        return 20;
    }

    fn loadToStackPointerRegisterDataFromNextWord(self: *CPU) u8 {
        self.registers.stack_pointer = self.readNextWord();
        return 12;
    }

    fn loadToBCRegisterAddressDataFromAccumulatorRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getBC(), self.registers.accumulator);
        return 8;
    }

    fn loadToDERegisterAddressDataFromAccumulatorRegister(self: *CPU) void {
        self.writeByteToMemory(self.registers.getDE(), self.registers.accumulator);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement(self: *CPU) void {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.registers.accumulator);
        self.registers.setHL(address +% 1);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement(self: *CPU) void {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.registers.accumulator);
        self.registers.setHL(address -% 1);
        return 8;
    }

    fn incrementBCRegister(self: *CPU) u8 {
        self.registers.setBC(self.registers.getBC() +% 1);
        return 8;
    }

    fn incrementDERegister(self: *CPU) u8 {
        self.registers.setDE(self.registers.getDE() +% 1);
        return 8;
    }

    fn incrementHLRegister(self: *CPU) u8 {
        self.registers.setHL(self.registers.getHL() +% 1);
        return 8;
    }

    fn incrementStackPointerRegister(self: *CPU) u8 {
        self.registers.stack_pointer +%= 1;
        return 8;
    }

    fn decrementBCRegister(self: *CPU) u8 {
        self.registers.setBC(self.registers.getBC() -% 1);
        return 8;
    }

    fn decrementDERegister(self: *CPU) u8 {
        self.registers.setDE(self.registers.getDE() -% 1);
        return 8;
    }

    fn decrementHLRegister(self: *CPU) u8 {
        self.registers.setHL(self.registers.getHL() -% 1);
        return 8;
    }

    fn decrementStackPointerRegister(self: *CPU) u8 {
        self.registers.stack_pointer -%= 1;
        return 8;
    }

    fn incrementBRegister(self: *CPU) u8 {
        self.registers.b = self.increment(self.registers.b);
        return 4;
    }

    fn incrementCRegister(self: *CPU) u8 {
        self.registers.c = self.increment(self.registers.c);
        return 4;
    }

    fn incrementDRegister(self: *CPU) u8 {
        self.registers.d = self.increment(self.registers.d);
        return 4;
    }

    fn incrementERegister(self: *CPU) u8 {
        self.registers.e = self.increment(self.registers.e);
        return 4;
    }

    fn incrementHRegister(self: *CPU) u8 {
        self.registers.h = self.increment(self.registers.h);
        return 4;
    }

    fn incrementLRegister(self: *CPU) u8 {
        self.registers.l = self.increment(self.registers.l);
        return 4;
    }

    fn incrementHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.increment(self.readByteFromMemory(address)));
        return 12;
    }

    fn incrementAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.increment(self.registers.accumulator);
        return 4;
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

    fn decrementBRegister(self: *CPU) u8 {
        self.registers.b = self.decrement(self.registers.b);
        return 4;
    }

    fn decrementCRegister(self: *CPU) u8 {
        self.registers.c = self.decrement(self.registers.c);
        return 4;
    }

    fn decrementDRegister(self: *CPU) u8 {
        self.registers.d = self.decrement(self.registers.d);
        return 4;
    }

    fn decrementERegister(self: *CPU) u8 {
        self.registers.e = self.decrement(self.registers.e);
        return 4;
    }

    fn decrementHRegister(self: *CPU) u8 {
        self.registers.h = self.decrement(self.registers.h);
        return 4;
    }

    fn decrementLRegister(self: *CPU) u8 {
        self.registers.l = self.decrement(self.registers.l);
        return 4;
    }

    fn decrementHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.decrement(self.readByteFromMemory(address)));
        return 12;
    }

    fn decrementAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.decrement(self.registers.accumulator);
        return 4;
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

    fn loadToBRegisterDataFromNextByte(self: *CPU) u8 {
        self.registers.b = self.readNextByte();
        return 8;
    }
    fn loadToCRegisterDataFromNextByte(self: *CPU) u8 {
        self.registers.c = self.readNextByte();
        return 8;
    }

    fn loadToDRegisterDataFromNextByte(self: *CPU) u8 {
        self.registers.d = self.readNextByte();
        return 8;
    }

    fn loadToERegisterDataFromNextByte(self: *CPU) u8 {
        self.registers.e = self.readNextByte();
        return 8;
    }

    fn loadToHRegisterDataFromNextByte(self: *CPU) u8 {
        self.registers.h = self.readNextByte();
        return 8;
    }

    fn loadToLRegisterDataFromNextByte(self: *CPU) u8 {
        self.registers.l = self.readNextByte();
        return 8;
    }

    fn loadToHLRegisterAddressDataFromNextByte(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.readNextByte());
        return 12;
    }

    fn loadToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.registers.accumulator = self.readNextByte();
        return 8;
    }

    fn loadToBRegisterDataFromBRegister(self: *CPU) u8 {
        self.registers.b = self.registers.b;
        return 4;
    }

    fn loadToBRegisterDataFromCRegister(self: *CPU) u8 {
        self.registers.b = self.registers.c;
        return 4;
    }

    fn loadToBRegisterDataFromDRegister(self: *CPU) u8 {
        self.registers.b = self.registers.d;
        return 4;
    }

    fn loadToBRegisterDataFromERegister(self: *CPU) u8 {
        self.registers.b = self.registers.e;
        return 4;
    }

    fn loadToBRegisterDataFromHRegister(self: *CPU) u8 {
        self.registers.b = self.registers.h;
        return 4;
    }

    fn loadToBRegisterDataFromLRegister(self: *CPU) u8 {
        self.registers.b = self.registers.l;
        return 4;
    }

    fn loadToBRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.registers.b = self.readByteFromMemory(self.registers.getHL());
        return 8;
    }

    fn loadToBRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.b = self.registers.accumulator;
        return 4;
    }

    fn loadToCRegisterDataFromBRegister(self: *CPU) u8 {
        self.registers.c = self.registers.b;
        return 4;
    }

    fn loadToCRegisterDataFromCRegister(self: *CPU) u8 {
        self.registers.c = self.registers.c;
        return 4;
    }

    fn loadToCRegisterDataFromDRegister(self: *CPU) u8 {
        self.registers.c = self.registers.d;
        return 4;
    }

    fn loadToCRegisterDataFromERegister(self: *CPU) u8 {
        self.registers.c = self.registers.e;
        return 4;
    }

    fn loadToCRegisterDataFromHRegister(self: *CPU) u8 {
        self.registers.c = self.registers.h;
        return 4;
    }

    fn loadToCRegisterDataFromLRegister(self: *CPU) u8 {
        self.registers.c = self.registers.l;
        return 4;
    }

    fn loadToCRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.registers.c = self.readByteFromMemory(self.registers.getHL());
        return 8;
    }

    fn loadToCRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.c = self.registers.accumulator;
        return 4;
    }

    fn loadToDRegisterDataFromBRegister(self: *CPU) u8 {
        self.registers.d = self.registers.b;
        return 4;
    }

    fn loadToDRegisterDataFromCRegister(self: *CPU) u8 {
        self.registers.d = self.registers.c;
        return 4;
    }

    fn loadToDRegisterDataFromDRegister(self: *CPU) u8 {
        self.registers.d = self.registers.d;
        return 4;
    }

    fn loadToDRegisterDataFromERegister(self: *CPU) u8 {
        self.registers.d = self.registers.e;
        return 4;
    }

    fn loadToDRegisterDataFromHRegister(self: *CPU) u8 {
        self.registers.d = self.registers.h;
        return 4;
    }

    fn loadToDRegisterDataFromLRegister(self: *CPU) u8 {
        self.registers.d = self.registers.l;
        return 4;
    }

    fn loadToDRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.registers.d = self.readByteFromMemory(self.registers.getHL());
        return 8;
    }

    fn loadToDRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.d = self.registers.accumulator;
        return 4;
    }

    fn loadToERegisterDataFromBRegister(self: *CPU) u8 {
        self.registers.e = self.registers.b;
        return 4;
    }

    fn loadToERegisterDataFromCRegister(self: *CPU) u8 {
        self.registers.e = self.registers.c;
        return 4;
    }

    fn loadToERegisterDataFromDRegister(self: *CPU) u8 {
        self.registers.e = self.registers.d;
        return 4;
    }

    fn loadToERegisterDataFromERegister(self: *CPU) u8 {
        self.registers.e = self.registers.e;
        return 4;
    }

    fn loadToERegisterDataFromHRegister(self: *CPU) u8 {
        self.registers.e = self.registers.h;
        return 4;
    }

    fn loadToERegisterDataFromLRegister(self: *CPU) u8 {
        self.registers.e = self.registers.l;
        return 4;
    }

    fn loadToERegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.registers.e = self.readByteFromMemory(self.registers.getHL());
        return 8;
    }

    fn loadToERegisterDataFromAccumulatorRegister(self: *CPU) 8 {
        self.registers.e = self.registers.accumulator;
        return 4;
    }

    fn loadToHRegisterDataFromBRegister(self: *CPU) u8 {
        self.registers.h = self.registers.b;
        return 4;
    }

    fn loadToHRegisterDataFromCRegister(self: *CPU) u8 {
        self.registers.h = self.registers.c;
        return 4;
    }

    fn loadToHRegisterDataFromDRegister(self: *CPU) u8 {
        self.registers.h = self.registers.d;
        return 4;
    }

    fn loadToHRegisterDataFromERegister(self: *CPU) u8 {
        self.registers.h = self.registers.e;
        return 4;
    }

    fn loadToHRegisterDataFromHRegister(self: *CPU) u8 {
        self.registers.h = self.registers.h;
        return 4;
    }

    fn loadToHRegisterDataFromLRegister(self: *CPU) u8 {
        self.registers.h = self.registers.l;
        return 4;
    }

    fn loadToHRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.registers.h = self.readByteFromMemory(self.registers.getHL());
        return 8;
    }

    fn loadToHRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.h = self.registers.accumulator;
        return 4;
    }

    fn loadToLRegisterDataFromBRegister(self: *CPU) u8 {
        self.registers.l = self.registers.b;
        return 4;
    }

    fn loadToLRegisterDataFromCRegister(self: *CPU) u8 {
        self.registers.l = self.registers.c;
        return 4;
    }

    fn loadToLRegisterDataFromDRegister(self: *CPU) u8 {
        self.registers.l = self.registers.d;
        return 4;
    }

    fn loadToLRegisterDataFromERegister(self: *CPU) u8 {
        self.registers.l = self.registers.e;
        return 4;
    }

    fn loadToLRegisterDataFromHRegister(self: *CPU) u8 {
        self.registers.l = self.registers.h;
        return 4;
    }

    fn loadToLRegisterDataFromLRegister(self: *CPU) u8 {
        self.registers.l = self.registers.l;
        return 4;
    }

    fn loadToLRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.registers.l = self.readByteFromMemory(self.registers.getHL());
        return 8;
    }

    fn loadToLRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.l = self.registers.accumulator;
        return 4;
    }

    fn loadToHLRegisterAddressDataFromBRegister(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.registers.b);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromCRegister(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.registers.c);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromDRegister(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.registers.d);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromERegister(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.registers.e);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromHRegister(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.registers.h);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromLRegister(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.registers.l);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegister(self: *CPU) u8 {
        self.writeByteToMemory(self.registers.getHL(), self.registers.accumulator);
        return 8;
    }

    fn loadToAccumulatorRegisterDataFromBRegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.b;
        return 4;
    }

    fn loadToAccumulatorRegisterDataFromCRegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.c;
        return 4;
    }

    fn loadToAccumulatorRegisterDataFromDRegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.d;
        return 4;
    }

    fn loadToAccumulatorRegisterDataFromERegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.e;
        return 4;
    }

    fn loadToAccumulatorRegisterDataFromHRegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.h;
        return 4;
    }

    fn loadToAccumulatorRegisterDataFromLRegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.l;
        return 4;
    }

    fn loadToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.registers.accumulator = self.readByteFromMemory(self.registers.getHL());
        return 8;
    }

    fn loadToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.accumulator;
        return 4;
    }

    fn loadToByteAddressFromAccumulatorRegister(self: *CPU) u8 {
        const offset: u16 = self.readNextByte();
        self.writeByteToMemory(0xFF00 + offset, self.registers.accumulator);
        return 12;
    }

    fn loadToAccumulatorRegisterFromByteAddress(self: *CPU) u8 {
        const offset: u16 = self.readNextByte();
        self.registers.accumulator = self.readByteFromMemory(0xFF00 + offset);
        return 12;
    }

    fn loadToAddressPlusCRegisterFromAccumulatorRegister(self: *CPU) u8 {
        self.writeByteToMemory(0xFF00 + @as(u16, self.registers.c), self.registers.accumulator);
        return 8;
    }

    fn loadToAccumulatorRegisterFromAddressPlusCRegister(self: *CPU) u8 {
        self.registers.accumulator = self.readByteFromMemory(0xFF00 + @as(u16, self.registers.c));
        return 8;
    }

    fn loadToNextWordAddressFromAccumulatorRegister(self: *CPU) u8 {
        self.writeByteToMemory(self.readNextWord(), self.registers.accumulator);
        return 16;
    }

    fn loadToAccumulatorRegisterFromNextWordAddress(self: *CPU) u8 {
        self.registers.accumulator = self.readByteFromMemory(self.readNextWord());
        return 16;
    }

    fn loadToStackPointerDataFromHLRegister(self: *CPU) u8 {
        self.registers.stack_pointer = self.registers.getHL();
        return 8;
    }

    fn addToAccumulatorRegisterDataFromBRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.b, false);
        return 4;
    }

    fn addToAccumulatorRegisterDataFromCRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.c, false);
        return 4;
    }

    fn addToAccumulatorRegisterDataFromDRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.d, false);
        return 4;
    }

    fn addToAccumulatorRegisterDataFromERegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.e, false);
        return 4;
    }

    fn addToAccumulatorRegisterDataFromHRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.h, false);
        return 4;
    }

    fn addToAccumulatorRegisterDataFromLRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.l, false);
        return 4;
    }

    fn addToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.addToAccumulator(self.readByteFromMemory(self.registers.getHL()), false);
        return 8;
    }

    fn addToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.accumulator, false);
        return 4;
    }

    fn addToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.addToAccumulator(self.readNextByte(), false);
        return 8;
    }

    fn addWithCarryToAccumulatorRegisterDataFromBRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.b, true);
        return 4;
    }

    fn addWithCarryToAccumulatorRegisterDataFromCRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.c, true);
        return 4;
    }

    fn addWithCarryToAccumulatorRegisterDataFromDRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.d, true);
        return 4;
    }

    fn addWithCarryToAccumulatorRegisterDataFromERegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.e, true);
        return 4;
    }

    fn addWithCarryToAccumulatorRegisterDataFromHRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.h, true);
        return 4;
    }

    fn addWithCarryToAccumulatorRegisterDataFromLRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.l, true);
        return 4;
    }

    fn addWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.addToAccumulator(self.readByteFromMemory(self.registers.getHL()), true);
        return 8;
    }

    fn addWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.addToAccumulator(self.registers.accumulator, true);
        return 4;
    }

    fn addWithCarryToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.addToAccumulator(self.readNextByte(), true);
        return 8;
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

    fn subToAccumulatorRegisterDataFromBRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.b, false);
        return 4;
    }

    fn subToAccumulatorRegisterDataFromCRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.c, false);
        return 4;
    }

    fn subToAccumulatorRegisterDataFromDRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.d, false);
        return 4;
    }

    fn subToAccumulatorRegisterDataFromERegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.e, false);
        return 4;
    }

    fn subToAccumulatorRegisterDataFromHRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.h, false);
        return 4;
    }

    fn subToAccumulatorRegisterDataFromLRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.l, false);
        return 4;
    }

    fn subToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.subToAccumulator(self.readByteFromMemory(self.registers.getHL()), false);
        return 8;
    }

    fn subToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.accumulator, false);
        return 4;
    }

    fn subToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.subToAccumulator(self.readNextByte(), false);
        return 8;
    }

    fn subWithCarryToAccumulatorRegisterDataFromBRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.b, true);
        return 4;
    }

    fn subWithCarryToAccumulatorRegisterDataFromCRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.c, true);
        return 4;
    }

    fn subWithCarryToAccumulatorRegisterDataFromDRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.d, true);
        return 4;
    }

    fn subWithCarryToAccumulatorRegisterDataFromERegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.E, true);
        return 4;
    }

    fn subWithCarryToAccumulatorRegisterDataFromHRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.h, true);
        return 4;
    }

    fn subWithCarryToAccumulatorRegisterDataFromLRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.l, true);
        return 4;
    }

    fn subWithCarryToAccumulatorRegisterDataFromHLRegisterAddress(self: *CPU) u8 {
        self.subToAccumulator(self.readByteFromMemory(self.registers.getHL()), true);
        return 8;
    }

    fn subWithCarryToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.subToAccumulator(self.registers.accumulator, true);
        return 4;
    }

    fn subWithCarryToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.subToAccumulator(self.readNextByte(), true);
        return 8;
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

    fn andToAccumulatorFromBRegister(self: *CPU) u8 {
        self.andToAccumulator(self.registers.b);
        return 4;
    }

    fn andToAccumulatorFromCRegister(self: *CPU) u8 {
        self.andToAccumulator(self.registers.c);
        return 4;
    }

    fn andToAccumulatorFromDRegister(self: *CPU) u8 {
        self.andToAccumulator(self.registers.d);
        return 4;
    }

    fn andToAccumulatorFromERegister(self: *CPU) u8 {
        self.andToAccumulator(self.registers.e);
        return 4;
    }

    fn andToAccumulatorFromHRegister(self: *CPU) u8 {
        self.andToAccumulator(self.registers.h);
        return 4;
    }

    fn andToAccumulatorFromLRegister(self: *CPU) u8 {
        self.andToAccumulator(self.registers.l);
        return 4;
    }

    fn andToAccumulatorFromHLRegisterAddress(self: *CPU) u8 {
        self.andToAccumulator(self.readByteFromMemory(self.registers.getHL()));
        return 8;
    }

    fn andToAccumulatorFromAccumulatorRegister(self: *CPU) u8 {
        self.andToAccumulator(self.registers.accumulator);
        return 4;
    }

    fn andToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.andToAccumulator(self.readNextByte());
        return 8;
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

    fn xorToAccumulatorFromBRegister(self: *CPU) u8 {
        self.xorToAccumulator(self.registers.b);
        return 4;
    }

    fn xorToAccumulatorFromCRegister(self: *CPU) u8 {
        self.xorToAccumulator(self.registers.c);
        return 4;
    }

    fn xorToAccumulatorFromDRegister(self: *CPU) u8 {
        self.xorToAccumulator(self.registers.d);
        return 4;
    }

    fn xorToAccumulatorFromERegister(self: *CPU) u8 {
        self.xorToAccumulator(self.registers.e);
        return 4;
    }

    fn xorToAccumulatorFromHRegister(self: *CPU) u8 {
        self.xorToAccumulator(self.registers.h);
        return 4;
    }

    fn xorToAccumulatorFromLRegister(self: *CPU) u8 {
        self.xorToAccumulator(self.registers.l);
        return 4;
    }

    fn xorToAccumulatorFromHLRegisterAddress(self: *CPU) u8 {
        self.xorToAccumulator(self.readByteFromMemory(self.registers.getHL()));
        return 8;
    }

    fn xorToAccumulatorFromAccumulatorRegister(self: *CPU) u8 {
        self.xorToAccumulator(self.registers.accumulator);
        return 4;
    }

    fn xorToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.xorToAccumulator(self.readNextByte());
        return 8;
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

    fn orToAccumulatorFromBRegister(self: *CPU) u8 {
        self.orToAccumulator(self.registers.b);
        return 4;
    }

    fn orToAccumulatorFromCRegister(self: *CPU) u8 {
        self.orToAccumulator(self.registers.c);
        return 4;
    }

    fn orToAccumulatorFromDRegister(self: *CPU) u8 {
        self.orToAccumulator(self.registers.d);
        return 4;
    }

    fn orToAccumulatorFromERegister(self: *CPU) u8 {
        self.orToAccumulator(self.registers.e);
        return 4;
    }

    fn orToAccumulatorFromHRegister(self: *CPU) u8 {
        self.orToAccumulator(self.registers.h);
        return 4;
    }

    fn orToAccumulatorFromLRegister(self: *CPU) u8 {
        self.orToAccumulator(self.registers.l);
        return 4;
    }

    fn orToAccumulatorFromHLRegisterAddress(self: *CPU) u8 {
        self.orToAccumulator(self.readByteFromMemory(self.registers.getHL()));
        return 8;
    }

    fn orToAccumulatorFromAccumulatorRegister(self: *CPU) u8 {
        self.orToAccumulator(self.registers.accumulator);
        return 4;
    }

    fn orToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.orToAccumulator(self.readNextByte());
        return 8;
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

    fn compareToAccumulatorFromBRegister(self: *CPU) u8 {
        self.compareToAccumulator(self.registers.b);
        return 4;
    }

    fn compareToAccumulatorFromCRegister(self: *CPU) u8 {
        self.compareToAccumulator(self.registers.c);
        return 4;
    }

    fn compareToAccumulatorFromDRegister(self: *CPU) u8 {
        self.compareToAccumulator(self.registers.d);
        return 4;
    }

    fn compareToAccumulatorFromERegister(self: *CPU) u8 {
        self.compareToAccumulator(self.registers.e);
        return 4;
    }

    fn compareToAccumulatorFromHRegister(self: *CPU) u8 {
        self.compareToAccumulator(self.registers.h);
        return 4;
    }

    fn compareToAccumulatorFromLRegister(self: *CPU) u8 {
        self.compareToAccumulator(self.registers.l);
        return 4;
    }

    fn compareToAccumulatorFromHLRegisterAddress(self: *CPU) u8 {
        self.compareToAccumulator(self.readByteFromMemory(self.registers.getHL()));
        return 8;
    }

    fn compareToAccumulatorFromAccumulatorRegister(self: *CPU) u8 {
        self.compareToAccumulator(self.registers.accumulator);
        return 4;
    }

    fn compareToAccumulatorRegisterDataFromNextByte(self: *CPU) u8 {
        self.compareToAccumulator(self.readNextByte());
        return 8;
    }

    fn compareToAccumulator(self: *CPU, value: u8) void {
        var flags = self.getFlags();

        flags.zero = self.registers.accumulator == value;
        flags.subtract = true;
        flags.carry = self.registers.accumulator < value;
        flags.half_carry = (self.registers.accumulator & 0xF) < (value & 0xF);

        self.registers.flags = flags.toInt();
    }

    fn rotateLeftAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.rotateLeft(self.registers.accumulator, false);
        return 4;
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

    fn rotateLeftThroughCarryAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.rotateLeftThroughCarry(self.registers.accumulator, false);
        return 4;
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

    fn rotateRightAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.rotateRight(self.registers.accumulator, false);
        return 4;
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

    fn rotateRightThroughCarryAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.rotateRightThroughCarry(self.registers.accumulator, false);
        return 4;
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

    fn addToHLRegisterDataFromBCRegister(self: *CPU) u8 {
        self.addToHLRegister(self.registers.getBC());
        return 8;
    }

    fn addToHLRegisterDataFromDERegister(self: *CPU) u8 {
        self.addToHLRegister(self.registers.getDE());
        return 8;
    }

    fn addToHLRegisterDataFromHLRegister(self: *CPU) u8 {
        self.addToHLRegister(self.registers.getHL());
        return 8;
    }

    fn addToHLRegisterDataFromStackPointerRegister(self: *CPU) u8 {
        self.addToHLRegister(self.registers.stack_pointer);
        return 8;
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

    fn jumpRelativeAlways(self: *CPU) u8 {
        _ = self;
        return jumpRelativeWithCondition(true);
    }

    fn jumpRelativeIfZero(self: *CPU) u8 {
        return jumpRelativeWithCondition(self.getFlags().zero);
    }

    fn jumpRelativeIfCarry(self: *CPU) u8 {
        return jumpRelativeWithCondition(self.getFlags().carry);
    }

    fn jumpRelativeIfNotZero(self: *CPU) u8 {
        return jumpRelativeWithCondition(!self.getFlags().zero);
    }

    fn jumpRelativeIfNotCarry(self: *CPU) u8 {
        return jumpRelativeWithCondition(!self.getFlags().carry);
    }

    fn jumpRelativeWithCondition(self: *CPU, condition: bool) u8 {
        const byte = @as(i8, self.readNextByte());

        if (condition) {
            self.registers.program_counter +%= byte;
            return 12;
        }

        return 8;
    }

    fn returnIfNotZero(self: *CPU) u8 {
        const flags = self.getFlags();
        return self.returnIf(!flags.zero);
    }

    fn returnIfNotCarry(self: *CPU) u8 {
        const flags = self.getFlags();
        return self.returnIf(!flags.carry);
    }

    fn returnIfZero(self: *CPU) u8 {
        const flags = self.getFlags();
        return self.returnIf(flags.zero);
    }

    fn returnIfCarry(self: *CPU) u8 {
        const flags = self.getFlags();
        return self.returnIf(flags.carry);
    }

    fn returnAlways(self: *CPU) u8 {
        _ = self.returnIf(true);
        return 16;
    }

    fn returnAlwaysWithInterrupt(self: *CPU) void {
        self.interrupts_enabled = true;
        _ = self.returnIf(true);
        return 16;
    }

    fn returnIf(self: *CPU, condition: bool) u8 {
        if (condition) {
            self.registers.program_counter = self.popStackPointer();
            return 20;
        }

        return 8;
    }

    fn jumpIfNotZero(self: *CPU) u8 {
        return self.jumpIf(!self.getFlags().zero);
    }

    fn jumpIfNotCarry(self: *CPU) u8 {
        return self.jumpIf(!self.getFlags().carry);
    }

    fn jumpIfZero(self: *CPU) u8 {
        return self.jumpIf(self.getFlags().zero);
    }

    fn jumpIfCarry(self: *CPU) u8 {
        return self.jumpIf(self.getFlags().carry);
    }

    fn jumpAlways(self: *CPU) u8 {
        return self.jumpIf(true);
    }

    fn jumpIf(self: *CPU, condition: bool) u8 {
        if (condition) {
            self.registers.program_counter = self.readNextWord();
            return 16;
        }

        return 12;
    }

    fn callIfNotZero(self: *CPU) u8 {
        return self.callIf(!self.getFlags().zero);
    }

    fn callIfNotCarry(self: *CPU) u8 {
        return self.callIf(!self.getFlags().carry);
    }

    fn callIfZero(self: *CPU) u8 {
        return self.callIf(self.getFlags().zero);
    }

    fn callIfCarry(self: *CPU) u8 {
        return self.callIf(self.getFlags().carry);
    }

    fn callAlways(self: *CPU) u8 {
        return self.callIf(true);
    }

    fn callIf(self: *CPU, condition: bool) u8 {
        const word = self.readNextWord();

        if (condition) {
            self.pushStackPointer(self.registers.program_counter);
            self.registers.program_counter = word;
            return 24;
        }

        return 12;
    }

    fn popBCRegister(self: *CPU) u8 {
        self.registers.setBC(self.popStackPointer());
        return 12;
    }

    fn popDERegister(self: *CPU) u8 {
        self.registers.setDE(self.popStackPointer());
        return 12;
    }

    fn popHLRegister(self: *CPU) u8 {
        self.registers.setHL(self.popStackPointer());
        return 12;
    }

    fn popAFRegister(self: *CPU) u8 {
        self.registers.setAF(self.popStackPointer());
        return 12;
    }

    fn pushBCRegister(self: *CPU) u8 {
        self.pushStackPointer(self.getBC());
        return 16;
    }

    fn pushDERegister(self: *CPU) u8 {
        self.pushStackPointer(self.getDE());
        return 16;
    }

    fn pushHLRegister(self: *CPU) u8 {
        self.pushStackPointer(self.getHL());
        return 16;
    }

    fn pushAFRegister(self: *CPU) u8 {
        self.pushStackPointer(self.getAF());
        return 16;
    }

    fn restartX00(self: *CPU) u8 {
        return self.restart(0x00);
    }

    fn restartX10(self: *CPU) u8 {
        return self.restart(0x10);
    }

    fn restartX20(self: *CPU) u8 {
        return self.restart(0x20);
    }

    fn restartX30(self: *CPU) u8 {
        return self.restart(0x30);
    }

    fn restartX08(self: *CPU) u8 {
        return self.restart(0x08);
    }

    fn restartX18(self: *CPU) u8 {
        return self.restart(0x18);
    }

    fn restartX28(self: *CPU) u8 {
        return self.restart(0x28);
    }

    fn restartX38(self: *CPU) u8 {
        return self.restart(0x38);
    }

    fn restart(self: *CPU, location: u16) u8 {
        self.pushStackPointer(self.registers.program_counter);
        self.registers.program_counter = location;
        return 16; // TODO: some docs says 16, some 24
    }

    fn jumpToAddressFromHL(self: *CPU) u8 {
        self.registers.program_counter = self.registers.getHL();
        return 4;
    }

    fn decimalAdjustAccumulator(self: *CPU) u8 {
        self.decimalAdjust(self.registers.accumulator);
        return 4;
    }

    fn decimalAdjust(self: *CPU, value: u8) u8 {
        var flags = self.getFlags();
        var carry = false;

        var result: u8 = 0x0;

        if (!flags.subtract) {
            var tempResult = value;

            if (flags.carry || value > 0x99) {
                carry = true;
                tempResult +%= 0x60;
            }

            if (flags.half_carry || value & 0x0F > 0x09) {
                tempResult +%= 0x06;
            }

            result = tempResult;
        } else if (flags.carry) {
            carry = true;
            result = value +% (if (flags.half_carry) 0x9A else 0xA0);
        } else if (flags.half_carry) {
            result = value +% 0xFA;
        } else {
            result = value;
        }

        flags.zero = result == 0;
        flags.half_carry = false;
        flags.carry = carry;

        self.registers.flags = flags.toInt();

        return result;
    }

    fn setCarryFlag(self: *CPU) u8 {
        var flags = self.getFlags();
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = true;
        self.registers.flags = flags.toInt();
        return 4;
    }

    fn complementAccumulatorRegister(self: *CPU) u8 {
        self.complement(self.registers.accumulator);
        return 4;
    }

    fn complement(self: *CPU, value: u8) u8 {
        const new_value = ~value;
        var flags = self.getFlags();
        flags.subtract = true;
        flags.half_carry = true;
        self.registers.flags = flags.toInt();
        return new_value;
    }

    fn complementCarryFlag(self: *CPU) u8 {
        var flags = self.getFlags();
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = !flags.carry;
        self.registers.flags = flags.toInt();
        return 4;
    }

    fn rotateLeftBRegister(self: *CPU) u8 {
        self.registers.b = self.rotateLeft(self.registers.b, true);
        return 8;
    }

    fn rotateLeftCRegister(self: *CPU) u8 {
        self.registers.c = self.rotateLeft(self.registers.c, true);
        return 8;
    }

    fn rotateLeftDRegister(self: *CPU) u8 {
        self.registers.d = self.rotateLeft(self.registers.d, true);
        return 8;
    }

    fn rotateLeftERegister(self: *CPU) u8 {
        self.registers.e = self.rotateLeft(self.registers.e, true);
        return 8;
    }

    fn rotateLeftHRegister(self: *CPU) u8 {
        self.registers.h = self.rotateLeft(self.registers.h, true);
        return 8;
    }

    fn rotateLeftLRegister(self: *CPU) u8 {
        self.registers.l = self.rotateLeft(self.registers.l, true);
        return 8;
    }

    fn rotateLeftHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.rotateLeft(self.readByteFromMemory(address), true));
        return 16;
    }

    fn rotateLeftAccumulatorRegisterPrefixed(self: *CPU) u8 {
        self.registers.accumulator = self.rotateLeft(self.registers.accumulator, true);
        return 8;
    }

    fn rotateLeftThroughCarryBRegister(self: *CPU) u8 {
        self.registers.b = self.rotateLeftThroughCarry(self.registers.b, true);
        return 8;
    }

    fn rotateLeftThroughCarryCRegister(self: *CPU) u8 {
        self.registers.c = self.rotateLeftThroughCarry(self.registers.c, true);
        return 8;
    }

    fn rotateLeftThroughCarryDRegister(self: *CPU) u8 {
        self.registers.d = self.rotateLeftThroughCarry(self.registers.d, true);
        return 8;
    }

    fn rotateLeftThroughCarryERegister(self: *CPU) u8 {
        self.registers.e = self.rotateLeftThroughCarry(self.registers.e, true);
        return 8;
    }

    fn rotateLeftThroughCarryHRegister(self: *CPU) u8 {
        self.registers.h = self.rotateLeftThroughCarry(self.registers.h, true);
        return 8;
    }

    fn rotateLeftThroughCarryLRegister(self: *CPU) u8 {
        self.registers.l = self.rotateLeftThroughCarry(self.registers.l, true);
        return 8;
    }

    fn rotateLeftThroughCarryHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.rotateLeftThroughCarry(self.readByteFromMemory(address), true));
        return 16;
    }

    fn rotateLeftThroughCarryAccumulatorRegisterPrefixed(self: *CPU) u8 {
        self.registers.accumulator = self.rotateLeftThroughCarry(self.registers.accumulator, true);
        return 8;
    }

    fn rotateRightBRegister(self: *CPU) u8 {
        self.registers.b = self.rotateRight(self.registers.b, true);
        return 8;
    }

    fn rotateRightCRegister(self: *CPU) u8 {
        self.registers.c = self.rotateRight(self.registers.c, true);
        return 8;
    }

    fn rotateRightDRegister(self: *CPU) u8 {
        self.registers.d = self.rotateRight(self.registers.d, true);
        return 8;
    }

    fn rotateRightERegister(self: *CPU) u8 {
        self.registers.e = self.rotateRight(self.registers.e, true);
        return 8;
    }

    fn rotateRightHRegister(self: *CPU) u8 {
        self.registers.h = self.rotateRight(self.registers.h, true);
        return 8;
    }

    fn rotateRightLRegister(self: *CPU) u8 {
        self.registers.l = self.rotateRight(self.registers.l, true);
        return 8;
    }

    fn rotateRightHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.rotateRight(self.readByteFromMemory(address), true));
        return 16;
    }

    fn rotateRightAccumulatorRegisterPrefixed(self: *CPU) u8 {
        self.registers.accumulator = self.rotateRight(self.registers.accumulator, true);
        return 8;
    }

    fn rotateRightThroughCarryBRegister(self: *CPU) u8 {
        self.registers.b = self.rotateRightThroughCarry(self.registers.b, true);
        return 8;
    }

    fn rotateRightThroughCarryCRegister(self: *CPU) u8 {
        self.registers.c = self.rotateRightThroughCarry(self.registers.c, true);
        return 8;
    }

    fn rotateRightThroughCarryDRegister(self: *CPU) u8 {
        self.registers.d = self.rotateRightThroughCarry(self.registers.d, true);
        return 8;
    }

    fn rotateRightThroughCarryERegister(self: *CPU) u8 {
        self.registers.e = self.rotateRightThroughCarry(self.registers.e, true);
        return 8;
    }

    fn rotateRightThroughCarryHRegister(self: *CPU) u8 {
        self.registers.h = self.rotateRightThroughCarry(self.registers.h, true);
        return 8;
    }

    fn rotateRightThroughCarryLRegister(self: *CPU) u8 {
        self.registers.l = self.rotateRightThroughCarry(self.registers.l, true);
        return 8;
    }

    fn rotateRightThroughCarryHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.rotateRightThroughCarry(self.readByteFromMemory(address), true));
        return 16;
    }

    fn rotateRightThroughCarryAccumulatorRegisterPrefixed(self: *CPU) u8 {
        self.registers.accumulator = self.rotateRightThroughCarry(self.registers.accumulator, true);
        return 8;
    }

    fn shiftLeftArithmeticBRegister(self: *CPU) u8 {
        self.registers.b = self.shiftLeftArithmetic(self.registers.b);
        return 8;
    }

    fn shiftLeftArithmeticCRegister(self: *CPU) u8 {
        self.registers.c = self.shiftLeftArithmetic(self.registers.c);
        return 8;
    }

    fn shiftLeftArithmeticDRegister(self: *CPU) u8 {
        self.registers.d = self.shiftLeftArithmetic(self.registers.d);
        return 8;
    }

    fn shiftLeftArithmeticERegister(self: *CPU) u8 {
        self.registers.e = self.shiftLeftArithmetic(self.registers.e);
        return 8;
    }

    fn shiftLeftArithmeticHRegister(self: *CPU) u8 {
        self.registers.h = self.shiftLeftArithmetic(self.registers.h);
        return 8;
    }

    fn shiftLeftArithmeticLRegister(self: *CPU) u8 {
        self.registers.l = self.shiftLeftArithmetic(self.registers.l);
        return 8;
    }

    fn shiftLeftArithmeticHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.shiftLeftArithmetic(self.readByteFromMemory(address)));
        return 16;
    }

    fn shiftLeftArithmeticAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.shiftLeftArithmetic(self.registers.accumulator);
        return 8;
    }

    fn shiftLeftArithmetic(self: *CPU, value: u8) u8 {
        const new_value = value << 1;

        var flags = self.getFlags();
        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = value & 0b1000_0000 == 0b1000_0000;
        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn shiftRightArithmeticBRegister(self: *CPU) u8 {
        self.registers.b = self.shiftRightArithmetic(self.registers.b);
        return 8;
    }

    fn shiftRightArithmeticCRegister(self: *CPU) u8 {
        self.registers.c = self.shiftRightArithmetic(self.registers.c);
        return 8;
    }

    fn shiftRightArithmeticDRegister(self: *CPU) u8 {
        self.registers.d = self.shiftRightArithmetic(self.registers.d);
        return 8;
    }

    fn shiftRightArithmeticERegister(self: *CPU) u8 {
        self.registers.e = self.shiftRightArithmetic(self.registers.e);
        return 8;
    }

    fn shiftRightArithmeticHRegister(self: *CPU) u8 {
        self.registers.h = self.shiftRightArithmetic(self.registers.h);
        return 8;
    }

    fn shiftRightArithmeticLRegister(self: *CPU) u8 {
        self.registers.l = self.shiftRightArithmetic(self.registers.l);
        return 8;
    }

    fn shiftRightArithmeticHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.shiftRightArithmetic(self.readByteFromMemory(address)));
        return 16;
    }

    fn shiftRightArithmeticAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.shiftRightArithmetic(self.registers.accumulator);
        return 8;
    }

    fn shiftRightArithmetic(self: *CPU, value: u8) u8 {
        const most_significant_bit = value & 0b1000_0000;
        const new_value = most_significant_bit | (value >> 1);

        const flags = self.getFlags();
        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = value & 0b1 == 0b1;
        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn swapNibblesBRegister(self: *CPU) u8 {
        self.registers.b = self.swapNibbles(self.registers.b);
        return 8;
    }

    fn swapNibblesCRegister(self: *CPU) u8 {
        self.registers.c = self.swapNibbles(self.registers.c);
        return 8;
    }

    fn swapNibblesDRegister(self: *CPU) u8 {
        self.registers.d = self.swapNibbles(self.registers.d);
        return 8;
    }

    fn swapNibblesERegister(self: *CPU) u8 {
        self.registers.e = self.swapNibbles(self.registers.e);
        return 8;
    }

    fn swapNibblesHRegister(self: *CPU) u8 {
        self.registers.h = self.swapNibbles(self.registers.h);
        return 8;
    }

    fn swapNibblesLRegister(self: *CPU) u8 {
        self.registers.l = self.swapNibbles(self.registers.l);
        return 8;
    }

    fn swapNibblesHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.swapNibbles(self.readByteFromMemory(address)));
        return 16;
    }

    fn swapNibblesAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.swapNibbles(self.registers.accumulator);
        return 8;
    }

    fn swapNibbles(self: *CPU, value: u8) u8 {
        const new_value = ((value & 0b0000_1111) << 4) | ((value & 0b1111_0000) >> 4);

        const flags = self.getFlags();
        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = false;
        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn shiftRightLogicalBRegister(self: *CPU) u8 {
        self.registers.b = self.shiftRightLogical(self.registers.b);
        return 8;
    }

    fn shiftRightLogicalCRegister(self: *CPU) u8 {
        self.registers.c = self.shiftRightLogical(self.registers.c);
        return 8;
    }

    fn shiftRightLogicalDRegister(self: *CPU) u8 {
        self.registers.d = self.shiftRightLogical(self.registers.d);
        return 8;
    }

    fn shiftRightLogicalERegister(self: *CPU) u8 {
        self.registers.e = self.shiftRightLogical(self.registers.e);
        return 8;
    }

    fn shiftRightLogicalHRegister(self: *CPU) u8 {
        self.registers.h = self.shiftRightLogical(self.registers.h);
        return 8;
    }

    fn shiftRightLogicalLRegister(self: *CPU) u8 {
        self.registers.l = self.shiftRightLogical(self.registers.l);
        return 8;
    }

    fn shiftRightLogicalHLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.shiftRightLogical(self.readByteFromMemory(address)));
        return 16;
    }

    fn shiftRightLogicalAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.shiftRightLogical(self.registers.accumulator);
        return 8;
    }

    fn shiftRightLogical(self: *CPU, value: u8) u8 {
        const new_value = value >> 1;

        const flags = self.getFlags();
        flags.zero = new_value == 0;
        flags.subtract = false;
        flags.half_carry = false;
        flags.carry = value & 0b1 == 0b1;
        self.registers.flags = flags.toInt();

        return new_value;
    }

    fn testBit0BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 0);
        return 8;
    }

    fn testBit0CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 0);
        return 8;
    }

    fn testBit0DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 0);
        return 8;
    }

    fn testBit0ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 0);
        return 8;
    }

    fn testBit0HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 0);
        return 8;
    }

    fn testBit0LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 0);
        return 8;
    }

    fn testBit0HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 0);
        return 12;
    }

    fn testBit0AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 0);
        return 8;
    }

    fn testBit1BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 1);
        return 8;
    }

    fn testBit1CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 1);
        return 8;
    }

    fn testBit1DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 1);
        return 8;
    }

    fn testBit1ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 1);
        return 8;
    }

    fn testBit1HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 1);
        return 8;
    }

    fn testBit1LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 1);
        return 8;
    }

    fn testBit1HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 1);
        return 12;
    }

    fn testBit1AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 1);
        return 8;
    }

    fn testBit2BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 2);
        return 8;
    }

    fn testBit2CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 2);
        return 8;
    }

    fn testBit2DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 2);
        return 8;
    }

    fn testBit2ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 2);
        return 8;
    }

    fn testBit2HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 2);
        return 8;
    }

    fn testBit2LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 2);
        return 8;
    }

    fn testBit2HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 2);
        return 12;
    }

    fn testBit2AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 2);
        return 8;
    }

    fn testBit3BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 3);
        return 8;
    }

    fn testBit3CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 3);
        return 8;
    }

    fn testBit3DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 3);
        return 8;
    }

    fn testBit3ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 3);
        return 8;
    }

    fn testBit3HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 3);
        return 8;
    }

    fn testBit3LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 3);
        return 8;
    }

    fn testBit3HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 3);
        return 12;
    }

    fn testBit3AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 3);
        return 8;
    }

    fn testBit4BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 4);
        return 8;
    }

    fn testBit4CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 4);
        return 8;
    }

    fn testBit4DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 4);
        return 8;
    }

    fn testBit4ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 4);
        return 8;
    }

    fn testBit4HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 4);
        return 8;
    }

    fn testBit4LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 4);
        return 8;
    }

    fn testBit4HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 4);
        return 12;
    }

    fn testBit4AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 4);
        return 8;
    }

    fn testBit5BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 5);
        return 8;
    }

    fn testBit5CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 5);
        return 8;
    }

    fn testBit5DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 5);
        return 8;
    }

    fn testBit5ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 5);
        return 8;
    }

    fn testBit5HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 5);
        return 8;
    }

    fn testBit5LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 5);
        return 8;
    }

    fn testBit5HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 5);
        return 12;
    }

    fn testBit5AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 5);
        return 8;
    }

    fn testBit6BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 6);
        return 8;
    }

    fn testBit6CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 6);
        return 8;
    }

    fn testBit6DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 6);
        return 8;
    }

    fn testBit6ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 6);
        return 8;
    }

    fn testBit6HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 6);
        return 8;
    }

    fn testBit6LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 6);
        return 8;
    }

    fn testBit6HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 6);
        return 12;
    }

    fn testBit6AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 6);
        return 8;
    }

    fn testBit7BRegister(self: *CPU) u8 {
        self.testBit(self.registers.b, 7);
        return 8;
    }

    fn testBit7CRegister(self: *CPU) u8 {
        self.testBit(self.registers.c, 7);
        return 8;
    }

    fn testBit7DRegister(self: *CPU) u8 {
        self.testBit(self.registers.d, 7);
        return 8;
    }

    fn testBit7ERegister(self: *CPU) u8 {
        self.testBit(self.registers.e, 7);
        return 8;
    }

    fn testBit7HRegister(self: *CPU) u8 {
        self.testBit(self.registers.h, 7);
        return 8;
    }

    fn testBit7LRegister(self: *CPU) u8 {
        self.testBit(self.registers.l, 7);
        return 8;
    }

    fn testBit7HLRegisterAddress(self: *CPU) u8 {
        self.testBit(self.readByteFromMemory(self.registers.getHL()), 7);
        return 12;
    }

    fn testBit7AccumulatorRegister(self: *CPU) u8 {
        self.testBit(self.registers.accumulator, 7);
        return 8;
    }

    fn testBit(self: *CPU, value: u8, bit_position: u8) void {
        const result = (value >> bit_position) & 0b1;
        var flags = self.getFlags();
        flags.zero = result == 0;
        flags.subtract = false;
        flags.half_carry = true;
    }

    fn resetBit0BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 0);
        return 8;
    }

    fn resetBit0CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 0);
        return 8;
    }

    fn resetBit0DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 0);
        return 8;
    }

    fn resetBit0ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 0);
        return 8;
    }

    fn resetBit0HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 0);
        return 8;
    }

    fn resetBit0LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 0);
        return 8;
    }

    fn resetBit0HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 0));
        return 16;
    }

    fn resetBit0AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 0);
        return 8;
    }

    fn resetBit1BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 1);
        return 8;
    }

    fn resetBit1CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 1);
        return 8;
    }

    fn resetBit1DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 1);
        return 8;
    }

    fn resetBit1ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 1);
        return 8;
    }

    fn resetBit1HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 1);
        return 8;
    }

    fn resetBit1LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 1);
        return 8;
    }

    fn resetBit1HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 1));
        return 16;
    }

    fn resetBit1AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 1);
        return 8;
    }
    fn resetBit2BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 2);
        return 8;
    }

    fn resetBit2CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 2);
        return 8;
    }

    fn resetBit2DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 2);
        return 8;
    }

    fn resetBit2ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 2);
        return 8;
    }

    fn resetBit2HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 2);
        return 8;
    }

    fn resetBit2LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 2);
        return 8;
    }

    fn resetBit2HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 2));
        return 16;
    }

    fn resetBit2AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 2);
        return 8;
    }
    fn resetBit3BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 3);
        return 8;
    }

    fn resetBit3CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 3);
        return 8;
    }

    fn resetBit3DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 3);
        return 8;
    }

    fn resetBit3ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 3);
        return 8;
    }

    fn resetBit3HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 3);
        return 8;
    }

    fn resetBit3LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 3);
        return 8;
    }

    fn resetBit3HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 3));
        return 16;
    }

    fn resetBit3AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 3);
        return 8;
    }
    fn resetBit4BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 4);
        return 8;
    }

    fn resetBit4CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 4);
        return 8;
    }

    fn resetBit4DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 4);
        return 8;
    }

    fn resetBit4ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 4);
        return 8;
    }

    fn resetBit4HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 4);
        return 8;
    }

    fn resetBit4LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 4);
        return 8;
    }

    fn resetBit4HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 4));
        return 16;
    }

    fn resetBit4AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 4);
        return 8;
    }
    fn resetBit5BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 5);
        return 8;
    }

    fn resetBit5CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 5);
        return 8;
    }

    fn resetBit5DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 5);
        return 8;
    }

    fn resetBit5ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 5);
        return 8;
    }

    fn resetBit5HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 5);
        return 8;
    }

    fn resetBit5LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 5);
        return 8;
    }

    fn resetBit5HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 5));
        return 16;
    }

    fn resetBit5AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 5);
        return 8;
    }
    fn resetBit6BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 6);
        return 8;
    }

    fn resetBit6CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 6);
        return 8;
    }

    fn resetBit6DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 6);
        return 8;
    }

    fn resetBit6ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 6);
        return 8;
    }

    fn resetBit6HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 6);
        return 8;
    }

    fn resetBit6LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 6);
        return 8;
    }

    fn resetBit6HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 6));
        return 16;
    }

    fn resetBit6AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 6);
        return 8;
    }
    fn resetBit7BRegister(self: *CPU) u8 {
        self.registers.b = self.resetBit(self.registers.b, 7);
        return 8;
    }

    fn resetBit7CRegister(self: *CPU) u8 {
        self.registers.c = self.resetBit(self.registers.c, 7);
        return 8;
    }

    fn resetBit7DRegister(self: *CPU) u8 {
        self.registers.d = self.resetBit(self.registers.d, 7);
        return 8;
    }

    fn resetBit7ERegister(self: *CPU) u8 {
        self.registers.e = self.resetBit(self.registers.e, 7);
        return 8;
    }

    fn resetBit7HRegister(self: *CPU) u8 {
        self.registers.h = self.resetBit(self.registers.h, 7);
        return 8;
    }

    fn resetBit7LRegister(self: *CPU) u8 {
        self.registers.l = self.resetBit(self.registers.l, 7);
        return 8;
    }

    fn resetBit7HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.resetBit(self.readByteFromMemory(address), 7));
        return 16;
    }

    fn resetBit7AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.resetBit(self.registers.accumulator, 7);
        return 8;
    }

    fn resetBit(self: *CPU, value: u8, bit_position: u8) u8 {
        _ = self;
        return value & ~(0b1 << bit_position);
    }

    fn setBit0BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 0);
        return 8;
    }

    fn setBit0CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 0);
        return 8;
    }

    fn setBit0DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 0);
        return 8;
    }

    fn setBit0ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 0);
        return 8;
    }

    fn setBit0HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 0);
        return 8;
    }

    fn setBit0LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 0);
        return 8;
    }

    fn setBit0HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 0));
        return 16;
    }

    fn setBit0AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 0);
        return 8;
    }

    fn setBit1BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 1);
        return 8;
    }

    fn setBit1CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 1);
        return 8;
    }

    fn setBit1DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 1);
        return 8;
    }

    fn setBit1ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 1);
        return 8;
    }

    fn setBit1HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 1);
        return 8;
    }

    fn setBit1LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 1);
        return 8;
    }

    fn setBit1HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 1));
        return 16;
    }

    fn setBit1AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 1);
        return 8;
    }
    fn setBit2BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 2);
        return 8;
    }

    fn setBit2CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 2);
        return 8;
    }

    fn setBit2DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 2);
        return 8;
    }

    fn setBit2ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 2);
        return 8;
    }

    fn setBit2HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 2);
        return 8;
    }

    fn setBit2LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 2);
        return 8;
    }

    fn setBit2HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 2));
        return 16;
    }

    fn setBit2AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 2);
        return 8;
    }
    fn setBit3BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 3);
        return 8;
    }

    fn setBit3CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 3);
        return 8;
    }

    fn setBit3DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 3);
        return 8;
    }

    fn setBit3ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 3);
        return 8;
    }

    fn setBit3HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 3);
        return 8;
    }

    fn setBit3LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 3);
        return 8;
    }

    fn setBit3HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 3));
        return 16;
    }

    fn setBit3AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 3);
        return 8;
    }
    fn setBit4BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 4);
        return 8;
    }

    fn setBit4CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 4);
        return 8;
    }

    fn setBit4DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 4);
        return 8;
    }

    fn setBit4ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 4);
        return 8;
    }

    fn setBit4HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 4);
        return 8;
    }

    fn setBit4LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 4);
        return 8;
    }

    fn setBit4HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 4));
        return 16;
    }

    fn setBit4AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 4);
        return 8;
    }
    fn setBit5BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 5);
        return 8;
    }

    fn setBit5CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 5);
        return 8;
    }

    fn setBit5DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 5);
        return 8;
    }

    fn setBit5ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 5);
        return 8;
    }

    fn setBit5HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 5);
        return 8;
    }

    fn setBit5LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 5);
        return 8;
    }

    fn setBit5HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 5));
        return 16;
    }

    fn setBit5AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 5);
        return 8;
    }
    fn setBit6BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 6);
        return 8;
    }

    fn setBit6CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 6);
        return 8;
    }

    fn setBit6DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 6);
        return 8;
    }

    fn setBit6ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 6);
        return 8;
    }

    fn setBit6HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 6);
        return 8;
    }

    fn setBit6LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 6);
        return 8;
    }

    fn setBit6HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 6));
        return 16;
    }

    fn setBit6AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 6);
        return 8;
    }
    fn setBit7BRegister(self: *CPU) u8 {
        self.registers.b = self.setBit(self.registers.b, 7);
        return 8;
    }

    fn setBit7CRegister(self: *CPU) u8 {
        self.registers.c = self.setBit(self.registers.c, 7);
        return 8;
    }

    fn setBit7DRegister(self: *CPU) u8 {
        self.registers.d = self.setBit(self.registers.d, 7);
        return 8;
    }

    fn setBit7ERegister(self: *CPU) u8 {
        self.registers.e = self.setBit(self.registers.e, 7);
        return 8;
    }

    fn setBit7HRegister(self: *CPU) u8 {
        self.registers.h = self.setBit(self.registers.h, 7);
        return 8;
    }

    fn setBit7LRegister(self: *CPU) u8 {
        self.registers.l = self.setBit(self.registers.l, 7);
        return 8;
    }

    fn setBit7HLRegisterAddress(self: *CPU) u8 {
        const address = self.registers.getHL();
        self.writeByteToMemory(address, self.setBit(self.readByteFromMemory(address), 7));
        return 16;
    }

    fn setBit7AccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.setBit(self.registers.accumulator, 7);
        return 8;
    }

    fn setBit(self: *CPU, value: u8, bit_position: u8) u8 {
        _ = self;
        return value | (0b1 << bit_position);
    }
};

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

    std.debug.print("{b}\n", .{cpu.registers.getBC()});
}
