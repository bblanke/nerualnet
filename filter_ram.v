/*********************************************************************************************

    File name   : filter_ram.v
    Author      : Bailey Blankenship
    Affiliation : North Carolina State University, Raleigh, NC
    Date        : Nov 2017
    email       : bblanke@ncsu.edu

    Description : Filter ram


*********************************************************************************************/

//`timescale 1ns/10ps

module filter_ram (
    input wire [9:0] address,
    input wire [15:0] write_data,
    output reg [15:0] read_data,
    input wire enable,
    input wire write,
    input wire clock
    );


    initial begin
      $readmemh("filter.hex", memory);
    end
    //--------------------------------------------------------
    // Associative memory

    reg [15:0] memory [0:575];


    //--------------------------------------------------------
    // Read

    always @(*)
      begin
        #4 read_data = (enable && ~write) ? memory [address] : 16'hx;
      end

    //--------------------------------------------------------
    // Write

    always @(posedge clock)
      begin
        if (enable && write) memory [address] = write_data;
      end
    //--------------------------------------------------------


endmodule
