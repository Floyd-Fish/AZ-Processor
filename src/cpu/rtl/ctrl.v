/*
 -- ============================================================================
 -- FILE	 : cpu.v
 -- SYNOPSIS : CPU top module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.13   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "isa.h"
`include "cpu.h"
`include "rom.h"
`include "spm.h"

/***** Modules *****/
module ctrl (
    /***** Clock & Reset *****/
    input  wire                 clk,            //  Clock
    input  wire                 reset,          //  Asynchrnous reset 

    /***** Control Register Interface *****/
    input  wire [`RegAddrBus]       creg_rd_addr,   //  Read Address
    output reg  [`WordDataBus]      creg_rd_data,   //  Read data
    output reg  [`CpuExeModeBus]    exe_mode,       //  Execution mode

    /***** Interrupt *****/
    input  wire [`CPU_IRQ_CH-1:0]   irq,            //  Interrupt Request
    output reg                      int_detect,     //  Interrupt Detection

    /***** ID / EX Pipeline register *****/
    input  wire [`WordAddrBus]      id_pc,          //  Program counter

    /***** MEM / WB Pipeline register *****/
    input  wire [`WordAddrBus]      mem_pc,         //  Program counter
    input  wire                     mem_en,         //  Validate pipelien data
    input  wire                     mem_br_flag,    //  Branch flag
    input  wire [`CtrlOpBus]        mem_ctrl_op,    //  Control register operation
    input  wire [`RegAddrBus]       mem_dst_addr,   //  Write address
    input  wire [`IsaExpBus]        mem_exp_code,   //  Exception code
    input  wire [`WordDataBus]      mem_out,        //  Processing result

    /***** Pipeline control signal *****/
    //  Pipeline status
    input  wire                     if_busy,        //  IF busy signal
    input  wire                     ld_hazard,      //  Road hazard
    input  wire                     mem_busy,       //  MEM busy signal
    //  Stall signal
    output wire                     if_stall,       //  IF stage Stall signal  
    output wire                     id_stall,       //  ID stage Stall signal  
    output wire                     ex_stall,       //  EX stage Stall signal
    output wire                     mem_stall,      //  MEM stage Stall signal
    //  Flush signal 
    output wire                     if_flush,       //  IF stage flush
    output wire                     id_flush,       //  ID stage flush
    output wire                     ex_flush,       //  EX stage flush
    output wire                     mem_flush,      //  MEM stage flush
    output reg  [`WordAddrBus]      new_pc          //  New Program counter
);

    /***** Control Register *****/
    reg                             int_en;         //  0: Interrupt enabled
    reg  [`CpuExeModeBus]           pre_exe_mode;   //  1: Execution Mode
    reg                             pre_int_en;     //  1: Interrupt enabled
    reg  [`WordAddrBus]             epc;            //  3: Exception Program counter
    reg  [`WordAddrBus]             exp_vector;     //  4: Exception vector
    reg  [`IsaExpBus]               exp_code;       //  5: Exception Code
    reg                             dly_flag;       //  6: delay slot flag
    reg  [`CPU_IRQ_CH - 1 : 0]      mask;           //  7: Interrupt mask

    /***** Internal signals *****/
    reg  [`WordAddrBus]             pre_pc;         //  Previous program counter
    reg                             br_flag;        //  Branch flag

    /***** Pipeline register *****/
    //  Stall signal
    wire   stall        = if_busy | mem_busy;
    assign if_stall     = stall | ld_hazard;
    assign id_stall     = stall;
    assign ex_stall     = stall;
    assign mem_stall    = stall;
    //  Flush signal
    reg    flush;
    assign if_flush     = flush;
    assign id_flush     = flush | ld_hazard;
    assign ex_flush     = flush;
    assign mem_flush    = flush;

    /***** Pipeline flush control *****/
    always @(*) begin
        /* Default Value */
        new_pc = `WORD_ADDR_W'h0;
        flush  = `DISABLE;
        /* Pipeline flush */
        if (mem_en == `ENABLE) begin // Pipeline data is validated
            if (mem_exp_code != `ISA_EXP_NO_EXP) begin          //  Exception occurred
                new_pc = exp_vector;
                flush  = `ENABLE;
            end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin    //  EXRT Command
                new_pc = epc;
                flush  = `ENABLE;
            end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin    //  WRCR Command
                new_pc = mem_pc;
                flush  = `ENABLE;
            end
        end
    end

    /***** Interrupt detection *****/
    



    

