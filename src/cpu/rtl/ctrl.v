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
    always @(*) begin 
        if ((int_en == `ENABLE) && ((|((~mask) & irq)) == `ENABLE)) begin
            int_detect = `ENABLE;
        end else begin 
            int_detect = `DISABLE;
        end
    end

    /***** Read access *****/
    always @(*) begin
        case (creg_rd_addr)
            `CREG_ADDR_STATUS       : begin     //  0: status
                creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, int_en, exe_mode};
            end
            `CREG_ADDR_PRE_STATUS   : begin     //  1: Status before Exception occurred
                creg_rd_data = {{`WORD_DATA_W-2{1'b0}},
                                    pre_int_en, pre_exe_mode};
            end
            `CREG_ADDR_PC           : begin     //  2: Program counter
                creg_rd_data = {id_pc, `BYTE_OFFSET_W'h0};
            end
            `CREG_ADDR_EPC          : begin     //  3: Exception program counter
                creg_rd_data = {epc, `BYTE_OFFSET_W'h0};
            end
            `CREG_ADDR_EXP_VECTOR   : begin     //  4: Exception vector
                creg_rd_data = {exp_vector, `BYTE_OFFSET_W'h0};
            end
            `CREG_ADDR_CAUSE        : begin     //  5: Cause of Exception
                creg_rd_data = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}},
                                    dly_flag, exp_code};
            end
            `CREG_ADDR_INT_MASK     : begin     //  6: Interrupt Mask
                creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, mask};
            end
            `CREG_ADDR_IRQ          : begin     //  6: Interrupt cause
                creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, irq};
            end
            `CREG_ADDR_ROM_SIZE     : begin     //  7: ROM size
                creg_rd_data = $unsigned(`ROM_SIZE);
            end
            `CREG_ADDR_SPM_SIZE     : begin     //  8: SPM size
                creg_rd_data = $unsigned(`SPM_SIZE);
            end
            `CREG_ADDR_CPU_INFO     : begin     //  9: CPU Info
                creg_rd_data = {`RELEASE_YEAR, `RELEASE_MONTH,
                                `RELEASE_VERSION,   `RELEASE_REVISION};
            end
            default                 : begin     //  Default value
                creg_rd_data = `WORD_DATA_W'h0;
            end
        endcase
    end

    /***** CPU control *****/
    always @(posedge clk or `RESET_EDGE reset) begin 
        if (reset == `RESET_ENABLE) begin
            /* Asynchronous reset */
            exe _mode       <= #1 `CPU_KERNEL_MODE;
            int_en          <= #1 `DISABLE;
            pre_exe_mode    <= #1 `CPU_KERNEL_MODE;
            pre_int_en      <= #1 `DISABLE;
            exp_code        <= #1 `ISA_EXP_NO_EXP;
            mask            <= #1 {`CPU_IRQ_CH{`ENABLE}};
            dly_flag        <= #1 `DISABLE;
            epc             <= #1 `WORD_ADDR_W'h0;
            exp_vector      <= #1 `WORD_ADDR_W'h0;
            pre_pc          <= #1 `WORD_ADDR_W'h0;
            br_flag         <= #1 `DISABLE;
        end else begin 
            /* CPU status Update */
            if ((mem_en == `ENABLE) && (stall == `DISABLE)) begin
                /* Save PC and Branch flags */
                pre_pc      <= #1 mem_pc;
                br_flag     <= #1 mem_br_flag;
                /* CPU status control */
                if (mem_exp_code != `ISA_EXP_NO_EXP) begin 
                    exe_mode        <= #1 `CPU_KERNEL_MODE;
                    int_en          <= #1 `DISABLE;
                    pre_exe_mode    <= #1 exe_mode;
                    pre_int_en      <= #1 int_en;
                    exp_code        <= #1 mem_exp_code;
                    dly_flag        <= #1 br_flag;
                    epc             <= #1 pre_pc;
                end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin 
                    exe_mode        <= #1 pre_exe_mode;
                    int_en          <= #1 pre_int_en;
                end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin 
                    /*Write to control register */
                    case (mem_dst_addr) 
                        `CREG_ADDR_STATUS       : begin     //  Status
                            exe_mode        <= #1 mem_out[`CregExeModeLoc];
                            int_en          <= #1 mem_out[`CregIntEnableLoc];
                        end
                        `CREG_ADDR_PRE_STATUS   : begin     //  Status before exception occurred
                            pre_exe_mode    <= #1 mem_out[`CregExeModeLoc];
                            pre_int_en      <= #1 mem_out[`CregIntEnableLoc];
                        end
                        `CREG_ADDR_EPC          : begin     //  Exception program counter
                            epc             <= #1 mem_out[`WordAddrLoc];
                        end
                        `CREG_ADDR_EXP_VECTOR   : begin     //  Exception Vector
                            exp_vector      <= #1 mem_out[`WordAddrLoc];
                        end
                        `CREG_ADDR_CAUSE        : begin     //  Exception reason
                            dly_flag        <= #1 mem_out[`CregDlyFlagLoc];
                            exp_code        <= #1 mem_out[`CregExpCodeLoc];
                        end 
                        `CREG_ADDR_INT_MASK     : begin     //  Interrupt Mask
                            mask            <= #1 mem_out[`CPU_IRQ_CH-1:0];
                        end
                    endcase 
                end
            end
        end
    end

endmodule
