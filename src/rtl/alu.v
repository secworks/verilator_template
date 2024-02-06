//======================================================================
//
// alu.v
// -----
// A simple ALU used as example Device Under Test (DUT).
//
//
// Author: Joachim Strombergson
// Copyright (c) 2024, Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

`default_nettype none

module alu(
           // Clock and reset.
           input wire           clk,
           input wire           reset_n,

           // Control.
           input wire           cs,
           input wire           we,

           // Data ports.
           input wire  [7 : 0]  address,
           input wire  [31 : 0] write_data,
           output wire [31 : 0] read_data
          );

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam ADDR_CTRL          = 8'h08;
  localparam CTRL_EXECUTE_BIT   = 0;

  localparam ADDR_CONFIG        = 8'h0a;
  localparam CONFIG_ADD_SUB_BIT = 0;

  localparam ADDR_OPA           = 8'h10;
  localparam ADDR_OPB           = 8'h11;

  localparam ADDR_RESULT        = 8'h20;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [31 : 0] opa_reg;
  reg          opa_we;

  reg [31 : 0] opb_reg;
  reg          opb_we;

  reg          add_sub_reg;
  reg          add_sub_we;

  reg [31 : 0] result_reg;
  reg [31 : 0] result_new;
  reg          result_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0]   tmp_read_data;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign read_data = tmp_read_data;


  //----------------------------------------------------------------
  // reg_update
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      if (!reset_n) begin
      end

      else begin
          if (opa_we) begin
            opa_reg <= write_data;
	  end

          if (opb_we) begin
            opb_reg <= write_data;
	  end

	if (add_sub_we) begin
	  add_sub_reg <= write_data[CONFIG_ADD_SUB_BIT];
	end
      end
    end // reg_update


  //----------------------------------------------------------------
  // alu_logic
  //----------------------------------------------------------------
  always @*
    begin: alu_logic
      if (add_sub_reg) begin
	result_new = opa_reg - opb_reg;

      end else begin
	result_new = opa_reg + opb_reg;
      end
    end


  //----------------------------------------------------------------
  // api
  //----------------------------------------------------------------
  always @*
    begin : api
      opa_we        = 1'b0;
      opb_we        = 1'b0;
      add_sub_we    = 1'h0;
      result_we     = 1'h0;
      tmp_read_data = 32'h0;

      if (cs) begin
          if (we) begin
            if (address == ADDR_CTRL) begin
              result_we = write_data[CTRL_EXECUTE_BIT];
            end

            if (address == ADDR_CONFIG) begin
              add_sub_we = 1'h1;
	    end

            if (address == ADDR_OPA) begin
              opa_we = 1'h1;
	    end

            if (address == ADDR_OPB) begin
              opb_we = 1'h1;
	    end
          end // if (we)

          else begin
            if (address == ADDR_CONFIG) begin
              tnm_read_data = {31'h0, add_sub_reg};
	    end

            if (address == ADDR_OPA) begin
              tnm_read_data = opa_reg;
	    end

            if (address == ADDR_OPB) begin
              tnm_read_data = opb_reg;
	    end

            if (address == ADDR_RESULT) begin
              tnm_read_data = result_reg;
	    end
          end
      end
    end
endmodule // aes

//======================================================================
// EOF aes.v
//======================================================================
