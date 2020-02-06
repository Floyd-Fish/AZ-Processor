/*
 -- ============================================================================
 -- FILE	 : spm.h
 -- SYNOPSIS : Scratchpad memory Header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.6   Floyd-Fish
 -- ============================================================================
*/

`ifndef __SPM_HEADER__
    `define __SPM_HEADER__  //  Include guard

/*
 *  [About SPM size]
 * To change the SPM size,
 * Change SPM_SIZE, SPM_DEPTH, SPM_ADDR_W,
 * SpmAddrBus, SpmAddrLoc.
 * 
 * SPM_SIZE defines the size of SPM.
 * SPM_DEPTH defines the SPM depth.
 * Since the width of SPM is basically fixed at 32Bit(4 Byte),
 * SPM_DEPTH is the value of SPM_SIZE divided by 4.
 * SPM_ADDR_W defines the address width of SPM.
 * SPM_DEPTH is log2 value.
 * SpmAddrBus and SpmAddrLoc are SPM_ADDR_W buses.
 * SPM_ADDR_W is set to 1:0.
 * 
 * [Example of SPM Size]
 * if the SPM size is 16384 Byte (16KB)
 * SPM_DEPTH is 4096 (16384 / 4)
 * SPM_ADDR_W is 12 (log2(4096))
 */ 

    `define SPM_SIZE        16384   //  SPM size
    `define SPM_DEPTH       4096    //  SPM depth
    `define SPM_ADDR_W      12      //  SPM Addr
    `define SpmAddrBus      11:0    //  Address Bus
    `define SpmAddrLoc      11:0    //  Address Location

`endif
