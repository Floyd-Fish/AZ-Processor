/*
 -- ============================================================================
 -- FILE	 : rom.h
 -- SYNOPSIS : ROM Header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.1   Floyd-Fish
 -- ============================================================================
*/

`ifndef __ROM_HEADER__
    `define __ROM_HEADER__

/*
 *  [About ROM Size]
 *  >   To change the ROM size,
 *  Change ROM_SIZE, ROM_DEPTH, ROM_ADDR_W, RomAddrBus, RomAddrLoc.
 *  >   ROM_SIZE defines the size of the ROM
 *  >   ROM_DEPTH defines the depth of ROM
 *  >   Since the width of the ROM is basically fixed at 32 bits(4 bytes),
 *  ROM_DEPTH is the value obtained by dividing ROM_SIZE by 4.
 *  >    ROM_ADDR_W defines the address width of ROM,
 *  >   The log2 value of ROM_DEPTH.
 *  >   RomAddrBus and RomAddrLoc are ROM_ADDR_W buses.
 *  
 *  >   Set ROM_ADDR_W-1:0.
 * 
 *  [Example of ROM size]:
 *  if the ROM size is 8192 bytes (4KB)
 *  ROM_DEPTH is 8192 / 4 = 2048
 *  ROM_ADDR_W is 11 in log2(2048)
 * 
 */

    `define ROM_SIZE        8192        //  ROM size
    `define ROM_DEPTH       2048        //  ROM Depth
    `define ROM_ADDR_W      11          //  Address Width
    `define RomAddrBus      10:0        //  Address Bus
    `define RomAddrLoc      10:0        //  Address Location

`endif
