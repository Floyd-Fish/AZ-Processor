/*
 -- ============================================================================
 -- FILE	 : if_reg.v
 -- SYNOPSIS : IF stage pipeline register
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.4.22   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "isa.h"
`include "cpu.h"

/***** Modules *****/
module if_reg (
    /***** Clock & Reset *****/
    input  wire                 clk,        //  Clock
    input  wire                 reset,      //  Asynchronous reset 

    /***** Fetch data *****/
    input  wire [`WordDataBus]  insn,       //  Fetched Instruction

    /***** Pipeline control signal *****/
    input  wire                 stall,      //  Stall
    input  wire                 flush,      //  Flush
    input  wire [`WordAddrBus]  new_pc,     //  New program counter
    input  wire                 br_taken,   //  Branch establishment
    input  wire [`WordAddrBus]  br_addr,    //  Branch destination Address

    /***** IF / ID pipeline register *****/
    output reg  [`WordAddrBus]  if_pc,      //  Program counter
    output reg  [`WordAddrBus]  if_insn,    //  Instruction
    output reg                  if_en       //  Validate pipeline data
);

    /***** Pipeline register *****/
    always @(posedge clk or `RESET_EDGE reset) begin 
        if (reset == `RESET_ENABLE) begin 
            /* Asynchronous reset */
            if_pc   <= #1 `RESET_VECTOR;
            if_insn <= #1 `ISA_NOP;
            if_en`  <= #1 `DISABLE;
        end else begin 
            /* Update pipeline register */
            if (stall == `DISABLE) begin 
                if (flush == `ENABLE) begin             //  Flush
                    if_pc   <= #1 new_pc;
                    if_insn <= #1 `ISA_NOP;
                    if_en   <= #1 `DISABLE;
                end else if (br_taken == `ENABLE) begin //  Branch establishment
                    if_pc   <= #1 br_addr;
                    if_insn <= #1 insn; 
                    if_en   <= #1 `ENABLE;
                end else begin 
                    if_pc   <= #1 if_pc + 1'd1;
                    if_insn <= #1 insn;
                    if_en   <= #1 `ENABLE;
                end
            end
        end
    end

endmodule
