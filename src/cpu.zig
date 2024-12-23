const std = @import("std");
const OpCode = @import("opcodes.zig").OpCode;
const registers = @import("registers.zig");
const Registers = registers.Registers;
const FlagsRegister = registers.FlagsRegister;
const MemoryBus = @import("memory_bus.zig").MemoryBus;

pub const CPU = struct {
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

    pub fn step(self: *CPU) u8 {
        var intruction_byte = self.readNextByte();
        const is_prefixed = intruction_byte == 0xCB;

        if (is_prefixed) {
            intruction_byte = self.readNextByte();
        }

        const instruction = if (is_prefixed) OpCode{ .prefixed = @enumFromInt(intruction_byte) } else OpCode{ .unprefixed = @enumFromInt(intruction_byte) };

        const cycles = self.execute(instruction);

        return cycles;
    }

    fn incrementProgramCounter(self: *CPU) void {
        self.registers.program_counter +%= 1;
    }

    fn readNextByte(self: *CPU) u8 {
        const byte = self.memoryBus.readByte(self.registers.program_counter);
        self.incrementProgramCounter();
        return byte;
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
        const least_significant_byte: u16 = self.memoryBus.readByte(self.registers.stack_pointer);
        self.registers.stack_pointer +%= 1;

        const most_significant_byte: u16 = self.memoryBus.readByte(self.registers.stack_pointer);
        self.registers.stack_pointer +%= 1;

        return (most_significant_byte << 8) | least_significant_byte;
    }

    fn pushStackPointer(self: *CPU, value: u16) void {
        self.registers.stack_pointer -%= 1;
        self.memoryBus.writeByte(self.registers.stack_pointer, @as(u8, (value & 0xFF00) >> 8));

        self.registers.stack_pointer -%= 1;
        self.memoryBus.writeByte(self.registers.stack_pointer, @as(u8, value & 0xFF));
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

        self.memoryBus.writeByte(address, @as(u8, @intCast(stack_pointer & 0xFF)));
        self.memoryBus.writeByte(address +% 1, @as(u8, @intCast((stack_pointer & 0xFF00) >> 8)));

        return 20;
    }

    fn loadToStackPointerRegisterDataFromNextWord(self: *CPU) u8 {
        self.registers.stack_pointer = self.readNextWord();
        return 12;
    }

    fn loadToBCRegisterAddressDataFromAccumulatorRegister(self: *CPU) void {
        self.memoryBus.writeByte(self.registers.getBC(), self.registers.accumulator);
        return 8;
    }

    fn loadToDERegisterAddressDataFromAccumulatorRegister(self: *CPU) void {
        self.memoryBus.writeByte(self.registers.getDE(), self.registers.accumulator);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegisterThenIncrement(self: *CPU) void {
        const address = self.registers.getHL();
        self.memoryBus.writeByte(address, self.registers.accumulator);
        self.registers.setHL(address +% 1);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegisterThenDecrement(self: *CPU) void {
        const address = self.registers.getHL();
        self.memoryBus.writeByte(address, self.registers.accumulator);
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
        self.memoryBus.writeByte(address, self.increment(self.memoryBus.readByte(address)));
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
        self.memoryBus.writeByte(address, self.decrement(self.memoryBus.readByte(address)));
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
        self.memoryBus.writeByte(self.registers.getHL(), self.readNextByte());
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
        self.registers.b = self.memoryBus.readByte(self.registers.getHL());
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
        self.registers.c = self.memoryBus.readByte(self.registers.getHL());
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
        self.registers.d = self.memoryBus.readByte(self.registers.getHL());
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
        self.registers.e = self.memoryBus.readByte(self.registers.getHL());
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
        self.registers.h = self.memoryBus.readByte(self.registers.getHL());
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
        self.registers.l = self.memoryBus.readByte(self.registers.getHL());
        return 8;
    }

    fn loadToLRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.l = self.registers.accumulator;
        return 4;
    }

    fn loadToHLRegisterAddressDataFromBRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.registers.getHL(), self.registers.b);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromCRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.registers.getHL(), self.registers.c);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromDRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.registers.getHL(), self.registers.d);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromERegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.registers.getHL(), self.registers.e);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromHRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.registers.getHL(), self.registers.h);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromLRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.registers.getHL(), self.registers.l);
        return 8;
    }

    fn loadToHLRegisterAddressDataFromAccumulatorRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.registers.getHL(), self.registers.accumulator);
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
        self.registers.accumulator = self.memoryBus.readByte(self.registers.getHL());
        return 8;
    }

    fn loadToAccumulatorRegisterDataFromAccumulatorRegister(self: *CPU) u8 {
        self.registers.accumulator = self.registers.accumulator;
        return 4;
    }

    fn loadToByteAddressFromAccumulatorRegister(self: *CPU) u8 {
        const offset: u16 = self.readNextByte();
        self.memoryBus.writeByte(0xFF00 + offset, self.registers.accumulator);
        return 12;
    }

    fn loadToAccumulatorRegisterFromByteAddress(self: *CPU) u8 {
        const offset: u16 = self.readNextByte();
        self.registers.accumulator = self.memoryBus.readByte(0xFF00 + offset);
        return 12;
    }

    fn loadToAddressPlusCRegisterFromAccumulatorRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(0xFF00 + @as(u16, self.registers.c), self.registers.accumulator);
        return 8;
    }

    fn loadToAccumulatorRegisterFromAddressPlusCRegister(self: *CPU) u8 {
        self.registers.accumulator = self.memoryBus.readByte(0xFF00 + @as(u16, self.registers.c));
        return 8;
    }

    fn loadToNextWordAddressFromAccumulatorRegister(self: *CPU) u8 {
        self.memoryBus.writeByte(self.readNextWord(), self.registers.accumulator);
        return 16;
    }

    fn loadToAccumulatorRegisterFromNextWordAddress(self: *CPU) u8 {
        self.registers.accumulator = self.memoryBus.readByte(self.readNextWord());
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
        self.addToAccumulator(self.memoryBus.readByte(self.registers.getHL()), false);
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
        self.addToAccumulator(self.memoryBus.readByte(self.registers.getHL()), true);
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
        self.subToAccumulator(self.memoryBus.readByte(self.registers.getHL()), false);
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
        self.subToAccumulator(self.memoryBus.readByte(self.registers.getHL()), true);
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
        self.andToAccumulator(self.memoryBus.readByte(self.registers.getHL()));
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
        self.xorToAccumulator(self.memoryBus.readByte(self.registers.getHL()));
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
        self.orToAccumulator(self.memoryBus.readByte(self.registers.getHL()));
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
        self.compareToAccumulator(self.memoryBus.readByte(self.registers.getHL()));
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
        self.memoryBus.writeByte(address, self.rotateLeft(self.memoryBus.readByte(address), true));
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
        self.memoryBus.writeByte(address, self.rotateLeftThroughCarry(self.memoryBus.readByte(address), true));
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
        self.memoryBus.writeByte(address, self.rotateRight(self.memoryBus.readByte(address), true));
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
        self.memoryBus.writeByte(address, self.rotateRightThroughCarry(self.memoryBus.readByte(address), true));
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
        self.memoryBus.writeByte(address, self.shiftLeftArithmetic(self.memoryBus.readByte(address)));
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
        self.memoryBus.writeByte(address, self.shiftRightArithmetic(self.memoryBus.readByte(address)));
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
        self.memoryBus.writeByte(address, self.swapNibbles(self.memoryBus.readByte(address)));
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
        self.memoryBus.writeByte(address, self.shiftRightLogical(self.memoryBus.readByte(address)));
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 0);
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 1);
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 2);
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 3);
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 4);
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 5);
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 6);
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
        self.testBit(self.memoryBus.readByte(self.registers.getHL()), 7);
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 0));
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 1));
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 2));
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 3));
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 4));
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 5));
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 6));
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
        self.memoryBus.writeByte(address, self.resetBit(self.memoryBus.readByte(address), 7));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 0));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 1));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 2));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 3));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 4));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 5));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 6));
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
        self.memoryBus.writeByte(address, self.setBit(self.memoryBus.readByte(address), 7));
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
