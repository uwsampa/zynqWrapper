`timescale 1ns / 1ps


module axi_top
(
    // clock and reset
    CLK,
    RST_N,
    
    // event bus
    EVENTO,
    EVENTI,
    
    // AXI4 Master (Input Data)
    M_AXI_ARREADY,
    M_AXI_RVALID,
    M_AXI_RDATA,
    M_AXI_AWREADY,
    M_AXI_WREADY,
    M_AXI_BVALID,
    M_AXI_ARVALID,
    M_AXI_AWVALID,
    M_AXI_RREADY,
    M_AXI_WLAST,
    M_AXI_WVALID,
    M_AXI_ARLEN,
    M_AXI_AWLEN,
    M_AXI_ARADDR,
    M_AXI_AWADDR,
    M_AXI_WDATA,
    M_AXI_ARBURST,
    M_AXI_ARCACHE,
    M_AXI_ARID,
    M_AXI_ARLOCK,
    M_AXI_ARPROT,
    M_AXI_ARQOS,
    M_AXI_ARSIZE,
    M_AXI_ARUSER,
    M_AXI_AWBURST,
    M_AXI_AWCACHE,
    M_AXI_AWID,
    M_AXI_AWLOCK,
    M_AXI_AWPROT,
    M_AXI_AWQOS,
    M_AXI_AWSIZE,
    M_AXI_AWUSER,
    M_AXI_BREADY,
    M_AXI_WID,
    M_AXI_WSTRB,
    
    // AXI4-Lite Slave (Control)
    S_AXI_AWADDR,
    S_AXI_AWPROT,
    S_AXI_AWVALID,
    S_AXI_AWREADY,
    S_AXI_WDATA,
    S_AXI_WSTRB,
    S_AXI_WVALID,
    S_AXI_WREADY,
    S_AXI_BRESP,
    S_AXI_BVALID,
    S_AXI_BREADY,
    S_AXI_ARADDR,
    S_AXI_ARPROT,
    S_AXI_ARVALID,
    S_AXI_ARREADY,
    S_AXI_RDATA,
    S_AXI_RRESP,
    S_AXI_RVALID,
    S_AXI_RREADY,

    // AXI-Stream Slave (Configuration)
    S_AXIS_TDATA,
    S_AXIS_TREADY,
    S_AXIS_TVALID,
);
    `include "macros.inc"
    `include "params.inc"

    // clock and reset
    input                           CLK;
    input                           RST_N;
    
    // event bus
    input                           EVENTO;
    output                          EVENTI;
    
    // AXI4 Master (Input Data)
    input                           M_AXI_ARREADY;
    input                           M_AXI_RVALID;
    input [ACP_WIDTH-1:0]           M_AXI_RDATA;
    input                           M_AXI_AWREADY;
    input                           M_AXI_WREADY;
    input                           M_AXI_BVALID;

    output                          M_AXI_ARVALID;
    output                          M_AXI_AWVALID;
    output                          M_AXI_RREADY;
    output                          M_AXI_WLAST;
    output                          M_AXI_WVALID;
    output [3:0]                    M_AXI_ARLEN;
    output [3:0]                    M_AXI_AWLEN;
    output [ADDR_WIDTH-1:0]         M_AXI_ARADDR;
    output [ADDR_WIDTH-1:0]         M_AXI_AWADDR;
    output [ACP_WIDTH-1:0]          M_AXI_WDATA;

    output [1:0]                    M_AXI_ARBURST;
    output [3:0]                    M_AXI_ARCACHE;
    output [2:0]                    M_AXI_ARID;
    output [1:0]                    M_AXI_ARLOCK;
    output [2:0]                    M_AXI_ARPROT;
    output [3:0]                    M_AXI_ARQOS;
    output [2:0]                    M_AXI_ARSIZE;
    output [4:0]                    M_AXI_ARUSER;
    output [1:0]                    M_AXI_AWBURST;
    output [3:0]                    M_AXI_AWCACHE;
    output [2:0]                    M_AXI_AWID;
    output [1:0]                    M_AXI_AWLOCK;
    output [2:0]                    M_AXI_AWPROT;
    output [3:0]                    M_AXI_AWQOS;
    output [2:0]                    M_AXI_AWSIZE;
    output [4:0]                    M_AXI_AWUSER;
    output                          M_AXI_BREADY;
    output [2:0]                    M_AXI_WID;
    output [7:0]                    M_AXI_WSTRB;

    // AXI4-Lite Slave (Control)
    input  [3 : 0]                  S_AXI_AWADDR;
    input  [2 : 0]                  S_AXI_AWPROT;
    input                           S_AXI_AWVALID;
    output                          S_AXI_AWREADY;
    input   [AXI_WIDTH-1 : 0]       S_AXI_WDATA;
    input  [(AXI_WIDTH/8)-1 : 0]    S_AXI_WSTRB;
    input                           S_AXI_WVALID;
    output                          S_AXI_WREADY;
    output [1 : 0]                  S_AXI_BRESP;
    output                          S_AXI_BVALID;
    input                           S_AXI_BREADY;
    input  [3 : 0]                  S_AXI_ARADDR;
    input  [2 : 0]                  S_AXI_ARPROT;
    input                           S_AXI_ARVALID;
    output                          S_AXI_ARREADY;
    output [AXI_WIDTH-1 : 0]        S_AXI_RDATA;
    output [1 : 0]                  S_AXI_RRESP;
    output                          S_AXI_RVALID;
    input                           S_AXI_RREADY;

    input [ACP_WIDTH-1:0] S_AXIS_TDATA;
    output                S_AXIS_TREADY;
    input                 S_AXIS_TVALID;
 

    assign M_AXI_ARBURST = 2'b01;
    assign M_AXI_ARCACHE = 4'b1111;
    assign M_AXI_ARID    = 3'b100;
    assign M_AXI_ARLOCK  = 2'b00;
    assign M_AXI_ARPROT  = 3'b000;
    assign M_AXI_ARQOS   = 4'b0000;
    assign M_AXI_ARSIZE  = 3'b011;
    assign M_AXI_ARUSER  = 5'b11111;
    assign M_AXI_AWBURST = 2'b01;
    assign M_AXI_AWCACHE = 4'b1111;
    assign M_AXI_AWID    = 3'b100;
    assign M_AXI_AWLOCK  = 2'b00;
    assign M_AXI_AWPROT  = 3'b000;
    assign M_AXI_AWQOS   = 4'b0000;
    assign M_AXI_AWSIZE  = 3'b011;
    assign M_AXI_AWUSER  = 5'b11111;
    assign M_AXI_BREADY  = 1'b1;
    assign M_AXI_WID     = 3'b100;
    assign M_AXI_WSTRB   = 8'hFF;

    wire [ADDR_WIDTH-1:0] read_addr_base;
    //assign read_addr_base = 32'hFFFF0000;
    
    wire [ADDR_WIDTH-1:0] write_addr_base;
    //assign write_addr_base = 32'hFFFF8000;
    
    wire [31:0] weight_control;

    zynqWrapper npu (
        // clock and reset
        .CLK(CLK),
        .RST_N(RST_N),
        
        // event bus
        .evento(EVENTO),
        .eventi(EVENTI),
        
        // axi master input
        .arready(M_AXI_ARREADY),
        .rvalid(M_AXI_RVALID),
        .rdata(M_AXI_RDATA),
        .awready(M_AXI_AWREADY),
        .wready(M_AXI_WREADY),
        .bvalid(M_AXI_BVALID),
        
        // axi master output
        .arvalid(M_AXI_ARVALID),
        .awvalid(M_AXI_AWVALID),
        .rready(M_AXI_RREADY),
        .wlast(M_AXI_WLAST),
        .wvalid(M_AXI_WVALID),
        .arlen(M_AXI_ARLEN),
        .awlen(M_AXI_AWLEN),
        .araddr(M_AXI_ARADDR),
        .awaddr(M_AXI_AWADDR),
        .wdata(M_AXI_WDATA),
        
        // read and write control
        .READ_ADDR_BASE(read_addr_base),
        .WRITE_ADDR_BASE(write_addr_base),
        
        .ram_din(ram_din),
        .ram_reg_adr(ram_reg_adr),
        .ram_mem_adr(ram_mem_adr),
        .ram_we(ram_we)
    );




    `REG(ram_din, reg, ACP_WIDTH, 0);
    
    `REG(ram_reg_adr, reg, 12, 0);
    
    wire [11:0] ram_input_length;
    assign ram_input_length = weight_control[11:0];
    
    wire [2:0]           ram_mem_adr;
    assign ram_mem_adr = weight_control[14:12];
    
    `REG(ram_we, reg, 1, 0);


    assign S_AXIS_TREADY = 1'b1;
      
    localparam STATE_IDLE       = 0;
    localparam STATE_RAM_READ   = 1;
    localparam STATE_RAM_IGNORE = 2;
    `REG(ram_rstate, reg, 3, STATE_IDLE);
    
    always @(*) begin
        ram_rstate_d  = ram_rstate;
        ram_reg_adr_d = ram_reg_adr;
        ram_din_d     = ram_din;
        ram_we_d      = 1'b0;
 
        if (RST_N) begin
        
            case(ram_rstate)
            
                STATE_IDLE: begin
                    // data incoming
                    if(S_AXIS_TVALID == 1'b1) begin
                    
                        // start transfer if control reg says so
                        if(|weight_control) begin
                            ram_reg_adr_d = 0;
                            ram_din_d     = S_AXIS_TDATA;
                            ram_rstate_d  = STATE_RAM_READ;
                            ram_we_d      = 1'b1;
                            
                        // otherwise ignore data
                        end else begin
                            ram_rstate_d  = STATE_RAM_IGNORE;
                        end
                    
                    // no data -- idle
                    end else begin
                        ram_rstate_d = STATE_IDLE;                        
                    end
                
                end
                
                STATE_RAM_READ: begin
                
                    // still data incoming
                    if(S_AXIS_TVALID == 1'b1) begin
                        
                        // but ram is already full -- excess data, ignore rest
                        if (ram_reg_adr == ram_input_length - 1) begin
                            ram_rstate_d = STATE_RAM_IGNORE;
                            
                        // ram is not full -- continue transfer at next offset                           
                        end else begin
                            ram_reg_adr_d = ram_reg_adr + 12'b1;
                            ram_din_d     = S_AXIS_TDATA;                        
                            ram_rstate_d  = STATE_RAM_READ;
                            ram_we_d      = 1'b1;
                        end
                    
                    
                    // no data this cycle
                    end else begin
                    
                        // transfer finished, go idle
                        // NOTE: if transfer isn't actually finished, (e.g. between bursts)
                        // this would re-start the ram write with the rest of the incoming data
                        if (ram_reg_adr == ram_input_length - 1) begin
                            ram_rstate_d = STATE_IDLE;
                
                        // transfer stalled, spin
                        end else begin
                            ram_rstate_d = STATE_RAM_READ;
                        end
                        
                    end
                end
                
                
                STATE_RAM_IGNORE: begin
                    if(S_AXIS_TVALID == 1'b1) begin
                        ram_rstate_d = STATE_RAM_IGNORE;
                    end else begin
                        ram_rstate_d = STATE_RAM_IDLE;
                    end
                end
            
            
            endcase
        
        end
    end
    
    

	slv_reg # ( 
		.C_S_AXI_DATA_WIDTH(AXI_WIDTH),
		.C_S_AXI_ADDR_WIDTH(4)
	) slv_reg_inst (
		.S_AXI_ACLK(CLK),
		.S_AXI_ARESETN(RST_N),
		.S_AXI_AWADDR(S_AXI_AWADDR),
		.S_AXI_AWPROT(S_AXI_AWPROT),
		.S_AXI_AWVALID(S_AXI_AWVALID),
		.S_AXI_AWREADY(S_AXI_AWREADY),
		.S_AXI_WDATA(S_AXI_WDATA),
		.S_AXI_WSTRB(S_AXI_WSTRB),
		.S_AXI_WVALID(S_AXI_WVALID),
		.S_AXI_WREADY(S_AXI_WREADY),
		.S_AXI_BRESP(S_AXI_BRESP),
		.S_AXI_BVALID(S_AXI_BVALID),
		.S_AXI_BREADY(S_AXI_BREADY),
		.S_AXI_ARADDR(S_AXI_ARADDR),
		.S_AXI_ARPROT(S_AXI_ARPROT),
		.S_AXI_ARVALID(S_AXI_ARVALID),
		.S_AXI_ARREADY(S_AXI_ARREADY),
		.S_AXI_RDATA(S_AXI_RDATA),
		.S_AXI_RRESP(S_AXI_RRESP),
		.S_AXI_RVALID(S_AXI_RVALID),
		.S_AXI_RREADY(S_AXI_RREADY),
		.reg0_out(read_addr_base),
		.reg1_out(write_addr_base),
		.reg2_out(weight_control)
	);


    

    
endmodule
