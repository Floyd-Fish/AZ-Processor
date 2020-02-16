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

    /***** Instruction field *****/
    wire [`IsaOpBus]    op          = if_insn[`IsaOpLoc];       //  Operation code
    wire [`RegAddrBus]  ra_addr     = if_insn[`IsaRaAddrLoc];   //  RA address
    wire [`RegAddrBus]  rb_addr     = if_insn[`IsaRbAddrLoc];   //  RB address
    wire [`RegAddrBus]  rc_addr     = if_insn[`IsaRcAddrLoc];   //  RC address
    wire [`IsaImmBus]   imm         = if_insn[`IsaImmLoc];      //  Immediate number

    /***** Immediate Number *****/
    //  Sign extension
    wire [`WordDataBus] imm_s = {{`ISA_EXT_W{imm[`ISA_IMM_MSB]}}, imm};
    //  Zero extension
    wire [`WordDataBus] imm_u = {{`ISA_EXT_W{1'b0}}, imm};

    /***** Register read address *****/
    assign gpr_rd_addr_0 = ra_addr; //  General Register read address 0
    assign gpr_rd_addr_1 = rb_addr; //  General Register read address 1
    assign creg_rd_addr  = ra_addr; //  Control register read address

    /***** General register read data *****/
    reg         [`WordDataBus]  ra_data;                        //  Unsigned RA
    wire signed [`WordDataBus]  s_ra_data = $signed(ra_data);   //  Signed RA
    reg         [`WordDataBus]  rb_data;                        //  Unsigned RB
    wire signed [`WordDataBus]  s_rb_data = $signed(rb_data);   //  Signed RB
    assign mem_wr_data = rb_data;   //  Memory write data
    /***** Address *****/
    wire [`WordAddrBus] ret_addr    = if_pc + 1'b1;                     //  Return address
    wire [`WordAddrBus] br_target   = if_pc + imm_s[`WORD_ADDR_MSB:0];  //  Branch destination
    wire [`WordAddrBus] jr_target   = ra_data[`WordAddrLoc];            //  Jump to destination

    /***** Forwarding *****/
    always @(*) begin 
        /* RA register */
        if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) &&
            (id_dst_addr == ra_addr)) begin
            ra_data = ex_fwd_data;      //  Forwarding from EX stage
        end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) &&
                    (ex_dst_addr == ra_addr)) begin
            ra_data = mem_fwd_data;     //  Forwarding from MEM stage
        end else begin 
            ra_data = gpr_rd_data_0;    //  Read from register file
        end

        /* RB register */
        if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) &&
            (id_dst_addr == rb_addr)) begin
            rb_data = ex_fwd_data;      //  Forwarding from EX stage
        end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) &&
                    (ex_dst_addr == rb_addr)) begin 
            rb_data = mem_fwd_data;     //  Forwarding from MEM stage
        end else begin
            rb_data = gpr_rd_data_1;    //  Read from register file
        end 
    end

    /***** Road hazard detection *****/
    always @(*) begin 
        if ((id_en == `ENABLE) && (id_mem_op == `MEM_OP_LDW) &&
            ((id_dst_addr == ra_addr) || (id_dst_addr == rb_addr))) begin 
            ld_hazard = `ENABLE;    //  Road hazard
        end else begin
            ld_hazard = `DISABLE;   //  No hazard
        end
    end

    /***** Instruction decoding *****/
    always @(*) begin 
        /* Default value */
        alu_op   = `ALU_OP_NOP;
        alu_in_0 = ra_data;
        alu_in_1 = rb_data;
        br_taken = `DISABLE;
        br_flag  = `DISABLE;
        br_addr  = {`WORD_ADDR_W{1'b0}};
        mem_op   = `MEM_OP_NOP;
        ctrl_op  = `CTRL_OP_NOP;
        dst_addr = rb_addr;
        gpr_we_  = `DISABLE_;
        exp_code = `ISA_EXP_NO_EXP;

        /* Operation Code Judgement */
        if (if_en == `ENABLE) begin
            case (op)
                /* Logical operation instruction */
                `ISA_OP_ANDR    : begin     //  Logical product of registers
                    alu_op   = `ALU_OP_AND;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_ANDI    : begin     //  Logical AND of register and immediate value
                    alu_op   = `ALU_OP_AND;
                    alu_in_1 = imm_u;
                    gpr_we_  = `ENABLE_;
                end 
                `ISA_OP_ORR     : begin     //  Logical OR between registers
                    alu_op   = `ALU_OP_OR;
                    alu_in_1 = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_ORI     : begin     //  Logical OR of register and immediate value
                    alu_op   = `ALU_OP_OR;
                    alu_in_1 = imm_u;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_XORR    : begin     //   Exclusive OR of registers
                    alu_op   = `ALU_OP_XOR;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_XORI    : begin     //  Exclusive OR of register and immediate
                    alu_op   = `ALU_OP_XOR;
                    alu_in_1 = imm_u;
                    gpr_we_  = `ENABLE_;
                end

                /* Arithmetic operation instructions */
                `ISA_OP_ADDSR   : begin     //  Signed addition between registers
                    alu_op   = `ALU_OP_ADDS;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_ADDSI   : begin     //  Signed addition of register and immediate value
                    alu_op   = `ALU_OP_ADDS;
                    alu_in_1 = imm_s;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_ADDUR   : begin     //  Unsigned addition between registers
                    alu_op   = `ALU_OP_ADDU;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_ADDUI   : begin     //  Unsigned addition of register and immediate
                    alu_op   = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_SUBSR   : begin     //  Signed subtraction between registers
                    alu_op   = `ALU_OP_SUBS;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_SUBUR   : begin     //  Unsigned subtraction between registers
                    alu_op   = `ALU_OP_SUBU;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_SHRLR   : begin     //  Logical shift right between registers
                    alu_op   = `ALU_OP_SHRL;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_SHRLI   : begin     //  Logical shift right of register and immediate value
                    alu_op   = `ALU_OP_SHLL;
                    dst_addr = rc_addr;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_SHLLR   : begin     //  Logical shift left between registers
                    alu_op   = `ALU_OP_SHLL;
                    alu_in_1 = imm_u;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_SHLLI   : begin     //  Logical shift left of register and immediate value
                    alu_op   = `ALU_OP_SHLL;
                    alu_in_1 = imm_u;
                    gpr_we_  = `ENABLE_;
                end

                /* Branch Instruction */
                `ISA_OP_BE      : begin     //  Signed comparison between registers (Ra == Rb)
                    br_addr  = br_target;
                    br_taken = (ra_data == rb_data) ? `ENABLE : `DISABLE;
                    br_flag  = `ENABLE;
                end
                `ISA_OP_BNE     : begin     //  Signed comparison between registers (Ra != Rb)
                    br_addr  = br_target;
                    br_taken = (ra_data != rb_data) ? `ENABLE : `DISABLE;
                    br_flag  = `ENABLE;
                end
                `ISA_OP_BSGT    : begin     //  Signed comparison between registers (Ra < Rb)
                    br_addr  = br_target;
                    br_taken = (s_ra_data < s_rb_data) > `ENABLE : `DISABLE;
                    br_flag  = `ENABLE;
                end
                `ISA_OP_BUGT    : begin     //  Unsigned comparison between registers (Ra < Rb)
                    br_addr  = br_target;
                    br_taken = (ra_data < rb_data) ? `ENABLE : `DISABLE;
                    br_flag  = `ENABLE;
                end
                `ISA_OP_JMP     : begin     //  Unconditional branch
                    br_addr  = jr_target;
                    br_taken = `ENABLE;
                    br_flag  = `ENABLE;
                end
                `ISA_OP_CALL    : begin     //   Call
                    alu_in_0 = {ret_addr, {`BYTE_OFFSET_W{1'b0}}};
                    br_addr  = jr_target;
                    br_taken = `ENABLE;
                    br_flag  = `ENABLE;
                    dst_addr = `REG_ADDR_W'd31;
                    gpr_we_  = `ENABLE_;
                end

                /* Memory access instructions */
                `ISA_OP_LDW     : begin     //  Read Word
                    alu_op   = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op   = `MEM_OP_LDW;
                    gpr_we_  = `ENABLE_;
                end
                `ISA_OP_STW     : begin     //  Write Word
                    alu_op   = `ALU_OP_ADDU;
                    alu_in_1 = imm_s;
                    mem_op   = `MEM_OP_STW;
                end

                /* System call instruction */
                `ISA_OP_TRAP    : begin     //  Trap
                    exp_code = `ISA_EXP_TRAP;
                end

                /* Privileged instructions */
                `ISA_OP_RDCR    : begin     //  Read control register
                    if (exe_mode == `CPU_KERNEL_MODE) begin 
                        alu_in_0 = creg_rd_data;
                        gpr_we_  = `ENABLE_;
                    end else begin 
                        exp_code = `ISA_EXP_PRV_VIO;
                    end
                end
                `ISA_OP_WRCR    : begin     //  Write to control register
                    if (exe_mode == `CPU_KERNEL_MODE) begin 
                        ctrl_op = `CTRL_OP_EXRT;
                    end else begin 
                        exp_code = `ISA_EXP_PRV_VIO;
                    end
                end
                /* Other instructions */
                default         : begin     //  Undefined instruction
                    exp_code = `ISA_EXP_UNDEF_INSN;
                end
            endcase 
        end
    end

endmodule
