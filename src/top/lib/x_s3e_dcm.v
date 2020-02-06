/*
 -- ============================================================================
 -- FILE	 : x_s3e_dcm.v
 -- SYNOPSIS : Xilinx Spartan-3E DCM model
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.6   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"


/***** Modules *****/
module x_s3e_dcm (
    input  wire     CLKIN_IN,       //  Default Clock
    input  wire     RST_IN,         //  Reset
    output wire     CLK0_OUT,       //  Clock (Zero phase shift)
    output wire     CLK180_OUT,     //  Clock (180 degrees phase shift)
    output wire     LOCKED_OUT      //  Lock
);

    /***** Clock Output *****/
    assign CLK0_OUT     = CLKIN_IN;
    assign CLK180_OUT   = ~CLKIN_IN;
    assign LOCKED_OUT   = ~RST_IN;

endmodule
