/*
 -- ============================================================================
 -- FILE	 : bus_arbiter.v
 -- SYNOPSIS : Bus Arbiter
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	
 -- 2.0.0	  2020.1.31   Floyd-Fish
 -- ============================================================================
*/

/***** Common Header Files *****/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/***** Indivisual Header Files *****/
`include "bus.h"

module bus_arbiter (

    /***** Time_clock and Reset *****/
    input wire          clk,        //Clock
    input wire          reset,      //Asynchronous Sync

    /***** Arbitration Signal *****/
    //  Bus Master 0
    input wire          m0_req_,    //Bus Request
    output reg          m0_grnt_,   //Bus Grant
    //  Bus Master 1
    input wire          m1_req_,    //Bus Request
    output reg          m1_grnt_,   //Bus Grant
    //  Bus Master 2
    input wire          m2_req_,    //Bus Request 
    output reg          m2_grnt_,   //Bus Grant 
    //  Bus Master 3
    input wire          m3_req_,    //Bus Request 
    output reg          m3_grnt_   //Bus Grant 
);

    /***** Internal Signals *****/
    reg [`BusOwnerBus] owner;       //Owner of the Bus right

    /***** Generation of Bus Grant *****/
    always @(*) begin
        //  Initialize Bus Grant
        m0_grnt_ = `DISABLE_;
        m1_grnt_ = `DISABLE_;
        m2_grnt_ = `DISABLE_;
        m3_grnt_ = `DISABLE_;
        //  Generate Bus Grant
        case (owner)
            `BUS_OWNER_MASTER_0 : begin //  Bus Master 0
                m0_grnt_ = `ENABLE_;
            end
            `BUS_OWNER_MASTER_1 : begin //  Bus Master 1
                m1_grnt_ = `ENABLE_;
            end
            `BUS_OWNER_MASTER_2 : begin //  Bus Master 2
                m2_grnt_ = `ENABLE_;
            end
            `BUS_OWNER_MASTER_3 : begin //  Bus Master 3
                m3_grnt_ = `ENABLE_;
            end
        endcase
    end

    /***** Arbitration of Bus Rights *****/
    always @(posedge clk or `RESET_EDGE reset) begin
        if (reset == `RESET_ENABLE) begin
            //  Asynchronous reset
            owner <= #1 `BUS_OWNER_MASTER_0;
        end else begin
            //  Arbitration 
            case (owner)
                /***** Bus Owner: Bus Master 0 *****/
                `BUS_OWNER_MASTER_0 : begin
                    //  Next Master who acquires the bus control right
                    if (m0_req_ == `ENABLE_) begin              //  Bus Master 0
                        owner <= #1 `BUS_OWNER_MASTER_0;
                    end else if (m1_req_ == `ENABLE_) begin     //  Bus Master 1
                        owner <= #1 `BUS_OWNER_MASTER_1;        
                    end else if (m2_req_ == `ENABLE_) begin     //  Bus Master 2
                        owner <= #1 `BUS_OWNER_MASTER_2;        
                    end else if (m3_req_ == `ENABLE_) begin     //  Bus Master 3
                        owner <= #1 `BUS_OWNER_MASTER_3;
                    end
                end

                /***** Bus Owner: Bus Master 1 *****/
                `BUS_OWNER_MASTER_1 : begin
                    //  Next Master who acquires the bus control right
                    if (m1_req_ == `ENABLE_) begin              //  Bus Master 1
                        owner <= #1 `BUS_OWNER_MASTER_1;
                    end else if (m2_req_ == `ENABLE_) begin     //  Bus Master 2
                        owner <= #1 `BUS_OWNER_MASTER_2;        
                    end else if (m3_req_ == `ENABLE_) begin     //  Bus Master 3
                        owner <= #1 `BUS_OWNER_MASTER_3;        
                    end else if (m0_req_ == `ENABLE_) begin     //  Bus Master 0
                        owner <= #1 `BUS_OWNER_MASTER_0;
                    end
                end

                /***** Bus Owner: Bus Master 2 *****/
                `BUS_OWNER_MASTER_2 : begin
                    //  Next Master who acquires the bus control right
                    if (m2_req_ == `ENABLE_) begin              //  Bus Master 2
                        owner <= #1 `BUS_OWNER_MASTER_2;
                    end else if (m3_req_ == `ENABLE_) begin     //  Bus Master 3
                        owner <= #1 `BUS_OWNER_MASTER_3;        
                    end else if (m0_req_ == `ENABLE_) begin     //  Bus Master 0
                        owner <= #1 `BUS_OWNER_MASTER_0;        
                    end else if (m1_req_ == `ENABLE_) begin     //  Bus Master 1
                        owner <= #1 `BUS_OWNER_MASTER_1;
                    end
                end

                /***** Bus Owner: Bus Master 3 *****/
                `BUS_OWNER_MASTER_3 : begin
                    //  Next Master who acquires the bus control right
                    if (m3_req_ == `ENABLE_) begin              //  Bus Master 3
                        owner <= #1 `BUS_OWNER_MASTER_3;
                    end else if (m0_req_ == `ENABLE_) begin     //  Bus Master 0
                        owner <= #1 `BUS_OWNER_MASTER_0;        
                    end else if (m1_req_ == `ENABLE_) begin     //  Bus Master 1
                        owner <= #1 `BUS_OWNER_MASTER_1;        
                    end else if (m2_req_ == `ENABLE_) begin     //  Bus Master 2
                        owner <= #1 `BUS_OWNER_MASTER_2;
                    end
                end
            endcase
        end
    end

endmodule
