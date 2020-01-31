/*
 -- ============================================================================
 -- FILE	 : bus.h
 -- SYNOPSIS : Bus Header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.1.31   Floyd-Fish
 -- ============================================================================
*/
`ifndef __BUS_HEADER__
    `define __BUS_HEADER__

    `define BUS_MASTER_CH           4
    `define BUS_MASTER_IDNEX_W      2


    `define BusOwnerBus             1:0
    `define BUS_OWNER_MASTER_0      2'h0
    `define BUS_OWNER_MASTER_1      2'h1
    `define BUS_OWNER_MASTER_2      2'h2
    `define BUS_OWNER_MASTER_3      2'h3


    `define BUS_SLAVE_CH            8
    `define BUS_SLAVE_IDNEX_N       3
    `define BusSlaveIndexBus        2:0
    `define BusSLaveIndexLoc        29:27


    `define BUS_SLAVE_0             0
    `define BUS_SLAVE_1             1
    `define BUS_SLAVE_2             2
    `define BUS_SLAVE_3             3
    `define BUS_SLAVE_4             4
    `define BUS_SLAVE_5             5
    `define BUS_SLAVE_6             6
    `define BUS_SLAVE_7             7

`endif
