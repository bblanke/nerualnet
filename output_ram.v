/*********************************************************************************************

    File name   : filter_ram.v
    Author      : Bailey Blankenship
    Affiliation : North Carolina State University, Raleigh, NC
    Date        : Nov 2017
    email       : bblanke@ncsu.edu

    Description : Filter ram


*********************************************************************************************/

//`timescale 1ns/10ps

module output_ram (
    input wire [2:0] address,
    input wire [15:0] write_data,
    input wire enable,
    input wire write,
    input wire clock
    );

    //--------------------------------------------------------
    // Associative memory

    reg [15:0] memory [0:7];

    //--------------------------------------------------------
    // Write

    always @(posedge clock)
      begin
        if (enable && write) begin
         memory [address] = write_data;
         $display("writing: %h to address: %h", write_data, address);
         end
      end
    //--------------------------------------------------------


endmodule
