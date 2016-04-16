////////////////////////////////////////////////////////////////////////////////////
// File Name: ram.v
// Author: Sung Min Kim
// Email: sungk9@uw.edu
//
// Copyright (c) 2012-2016 University of Washington
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// -       Redistributions of source code must retain the above copyright notice,
//         this list of conditions and the following disclaimer.
// -       Redistributions in binary form must reproduce the above copyright notice,
//         this list of conditions and the following disclaimer in the documentation
//         and/or other materials provided with the distribution.
// -       Neither the name of the University of Washington nor the names of its
//         contributors may be used to endorse or promote products derived from this
//         software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY OF WASHINGTON AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE UNIVERSITY OF WASHINGTON OR CONTRIBUTORS BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
// OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

// Ram module for NPU memories,
// to be used during synthesis testing
//
// MEMSEL_W number of MSB's are used to select the memory,
// and the remaining REGSEL_W number of bits are used for
// addressing registers
//

module ram #(
  parameter DEPTH = 2048,
  parameter WIDTH = 16,
  parameter MEMSEL_W = 3,
  parameter REGSEL_W = 11,
  parameter MEM_ADDR = 3'b000
)(
  dout,
  mem_adr,
  reg_adr,
  clk,
  din,
  we
);

// Outputs
output [WIDTH-1:0]    dout;    // RAM data output

// Inputs
input [MEMSEL_W-1:0]  mem_adr; // memory selection address
input [REGSEL_W-1:0]  reg_adr; // register selection address
input                 clk;     // clock
input [WIDTH-1:0]     din;     // mem data input
input                 we;      // write enable (active high)

// RAM
reg   [WIDTH-1:0] mem [0:DEPTH-1];

// RAM write behavior
always @(posedge clk) begin
  if (mem_adr == MEM_ADDR && reg_adr <= DEPTH && we) begin
    mem[reg_adr] <= din;
  end else begin
    mem[reg_adr] <= mem[reg_adr];
  end
end

// RAM read behavior
reg [WIDTH-1:0] dout_reg;
always @(posedge clk) begin
  if (reg_adr <= DEPTH-1) dout_reg <= mem[reg_adr];
  else                    dout_reg <= {WIDTH{1'bx}};
end

// Output assignment
assign dout = dout_reg;

endmodule
