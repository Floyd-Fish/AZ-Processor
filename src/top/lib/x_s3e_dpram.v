/*
 -- ============================================================================
 -- FILE	 : x_s3e_dpram.v
 -- SYNOPSIS : Xilinx Spartan-3E Dual Port RAM model
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.6   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "spm.h"

/***** Modules *****/
module x_s3e_dpram (
    /***** Port A *****/
    input  wire                clka,    //  Clock
    input  wire [`SpmAddrBus]  addra,   //  Address
    input  wire [`WordDataBus] dina,    //  Write data
    input  wire                wea,     //  Write enabled
    output reg  [`WordDataBus] douta,   //  Read-out data

    /***** Port B *****/
    input  wire                clkb,    //  Clock
    input  wire [`SpmAddrBus]  addrb,   //  Address
    input  wire [`WordDataBus] dinb,    //  Write data
    input  wire                web,     //  Write enabled
    output reg  [`WordDataBus] doutb   //  Read-out data
);

    /***** Memory *****/
    reg [`WordDataBus] mem [0:`SPM_DEPTH-1]

    /***** Memory access (Port A) *****/
    always @(posedge clka) begin
        //  Read Access
        if ((web == `ENABLE) && (addra == addrb)) begin
            douta   <= #1 dinb;
        end else begin
            douta   <= #1 mem[addra];
        end

        //  Write Access
        if (wea == `ENABLE) begin
            mem[addra] <= #1 dina;
        end
    end

    /***** Memory access (Port B) *****/
    always @(posedge clkb) begin
        //  Read Access
        if ((wea == `ENABLE) && (addrb == addra)) begin
            doutb   <= #1 dina;
        end else begin 
            doutb   <= #1 mem[addrb]; 
        end

        //  Write Access
        if (web == `ENABLE) begin
            mem[addrb] <= #1 dinb;
        end
    end

endmodule
