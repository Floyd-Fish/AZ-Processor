/*
 -- ============================================================================
 -- FILE	 : id_state.v
 -- SYNOPSIS : ID stage
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
module id_stage (
    /***** Clock & Reset *****/
    input  wire                     clk,    //  Clock
    input  wire                     reset,  //  Asynchronous Reset

    /***** GPR Interface *****/
    input  wire [`WordDataBus]  gpr_rd_data_0,  //  Read data 0
    input  wire [`WordDataBus]  gpr_rd_data_1,  //  Read data 1
    output wire [`RegAddrBus]   gpr_rd_addr_0,  //  Read Address 0
    output wire [`RedAddrBus]   gpr_rd_addr_1,  //  Read Address 1

    /***** Forwarding *****/
    //  Forwarding from EX stage
    input  wire                 ex_en,          //  Validate pipeline data
    input  wire [`WordDataBus]  ex_fwd_data,    //  Forwarding data
    input  wire [`RegAddrBus]   ex_dst_addr,    //  Write address
    input  wire                 ex_gpr_we_,     //  Write enable

    //  Forwarding from MEM stage
    input  wire [`WordDataBus]  mem_fwd_data,   //  Forwarding data

    /***** Control Register Interface *****/
    input  wire [`CpuExeModeBus]    exe_mode,   //  Run Mode
    input  wire [`WordDataBus]  creg_rd_data,   //  Read data
    input  wire [`RegAddrBus]   creg_rd_addr,   //  Read address

    /***** Pipeline control signal *****/
    input  wire                 stall,          //  Stall
    input  wire                 flush,          //  Flush
    output wire [`WordAddrBus]  br_addr,        //  Branch Address
    output wire                 br_taken,       //  Branch taken
    output wire                 ld_hazard,      //  Hazard

    /***** IF / ID pipeline register *****/
    input  wire [`WordAddrBus]  if_pc,          //  Program Counter
    input  wire [`WordDataBus]  if_insn,        //  Instruction
    input  wire                 if_en,          //  Validate pipeline data

    /***** ID / EX pipeline register *****/
    output wire [`WordDataBus]  id_pc,          //  Program counter
    output wire                 id_en,          //  Validate pipeline data
    output wire [`AluOpBus]     id_alu_op,      //  ALU Operation
    output wire [`WordDataBus]  id_alu_in_0,    //  ALU input 0
    output wire [`WordDataBus]  id_alu_in_1,    //  ALU input 1
    output wire                 id_br_flag,     //  Branch flag
    output wire [`MemOpBus]     id_mem_op,      //  Memory Operation
    output wire [`WordAddrBus]  id_mem_wr_data, //  Memory write data
    output wire [`CtrlOpBus]    id_ctrl_op,     //  Control Operation
    output wire [`RegAddrBus]   id_dst_addr,    //  GPR write address
    output wire                 id_gpr_we_,     //  GPR write enabled
    output wire [`IsaExpBus]    id_exp_code,    //  Exception code
);

    /***** Decode Signal *****/
    wire  [`AluOpBus]           alu_op;         //  ALU operation
    wire  [`WordDataBus]        alu_in_0;       //  ALU input 0
    wire  [`WordDataBus]        alu_in_1;       //  ALU input 1
    wire                        br_flag;        //  Branch flag
    wire  [`MemOpBus]           mem_op;         //  Memory operation
    wire  [`WordDataBus]        mem_wr_data;    //  Memory write data
    wire  [`CtrlOpBus]          ctrl_op;        //  Control Operation
    wire  [`RedAddrBus]         dst_addr;       //  GPR write address
    wire                        gpr_we_;        //  GPR write enabled
    wire  [`IsaExpBus]          exp_code;       //  Exception Code

    /***** Decoder *****/
    decoder decoder (
        /***** IF / ID pipeline register *****/
        .if_pc          (if_pc),                //  Program counter
        .if_insn        (if_insn),              //  Instruction
        .if_en          (if_en),                //  Validate pipeline data

        /***** GPR Interface *****/
        .gpr_rd_data_0  (gpr_rd_data_0),        //  Read data 0
        .gpr_rd_data_1  (gpr_rd_data_1),        //  Read data 1
        .gpr_rd_addr_0  (gpr_rd_addr_0),        //  Read address 0
        .gpr_rd_addr_1  (gpr_rd_addr_1),        //  Read address 1

        /***** Forwarding *****/
        //  Forwarding from ID stage 
        .id_en          (id_en),                //  Validate piepline data
        .id_dst_addr    (id_dst_addr),          //  Write address
        .id_gpr_we_     (id_gpr_we_),           //  Write enable
        .id_mem_op      (id_mem_op),            //  Memory operation

        //  Forwarding from EX stage 
        .ex_en          (ex_en),                //  Validate pipeline data
        .ex_fwd_data    (ex_fwd_data),          //  Forwarding data
        .ex_dst_addr    (ex_dst_addr),          //  Write address
        .ex_gpr_we_     (ex_gpr_we_),           //  Write enable

        //  Forwarding from MEM stage
        .mem_fwd_data   (mem_fwd_data),         //  Forwarding data

        /***** Control register interface *****/
        .exe_mode       (exe_mode),             //  Run Mode
        .creg_rd_data   (creg_rd_data),         //  Read data
        .creg_rd_addr   (creg_rd_addr),         //  Read address

        /***** Decode signal *****/
        .alu_op         (alu_op),               //  ALU operation
        .alu_in_0       (alu_in_0),             //  ALU input 0
        .alu_in_1       (alu_in_1),             //  ALU input 1
        .br_addr        (br_addr),              //  Branch Address
        .br_taken       (br_taken),             //  Branch establishment
        .br_flag        (br_flag),              //  Branch flag
        .mem_op         (mem_op),               //  Memory operation
        .mem_wr_data    (mem_wr_data),          //  Memory write data
        .ctrl_op        (ctrl_op),              //  Control Operation
        .dst_addr       (dst_addr),             //  General register write address
        .gpr_we_        (gpr_we_),              //  General purpose register write enable
        .exp_code       (exp_code),             //  Exception code
        .ld_hazard      (ld_hazard)             //  Hazard
    );

    /***** Pipeline register *****/
    id_reg id_reg (
        /***** Clock & Reset *****/
        .clk                (clk),              //  Clock
        .reset              (reset),            //  Asynchronous reset 

        /***** Decoding result *****/
        .alu_op             (alu_op),           //  ALU Operation
        .alu_in_0           (alu_in_0),         //  ALU input 0
        .alu_in_1           (alu_in_1),         //  ALU input 1
        .br_flag            (br_flag),          //  Branch flag
        .mem_op             (mem_op),           //  Memory Operation
        .mem_wr_data        (mem_wr_data),      //  Memory write data
        .ctrl_op            (ctrl_op),          //  Control Operation
        .dst_addr           (dst_addr),         //  General register write address
        .gpr_we_            (gpr_we_),          //  General purpose register write enable
        .exp_code           (exp_code),         //  Exception Code

        /***** Pipeline control signal *****/
        .stall              (stall),            //  Stall
        .flush              (flush),            //  Flush

        /***** IF / ID Pipeline control signal *****/
        .if_pc              (if_pc),            //  Program counter
        .if_en              (if_en),            //  Validate pipeline data

        /***** ID / EX Pipeline control signal *****/
        .id_pc              (id_pc),            //  Program counter
        .id_en              (id_en),            //  Validate pipeline data
        .id_alu_op          (id_alu_op),        //  ALU operation
        .id_alu_in_0        (id_alu_in_0),      //  ALU input 0
        .id_alu_in_1        (id_alu_in_1),      //  ALU input 1
        .id_br_flag         (id_br_flag),       //  Branch Flag
        .id_mem_op          (id_mem_op),        //  Memory operation
        .id_mem_wr_data     (id_mem_wr_data),   //  Memory write data
        .id_ctrl_op         (id_ctrl_op),       //  Control operation
        .id_dst_addr        (id_dst_addr),      //  General register write address
        .id_gpr_we_         (id_gpr_we_),       //  General purpose register write enable
        .id_exp_code        (id_exp_code)       //  Exception code       
    );

endmodule
