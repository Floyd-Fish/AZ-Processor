/*
 -- ============================================================================
 -- FILE	 : bus_slave_mux.v
 -- SYNOPSIS : Bus Slave Address Multiplexer
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

/***** Modules *****/
module bus_slave_mux (
    /***** Chip Select *****/
    input  wire				   s0_cs_,      //  Bus Slave 0
	input  wire				   s1_cs_,      //  Bus Slave 1 
	input  wire				   s2_cs_,      //  Bus Slave 2 
	input  wire				   s3_cs_,      //  Bus Slave 3 
	input  wire				   s4_cs_,      //  Bus Slave 4 
	input  wire				   s5_cs_,      //  Bus Slave 5 
	input  wire				   s6_cs_,      //  Bus Slave 6 
	input  wire				   s7_cs_,      //  Bus Slave 7 
    /***** Bus Slave Signal *****/
    //  Bus Slave 0
    input wire [`WordDataBus] s0_rd_data,   //  Read Data
    input wire                s0_rdy_,      //  Ready
    //  Bus Slave 1
    input wire [`WordDataBus] s1_rd_data,   //  Read Data
    input wire                s1_rdy_,      //  Ready
    //  Bus Slave 2
    input wire [`WordDataBus] s2_rd_data,   //  Read Data
    input wire                s2_rdy_,      //  Ready
    //  Bus Slave 3
    input wire [`WordDataBus] s3_rd_data,   //  Read Data
    input wire                s3_rdy_,      //  Ready
    //  Bus Slave 4
    input wire [`WordDataBus] s4_rd_data,   //  Read Data
    input wire                s4_rdy_,      //  Ready
    //  Bus Slave 5
    input wire [`WordDataBus] s5_rd_data,   //  Read Data
    input wire                s5_rdy_,      //  Ready
    //  Bus Slave 6
    input wire [`WordDataBus] s6_rd_data,   //  Read Data
    input wire                s6_rdy_,      //  Ready
    //  Bus Slave 7
    input wire [`WordDataBus] s7_rd_data,   //  Read Data
    input wire                s7_rdy_,      //  Ready
    /***** Bus Master Common Signal(s) *****/
    output reg [`WordDataBus] m_rd_data,    //  Read-out data
    output reg                m_rdy_        //  Ready
);

    /***** Bus Slave Multiplexer *****/
    always @(*) begin
        //  Select Slave Corresponded to Chip Select Signal
        if (s0_cs_ == `ENABLE) begin                //  Bus Slave 0
            m_rd_data = s0_rd_data;
            m_rdy_ = s0_rdy_;
        end else if (s1_cs_ == `ENABLE) begin       //  Bus Slave 1
            m_rd_data = s1_rd_data;
            m_rdy_ = s1_rdy_;
        end else if (s2_cs_ == `ENABLE) begin       //  Bus Slave 2
            m_rd_data = s2_rd_data;
            m_rdy_ = s2_rdy_;
        end else if (s3_cs_ == `ENABLE) begin       //  Bus Slave 3
            m_rd_data = s3_rd_data;
            m_rdy_ = s3_rdy_;
        end else if (s4_cs_ == `ENABLE) begin       //  Bus Slave 4
            m_rd_data = s4_rd_data;
            m_rdy_ = s4_rdy_;
        end else if (s5_cs_ == `ENABLE) begin       //  Bus Slave 5
            m_rd_data = s5_rd_data;
            m_rdy_ = s5_rdy_;
        end else if (s6_cs_ == `ENABLE) begin       //  Bus Slave 6
            m_rd_data = s6_rd_data;
            m_rdy_ = s6_rdy_;
        end else if (s7_cs_ == `ENABLE) begin       //  Bus Slave 7
            m_rd_data = s7_rd_data;
            m_rdy_ = s7_rdy_;
        end else begin 
            m_rd_data = `WORD_DATA_W'h0;
            m_rdy_    = `DISABLE_;
        end
    end

endmodule
