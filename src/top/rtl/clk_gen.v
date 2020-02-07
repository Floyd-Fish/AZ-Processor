/*
 -- ============================================================================
 -- FILE	 : clk_gen.v
 -- SYNOPSIS : Clock generation module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.7   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Modules *****/
module clk_gen (
    /***** Clock & Reset *****/
    input  wire clk_ref,    //  Clock reference
    input  wire reset_sw,   //  Reset switch
    /***** Generated clock *****/
    output wire clk,        //  Clock
    output wire clk_,       //  Inverted clock
    /***** Chip reset *****/
    output wire chip_reset  //  Chip reset
);

    /***** Internal signal *****/
    wire            locked;     //  Lock
    wire            dcm_reset; //  Reset

    /***** Generate reset *****/
    //  DCM reset
    assign dcm_reset = (reset_sw == `RESET_ENABLE) ? `ENABLE : `DISABLE;
    //  Chip reset
    assign chip_reset = ((reset_sw == `RESET_ENABLE) || (locked == `DISABLE)) ? 
                        `RESET_ENABLE : `RESET_DISABLE;

    /***** Xilinx DCM (Digital Clock Manager) *****/
    x_s3e_dcm x_s3e_dcm (
        .CLKIN_IN           (clk_ref),      //  Clock reference
        .RST_IN             (dcm_reset),    //  DCM reset
        .CLK0_OUT           (clk),          //  Clock
        .CLK180_OUT         (clk_),         //  Inverted Clock
        .LOCKED_OUT         (locked)        //  Lock
    );

endmodule
