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

