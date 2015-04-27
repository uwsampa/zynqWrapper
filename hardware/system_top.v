//-----------------------------------------------------------------------------
// system_top.v
// Author: Thierry Moreau
// Email: moreau@cs.washington.edu
//-----------------------------------------------------------------------------

module system_top
  (
    processing_system7_0_MIO,
    processing_system7_0_PS_SRSTB,
    processing_system7_0_PS_CLK,
    processing_system7_0_PS_PORB,
    processing_system7_0_DDR_Clk,
    processing_system7_0_DDR_Clk_n,
    processing_system7_0_DDR_CKE,
    processing_system7_0_DDR_CS_n,
    processing_system7_0_DDR_RAS_n,
    processing_system7_0_DDR_CAS_n,
    processing_system7_0_DDR_WEB,
    processing_system7_0_DDR_BankAddr,
    processing_system7_0_DDR_Addr,
    processing_system7_0_DDR_ODT,
    processing_system7_0_DDR_DRSTB,
    processing_system7_0_DDR_DQ,
    processing_system7_0_DDR_DM,
    processing_system7_0_DDR_DQS,
    processing_system7_0_DDR_DQS_n,
    processing_system7_0_DDR_VRN,
    processing_system7_0_DDR_VRP
  );
  `include "macros.inc"
  `include "params.inc"

  inout [53:0] processing_system7_0_MIO;
  input processing_system7_0_PS_SRSTB;
  input processing_system7_0_PS_CLK;
  input processing_system7_0_PS_PORB;
  inout processing_system7_0_DDR_Clk;
  inout processing_system7_0_DDR_Clk_n;
  inout processing_system7_0_DDR_CKE;
  inout processing_system7_0_DDR_CS_n;
  inout processing_system7_0_DDR_RAS_n;
  inout processing_system7_0_DDR_CAS_n;
  output processing_system7_0_DDR_WEB;
  inout [2:0] processing_system7_0_DDR_BankAddr;
  inout [14:0] processing_system7_0_DDR_Addr;
  inout processing_system7_0_DDR_ODT;
  inout processing_system7_0_DDR_DRSTB;
  inout [31:0] processing_system7_0_DDR_DQ;
  inout [3:0] processing_system7_0_DDR_DM;
  inout [3:0] processing_system7_0_DDR_DQS;
  inout [3:0] processing_system7_0_DDR_DQS_n;
  inout processing_system7_0_DDR_VRN;
  inout processing_system7_0_DDR_VRP;

  // clock and reset
  wire clk, rst_n;
  // from PS7
  wire          evento;
  wire          arready;
  wire          rvalid;
  wire [63:0]   rdata;
  wire          awready;
  wire          wready;
  wire          bvalid;
  // to PS7
  wire          eventi;
  wire          arvalid;
  wire          awvalid;
  wire          rready;
  wire          wlast;
  wire          wvalid;
  wire [3:0]    arlen;
  wire [3:0]    awlen;
  wire [31:0]   araddr;
  wire [31:0]   awaddr;
  wire [63:0]   wdata;


  reg [63:0] counter;
  reg [63:0] counter_out;

  (* BOX_TYPE = "user_black_box" *)
  system
    system_i (
      .processing_system7_0_MIO ( processing_system7_0_MIO ),
      .processing_system7_0_PS_SRSTB ( processing_system7_0_PS_SRSTB ),
      .processing_system7_0_PS_CLK ( processing_system7_0_PS_CLK ),
      .processing_system7_0_PS_PORB ( processing_system7_0_PS_PORB ),
      .processing_system7_0_DDR_Clk ( processing_system7_0_DDR_Clk ),
      .processing_system7_0_DDR_Clk_n ( processing_system7_0_DDR_Clk_n ),
      .processing_system7_0_DDR_CKE ( processing_system7_0_DDR_CKE ),
      .processing_system7_0_DDR_CS_n ( processing_system7_0_DDR_CS_n ),
      .processing_system7_0_DDR_RAS_n ( processing_system7_0_DDR_RAS_n ),
      .processing_system7_0_DDR_CAS_n ( processing_system7_0_DDR_CAS_n ),
      .processing_system7_0_DDR_WEB ( processing_system7_0_DDR_WEB ),
      .processing_system7_0_DDR_BankAddr ( processing_system7_0_DDR_BankAddr ),
      .processing_system7_0_DDR_Addr ( processing_system7_0_DDR_Addr ),
      .processing_system7_0_DDR_ODT ( processing_system7_0_DDR_ODT ),
      .processing_system7_0_DDR_DRSTB ( processing_system7_0_DDR_DRSTB ),
      .processing_system7_0_DDR_DQ ( processing_system7_0_DDR_DQ ),
      .processing_system7_0_DDR_DM ( processing_system7_0_DDR_DM ),
      .processing_system7_0_DDR_DQS ( processing_system7_0_DDR_DQS ),
      .processing_system7_0_DDR_DQS_n ( processing_system7_0_DDR_DQS_n ),
      .processing_system7_0_DDR_VRN ( processing_system7_0_DDR_VRN ),
      .processing_system7_0_DDR_VRP ( processing_system7_0_DDR_VRP ),
      // From NPU to PS7
      .processing_system7_0_EVENT_EVENTI ( eventi ),
      .processing_system7_0_S_AXI_ACP_ARVALID ( arvalid ),
      .processing_system7_0_S_AXI_ACP_AWVALID ( awvalid ),
      .processing_system7_0_S_AXI_ACP_RREADY ( rready ),
      .processing_system7_0_S_AXI_ACP_WLAST ( wlast ),
      .processing_system7_0_S_AXI_ACP_WVALID ( wvalid ),
      .processing_system7_0_S_AXI_ACP_ARLEN ( arlen ),
      .processing_system7_0_S_AXI_ACP_AWLEN ( awlen ),
      .processing_system7_0_S_AXI_ACP_ARADDR ( araddr ),
      .processing_system7_0_S_AXI_ACP_AWADDR ( awaddr ),
      .processing_system7_0_S_AXI_ACP_WDATA ( wdata ),
      // From PS7 to NPU
      .processing_system7_0_EVENT_EVENTO ( evento ),
      .processing_system7_0_S_AXI_ACP_ARREADY ( arready ),
      .processing_system7_0_S_AXI_ACP_RVALID ( rvalid ),
      .processing_system7_0_S_AXI_ACP_RDATA ( rdata ),
      .processing_system7_0_S_AXI_ACP_AWREADY ( awready ),
      .processing_system7_0_S_AXI_ACP_WREADY ( wready ),
      .processing_system7_0_S_AXI_ACP_BVALID ( bvalid ),
      .processing_system7_0_FCLK_CLK0 ( clk ),
      .processing_system7_0_FCLK_RESET0_N ( rst_n )
    );

  zynqWrapper zynqWrapper(
      .CLK ( clk ),
      .RST_N ( rst_n ),
      .evento ( evento ),
      .arready ( arready ),
      .rvalid ( rvalid ),
      .rdata ( rdata ),
      .awready ( awready ),
      .wready ( wready ),
      .bvalid ( bvalid ),
      .eventi ( eventi ),
      .arvalid ( arvalid ),
      .awvalid ( awvalid ),
      .rready ( rready ),
      .wlast ( wlast ),
      .wvalid ( wvalid ),
      .arlen ( arlen ),
      .awlen ( awlen ),
      .araddr ( araddr ),
      .awaddr ( awaddr ),
      .wdata ( wdata )
    );

  always @ (posedge clk) begin
    if ( rst_n == 1'b0 ) begin
      counter     <= 0;
      counter_out <= 0;
    end else begin
      counter     <= counter + {{63{1'b0}},1'b1};
      counter_out <= counter;
    end
  end

endmodule

