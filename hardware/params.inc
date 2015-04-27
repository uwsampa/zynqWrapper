//-----------------------------------------------------------------------------
// params.inc
// Author: Thierry Moreau
// Email: moreau@cs.washington.edu
//-----------------------------------------------------------------------------

// High Level Parameters
localparam BATCH_SIZE       = 64;

// AXI-specific parameters
localparam ADDR_WIDTH       = 32;
localparam AXI_BURST_LEN    = 16;
localparam MAX_BURST_NUM    = 1024;
localparam READ_ADDR_BASE   = 32'hFFFF0000;
localparam WRITE_ADDR_BASE  = 32'hFFFF8000;
localparam TR_RQ_WIDTH      = 8;

// Bus width
localparam ACP_WIDTH        = 64;

// FIFO depth
localparam FIFO_DEPTH       = 1024;
localparam FIFO_CNT_W       = 10;