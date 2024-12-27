const std = @import("std");
const addr = @import("addressable_space.zig");
const PPU = @import("ppu.zig").PPU;
const Joypad = @import("joypad.zig").Joypad;
const InterruptFlags = @import("interrupt_flags.zig").InterruptFlags;
const timer = @import("timer.zig");
const Timer = timer.Timer;
const Frequency = timer.Frequency;
const TimerControlFlags = timer.TimerControlFlags;

pub const MemoryBus = struct {
    boot_rom: ?*const [addr.BOOT_ROM_SIZE]u8 = null,
    rom_bank_0: [addr.ROM_BANK_0_SIZE]u8 = std.mem.zeroes([addr.ROM_BANK_0_SIZE]u8),
    rom_bank_n: [addr.ROM_BANK_N_SIZE]u8 = std.mem.zeroes([addr.ROM_BANK_N_SIZE]u8),
    external_ram: [addr.EXTERNAL_RAM_SIZE]u8 = std.mem.zeroes([addr.EXTERNAL_RAM_SIZE]u8),
    working_ram: [addr.WORKING_RAM_SIZE]u8 = std.mem.zeroes([addr.WORKING_RAM_SIZE]u8),
    zero_page: [addr.ZERO_PAGE_SIZE]u8 = std.mem.zeroes([addr.ZERO_PAGE_SIZE]u8),

    interrupt_enable: InterruptFlags = InterruptFlags{},
    interrupt_request: InterruptFlags = InterruptFlags{},

    ppu: PPU = PPU{},

    joypad: Joypad = Joypad{},

    timer: Timer = Timer{ .timerControl = TimerControlFlags{ .frequency = Frequency.F4096 } },
    divider: Timer = Timer{ .timerControl = TimerControlFlags{ .frequency = Frequency.F16384, .enable = true } },

    pub fn init(boot_rom: *const [addr.BOOT_ROM_SIZE]u8) MemoryBus {
        //const rom_bank_0: [addr.ROM_BANK_0_SIZE]u8 = game_rom.items[0..addr.ROM_BANK_0_SIZE];
        //const rom_bank_n: [addr.ROM_BANK_N_SIZE]u8 = game_rom.items[addr.ROM_BANK_0_SIZE .. addr.ROM_BANK_0_SIZE + addr.ROM_BANK_N_SIZE];

        return MemoryBus{
            .boot_rom = boot_rom,
            // .rom_bank_0 = rom_bank_0,
            // .rom_bank_n = rom_bank_n,
        };
    }

    pub fn step(self: *MemoryBus, cycles: u8) InterruptFlags {
        if (self.timer.step(cycles)) {
            self.interrupt_enable.timer = true;
        }

        _ = self.divider.step(cycles);

        const ppu_interrupt_request = self.ppu.step(cycles);

        if (ppu_interrupt_request.vblank) {
            self.interrupt_request.vblank = true;
        }

        if (ppu_interrupt_request.lcdstat) {
            self.interrupt_request.lcdstat = true;
        }

        return InterruptFlags.fromByte(self.interrupt_request.toByte() & self.interrupt_enable.toByte());
    }

    pub fn hasInterrupt(self: *MemoryBus) bool {
        return (self.interrupt_enable.toByte() & self.interrupt_request.toByte()) > 0;
    }

    pub fn readByte(self: *MemoryBus, address: u16) u8 {
        return switch (address) {
            addr.ROM_BANK_0_BEGIN...addr.ROM_BANK_0_END => if (self.boot_rom) |*boot_rom| if (address < addr.BOOT_ROM_END) boot_rom.*[address] else self.rom_bank_0[address] else self.rom_bank_0[address],
            addr.ROM_BANK_N_BEGIN...addr.ROM_BANK_N_END => self.rom_bank_n[address - addr.ROM_BANK_N_BEGIN],
            addr.VRAM_BEGIN...addr.VRAM_END => self.ppu.vram[address - addr.VRAM_BEGIN],
            addr.EXTERNAL_RAM_BEGIN...addr.EXTERNAL_RAM_END => self.external_ram[address - addr.EXTERNAL_RAM_BEGIN],
            addr.WORKING_RAM_BEGIN...addr.WORKING_RAM_END => self.working_ram[address - addr.WORKING_RAM_BEGIN],
            addr.ECHO_RAM_BEGIN...addr.ECHO_RAM_END => self.working_ram[address - addr.ECHO_RAM_BEGIN],
            addr.OAM_BEGIN...addr.OAM_END => self.ppu.oam[address - addr.OAM_BEGIN],
            addr.IO_REGISTERS_BEGIN...addr.IO_REGISTERS_END => self.readIoRegister(address),
            addr.UNUSED_BEGIN...addr.UNUSED_END => 0,
            addr.ZERO_PAGE_BEGIN...addr.ZERO_PAGE_END => self.zero_page[address - addr.ZERO_PAGE_BEGIN],
            addr.INTERRUPT_ENABLE_REGISTER => self.interrupt_enable.toByte(),
        };
    }

    fn readIoRegister(self: *MemoryBus, address: u16) u8 {
        return switch (address) {
            0xFF00 => self.joypad.toByte(),
            0xFF01...0xFF02 => 0, // TODO: Serial transfer,
            0xFF04 => self.divider.value,
            0xFF05 => self.timer.value,
            0xFF06 => self.timer.modulo,
            0xFF07 => self.timer.timerControl.toByte(),
            0xFF0F => self.interrupt_request.toByte(),
            0xFF40 => self.ppu.lcd_control.toByte(),
            0xFF41 => self.ppu.lcd_status.toByte(),
            0xFF42 => 0, // TODO: y offset,
            0xFF44 => 0, // TODO: line,
            else => std.debug.panic("Unsuported address 0x{X}", .{address}),
        };
    }

    pub fn writeByte(self: *MemoryBus, address: u16, byte: u8) void {
        switch (address) {
            addr.ROM_BANK_0_BEGIN...addr.ROM_BANK_0_END => self.rom_bank_0[address] = byte,
            addr.VRAM_BEGIN...addr.VRAM_END => self.ppu.vram[address - addr.VRAM_BEGIN] = byte,
            addr.EXTERNAL_RAM_BEGIN...addr.EXTERNAL_RAM_END => self.external_ram[address - addr.EXTERNAL_RAM_BEGIN] = byte,
            addr.WORKING_RAM_BEGIN...addr.WORKING_RAM_END => self.working_ram[address - addr.WORKING_RAM_BEGIN] = byte,
            addr.OAM_BEGIN...addr.OAM_END => self.ppu.oam[address - addr.OAM_BEGIN] = byte,
            addr.IO_REGISTERS_BEGIN...addr.IO_REGISTERS_END => self.writeIORegister(address, byte),
            addr.UNUSED_BEGIN...addr.UNUSED_END => {},
            addr.ZERO_PAGE_BEGIN...addr.ZERO_PAGE_END => self.zero_page[address - addr.ZERO_PAGE_BEGIN] = byte,
            addr.INTERRUPT_ENABLE_REGISTER => self.interrupt_enable.putByte(byte),
            else => unreachable,
        }
    }

    fn writeIORegister(self: *MemoryBus, address: u16, byte: u8) void {
        switch (address) {
            0xFF00 => self.joypad.putByte(byte),
            0xFF01...0xFF02 => {}, // TODO: Serial transfer
            0xFF04 => self.divider.value = 0,
            0xFF05 => self.timer.value = 0,
            0xFF06 => self.timer.modulo = 0,
            0xFF07 => self.timer.timerControl.putByte(byte),
            0xFF0F => self.interrupt_request.putByte(byte),
            0xFF10...0xFF26 => {}, // TODO: Audio
            0xFF30...0xFF3F => {}, // TODO: Audio
            0xFF40 => self.ppu.lcd_control.putByte(byte),
            0xFF41 => self.ppu.lcd_status.putByte(byte),
            0xFF42 => {}, // TODO: y offset
            0xFF43 => {}, // TODO: x offset
            0xFF45 => {}, // TODO: line check
            0xFF46 => {}, // TODO: DMA transfer
            0xFF47 => {}, // TODO: BG Palette data,
            0xFF48 => {}, // TODO: Obj 0 palette
            0xFF49 => {}, // TODO: Obj 1 palette
            0xFF4A => {}, // TODO: Scroll y
            0xFF4B => {}, // TODO: Scroll x
            0xFF50 => self.boot_rom = null,
            0xFF7F => {}, // Does nothing
            else => std.debug.panic("Unsuported address 0x{X}", .{address}),
        }
    }
};
