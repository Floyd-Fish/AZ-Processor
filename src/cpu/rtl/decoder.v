/*
 -- ============================================================================
 -- FILE	 : decoder.v
 -- SYNOPSIS : Instruction decoder
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.14   Floyd-Fish
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
module decoder (
    /***** IF / ID Pipeline register *****/
    input  wire [`WordAddrBus]      if_pc,          //  Program counter
    input  wire [`WordDataBus]      if_insn,        //  Command
    input  wire                     if_en,          //  Validate pipeline data

    /***** GPR Interface *****/
    input  wire [`WordDataBus]      gpr_rd_data_0,  //  Read data 0
    input  wire [`WordDataBus]      gpr_rd_data_1,  //  Read data 1
    output wire [`WordAddrBus]      gpr_rd_addr_0,  //  Read Addr 0
    output wire [`WordAddrBus]      gpr_rd_addr_1,  //  Read Addr 1

    /***** Forwarding *****/
    //  Forwarding from ID stage
    input  wire                     id_en,          //  Validate pipeline data
    input  wire [`RegAddrBus]       id_dst_addr,    //  Write address
    input  wire                     id_gpr_we_,     //  Write enabled
    input  wire [`MemOpBus]         id_mem_op,      //  Memory Operation

    //  Forwarding from EX stage 
    input  wire                     ex_en,          //  Validate pipeline data
    input  wire [`RegAddrBus]       ex_dst_addr,    //  Write address
    input  wire                     ex_gpr_we_,     //  Write enabled
    input  wire [`WordDataBus]      ex_fwd_data,    //  Forwarding data
    //  Forwarding from MEM stage 
    input  wire [`WordDataBus]      mem_fwd_data,   //  Forwarding data

    /***** Control register interface *****/
    input  wire [`CpuExeModeBus]    exe_mode,       //  Execution Mode
    input  wire [`WordDataBus]      creg_rd_data,   //  Read data
    output wire [`RegAddrBus]       creg_rd_addr,   //  Read address

    /***** Decoding result *****/
    output reg [`AluOpBus]          alu_op,         //  ALU operation
    output reg [`WordDataBus]       alu_in_0,       //  ALU input 0
    output reg [`WordDataBus]       alu_in_1,       //  ALU input 1
    output reg [`WordAddrBus]       br_addr,        //  Branch address
    output reg                      br_taken,       //  Branch taken
    output reg                      br_flag,        //  Branch flag
    output reg [`MemOpBus]          mem_op,         //  Memory Operation
    output reg [`WordDataBus]       mem_wr_data,    //  Memory write data
    output reg [`CtrlOpBus]         ctrl_op,        //  Control operation
    output reg [`RegAddrBus]        dst_addr,       //  General register write address
    output reg                      gpr_we_,        //  General register write enabled
    output reg [`IsaExpBus]         exp_code,       //  Exception code
    output reg                      ld_hazard       //  Road hazard
);


