/*
 -- ============================================================================
 -- FILE	 : rom.v
 -- SYNOPSIS : Read Only Memory
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.1   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "rom.h"

/***** Modules *****/
module rom (
    /***** Clock & Reset *****/
    input  wire                  clk,     //  Clock
    input  wire                  reset,   //  Asynchronous Reset
 
    /***** Bus Interface *****/ 
    input  wire                  cs_,     //  Chip Select
    input  wire                  as_,     //  Address Strobe
    input  wire [`RomAddrBus]    addr,    //  Address
    output wire [`WordDataBus]   rd_data, //  Read-out data
    output reg                   rdy_     //  Ready
);

    /***** Xilinx FPGA Block RAM : Single Port ROM *****/
    x_s3e_sprom x_s3e_sprom (
        .clka   (clk),          //  Clock
        .addra  (addr),         //  Address
        .douta  (rd_data)       //  Read-out data
    );

    /***** Ready Signal Generation *****/
    always @(posedge clk or `RESET_EDGE reset) begin
        if (reset == `RESET_ENABLE) begin
            /* Asynchronous Reset */
            rdy_ <= #1 `DISABLE_;
        end else begin
            /* Ready Signal Generation */
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
                rdy_ <= #1 `ENABLE_;
            end else begin
                rdy_ <= #1 `DISABLE_;
            end
        end
    end

endmodule
