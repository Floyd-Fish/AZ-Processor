`ifndef __GLOBAL_CONFIG_HEADER__
    `define __GLOBAL_CONFIG_HEADER__

/***** Global Configuration Select *****/
    `define TARGET_DEV_AZPR_EV_BOARD
//    `define TARGET_DEV_MFPGA_SPAR3E

//    `define POSITIVE_RESET      //Active High
    `define NEGATIVE_RESET      //Active Low

    `define POSITIVE_MEMORY     //Active High
//    `define NEGATIVE_MEMORY     //Active Low

    `define IMPLEMENT_TIMER     //Timer
    `define IMPLEMENT_UART      //UART
    `define IMPLEMENT_GPIO      //GPIO


/***** Progress *****/

    //Active High
    `ifdef POSITIVE_MEMORY
        `define MEM_ENABLE      1'b1
        `define MEM_DISABLE     1'b0
    `endif
    
    //Active Low
    `ifdef NEGATIVE_MEMORY
        `define MEM_ENABLE      1'b0
        `define MEM_DISABLE     1'b1
    `endif

`endif
