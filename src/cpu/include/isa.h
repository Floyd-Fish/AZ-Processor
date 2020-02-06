/*
 -- ============================================================================
 -- FILE	 : isa.h
 -- SYNOPSIS : Instruction set Architecture
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.6   Floyd-Fish
 -- ============================================================================
*/

`ifndef __ISA_HEADER__
    `define __ISA_HEADER__          //  Include guard

//---------------------------------------------
//  Command
//---------------------------------------------

    /***** Command *****/
    `define ISA_NOP                 32'h0   //  No operation

    /***** Operation code *****/
    //  Bus
    `define ISA_OP_W                6       //  Operation code Width
    `define IsaOpBus                5:0     //  Operation code Bus
    `define IsaOpLoc                31:26   //  Operation code Location

    //  Operation code
    `define ISA_OP_ANDR             6'h00   //  Logic AND of registers
    `define ISA_OP_ANDI             6'h01   //  Logic AND of registers and constants
    `define ISA_OP_ORR              6'h02   //  Logic OR of registers
    `define ISA_OP_ORI              6'h03   //  Logic OR of registers and constants
    `define ISA_OP_XORR             6'h04   //  Exclusive OR of registers
    `define ISA_OP_XORI             6'h05   //  Exclusive OR of registers and constants
    `define ISA_OP_ADDSR            6'h06   //  Signed ADD between registers
    `define ISA_OP_ADDSI            6'h07   //  Signed ADD between registers and constants
    `define ISA_OP_ADDUR            6'h08   //  Unsigned ADD between registers
    `define ISA_OP_ADDUI            6'h09   //  Unsigned ADD between registers and constants
    `define ISA_OP_SUBSR            6'h0a   //  Signed subtraction between registers
    `define ISA_OP_SUBUR            6'h0b   //  Signed subtraction between registers and constants
    `define ISA_OP_SHRLR            6'h0c   //  Logic shift Right between registers
    `define ISA_OP_SHRLI            6'h0d   //  Logic shift Right between registers and constants
    `define ISA_OP_SHLLR            6'h0e   //  Logic shift Left between registers
    `define ISA_OP_SHLLI            6'h0f   //  Logic shift Left between registers and constants
    `define ISA_OP_BE               6'h10   //  Signed comparison between registers (==)
    `define ISA_OP_BNE              6'h11   //  Signed comparison between registers (!=)
    `define ISA_OP_BSGT             6'h12   //  Signed comparison between registers (<)
    `define ISA_OP_BUGT             6'h13   //  Unsigned comparison between registers (<)
    `define ISA_OP_JMP              6'h14   //  Absolute branch specified by register
    `define ISA_OP_CALL             6'h15   //  Subroutine call for register specification
    `define ISA_OP_LDW              6'h16   //  Read Word
    `define ISA_OP_STW              6'h17   //  Word Write
    `define ISA_OP_TRAP             6'h18   //  Trap
    `define ISA_OP_RDCR             6'h19   //  Read Control Register
    `define ISA_OP_WRCR             6'h1a   //  Write to control Register
    `define ISA_OP_EXRT             6'h1b   //  Return from exception

    /***** Register Address *****/
    //  Bus
    `define ISA_REG_ADDR_W          5       //  Register address width
    `define IsaRegAddrBus           4:0     //  Register address bus
    `define IsaRaAddrLoc            25:21   //  Register A's location
    `define IsaRbAddrLoc            20:16   //  Register B's location
    `define IsaRcAddrLoc            15:11   //  Register C's location

    /***** Immediate *****/
    //  Bus
    `define ISA_IMM_W               16      //  Immediate Width
    `define ISA_EXT_W               16      //  Immediate sign extention Width
    `define ISA_IMM_MSB             15      //  Most Significant Bit (MSB) of Immediate value
    `define IsaImmBus               15:0    //  Immediate bus
    `define IsaImmLoc               15:0    //  Immediate position

//---------------------------------------------
//  exception
//---------------------------------------------

    /***** Exception code *****/
    //  Bus
    `define ISA_EXP_W               3       //  Exception code Width
    `define IsaExpBus               2:0     //  Exception code Bus
    
    //  Exceptions 
    `define ISA_EXP_NO_EXP          3'h0    //  No exception
    `define ISA_EXP_EXT_INT         3'h1    //  External Interrupt
    `define ISA_EXP_UNDEF_INSN      3'h2    //  Undefined command
    `define ISA_EXP_OVERFLOW        3'h3    //  Arithmetic overflow
    `define ISA_EXP_MISS_ALIGN      3'h4    //  Address misalignment
    `define ISA_EXP_TRAP            3'h5    //  Trap
    `define ISA_EXP_PRV_VIO         3'h6    //  Privilege violation

`endif 
