`timescale 1ns/1ps
`include "IRR.v"
`include "Interrupt_Mask.v"

`timescale 1ns/1ps

module Testbench;

  // Parameters
  parameter SIM_TIME = 1000;

  // Signals for IRR module
  reg sensitivityMode;
  reg [7:0] peripheralInterrupts;
  reg [7:0] clear;
  wire [7:0] interruptRequest;

  // Instantiate the IRR module
  IRR uut_irr (
    .sensitivityMode(sensitivityMode),
    .clearInterruptRequest(clear),
    .peripheralInterrupts(peripheralInterrupts),
    .interruptRequest(interruptRequest)
  );

  // Signals for Interrupt_Mask module
  reg [7:0] interruptMask;
  wire[7:0] mask;
  wire [7:0] irq; // Declare wire for Interrupt_Mask module output

  // Instantiate the Interrupt_Mask module
  Interrupt_Mask uut_mask (
    .interruptRequest(interruptRequest),
    .interruptMask(interruptMask),
    .irq(irq),  // Connect wire to the irq output
    .interruptMask_output(mask)
  );

  // Initial stimulus
  initial begin
    // Initialize inputs
    sensitivityMode = 0;
    clear = 0;
    peripheralInterrupts = 8'b00000000;
    interruptMask = 8'b00000000;
  
  #10
    // Apply stimulus and monitor outputs
    repeat(SIM_TIME) begin
      // Apply random stimuli
      sensitivityMode = $random;
      peripheralInterrupts = $random;
      clear = $random;
      interruptMask = $random;

      // Display inputs
      $display("Time=%0t | sensitivityMode=%b | peripheralInterrupts=%b | interruptMask=%b", $time, sensitivityMode, peripheralInterrupts, interruptMask);

      // Wait for some time
      #1;

      // Display outputs of IRR module
      $display("Time=%0t | interruptRequest=%b", $time, interruptRequest);

      // Display outputs of Interrupt_Mask module
      $display("Time=%0t | irq=%b | mask=%b", $time, irq, mask);
    end

    // End simulation
    $finish;
  end

endmodule