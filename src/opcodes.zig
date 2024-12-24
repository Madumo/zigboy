pub const OpCodeType = enum {
    unprefixed,
    prefixed,
};

pub const UnprefixedOpCode = enum(u8) {
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

pub const PrefixedOpCode = enum(u8) {
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

pub const OpCode = union(OpCodeType) {
    unprefixed: UnprefixedOpCode,
    prefixed: PrefixedOpCode,
};