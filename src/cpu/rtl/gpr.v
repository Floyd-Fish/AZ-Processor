/*
 -- ============================================================================
 -- FILE	 : gpr.v
 -- SYNOPSIS : General-purpose Register
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.4.15   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "cpu.h"

/***** Modules *****/
module gpr (
    /***** Clock & Reset *****/
    input  wire                 clk,            //  Clock
    input  wire                 reset,          //  Asynchronous reset

    /***** Read Port 0 *****/
    input  wire [`RegAddrBus]   rd_addr_0,      //  Read Address
    output wire [`WordDataBus]  rd_data_0,      //  Read data

    /***** Read Port 1 *****/
    input  wire [`RegAddrBus]   rd_addr_1,      //  Read Address
    output wire [`WordDataBus]  rd_data_1,      //  Read data

    /***** Writing Port *****/
    input  wire                 we_,            //  Write Enable
    input  wire [`RegAddrBus]   wr_addr,        //  Write Address
    input  wire [`WordDataBus]  wr_data,        //  Write data
);

    /***** Internal Signals ****/
    reg [`WordDataBus]          gpr [`REG_NUM-1:0]; //  Register array
    integer                     i;                  //  Iterator

    /***** Read Access (Write After Read) *****/
    //  Read port 0
    assign rd_data_0 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_0)) ?
                        wr_data : gpr[rd_addr_0];

    //  Read port 1
    assign rd_data_1 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_1)) ?
                        wr_data : gpr[rd_addr_1];

    /***** Write Access *****/
    always @ (posedge clk or `RESET_EDGE reset) begin 
        if (reset == `RESET_ENABLE) begin 
            /* Asynchronous Reset */
            for (i = 0; i < `REG_NUM; i = i + 1) begin 
                gpr[i]          <= #1 `WORD_DATA_W'h0;
            end
        end else begin 
            /* Write access */
            if (we_ == `ENABLE_) begin 
                gpr[wr_addr] <= #1 wr_data;
            end
        end
    end

endmodule
