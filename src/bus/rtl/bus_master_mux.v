/*
 -- ============================================================================
 -- FILE	 : bus_master_mux.v
 -- SYNOPSIS : Bus Master Multiplexer
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

/***** Module *****/
module bus_master_mux (
    /***** Bus Master Signal *****/
    //  Bus Master 0
    input wire [`WordAddrBus] m0_addr,     //   Address 
    input wire                m0_as_,      //   Address Strobe
    input wire                m0_rw,       //   Read / Write
    input wire [`WordAddrBus] m0_wr_data,  //   Write data(s)
    input wire                m0_grnt_,    //   Bus Grant

    //  Bus Master 1
    input wire [`WordAddrBus] m1_addr,     //   Address 
    input wire                m1_as_,      //   Address Strobe
    input wire                m1_rw,       //   Read / Write
    input wire [`WordAddrBus] m1_wr_data,  //   Write data(s)
    input wire                m1_grnt_,    //   Bus Grant

    //  Bus Master 2
    input wire [`WordAddrBus] m2_addr,     //   Address 
    input wire                m2_as_,      //   Address Strobe
    input wire                m2_rw,       //   Read / Write
    input wire [`WordAddrBus] m2_wr_data,  //   Write data(s)
    input wire                m2_grnt_,    //   Bus Grant

    //  Bus Master 3
    input wire [`WordAddrBus] m3_addr,     //   Address 
    input wire                m3_as_,      //   Address Strobe
    input wire                m3_rw,       //   Read / Write
    input wire [`WordAddrBus] m3_wr_data,  //   Write data(s)
    input wire                m3_grnt_,    //   Bus Grant

    /***** Bus slave Common signals *****/
    output reg [`WordAddrBus] s_addr,      //   Address
    output reg                s_as_,       //   Address Strobe
    output reg                s_rw,        //   Read / Write
    output reg [`WordAddrBus] s_wr_data    //   Write data(s)
);

    /***** Bus Master Multiplexer *****/
    always @(*) begin
        /***** Select Master which has the Bus Right *****/
        if (m0_grnt_ == `ENABLE_) begin             //  Bus Master 0
            s_addr      = m0_addr;
            s_as_       = m0_as_;
            s_rw        = m0_rw;
            s_wr_data   = m0_wr_data;
        end else if (m1_grnt_ == `ENABLE_) begin    //  Bus Master 1
            s_addr      = m1_addr;
            s_as_       = m1_as_;
            s_rw        = m1_rw;
            s_wr_data   = m1_wr_data;
        end else if (m2_grnt_ == `ENABLE_) begin    //  Bus Master 2
            s_addr      = m2_addr;
            s_as_       = m2_as_;
            s_rw        = m2_rw;
            s_wr_data   = m2_wr_data;
        end else if (m3_grnt_ == `ENABLE_) begin    //  Bus Master 3
            s_addr      = m3_addr;
            s_as_       = m3_as_;
            s_rw        = m3_rw;
            s_wr_data   = m3_wr_data;
        end else begin                              //  Default Value
            s_addr      = `WORD_ADDR_W'h0;
            s_as_       = `DISABLE_;
            s_rw        = `READ;
            s_wr_data   = `WORD_DATA_W'h0;
        end
    end

endmodule
