/*
 -- ============================================================================
 -- FILE	 : bus_if.v
 -- SYNOPSIS : Bus interface
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
`include "bus.h"

/***** Module *****/
module bus_if (
    /***** Clock & Reset *****/
    input  wire                 clk,            //  Clock
    input  wire                 reset,          //  Asynchronous reset

    /***** Pipeline control signal *****/
    input  wire                 stall,          //  Stall
    input  wire                 flush,          //  Flush signal
    output reg                  busy,           //  Busy signal

    /***** CPU Interface *****/
    input  wire [`WordAddrBus]  addr,           //  Address
    input  wire                 as_,            //  Address Valid
    input  wire                 rw_,            //  Read / Write
    input  wire [`WordDataBus]  wr_data,        //  Write data
    input  wire [`WordDataBus]  rd_data,        //  Read-out data

    /***** SPM Interface *****/
    input  wire [`WordDataBus]  spm_rd_data,    //  Read-out data
    input  wire [`WordAddrBus]  spm_addr,       //  Address
    output reg                  spm_as_,        //  Address Strobe
    output wire                 spm_rw,         //  Read / Write
    output wire [`WordDataBus]  spm_wr_data,    //  Write data

    /***** Bus Interface *****/
    input  wire [`WordDataBus]  bus_rd_data,    //  Read-out data
    input  wire                 bus_rdy_,       //  Ready
    input  wire                 bus_grnt_,      //  Bus grant
    output reg                  bus_req_,       //  Bus request
    output reg  [`WordAddrBus]  bus_addr,       //  Address
    output reg                  bus_as_,        //  Address Strobe
    output reg                  bus_rw,         //  Read / Write
    output reg [`WordDataBus]   bus_wr_data     //  Write data
);

    /***** Internal signals *****/  
    reg     [`BusIfStateBus]    state;          //  Bus interface status
    reg     [`WordDataBus]      rd_buf;         //  Read-out buffer
    wire    [`BusSlaveIndexBus] s_index;        //  Bus slave index

    /***** Bus slave index *****/
    assign s_index      = addr[`BusSlaveIndexLoc];

    /***** Output assignment *****/
    assign spm_addr     = addr;
    assign spm_rw       = rw;
    assign spm_wr_data  = wr_data;

    /***** Controlling memory access *****/
    always @(*) begin
        /* Default Value */
        rd_data     = `WORD_DATA_W'h0;
        spm_as_     = `DISABLE_;
        busy        = `DISABLE;

        /* Bus Interface Status */
        case (state) 
            `BUS_IF_STATE_IDLE   : begin    //  Idle
                /* Memory access */
                if ((flush == `DISABLE) && (as_ == `ENABLE_)) begin
                    /* Select access destination */
                    if (s_index == `BUS_SLAVE_1) begin  //  Access SPM
                        if (stall == `DISABLE) begin    //  Check for stall occurrence
                            spm_as_ = `ENABLE_;
                            if (rw == `READ) begin      //  Read access
                                rd_data = spm_rd_data;
                            end
                        end
                    end else begin
                        busy    = `ENABLE;
                    end
                end
            end
            `BUS_IF_STATE_REQ    : begin    //  Bus request
                busy    = `ENABLE;
            end
            `BUS_OF_STATE_ACCESS : begin    //  Bus access
                /* Ready Waiting */
                if (bus_rdy_ == `ENABLE_) begin     //  Ready arrival
                    if (rw == `READ) begin  // Read access
                        rd_data  = bus_rd_data;
                    end
                end else begin
                    busy    = `ENABLE;
                end
            end
            `BUS_IF_STATE_STALL  : begin    //  Stall
                if (rw == `READ) begin  //  Read access
                    rd_data  = rd_buf;
                end
            end
        endcase
    end

    /***** Bus interface state control *****/
    always @(posedge clk or `RESET_EDGE reset) begin
        if (reset == `RESET_ENABLE) begin
            /* Asynchronous reset */
            state       <= #1 `BUS_IF_STATE_IDLE;
            bus_req_    <= #1 `DISABLE_;
            bus_addr    <= #1 `WORD_ADDR_W'h0;
            bus_as_     <= #1 `DISABLE_;
            bus_rw      <= #1 `READ;
            bus_wr_data <= #1 `WORD_DATA_W'h0;
            rd_buf      <= #1 `WORD_DATA_W'h0;
        end else begin
            /* Bus interface status */
            case (state) 
                `BUS_IF_STATE_IDLE   : begin    //  Idle
                    /* Memory access */
                    if ((flush == `DISABLE) && (as_ == `ENABLE_)) begin
                        /* Select access destination */
                        if (s_index != `BUS_SLAVE_1) begin  //  Access to bus
                            state       <= #1 `BUS_IF_STATE_REQ;
                            bus_req_    <= #1 `ENABLE_;
                            bus_addr    <= #1 addr;
                            bus_rw      <= #1 rw;
                            bus_wr_data <= #1 wr_data;
                        end
                    end
                end
                `BUS_IF_STATE_REQ    : begin    //  Bus request
                    /* Waiting for bus request */
                    if (bus_grnt_ == `ENABLE_) begin    //  Bus right acquisition
                        state       <= #1 `BUS_IF_STATE_ACCESS;
                        bus_as_     <= #1 `ENABLE_;
                    end
                end
                `BUS_IF_STATE_ACCESS : begin    //  Bus access 
                    /* Negation of address strobe */
                    bus_as_     <= #1 `DISABLE_;

                    /* Ready waiting */
                    if (bus_rdy_ == `ENABLE_) begin //  Ready arrival
                        bus_req_        <= #1 `DISABLE_;
                        bus_addr        <= #1 `WORD_ADDR_W'h0;
                        bus_rw          <= #1 `READ;
                        bus_wr_data     <= #1 `WORD_DATA_W'h0;

                        /* Saving read data */
                        if (bus_rw == `READ) begin  //  Read access
                            rd_buf      <= #1 bus_rd_data;
                        end

                        /* Check for stall occurrence */
                        if (stall == `ENABLE) begin //  Stall occurred
                            state       <= #1 `BUS_IF_STATE_STALL;
                        end else begin 
                            state       <= #1 `BUS_IF_STATE_IDLE;
                        end
                    end
                end
                `BUS_IF_STATE_STALL  : begin    //  Stall
                    /* Check for stall occurrence */
                    if (stall == `DISABLE) begin    //  Stall release
                        state           <= #1 `BUS_IF_STATE_IDLE;
                    end
                end
            endcase
        end
    end

endmodule
