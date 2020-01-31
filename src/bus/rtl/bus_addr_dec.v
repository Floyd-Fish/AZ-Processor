/*
 -- ============================================================================
 -- FILE	 : bus_addr_dec.v
 -- SYNOPSIS : Bus Address Decoder
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.1.31   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "bus.h"

/***** Modules *****/
module bus_addr_dec (
    /***** Address *****/
    input wire [`WordAddrBus] s_addr,       //  Address
    /***** Chip Select Signals *****/
    output reg                s0_cs_,       //  Bus Slave 0
    output reg                s1_cs_,       //  Bus Slave 1
    output reg                s2_cs_,       //  Bus Slave 2
    output reg                s3_cs_,       //  Bus Slave 3
    output reg                s4_cs_,       //  Bus Slave 4
    output reg                s5_cs_,       //  Bus Slave 5
    output reg                s6_cs_,       //  Bus Slave 6
    output reg                s7_cs_       //  Bus Slave 7
);

    /***** Bus Slave Index *****/
    wire [`BusSlaveIndexBus] s_index = s_addr [`BusSlaveIndexLoc];

    /***** Bus Slave Multiplexer *****/
    always @(*) begin 
        /***** Initialize Chip Select *****/
        s0_cs_ = `DISABLE_;
        s1_cs_ = `DISABLE_;
        s2_cs_ = `DISABLE_;
        s3_cs_ = `DISABLE_;
        s4_cs_ = `DISABLE_;
        s5_cs_ = `DISABLE_;
        s6_cs_ = `DISABLE_;
        s7_cs_ = `DISABLE_;
        /***** Select Slave Corresponded to Address *****/
        case (s_index)
            `BUS_SLAVE_0 : begin        //  Bus Slave 0
                s0_cs   = `ENABLE_;
            end
            `BUS_SLAVE_1 : begin        //  Bus Slave 1
                s1_cs   = `ENABLE_;
            end
            `BUS_SLAVE_2 : begin        //  Bus Slave 2
                s2_cs   = `ENABLE_;
            end
            `BUS_SLAVE_3 : begin        //  Bus Slave 3
                s3_cs   = `ENABLE_;
            end
            `BUS_SLAVE_4 : begin        //  Bus Slave 4
                s4_cs   = `ENABLE_;
            end
            `BUS_SLAVE_5 : begin        //  Bus Slave 5
                s5_cs   = `ENABLE_;
            end
            `BUS_SLAVE_6 : begin        //  Bus Slave 6
                s6_cs   = `ENABLE_;
            end
            `BUS_SLAVE_7 : begin        //  Bus Slave 7
                s7_cs   = `ENABLE_;
            end
        endcase
    end

endmodule
