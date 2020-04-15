/*
 -- ============================================================================
 -- FILE	 : id_reg.v
 -- SYNOPSIS : ID stage pipeline register
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
`include "isa.h"
`include "cpu.h"

/***** Modules *****/
module id_reg (
    /***** Clock & Reset *****/
    input  wire                 clk,            //  Clock
    input  wire                 reset,          //  Asynchronous Reset

    /***** Decoding result *****/
    input  wire [`AluOpBus]     alu_op,         //  ALU Operation
    input  wire [`WordDataBus]  alu_in_0,       //  ALU Input 0
    input  wire [`WordDataBus]  alu_in_1,       //  ALU Input 1
    input  wire                 br_flag,        //  Branch Flag
    input  wire [`MemOpBus]     mem_op,         //  Memory operation
    input  wire [`WordDataBus]  mem_wr_data,    //  Memory write data
    input  wire [`CtrlOpBus]    ctrl_op,        //  Control Operation
    input  wire [`RegAddrBus]   dst_addr,       //  General purpose register write address
    input  wire                 gpr_we_,        //  General purpose register write enabled
    input  wire [`IsaExpBus]    exp_code,       //  Exception Code

    /***** Pipeline Control signal *****/
    input  wire                 stall,          //  Stall
    input  wire                 flush,          //  Flush

    /***** IF / ID pipeline register *****/
    input  wire [`WordAddrBus]  if_pc,          //  Program counter
    input  wire                 if_en,          //  Validate Pipeline data

    /***** ID / EX Pipeline register *****/
    output reg [`WordDataBus]   id_pc,          //  Program counter
    output reg                  id_en,          //  Validate Pipeline data
    output reg [`AluOpBus]      id_alu_op,      //  ALU Operation
    output reg [`WordDataBus]   id_alu_in_0,    //  ALU Input 0
    output reg [`WordDataBus]   id_alu_in_1,    //  ALU Input 1
    output reg                  id_br_flag,     //  Branch Flag
    output reg [`MemOpBus]      id_mem_op,      //  Memory Operation
    output reg [`WordDataBus]   id_mem_wr_data, //  Memory Write data
    output reg [`CtrlOpBus]     id_ctrl_op,     //  Control Operation
    output reg [`RegAddrBus]    id_dst_addr,    //  General purpose register write address
    output reg                  id_gpr_we_,     //  General purpose register write enabled
    output reg [`IsaExpBus]     id_exp_code     //  Exception Code
);

    /***** Pipeline Register *****/
    always @(posedge clk or `RESET_EDGE reset) begin 
        if (reset == `RESET_ENABLE) begin 
            /* Asynchronous Reset */
            id_pc           <= #1 `WORD_ADDR_W'h0;
            id_en           <= #1 `DISABLE;
            id_alu_op       <= #1 `ALU_OP_NOP;
            id_alu_in_0     <= #1 `WORD_DATA_W'h0;
            id_alu_in_1     <= #1 `WORD_DATA_W'h0;
            id_br_flag      <= #1 `DISABLE;
            id_mem_op       <= #1 `MEM_OP_NOP;
            id_mem_wr_data  <= #1 `WORD_DATA_W'h0;
            id_ctrl_op      <= #1 `CTRL_OP_NOP;
            id_dst_addr     <= #1 `REG_ADDR_W'd0;
            id_gpr_we_      <= #1 `DISABLE_;
            id_exp_code     <= #1 `ISA_EXP_NO_EXP;
        end else begin 
            /* Update pipeline register */
            if (stall == `DISABLE) begin 
                if (flush == `ENABLE) begin     //  Flush
                    id_pc           <= #1 `WORD_ADDR_W'h0;
                    id_en           <= #1 `DISABLE;
                    id_alu_op       <= #1 `ALU_OP_NOP;
                    id_alu_in_0     <= #1 `WORD_DATA_W'h0;
                    id_alu_in_1     <= #1 `WORD_DATA_W'h0;
                    id_br_flag      <= #1 `DISABLE;
                    id_mem_op       <= #1 `MEM_OP_NOP;
                    id_mem_wr_data  <= #1 `WORD_DATA_W'h0;
                    id_ctrl_op      <= #1 `CTRL_OP_NOP;
                    id_dst_addr     <= #1 `REG_ADDR_W'd0;
                    id_gpr_we_      <= #1 `DISABLE_;
                    id_exp_code     <= #1 `ISA_EXP_NO_EXP;
                end else begin                  //  Next Data
                    id_pc           <= #1 if_pc;
                    id_en           <= #1 if_en;
                    id_alu_op       <= #1 alu_op;
                    id_alu_in_0     <= #1 alu_in_0;
                    id_alu_in_1     <= #1 alu_in_1;
                    id_br_flag      <= #1 br_flag;
                    id_mem_op       <= #1 mem_op;
                    id_mem_wr_data  <= #1 mem_wr_data;
                    id_ctrl_op      <= #1 ctrl_op;
                    id_dst_addr     <= #1 dst_addr;
                    id_gpr_we_      <= #1 gpr_we_;
                    id_exp_code     <= #1 exp_code;
                end
            end
        end
    end

endmodule
    