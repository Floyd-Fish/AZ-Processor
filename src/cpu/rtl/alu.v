/*
 -- ============================================================================
 -- FILE	 : alu.v
 -- SYNOPSIS : Arithmetic logic unit
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.2.7   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "cpu.h"

/***** Modules *****/
module alu (
    input  wire [`WordDataBus] in_0,    //  Input port 0
    input  wire [`WordDataBus] in_1,    //  Input port 1
    input  wire [`AluopBus]    op,      //  Operation
    output reg  [`WordDataBus] out,     //  Output port
    output reg                 of       //  Overflow
);

/***** Signed input/output signal *****/
    wire signed [`WordDataBus] s_in_0 = $signed (in_0);     //  Signed input port 0
    wire signed [`WordDataBus] s_in_1 = $signed (in_1);     //  Signed input port 1
    wire signed [`WordDataBus] s_out  = $signed (out);      //  Signed output

    /***** Arithmetic logic operation *****/
    always @(*) begin
        case (op)
            `ALU_OP_AND     : begin     //  AND
                out     =   in_0 & in_1;
            end
            `ALU_OP_OR      : begin     //  OR
                out     =   in_0 | in_1;
            end
            `ALU_OP_XOR     : begin     //  XOR
                out     =   in_0 ^ in_1;
            end
            `ALU_OP_ADDS    : begin     //  Signed addition
                out     =   in_0 + in_1;
            end
            `ALU_OP_ADDU    : begin     //  Unsigned addition
                out     =   in_0 + in_1;
            end
            `ALU_OP_SUBS    : begin     //  Signed subtraction
                out     =   in_0 - in_1;
            end
            `ALU_OP_SUBU    : begin     //  Unsigned subtraction
                out     =   in_0 - in_1;
            end
            `ALU_OP_SHRL    : begin     //  Logic shift right
                out     =   in_0 >> in_1[`ShAmountLoc];
            end
            `ALU_OP_SHLL    : begin     //  Logic shift left
                out     =   in_0 << in_1[`ShAmountLoc];
            end
            default         : begin     // Default : No operation
                out     = in_0;
            end
        endcase
    end

    /***** Overflow Check *****/
    always @(*) begin
        case (op)
            `ALU_OP_ADDS : begin    //  Check for addition overflow
                if (((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
                    ((s_in_0 < 0) && (s_in_1 <0) && (s_out > 0))) begin
                    of = `ENABLE;
                end else begin
                    of = `DISABLE;
                end
            end

            `ALU_OP_SUBS : begin    //  Check for subtraction overflow
                if (((s_in_0 < 0) && (s_in_1 > 0 ) && (s_out >0)) ||
                    ((s_in_0 >0) && (s_in_1 <0) && (s_out < 0))) begin
                    of = `ENABLE;
                end else begin
                    of = `DISABLE;
                end
            end
            default : begin     //  Default value
                of = `DISABLE;
            end
        endcase
    end

endmodule

            


















