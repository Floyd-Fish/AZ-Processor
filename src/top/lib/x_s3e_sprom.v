/*
 -- ============================================================================
 -- FILE	 : x_s3e_sprom.v
 -- SYNOPSIS : Xilinx Spartan-3E Single Port ROM Model
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.1   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "rom.h"

/***** Modules *****/
module x_s3e_sprom (
    input wire                clka,   //  Clock
    input wire [`RomAddrBus]  addra,  //  Address
    output reg [`WordDataBus] douta   //  Read-out data
);

    /***** Memory *****/
    reg [`WordDataBus] mem [0:`ROM_DEPTH-1];

    /***** Read Accessory *****/
    always @(posedge clka) begin
        douta <= #1 mem[addra];
    end

endmodule
