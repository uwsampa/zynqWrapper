//-----------------------------------------------------------------------------
// zynqWrapper.v
// Author: Thierry Moreau
// Email: moreau@cs.washington.edu
//-----------------------------------------------------------------------------

module zynqWrapper
(
    // clock and reset
    CLK,
    RST_N,

    // event bus
    evento,
    eventi,

    // axi master input
    arready,
    rvalid,
    rdata,
    awready,
    wready,
    bvalid,

    // axi master output
    arvalid,
    awvalid,
    rready,
    wlast,
    wvalid,
    arlen,
    awlen,
    araddr,
    awaddr,
    wdata,

    // read and write control
    READ_ADDR_BASE,
    WRITE_ADDR_BASE,

    // ram ports
    ram_din,
    ram_reg_adr,
    ram_mem_adr,
    ram_we
);

    `include "macros.inc"
    `include "params.inc"

    // clock and reset
    input                           CLK;
    input                           RST_N;
    // inputs from PS7
    input                           evento;
    input                           arready;
    input                           rvalid;
    input [ACP_WIDTH-1:0]           rdata;
    input                           awready;
    input                           wready;
    input                           bvalid;
    // outputs to PS7
    output                          eventi;
    output                          arvalid;
    output                          awvalid;
    output                          rready;
    output                          wlast;
    output                          wvalid;
    output [3:0]                    arlen;
    output [3:0]                    awlen;
    output [ADDR_WIDTH-1:0]         araddr;
    output [ADDR_WIDTH-1:0]         awaddr;
    output [ACP_WIDTH-1:0]          wdata;

    input [ADDR_WIDTH-1:0]          READ_ADDR_BASE;
    input [ADDR_WIDTH-1:0]          WRITE_ADDR_BASE;


    // ram ports
    input [ACP_WIDTH-1:0] ram_din;
    input [11:0] ram_reg_adr;
    input [2:0] ram_mem_adr;
    input ram_we;


    localparam READ_BURSTS        = BATCH_SIZE/AXI_BURST_LEN;
    localparam WRITE_BURSTS       = BATCH_SIZE/AXI_BURST_LEN;
    localparam FIFO_THRSHLD       = AXI_BURST_LEN;

    // Read burst counter width
    localparam RB_CNTR_WIDTH      = 10;
    // Write counter width
    localparam WR_CNTR_WIDTH      = 4;
    // Write burst counter width
    localparam WB_CNTR_WIDTH      = 10;
    // Read counter width
    localparam RD_CNTR_WIDTH      = 16;

    // FSM states
    localparam STATE_IDLE         = 0;

    localparam STATE_RD_RQ_0      = 1;
    localparam STATE_RD_RQ_1      = 2;

    localparam STATE_WR_RQ0       = 1;
    localparam STATE_WR_RQ1       = 2;
    localparam STATE_WR_RQ_WAIT   = 3;
    localparam STATE_WROTE0       = 4;
    localparam STATE_WROTE1       = 5;
    localparam STATE_WRITE_WAIT   = 6;

    // Registers
    `REG(rstate,            reg, 3,              STATE_IDLE);
    `REG(wstate,            reg, 3,              STATE_IDLE);

    `REG(cpuevent,          reg, 1,              0         );
    `REG(cpuevent_dly,      reg, 1,              0         );
    `REG(cpuwakeup,         reg, 1,              0         );

    `REG(tx_started,        reg, 1,              0         );
    `REG(tx_requests,       reg, TR_RQ_WIDTH,    0         );

    `REG(rb_cntr,           reg, RB_CNTR_WIDTH,  0         );
    `REG(wr_cntr,           reg, WR_CNTR_WIDTH,  0         );
    `REG(wb_cntr,           reg, WB_CNTR_WIDTH,  0         );
    `REG(bv_cntr,           reg, WB_CNTR_WIDTH,  0         );

    // Inputs
    `REG(arready_i,         reg, 1,              0         );
    `REG(rvalid_i,          reg, 1,              0         );
    `REG(rdata_i,           reg, ACP_WIDTH,      0         );
    `REG(awready_i,         reg, 1,              0         );
    `REG(wready_i,          reg, 1,              0         );
    `REG(bvalid_i,          reg, 1,              0         );

    // Outputs
    `REG(do_read,           reg, 1,              0         );
    `REG(wraddr_val,        reg, 1,              0         );
    `REG(wrdata_val,        reg, 1,              0         );
    `REG(rdata_rdy,         reg, 1,              0         );
    `REG(rdata_rdy_dly,     reg, 1,              0         );
    `REG(last_write,        reg, 1,              0         );
    `REG(wr_len,            reg, 4,              0         );
    `REG(wr_data,           reg, ACP_WIDTH,      0         );
    `REG(rd_addr,           reg, ADDR_WIDTH,     0         );
    `REG(wr_addr,           reg, ADDR_WIDTH,     0         );

    // Datapath
    `REG(npu_in,            reg, ACP_WIDTH,      0         );
    `REG(npu_enq,           reg, 1,              0         );

    // Combinational reg
    `CREG(npu_deq,          1);

    // Wires
    wire [ACP_WIDTH-1:0]            npu_out;
    wire [FIFO_CNT_W-1:0]           fifo_count;

    wire                            wr_burst_rdy;
    wire                            rd_burst_wait;

    // Decoding logic
    assign wr_burst_rdy     = (fifo_count >= FIFO_THRSHLD) ? 1'b1 : 1'b0;
    assign rd_burst_wait    = (fifo_count >= FIFO_DEPTH-FIFO_THRSHLD) ? 1'b1 : 1'b0;
    // Outputs
    assign eventi   = cpuwakeup;
    assign arvalid  = do_read;
    assign awvalid  = wraddr_val;
    assign rready   = rdata_rdy;
    assign wvalid   = wrdata_val;
    assign wlast    = (AXI_BURST_LEN==1) ? 1'b1 : last_write;
    assign arlen    = AXI_BURST_LEN-1;
    assign awlen    = wr_len;
    assign wdata    = wr_data;
    assign araddr   = rd_addr;
    assign awaddr   = wr_addr;

    /////////////////////////////
    // Latch inputs
    /////////////////////////////

    always@(*) begin
        arready_i_d         = 0;
        rvalid_i_d          = 0;
        rdata_i_d           = 0;
        awready_i_d         = 0;
        wready_i_d          = 0;
        bvalid_i_d          = 0;
        if (RST_N) begin
            arready_i_d     = arready;
            rvalid_i_d      = rvalid;
            rdata_i_d       = rdata;
            awready_i_d     = awready;
            wready_i_d      = wready;
            bvalid_i_d      = bvalid;
        end
    end


    /////////////////////////////
    // READ State Machine
    /////////////////////////////

    always@(*) begin

        rstate_d            = rstate;

        cpuevent_d          = evento;
        cpuevent_dly_d      = cpuevent;

        tx_started_d        = tx_started;
        tx_requests_d       = tx_requests;

        rb_cntr_d           = rb_cntr;

        rd_addr_d           = rd_addr;
        do_read_d           = 1'b0;
        rdata_rdy_d         = 1'b1;
        rdata_rdy_dly_d     = rdata_rdy;

        npu_in_d            = npu_in;
        npu_enq_d           = 1'b0;

        if(RST_N) begin

            // Handle Read Data
            if (rvalid_i == 1'b1 && tx_started == 1'b1 && rdata_rdy_dly == 1'b1) begin
                npu_in_d            = rdata_i;
                npu_enq_d           = 1'b1;
            end

            // Prevent input buffer overflow
            if(rd_burst_wait) begin
                rdata_rdy_d         = 1'b0;
            end

            if (cpuevent_dly^cpuevent) begin
                tx_requests_d       = tx_requests + 1;
                tx_started_d        = 1'b1;
            end

            // Handle Read Requests
            case(rstate)
                STATE_IDLE: begin
                    if (|tx_requests) begin
                        if (cpuevent_dly^cpuevent) begin
                           tx_requests_d       = tx_requests;
                        end else begin
                           tx_requests_d       = tx_requests - 1;
                        end
                        rb_cntr_d       = 0;
                        rd_addr_d       = READ_ADDR_BASE;
                        do_read_d       = 1'b1;
                        rstate_d        = STATE_RD_RQ_0;
                    end else
                        rstate_d        = STATE_IDLE;
                end
                STATE_RD_RQ_0: begin
                    rstate_d        = STATE_RD_RQ_1;
                end
                STATE_RD_RQ_1: begin
                    if (arready_i == 1'b1) begin
                        if (rb_cntr == READ_BURSTS-1)
                            rstate_d        = STATE_IDLE;
                        else begin
                            rb_cntr_d       = rb_cntr + {{(RB_CNTR_WIDTH-1){1'b0}},1'b1};
                            rd_addr_d       = rd_addr + 32'h00000080;
                            do_read_d       = 1'b1;
                            rstate_d        = STATE_RD_RQ_0;
                        end
                    end else begin
                        do_read_d       = 1'b1;
                        rstate_d        = STATE_RD_RQ_0;
                    end
                end
            endcase
        end
    end


    /////////////////////////////
    // Write State Machine
    /////////////////////////////

    always@(*) begin

        wstate_d            = wstate;

        npu_deq             = 1'b0;

        wr_cntr_d           = wr_cntr;
        wb_cntr_d           = wb_cntr;
        bv_cntr_d           = bv_cntr;

        cpuwakeup_d         = cpuwakeup;
        wraddr_val_d        = 1'b0;
        wrdata_val_d        = 1'b0;
        last_write_d        = 1'b0;
        wr_len_d            = wr_len;
        wr_addr_d           = wr_addr;
        wr_data_d           = wr_data;

        if(RST_N) begin

            if (bv_cntr==WRITE_BURSTS) begin
                bv_cntr_d   = {{(WB_CNTR_WIDTH-1){1'b0}},{bvalid_i}};
                cpuwakeup_d = ~cpuwakeup;
            end else if (bvalid_i == 1'b1)
                bv_cntr_d   = bv_cntr + {{(WB_CNTR_WIDTH-1){1'b0}},1'b1};

            // Handle writes
            case(wstate)
                STATE_IDLE: begin
                    if (wr_burst_rdy == 1'b1) begin
                        wr_cntr_d           = 0;
                        wb_cntr_d           = 0;
                        wraddr_val_d        = 1'b1;
                        wr_len_d            = AXI_BURST_LEN-1;
                        wr_addr_d           = WRITE_ADDR_BASE;
                        wstate_d            = STATE_WR_RQ0;
                    end else
                        wstate_d            = STATE_IDLE;
                end
                STATE_WR_RQ_WAIT: begin
                    if (wr_burst_rdy == 1'b1) begin
                        wr_cntr_d           = 0;
                        wb_cntr_d           = wb_cntr + {{(WB_CNTR_WIDTH-1){1'b0}},1'b1};
                        wraddr_val_d        = 1'b1;
                        wr_len_d            = AXI_BURST_LEN-1;
                        wr_addr_d           = wr_addr + 32'h00000080;
                        wstate_d            = STATE_WR_RQ0;
                    end
                end
                STATE_WR_RQ0:
                    wstate_d                = STATE_WR_RQ1;
                STATE_WR_RQ1: begin
                    if (awready_i == 1'b1) begin
                        npu_deq             = 1'b1;
                        wrdata_val_d        = 1'b1;
                        wr_data_d           = npu_out;
                        wstate_d            = STATE_WROTE0;
                    end else begin
                        wraddr_val_d        = 1'b1;
                        wstate_d            = STATE_WR_RQ0;
                    end
                end
                STATE_WROTE0:
                    wstate_d                = STATE_WROTE1;
                STATE_WROTE1: begin
                    if (wready_i == 1'b1) begin
                        if (wr_cntr == AXI_BURST_LEN-1) begin
                            if (wb_cntr == WRITE_BURSTS-1)
                                wstate_d    = STATE_IDLE;
                            else begin
                                wstate_d    = STATE_WR_RQ_WAIT;
                            end
                        end else begin
                            if (wr_cntr == AXI_BURST_LEN-2)
                                last_write_d = 1'b1;
                            npu_deq         = 1'b1;
                            wr_cntr_d       = wr_cntr + {{(WR_CNTR_WIDTH-1){1'b0}},1'b1};
                            wrdata_val_d    = 1'b1;
                            wr_data_d       = npu_out;
                            wstate_d        = STATE_WROTE0;
                        end
                    end else
                        wstate_d        = STATE_WRITE_WAIT;
                end
                STATE_WRITE_WAIT: begin
                    if (wready_i == 1'b1) begin
                        if (wr_cntr == AXI_BURST_LEN-1)
                            last_write_d = 1'b1;
                        wrdata_val_d    = 1'b1;
                        wstate_d        = STATE_WROTE0;
                    end else
                        wstate_d        = STATE_WRITE_WAIT;
                end
            endcase
        end
    end

    /////////////////////////////
    // FIFO
    /////////////////////////////

    BRAMFIFO #(
        .p1width(ACP_WIDTH),
        .p2depth(FIFO_DEPTH),
        .p3cntr_width(FIFO_CNT_W)) input_fifo (
        .CLK(CLK),
        .RST_N(RST_N),
        .D_IN(npu_in),
        .D_OUT(npu_out),
        .ENQ(npu_enq),
        .DEQ(npu_deq),
        .EMPTY_N(),
        .FULL_N(),
        .COUNT(fifo_count),
        .CLR(1'b0)
    );

    ram #(
        .DEPTH(4096),
        .WIDTH(ACP_WIDTH),
        .MEMSEL_W(3),
        .REGSEL_W(12),
        .MEM_ADDR(3'b000)
    )ram_test(
        .clk(CLK),
        .mem_adr(ram_mem_adr),
        .reg_adr(ram_reg_adr),
        .din(ram_din),
        .we(ram_we),
        .dout(ram_dout)
    );

endmodule
