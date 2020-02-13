/*
 -- ============================================================================
 -- FILE	 : cpu.v
 -- SYNOPSIS : CPU top module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.12   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "isa.h"
`include "cpu.h"
`include "bus.h"
`include "spm.h"

/***** Module *****/
module cpu (
    /***** Clock & Reset *****/
    input  wire                     clk,    //  Clock
    input  wire                     clk_,   //  Inverted clock
    input  wire                     reset,  //  Asynchronous reset

    /***** Bus Interface *****/
    //  I/F Stage
    input  wire [`WordDataBus]      if_bus_rd_data,     //  Read data
    input  wire                     if_bus_rdy_,        //  Ready
    input  wire                     if_bus_grnt_,       //  Bus Grant
    output wire                     if_bus_req_,        //  Bus request
    output wire [`WordAddrBus]      if_bus_addr,        //  Address
    output wire                     if_bus_as_,         //  Address Strobe
    output wire                     if_bus_rw,          //  Read /Write
    output wire [`WordDataBus]      if_bus_wr_data,     //  Write data

    //  MEM Stage
    input  wire [`WordDataBus]      mem_bus_rd_data,    //  Read data
    input  wire                     mem_bus_rdy_,       //  Ready
    input  wire                     mem_bus_grnt_,      //  Bus Grant
    output wire                     mem_bus_req_,       //  Bus request
    output wire [`WordAddrBus]      mem_bus_addr,       //  Address
    output wire                     mem_bus_as_,        //  Address Strobe
    output wire                     mem_bus_rw,         //  Read / Write
    output wire [`WordDataBus]      mem_bus_wr_data,    //  Write data

    //  Interrupt 
    input  wire [`CPU_IRQ_CH-1:0]   cpi_irq             //  Interrupt request
);

    /***** Pipeline Register *****/
    //  IF / ID
    wire [`WordAddrBus]             if_pc;          //  Program Counter
    wire [`WordDataBus]             if_insn;        //  Order
    wire                            if_en;          //  Validate pipeline data
    
    //  ID / EX Pipeline Register
    wire [`WordAddrBus]             id_pc;          //  Program Counter
    wire                            id_en;          //  Validate pipeline data
    wire [`AluOpBus]                id_alu_op;      //  ALU operation
    wire [`WordDataBus]             id_alu_in_0;    //  ALU input 0
    wire [`WordDataBus]             id_alu_in_1;    //  ALU input 1
    wire                            id_br_flag;     //  Branch flag
    wire [`MemOpBus]                id_mem_op;      //  Memory operation
    wire [`WordDataBus]             id_mem_wr_data; //  Memory write data
    wire [`CtrlOpBus]               id_ctrl_op;     //  Control operation
    wire [`RegAddrBus]              id_dst_addr;    //  GPR write address
    wire                            id_gpr_we_;     //  GPR write enable
    wire [`IsaExpBus]               id_exp_code;    //  Exception code

    //  EX / MEM Pipeline Register
    wire [`WordAddrBus]             ex_pc;          //  Program counter
    wire                            ex_en;          //  Validate pipeline data
    wire                            ex_br_flag;     //  Branch flag
    wire [`MemOpBus]                ex_mem_op;      //  Memory operation
    wire [`WordDataBus]             ex_mem_wr_data; //  Memory write data
    wire [`CtrlOpBus]               ex_ctrl_op;     //  Control register operation
    wire [`RegAddrBus]              ex_dst_addr;    //  General register write address
    wire                            ex_gpr_we_;     //  General register write enable
    wire [`IsaExpBus]               ex_exp_code;    //  Exception code
    wire [`WordDataBus]             ex_out;         //  Processing result

    //  MEM / WB Pipeline Register
    wire [`WordAddrBus]             mem_pc;         //  Program counter
    wire                            mem_en;         //  Validate pipeline data
    wire                            mem_br_flag;    //  Branch flag
    wire [`CtrlOpBus]               mem_ctrl_op;    //  Control Register operation
    wire [`RegAddrBus]              mem_dst_addr;   //  General register write address
    wire                            mem_gpr_we_;    //  General register write enable
    wire [`IsaExpBus]               mem_exp_code;   //  Exception code
    wire [`WordDataBus]             mem_out;        //  Processing result

    /***** Pipeline control signal *****/
    //  Stall signal
    wire                            if_stall;       //  IF stage 
    wire                            id_stall;       //  ID stage
    wire                            ex_stall;       //  EX stage
    wire                            mem_stall;      //  MEM stage
    //  Flash signal
    wire                            if_flush;       //  IF stage 
    wire                            id_flush;       //  ID stage
    wire                            ex_flush;       //  EX stage
    wire                            mem_flush;      //  MEM stage
    //  Busy signal
    wire                            if_busy;        //  IF stage
    wire                            mem_busy;       //  MEM stage
    //  Other Control signals
    wire [`WordAddrBus]             new_pc;         //  New Program counter
    wire [`WordAddrBus]             br_addr;        //  Branch address
    wire                            br_taken;       //  Branch taken
    wire                            ld_hazard;      //  Road hazard
    
    /***** General purpose register signal ******/
    wire [`WordDataBus]             gpr_rd_data_0;  //  Read data 0
    wire [`WordDataBus]             gpr_rd_data_1;  //  Read data 1
    wire [`RegAddrBus]              gpr_rd_addr_0;  //  Read Address 0
    wire [`RegAddrBus]              gpr_rd_addr_1;  //  Read Address 1

    /***** Control Register signal *****/
    wire [`CpuExeModeBus]           exe_mode;       //  Execution mode
    wire [`WordDataBus]             creg_rd_data;   //  Read data
    wire [`RegAddrBus]              creg_rd_addr;   //  Read Address

    /***** Interrupt Request *****/
    wire                            int_detect;     //  Interrupt detection

    /***** Scratch pad memory signal *****/
    //  IF Stage
    wire [`WordDataBus]             if_spm_rd_data; //  Read data
    wire [`WordAddrBus]             if_spm_addr;    //  Address
    wire                            if_spm_as_;     //  Address strobe
    wire                            if_spm_rw;      //  Read / Write
    wire [`WordDataBus]             if_spm_wr_data; //  Write data
    //  MEM Stage 
    wire [`WordDataBus]             mem_spm_rd_data;//  Read data
    wire [`WordAddrBus]             mem_spm_addr;   //  Address
    wire                            mem_spm_as_;    //  Address strobe
    wire                            mem_spm_rw;     //  Read / Write
    wire [`WordDataBus]             mem_spm_wr_data;//  Write data

    /***** Forwarding signal *****/
    wire [`WordDataBus]             ex_fwd_data;    //  EX stage
    wire [`WordDataBus]             mem_fwd_data;   //  MEM stage

    /***** IF stage *****/
    if_stage if_stage (
        /***** Clock & Reset *****/
        .clk            (clk),              //  Clock
        .reset          (reset),            //  Asynchronous reset

        /***** SPM Interface *****/
        .spm_rd_data    (if_spm_rd_data),   //  Read data
        .spm_addr       (if_spm_addr),      //  Address
        .spm_as_        (if_spm_as_),       //  Address strobe
        .spm_rw         (if_spm_rw),        //  Read / Write
        .spm_wr_data    (if_spm_wr_data),   //  Write data

        /***** Bus Interface *****/
        .bus_rd_data    (if_bus_rd_data),   //  Read data
        .bus_rdy_       (if_bus_rdy_),      //  Ready 
        .bus_grnt_      (if_bus_grnt_),     //  Bus Grant
        .bus_req_       (if_bus_req_),      //  Bus request
        .bus_addr       (if_bus_addr),      //  Address
        .bus_as_        (if_bus_as_),       //  Address strobe
        .bus_rw         (if_bus_rw),        //  Read / Write
        .bus_wr_data    (if_bus_wr_data),   //  Write data

        /***** Pipeline control signal *****/
        .stall          (if_stall),         //  Stall
        .flush          (if_flush),         //  Flush
        .new_pc         (new_pc),           //  New program counter
        .br_taken       (br_taken),         //  Branch taken
        .br_addr        (br_addr),          //  Branch Address
        .busy           (if_busy),          //  Busy signal

        /***** IF/ID Pipeline register *****/
        .if_pc          (if_pc),            //  Program counter
        .if_insn        (if_insn),          //  Command
        .if_en          (if_en)             //  Validate pipeline data
    );

    /***** ID stage *****/
    id_stage id_stage (
        /***** Clock & Reset *****/
        .clk            (clk),              //  Clock
        .reset          (reset),            //  Asynchronous reset 

        /***** GPR Interface *****/
        .gpr_rd_data_0  (gpr_rd_data_0),    //  Read data 0
        .gpr_rd_data_1  (gpr_rd_data_1),    //  Read data 1
        .gpr_rd_addr_0  (gpr_rd_addr_0),    //  Read Address 0
        .gpr_rd_addr_1  (gpr_rd_addr_1),    //  Read Address 1

        /***** Forwarding *****/
        //  Forwarding from EX stage 
        .ex_en          (ex_en),            //  Validate pipeline data
        .ex_fwd_data    (ex_fwd_data),      //  Forwarding data
        .ex_dst_addr    (ex_dst_addr),      //  Write access
        .ex_gpr_we_     (ex_gpr_we_),       //  Write enabled
        
        /***** Forwarding from MEM stage *****/
        .mem_fwd_data   (mem_fwd_data),     //  Forwarding data

        /***** Control register Interface *****/
        .exe_mode       (exe_mode),         //  Execution mode
        .creg_rd_data   (creg_rd_data),     //  Read data
        .creg_rd_addr   (creg_rd_addr),     //  Read address

        /***** Pipeline control signal *****/
        .stall          (id_stall),         //  Stall
        .flush          (id_flush),         //  Flush
        .br_addr        (br_addr),          //  Branch address
        .br_taken       (br_taken),         //  Branch taken 
        .ld_hazard      (ld_hazard),        //  Road hazard

        /***** IF / ID pipeline register *****/
        .if_pc          (if_pc),            //  Program counter
        .if_insn        (if_insn),          //  Order
        .if_en          (if_en),            //  Validate pipeline data

        /***** ID / EX pipeline register *****/
        .id_pc          (id_pc),            //  Program counter
        .id_en          (id_en),            //  Validate pipeline data
        .id_alu_op      (id_alu_op),        //  ALU Operation
        .id_alu_in_0    (id_alu_in_0),      //  ALU Input 0
        .id_alu_in_1    (id_alu_in_1),      //  ALU Input 1
        .id_br_flag     (id_br_flag),       //  Branch flag 
        .id_mem_op      (id_mem_op),        //  Memory operation
        .id_mem_wr_data (id_mem_wr_data),   //  Memory write data
        .id_ctrl_op     (id_ctrl_op),       //  Control Operation
        .id_dst_addr    (id_dst_addr),      //  GPR write address
        .id_gpr_we_     (id_gpr_we_),       //  GPR writing enable
        .id_exp_code    (id_exp_code)       //  Exception code
    );

    /***** EX Stage *****/
    ex_stage ex_stage (
        /***** Clock & Reset *****/
        .clk            (clk),              //  Clock
        .reset          (reset),            //  Asynchronous reset 

        /***** Pipeline control signal *****/
        .stall          (ex_stall),         //  Stall
        .flush          (ex_flush),         //  Flush
        .int_detect     (int_detect),       //  Interrupt detection

        /***** Forwarding *****/
        .fwd_data       (ex_fwd_data),      //  Forwarding data

        /***** ID / EX Pipeline register *****/
        .id_pc          (id_pc),            //  Program counter
        .id_en          (id_en),            //  Validate pipeline data
        .id_alu_op      (id_alu_op),        //  ALU Operation 
        .id_alu_in_0    (id_alu_in_0),      //  ALU Input 0
        .id_alu_in_1    (id_alu_in_1),      //  ALU Input 1
        .id_br_flag     (id_br_flag),       //  Branch flag 
        .id_mem_op      (id_mem_op),        //  Memory operation 
        .id_mem_wr_data (id_mem_wr_data),   //  Memory write data
        .id_ctrl_op     (id_ctrl_op),       //  Control register operation
        .id_dst_addr    (id_dst_addr),      //  General register write address
        .id_gpr_we_     (id_gpr_we_),       //  General register writing enable
        .id_exp_code    (id_exp_code),      //  Exception code 

        /***** EX / MEM Pipeline register *****/
        .ex_pc          (ex_pc),            //  Program counter
        .ex_en          (ex_en),            //  Validate pipeline data 
        .ex_br_flag     (ex_br_flag),       //  Branch flag 
        .ex_mem_op      (ex_mem_op),        //  Memory Operation
        .ex_mem_wr_data (ex_mem_wr_data),   //  Memory write data
        .ex_ctrl_op     (ex_ctrl_op),       //  Control register operation 
        .ex_dst_addr    (ex_dst_addr),      //  General register write address
        .ex_gpr_we_     (ex_gpr_we_),       //  General register writing enable
        .ex_exp_code    (ex_exp_code),      //  Exception code 
        .ex_out         (ex_out)            //  Processing result
    );

    /***** MEM Stage *****/
    mem_stage mem_stage (
        /***** Clock & Reset *****/
        .clk            (clk),              //  Clock
        .reset          (reset),            //  Asynchronous reset 

        /***** Pipeline control signal *****/
        .stall          (mem_stall),        //  Stall
        .flush          (mem_flush),        //  Flush
        .busy           (mem_busy),         //  Busy signal 

        /***** Forwarding *****/
        .fwd_data       (mem_fwd_data),     //  Forwarding data

        /***** SPM Interface *****/
        .spm_rd_data    (mem_spm_rd_data),  //  Read data
        .spm_addr       (mem_spm_addr),     //  Address
        .spm_as_        (mem_spm_as_),      //  Address strobe
        .spm_rw         (mem_spm_rw),       //  Read / Write 
        .spm_wr_data    (mem_spm_wr_data),  //  Write data

        /***** Bus Interface *****/
        .bus_rd_data    (mem_bus_rd_data),  //  Read data
        .bus_rdy_       (mem_bus_rdy_),     //  Ready 
        .bus_grnt_      (mem_bus_grnt_),    //  Bus grant
        .bus_req_       (mem_bus_req_),     //  Bus request 
        .bus_addr       (mem_bus_addr),     //  Address
        .bus_as_        (mem_bus_as_),      //  Address strobe
        .bus_rw         (mem_bus_rw),       //  Read / Write 
        .bus_wr_data    (bus_wr_data),      //  Write data

        /***** EX / MEM pipeline register *****/
        .ex_pc          (ex_pc),            //  Program counter
        .ex_en          (ex_en),            //  Validate pipeline data
        .ex_br_flag     (ex_br_flag),       //  Branch flag 
        .ex_mem_op      (ex_mem_op),        //  Memory operation
        .ex_mem_wr_data (ex_mem_wr_data),   //  Memory write data
        .ex_ctrl_op     (ex_ctrl_op),       //  Control register operation
        .ex_dst_addr    (ex_dst_addr),      //  General register write address
        .ex_gpr_we_     (ex_gpr_we_),       //  General register writing enable
        .ex_exp_code    (ex_exp_code),      //  Exception code 
        .ex_out         (ex_out),           //  Processing result

        /***** MEM / WB pipeline register *****/
        .mem_pc         (mem_pc),           //  Program counter
        .mem_en         (mem_en),           //  Validate pipeline data
        .mem_br_flag    (mem_br_flag),      //  Branch flag
        .mem_ctrl_op    (mem_ctrl_op),      //  Control register operation
        .mem_dst_addr   (mem_dst_addr),     //  General register write address
        .mem_gpr_we_    (mem_gpr_we_),      //  General register writing enable
        .mem_exp_code   (mem_exp_code),     //  Exception code 
        .mem_out        (mem_out)           //  Processing result
    );

    /***** Controller unit *****/
    ctrl ctrl (
        /***** Clock & Reset *****/
        .clk            (clk),              //  Clock 
        .reset          (reset),            //  Asynchronous reset

        /***** Control register Interface *****/
        .creg_rd_addr   (creg_rd_addr),     //  Read address
        .creg_rd_data   (creg_rd_data),     //  Read data
        .exe_mode       (exe_mode),         //  Execution mode

        /***** Interrupt *****/
        .irq            (cpi_irq),          //  Interrupt request
        .int_detect     (int_detect),       //  Interrupt detection

        /***** ID / EX pipeline register *****/
        .id_pc          (id_pc),            //  Program counter

        /***** MEM / WB pipeline register *****/
        .mem_pc         (mem_pc),           //  Program counter
        .mem_en         (mem_en),           //  Validate pipeline data
        .mem_br_flag    (mem_br_flag),      //  Branch flag
        .mem_ctrl_op    (mem_ctrl_op),      //  Control register operation
        .mem_dst_addr   (mem_dst_addr),     //  General register write address
        .mem_exp_code   (mem_exp_code),     //  Exception code 
        .mem_out        (mem_out),          //  Processing result

        /***** Pipeline control signal *****/
        //  Pipeline status 
        .if_busy        (if_busy),          //  IF stage busy
        .id_hazard      (id_hazard),        //  Load Hazard
        .mem_busy       (mem_busy),         //  MEM stage busy
        //  Stall signal 
        .if_stall       (if_stall),         //  IF stage stall 
        .id_stall       (id_stall),         //  ID stage stall
        .ex_stall       (ex_stall),         //  EX stage stall
        .mem_stall      (mem_stall),        //  MEM stage stall
        //  Flush signal
        .if_flush       (if_flush),         //  IF stage flush
        .id_flush       (id_flush),         //  ID stage flush
        .ex_flush       (ex_flush),         //  EX stage flush
        .mem_flush      (mem_flush),        //  MEM stage flush
        //  New program counter
        .new_pc         (new_pc)            //  New program counter
    );

    /***** General Registers *****/
    gpr gpr (
        /***** Clock & Reset *****/
        .clk            (clk),              //  Clock
        .reset          (reset),            //  Asynchronous reset

        /***** Read Port 0 *****/
        .rd_addr_0 (gpr_rd_addr_0),         //  Read address
        .rd_data_0 (gpr_rd_data_0),         //  Read data

        /***** Read Port 1 *****/
        .rd_addr_1 (gpr_rd_addr_1),         //  Read address
        .rd_data_1 (gpr_rd_data_1),         //  Read data

        /***** Write port *****/
        .we_            (mem_gpr_we_),      //  Write enabled
        .wr_addr        (mem_dst_addr),     //  Write address
        .wr_data        (mem_out)           //  Write data
    );

    /***** Scratchpad memory *****/
    spm spm (
        /***** Clock *****/
        .clk            (clk),              //  Clock 

        /***** Port A---IF stage *****/
        .if_spm_addr    (if_spm_addr[`SpmAddrLoc]),     //  Address
        .if_spm_as_     (if_spm_as_),                   //  Address strobe
        .if_spm_rw      (if_spm_rw),                    //  Read / Write
        .if_spm_wr_data (if_spm_wr_data),               //  Write data
        .if_spm_rd_data (if_spm_rd_data),               //  Read data
        
        /***** Port B---MEM stage *****/
        .mem_spm_addr       (mem_spm_addr[`SpmAddrLoc]),//  Address 
        .mem_spm_as_        (mem_spm_as_),              //  Address strobe
        .mem_spm_rw         (mem_spm_rw),               //  Read / Write
        .mem_spm_wr_data    (mem_spm_wr_data),          //  Write data
        .mem_spm_rd_data    (mem_spm_rd_data)           //  Read data
    );

endmodule
