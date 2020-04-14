/*
 -- ============================================================================
 -- FILE	 : ex_stage.v
 -- SYNOPSIS : EX stage
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.4.14   Floyd-Fish
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
module ex_stage (
    /***** Clock & Reset *****/
    input  wire                 clk,            //  Clock
    input  wire                 reset,          //  Asynchronous reset

    /***** Pipeline control signal *****/
    input  wire                 stall,          //  Stall
    input  wire                 flush,          //  Flush
    input  wire                 int_detect,     //  Interrupt detection

    /***** Forwarding *****/
    output wire [`WordDataBus]  fwd_data,       //  Forwarding data

    /***** ID / EX Pipeline register *****/
    input  wire [`WordAddrBus]  fwd_data,       //  Program counter
    input  wire                 id_en,          //  Validate Pipeline data
    input  wire [`AluOpBus]     id_alu_op,      //  ALU operation
    input  wire [`WordDataBus]  id_alu_in_0,    //  ALU Input 0
    input  wire [`WordDataBus]  id_alu_in_1,    //  ALU Input 1
    input  wire                 id_br_flag,     //  Branch Flag
    input  wire [`MemOpBus]     id_mem_op,      //  Memory Operation
    input  wire [`WordDataBus]  id_mem_wr_data, //  Memory Write data
    input  wire [`CtrlOpBus]    id_ctrl_op,     //  Control Register Operation
    input  wire [`RegAddrBus]   id_dst_addr,    //  General register write address
    input  wire                 id_gpr_we_,     //  General register write Enable
    input  wire [`IsaExpBus]    id_exp_code,    //  Exception code

    /***** EX / MEM Pipeline register *****/
    output wire [`WordAddrBus]  ex_pc,          //  Program counter
    output wire                 ex_en,          //  Validate pipeline data
    output wire                 ex_br_flag,     //  Branch Flag
    output wire [`MemOpBus]     ex_mem_op,      //  Memory Operation
    output wire [`WordDataBus]  ex_mem_wr_data, //  Memory Write data
    output wire [`CtrlOpBus]    ex_ctrl_op,     //  Control Register Operation
    output wire [`RegAddrBus]   ex_dst_addr,    //  General register write address
    output wire                 ex_gpr_we_,     //  General register write Enable
    output wire [`IsaExpBus]    ex_exp_code,    //  Exception code
    output wire [`WordDataBus]  ex_out,         //  Processing result
);

    /***** ALU Output *****/
    wire [`WordDataBus]         alu_out,        //  Calculation result
    wire                        alu_of,         //  ALU Overflow

    /***** Forwarding calculation results *****/
    assign fwd_data = alu_out;

    /***** ALU *****/
    alu alu(
        .in_0           (id_alu_in_0),  //  input 0
        .in_1           (id_alu_in_1),  //  input 1
        .op             (id_alu_op),    //  Operation
        .out            (alu_out),      //  Output
        .of             (alu_of),       //  Overflow
    )

    /***** Pipeline Register *****/
    ex_reg ex_reg (
        /***** Clock & Reset *****/
        .clk            (clk),          //  Clock
        .reset          (reset),        //  Asynchronous Reset

        /***** ALU Output *****/
        .alu_out        (alu_out),      //  Calculation result
        .alu_of         (alu_of),       //  ALU Overflow

        /***** Pipeline Control Signal *****/
        .stall          (stall),        //  Stall
        .flush          (flush),        //  Flush
        .int_detect     (int_detect),   //  Interrupt detection

        /***** ID / EX Pipeline Register *****/
        .id_pc          (id_pc),            //  Program counter
        .id_en          (id_en),            //  Validate pipeline data
        .id_br_flag     (id_br_flag),       //  Branch Flag
        .id_mem_op      (id_mem_op),        //  Memory Operation
        .id_mem_wr_data (id_mem_wr_data),   //  Memory write data
        .id_ctrl_op     (id_ctrl_op),       //  Control Register Operation
        .id_dst_addr    (id_dst_addr),      //  General register write address
        .id_gpr_we_     (id_gpr_we_),       //  General register write Enable
        .id_exp_code    (id_exp_code),      //  Exception code

        /***** EX / MEM Pipeline Register *****/
        .ex_pc          (ex_pc),            //  Program counter
        .ex_en          (ex_en),            //  Validate pipeline data
        .ex_br_flag     (ex_br_flag),       //  Branch Flag
        .ex_mem_op      (ex_mem_op),        //  Memory Operation
        .ex_mem_wr_data (ex_mem_wr_data),   //  Memory write data
        .ex_ctrl_op     (ex_ctrl_op),       //  Control Register Operation
        .ex_dst_addr    (ex_dst_addr),      //  General register write address
        .ex_gpr_we_     (ex_gpr_we_),       //  General register write Enable
        .ex_exp_code    (ex_exp_code),      //  Exception code
        .ex_out         (ex_out)            //  Processing Result
    );

endmodule
