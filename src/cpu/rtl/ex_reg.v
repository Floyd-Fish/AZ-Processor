/*
 -- ============================================================================
 -- FILE	 : ex_reg.v
 -- SYNOPSIS : EX stage pipeline register
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.16   Floyd-Fish
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
module ex_reg (
    /***** Clock & Reset *****/
    input  wire                 clk,        //  Clock
    input  wire                 reset,      //  Asynchronous reset 

    /***** ALU output *****/
    input  wire [`WordDataBus]  alu_out,    //  Calculation result
    input  wire                 alu_of,     //  ALU Overflow

    /***** Pipeline control signal *****/
    input  wire                 stall,      //  Stall
    input  wire                 flush,      //  Flush
    input  wire                 int_detect, //  Interrupt detection

    /***** ID /EX Pipeline register *****/
    input  wire [`WordAddrBus]  id_pc,          //  Program counter
    input  wire                 id_en,          //  Validate pipeline data
    input  wire                 id_br_flag,     //  Branch flag
    input  wire [`MemOpBus]     id_mem_op,      //  Memory operation
    input  wire [`WordDataBus]  id_mem_wr_data, //  Memory write data
    input  wire [`CtrlOpBus]    id_ctrl_op,     //  Control register operation
    input  wire [`RegAddrBus]   id_dst_addr,    //  General register write address
    input  wire                 id_gpr_we_,     //  General register write enabled
    input  wire [`IsaExpBus]    id_exp_code,    //  Exception code

    /***** EX / MEM pipeline register *****/
    output reg  [`WordAddrBus]  ex_pc,          //  Program counter
    output reg                  ex_en,          //  Validate pipeline data
    output reg                  ex_br_flag,     //  Branch flag
    output reg  [`MemOpBus]     ex_mem_op,      //  Memory operation
    output reg  [`WordDataBus]  ex_mem_wr_data, //  Memory write data
    output reg  [`CtrlOpBus]    ex_ctrl_op.     //  Control register operation
    output reg  [`RegAddrBus]   ex_dst_addr,    //  General register write address
    output reg                  ex_gpr_we_,     //  General register write enabled
    output reg  [`IsaExpBus]    ex_exp_code,    //  Exception code
    output reg  [`WordDataBus]  ex_out          //  Processing result
);

    /***** Pipeline Register *****/
    always @(posedge clk or `RESET_EDGE reset) begin
        /* Asynchronous Reset */
        if (reset == `RESET_ENABLE) begin 
            ex_pc           <= #1 `WORD_ADDR_W'h0;
            ex_en           <= #1 `DISABLE;
            ex_br_flag      <= #1 `DISABLE;
            ex_mem_op       <= #1 `MEM_OP_NOP;
            ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
            ex_ctrl_op      <= #1 `CTRL_OP_NOP;
            ex_dst_addr     <= #1 `REG_ADDR_W'd0;
            ex_gpr_we_      <= #1 `DISABLE;
            ex_exp_code     <= #1 `ISA_EXP_NO_EXP;
            ex_out          <= #1 `WORD_DATA_W'h0;
        end else begin 
            /* Update pipeline Register */
            if (stall == `DISABLE) begin 
                if (flush == `ENABLE) begin         //  Flush
                    ex_pc           <= #1 `WORD_ADDR_W'h0;
                    ex_en           <= #1 `DISABLE;
                    ex_br_flag      <= #1 `DISABLE;
                    ex_mem_op       <= #1 `MEM_OP_NOP;
                    ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    ex_ctrl_op      <= #1 `CTRL_OP_NOP;
                    ex_dst_addr     <= #1 `REG_ADDR_W'd0;
                    ex_gpr_we_      <= #1 `DISABLE_;
                    ex_exp_code     <= #1 `ISA_EXP_NO_EXP;
                    ex_out          <= #1 `WORD_DATA_W'h0;
                end else if (int_detect == `ENABLE) begin   //  Interrupt detection
                    ex_pc           <= #1 id_pc;
                    ex_en           <= #1 id_en;
                    ex_br_flag      <= #1 id_br_flag;
                    ex_mem_op       <= #1 `MEM_OP_NOP;
                    ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    ex_ctrl_op      <= #1 `CTRL_OP_NOP;
                    ex_dst_addr     <= #1 `REG_ADDR_W'd0;
                    ex_gpr_we_      <= #1 `DISABLE_;
                    ex_exp_code     <= #1 `ISA_EXP_EXT_INT;
                    ex_out          <= #1 `WORD_DATA_W'h0;
                end else if (alu_of == `ENABLE) begin       //  Arithmetic overflow
                    ex_pc           <= #1 id_pc;
                    ex_en           <= #1 id_en;
                    ex_br_flag      <= #1 id_br_flag;
                    ex_mem_op       <= #1 `MEM_OP_NOP;
                    ex_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    ex_ctrl_op      <= #1 `CTRL_OP_NOP;
                    ex_dst_addr     <= #1 `REG_ADDR_W'd0;
                    ex_gpr_we_      <= #1 `DISABLE_;
                    ex_exp_code     <= #1 `ISA_EXP_OVERFLOW;
                    ex_out          <= #1 `WORD_DATA_W'h0;
                end else begin                              //  Next data
                    ex_pc		   <= #1 id_pc;
					ex_en		   <= #1 id_en;
					ex_br_flag	   <= #1 id_br_flag;
					ex_mem_op	   <= #1 id_mem_op;
					ex_mem_wr_data <= #1 id_mem_wr_data;
					ex_ctrl_op	   <= #1 id_ctrl_op;
					ex_dst_addr	   <= #1 id_dst_addr;
					ex_gpr_we_	   <= #1 id_gpr_we_;
					ex_exp_code	   <= #1 id_exp_code;
					ex_out		   <= #1 alu_out;
                end
            end
        end
    end

endmodule
