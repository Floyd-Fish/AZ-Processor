/*
 -- ============================================================================
 -- FILE	 : cpu.h
 -- SYNOPSIS : cpu Header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.6   Floyd-Fish
 -- ============================================================================
*/

`ifndef __CPU_HEADER__
    `define __CPU_HEADER__

//---------------------------------------------
//  Operation
//---------------------------------------------

    /***** Register *****/
    `define REG_NUM             32      //  Number of Registers
    `define REG_ADDR_W          5       //  Register Address width
    `define RegAddrBus          4:0     //  Register Address bus

    /***** Interrrupt request signal *****/
    `define CPU_IRQ_CH          8       //  IRQ amptitude

    /***** ALU operation code *****/
    //  Bus
    `define ALU_OP_W            4       //  ALU operation code width
    `define AluOpBus            3:0     //  ALU operation code bus

    //  Operation code 
    ·define ALU_OP_NOP          4'h0    //  No operation
    ·define ALU_OP_AND          4'h1    //  AND
    ·define ALU_OP_OR           4'h2    //  OR
    ·define ALU_OP_XOR          4'h3    //  XOR
    ·define ALU_OP_ADDS         4'h4    //  Signed addition
    ·define ALU_OP_ADDU         4'h5    //  Unsigned addition
    ·define ALU_OP_SUBS         4'h6    //  Signed subtraction
    ·define ALU_OP_SUBU         4'h7    //  Unsigned subtraction
    ·define ALU_OP_SHRL         4'h8    //  Logic Shift Right
    ·define ALU_OP_SHLL         4'h9    //  Logic Shift Left

    /***** Memory operation code *****/
    //  Bus
    `define MEM_OP_W            2       //  Memory Operation code width
    `define MemOpBus            1:0     //  Memory Operation code bus

    //  Operation code 
    `define MEM_OP_NOP          2'h0    //  No operation
    `define MEM_OP_LDW          2'h1    //  Read Word
    `define MEM_OP_STW          2'h2    //  Word Write

    /***** Control Operation code *****/
    //  Bus
    `define CTRL_OP_W           2       //  Control Operation code width
    `define CtrlOpBus           1:0     //  Control Operation code bus

    //  Operation code 
    `define CTRL_OP_NOP         2'h0    //  No Operation
    `define CTRL_OP_WRCR        2'h1    //  Write to control register
    `define CTRL_OP_EXRT        2'h2    //  Return from exception

    /***** Execution Mode *****/
    //  Bus
    `define CPU_EXE_MODE_W      1       //  Execution Mode Width
    `define CpuExeModeBus       0:0     //  Execution Mode Bus
    //  Execution Mode
    `define CPU_KERNEL_MODE     1'b0    //  Kernel mode
    `define CPU_USER_MODE       1'b1    //  User Mode

//---------------------------------------------
//  Control Register
//---------------------------------------------
    /***** Address Map *****/
    `define CREG_ADDR_STATUS        5'h0    //  Status
    `define CREG_ADDR_PRE_STATUS    5'h1    //  Previous Status
    `define CREG_ADDR_PC            5'h2    //  Program Counter
    `define CREG_ADDR_EPC           5'h3    //  Exception Program Counter
    `define CREG_ADDR_EXP_VECTOR    5'h4    //  Exception Vector
    `define CREG_ADDR_CAUSE         5'h5    //  Exception Cause Register
    `define CREG_ADDR_INT_MASK      5'h6    //  Interrupt Mask
    `define CREG_ADDR_IRQ           5'h7    //  Interrupt request

    //  Read-Only area
    `define CREG_ADDR_ROM_SIZE      5'h1d   //  ROM size
    `define CREG_ADDR_SPM_SIZE      5'h1e   //  SPM size
    `define CREG_ADDR_CPU_INFO      5'h1f   //  CPU info

    /***** Bitmap *****/
    `define CregExeModeLoc          0       //  Run mode position
    `define CregIntEnableLoc        1       //  Interrupt enabled position
    `define CregExpCodeLoc          2:0     //  Exception code location
    `define CregDlyFlagLoc          3       //  Position of delay slot flag

//---------------------------------------------
//  Bus Interface
//---------------------------------------------

    /***** BUs Interface Status *****/
    //  Bus
    `define BusIfStateBus           1:0     //  State Bus
    //  Stauts
    `define BUS_IF_STATE_IDLE       2'h0    //  idle
    `define BUS_IF_STATE_REQ        2'h1    //  Bus request
    `define BUS_IF_STATE_ACCESS     2'h2    //  Bus access
    `define BUS_IF_STATE_STALL      2'h3    //  Stall

//---------------------------------------------
//  MISC
//---------------------------------------------

    /***** Vector *****/
    `define RESET_VECTOR            30'h0   //  Reset Vector
    `define ShAmountBus             4:0     //  Shift amount bus
    `define ShAmountLoc             4:0     //  Shift Position

    /***** CPU Info *****/
    `define RELEASE_YEAR            8'd41   //  Finished year (XXXX - 1970)
    `define RELEASE_MONTH           8'd7    //  Finished Month
    `define RELEASE_VERSION         8'd2    //  Version
    `define RELEASE_REVISION        8'd0    //  Revision

`endif
