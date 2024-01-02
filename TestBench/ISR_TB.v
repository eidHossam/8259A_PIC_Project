`include "ISR.v"
`timescale 1ns/1ps

module ISR_tb;

  // Inputs
  reg EOI;
  reg [7:0] currentInterrupt;

  // Outputs
  wire [7:0] ISR;

  // Instantiate the ISR module
  ISR ISR_inst (
    .eoi(EOI),
    .int_no(currentInterrupt),
    .isr(ISR)
  );

  // Initial values
  initial begin
    EOI = 0;
    currentInterrupt = 8'b00000000;

    // Test scenario 1: Handle currentInterrupt
    #10 currentInterrupt = 8'b00000100; // Set bit 2
    #10;
    #10 $display("ISR = %b", ISR); // Should display "ISR = 00000100"

    // Test scenario 2: Handle EOI
    #10 currentInterrupt = 8'b00000100; // Set bit 2
    #10 EOI = 1;
    #10;
    #10 $display("ISR = %b", ISR); // Should display "ISR = 00000000"

    // Test scenario 3: Handle multiple interrupts
    EOI = 0;
    currentInterrupt = 8'b00001000; // Set bit 3
    #10
    #10 $display("ISR = %b", ISR); // Should display "ISR = 00001010"
    #10 currentInterrupt = 8'b00000010; // Set bit 1
    #10;
    #10 $display("ISR = %b", ISR); // Should display "ISR = 00001010"

    // Test scenario 4: Handle EOI
    #10 EOI = 1;
    #10;
    #10 $display("ISR = %b", ISR); // Should display "ISR = 00001000"
    // End simulation
    #10 $finish;
  end

endmodule
