/*
 -- ============================================================================
 -- FILE	 : bus.v
 -- SYNOPSIS : Bus Top level
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

/***** Module *****/
module bus (
    /***** Clock & Reset *****/
    input  wire                clk,         //  Clock
    input  wire                reset,       //  Asynchronous Reset

    /***** Bus Master Signal(s) *****/
    //  Bus Master Common Signal
    output wire [`WordDataBus] m_rd_data,   //  Read-out Data
    output wire                m_rdy_,      //  Ready
    //  Bus Master 0
	input  wire				   m0_req_,	    //  Bus Request
	input  wire [`WordAddrBus] m0_addr,	    //  Address
	input  wire				   m0_as_,	    //  Address Strobe
	input  wire				   m0_rw,	    //  Read / Write
	input  wire [`WordDataBus] m0_wr_data,  //  Write data
	output wire				   m0_grnt_,    //  Bus grant
    //  Bus Master 1
	input  wire				   m1_req_,	    //  Bus Request
	input  wire [`WordAddrBus] m1_addr,	    //  Address
	input  wire				   m1_as_,	    //  Address Strobe
	input  wire				   m1_rw,	    //  Read / Write
	input  wire [`WordDataBus] m1_wr_data,  //  Write data
	output wire				   m1_grnt_,    //  Bus grant
    //  Bus Master 2
	input  wire				   m2_req_,	    //  Bus Request
	input  wire [`WordAddrBus] m2_addr,	    //  Address
	input  wire				   m2_as_,	    //  Address Strobe
	input  wire				   m2_rw,	    //  Read / Write
	input  wire [`WordDataBus] m2_wr_data,  //  Write data
	output wire				   m2_grnt_,    //  Bus grant
    //  Bus Master 3
	input  wire				   m3_req_,	    //  Bus Request
	input  wire [`WordAddrBus] m3_addr,	    //  Address
	input  wire				   m3_as_,	    //  Address Strobe
	input  wire				   m3_rw,	    //  Read / Write
	input  wire [`WordDataBus] m3_wr_data,  //  Write data
	output wire				   m3_grnt_,    //  Bus grant

    /***** Bus Slave Signal *****/
    //  Bus Slave Common Signal
    output wire [`WordAddrBus] s_addr,      //  Address
    output wire                s_as_,       //  Address Strobe
    output wire                s_rw,        //  Read / Write
    output wire [`WordDataBus] s_wr_data,   //  Write Data
    //Bus Slave 0
	input  wire [`WordDataBus] s0_rd_data,  //  Read-out data
	input  wire				   s0_rdy_,	    //  Ready
	output wire				   s0_cs_,	    //  Chip Select
    //Bus Slave 1
	input  wire [`WordDataBus] s1_rd_data,  //  Read-out data
	input  wire				   s1_rdy_,	    //  Ready
	output wire				   s1_cs_,	    //  Chip Select
    //Bus Slave 2
	input  wire [`WordDataBus] s2_rd_data,  //  Read-out data
	input  wire				   s2_rdy_,	    //  Ready
	output wire				   s2_cs_,	    //  Chip Select
    //Bus Slave 3
	input  wire [`WordDataBus] s3_rd_data,  //  Read-out data
	input  wire				   s3_rdy_,	    //  Ready
	output wire				   s3_cs_,	    //  Chip Select
    //Bus Slave 4
	input  wire [`WordDataBus] s4_rd_data,  //  Read-out data
	input  wire				   s4_rdy_,	    //  Ready
	output wire				   s4_cs_,	    //  Chip Select
    //Bus Slave 5
	input  wire [`WordDataBus] s5_rd_data,  //  Read-out data
	input  wire				   s5_rdy_,	    //  Ready
	output wire				   s5_cs_,	    //  Chip Select
    //Bus Slave 6
	input  wire [`WordDataBus] s6_rd_data,  //  Read-out data
	input  wire				   s6_rdy_,	    //  Ready
	output wire				   s6_cs_,	    //  Chip Select
    //Bus Slave 7
	input  wire [`WordDataBus] s7_rd_data,  //  Read-out data
	input  wire				   s7_rdy_,	    //  Ready
	output wire				   s7_cs_	    //  Chip Select
);

    /***** Bus Arbiter *****/
    bus_arbiter bus_arbiter (
        /***** Clock & Reset *****/
        .clk        (clk),      //  Clock
        .reset      (reset),    //  Asynchronous Reset

        /***** Arbitration Signal *****/
        //  Bus Master 0
        .m0_req_    (m0_req_),  //  Bus Request
        .m0.grnt_   (m0_grnt_), //  Bus Grant
        //  Bus Master 1
        .m1_req_    (m1_req_),  //  Bus Request
        .m1.grnt_   (m1_grnt_), //  Bus Grant
        //  Bus Master 2
        .m2_req_    (m2_req_),  //  Bus Request
        .m2.grnt_   (m2_grnt_), //  Bus Grant
        //  Bus Master 3
        .m3_req_    (m3_req_),  //  Bus Request
        .m3.grnt_   (m3_grnt_) //  Bus Grant
    );

    /***** Bus Master Multiplexer *****/
    bus_master_mux bus_master_mux (
        /***** Bus Master Signal *****/
        //  Bus Master 0
        .m0_addr        (m0_addr),      //  Address
        .m0_as_         (m0_as_),       //  Address Strobe
        .m0_rw          (m0_rw),        //  Read / Write
        .m0_wr_data     (m0_wr_data),   //  Write Data
        .m0_grnt_       (m0_grnt_),     //  Bus Grant
        //  Bus Master 1
        .m1_addr        (m1_addr),      //  Address
        .m1_as_         (m1_as_),       //  Address Strobe
        .m1_rw          (m1_rw),        //  Read / Write
        .m1_wr_data     (m1_wr_data),   //  Write Data
        .m1_grnt_       (m1_grnt_),     //  Bus Grant
        //  Bus Master 2
        .m2_addr        (m2_addr),      //  Address
        .m2_as_         (m2_as_),       //  Address Strobe
        .m2_rw          (m2_rw),        //  Read / Write
        .m2_wr_data     (m2_wr_data),   //  Write Data
        .m2_grnt_       (m2_grnt_),     //  Bus Grant
        //  Bus Master 3
        .m3_addr        (m3_addr),      //  Address
        .m3_as_         (m3_as_),       //  Address Strobe
        .m3_rw          (m3_rw),        //  Read / Write
        .m3_wr_data     (m3_wr_data),   //  Write Data
        .m3_grnt_       (m3_grnt_),     //  Bus Grant

        /***** Bus Slave Common Signal *****/
        .s_addr         (s_addr),       //  Address
        .s_as_          (s_as_),        //  Address Strobe
        .s_rw           (s_rw),         // Read / Write
        .s_wr_data      (s_wr_data)     // Write Data
    );

    /***** Address Decoder *****/
    bus_addr_dec bus_addr_dec (
        /***** Address *****/
        .s_addr         (s_addr),       //  Address
        /***** Chip Select *****/
        .s0_cs_         (s0_cs_),       //  Bus Slave 0
        .s1_cs_         (s1_cs_),       //  Bus Slave 1
        .s2_cs_         (s2_cs_),       //  Bus Slave 2
        .s3_cs_         (s3_cs_),       //  Bus Slave 3
        .s4_cs_         (s4_cs_),       //  Bus Slave 4
        .s5_cs_         (s5_cs_),       //  Bus Slave 5
        .s6_cs_         (s6_cs_),       //  Bus Slave 6
        .s7_cs_         (s7_cs_)        //  Bus Slave 7
    );

    /***** Bus Slave Multiplexer *****/
    bus_slave_mux bus_slave_mux (
        /***** Chip Select *****/
		.s0_cs_		    (s0_cs_),	    //  Bus Slave 0
		.s1_cs_		    (s1_cs_),	    //  Bus Slave 1
		.s2_cs_		    (s2_cs_),	    //  Bus Slave 2
		.s3_cs_		    (s3_cs_),	    //  Bus Slave 3
		.s4_cs_		    (s4_cs_),	    //  Bus Slave 4
		.s5_cs_		    (s5_cs_),	    //  Bus Slave 5
		.s6_cs_		    (s6_cs_),	    //  Bus Slave 6
		.s7_cs_		    (s7_cs_),	    //  Bus Slave 7

        /***** Bus Slave Signal *****/
        //  Bus Slave 0
        .s0_rd_data     (s0_rd_data),   //  Read-out Data
        .s0_rdy_        (s0_rdy_),      //  Ready
        //  Bus Slave 1
        .s1_rd_data     (s1_rd_data),   //  Read-out Data
        .s1_rdy_        (s1_rdy_),      //  Ready
        //  Bus Slave 2
        .s2_rd_data     (s2_rd_data),   //  Read-out Data
        .s2_rdy_        (s2_rdy_),      //  Ready
        //  Bus Slave 3
        .s3_rd_data     (s3_rd_data),   //  Read-out Data
        .s3_rdy_        (s3_rdy_),      //  Ready
        //  Bus Slave 4
        .s4_rd_data     (s4_rd_data),   //  Read-out Data
        .s4_rdy_        (s4_rdy_),      //  Ready
        //  Bus Slave 5
        .s5_rd_data     (s5_rd_data),   //  Read-out Data
        .s5_rdy_        (s5_rdy_),      //  Ready
        //  Bus Slave 6
        .s6_rd_data     (s6_rd_data),   //  Read-out Data
        .s6_rdy_        (s6_rdy_),      //  Ready
        //  Bus Slave 7
        .s7_rd_data     (s7_rd_data),   //  Read-out Data
        .s7_rdy_        (s7_rdy_),      //  Ready

        /***** Bus Master Common Signal *****/
        .m_rd_data      (m_rd_data),    //  Read-out Data
        .m_rdy_         (m_rdy_)        //  Ready
    );

endmodule