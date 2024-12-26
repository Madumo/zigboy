pub const BOOT_ROM_BEGIN: u16 = 0x00;
pub const BOOT_ROM_END: u16 = 0xFF;
pub const BOOT_ROM_SIZE: u16 = BOOT_ROM_END - BOOT_ROM_BEGIN + 1;

pub const ROM_BANK_0_BEGIN: u16 = 0x0000;
pub const ROM_BANK_0_END: u16 = 0x3FFF;
pub const ROM_BANK_0_SIZE: u16 = ROM_BANK_0_END - ROM_BANK_0_BEGIN + 1;

pub const ROM_BANK_N_BEGIN: u16 = 0x4000;
pub const ROM_BANK_N_END: u16 = 0x7FFF;
pub const ROM_BANK_N_SIZE: u16 = ROM_BANK_N_END - ROM_BANK_N_BEGIN + 1;

pub const VRAM_BEGIN: u16 = 0x8000;
pub const VRAM_END: u16 = 0x9FFF;
pub const VRAM_SIZE: u16 = VRAM_END - VRAM_BEGIN + 1;

pub const EXTERNAL_RAM_BEGIN: u16 = 0xA000;
pub const EXTERNAL_RAM_END: u16 = 0xBFFF;
pub const EXTERNAL_RAM_SIZE: u16 = EXTERNAL_RAM_END - EXTERNAL_RAM_BEGIN + 1;

pub const WORKING_RAM_BEGIN: u16 = 0xC000;
pub const WORKING_RAM_END: u16 = 0xDFFF;
pub const WORKING_RAM_SIZE: u16 = WORKING_RAM_END - WORKING_RAM_BEGIN + 1;

pub const ECHO_RAM_BEGIN: u16 = 0xE000;
pub const ECHO_RAM_END: u16 = 0xFDFF;

pub const OAM_BEGIN: u16 = 0xFE00;
pub const OAM_END: u16 = 0xFE9F;
pub const OAM_SIZE: u16 = OAM_END - OAM_BEGIN + 1;

pub const UNUSED_BEGIN: u16 = 0xFEA0;
pub const UNUSED_END: u16 = 0xFEFF;

pub const IO_REGISTERS_BEGIN: u16 = 0xFF00;
pub const IO_REGISTERS_END: u16 = 0xFF7F;

pub const ZERO_PAGE_BEGIN: u16 = 0xFF80;
pub const ZERO_PAGE_END: u16 = 0xFFFE;
pub const ZERO_PAGE_SIZE: u16 = ZERO_PAGE_END - ZERO_PAGE_BEGIN + 1;

pub const INTERRUPT_ENABLE_REGISTER: u16 = 0xFFFF;

pub const InterruptLocation = enum(u16) {
    VBlank = 0x40,
    LCDStat = 0x48,
    Timer = 0x50,
};
