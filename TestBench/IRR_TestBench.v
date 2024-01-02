`timescale 1ns/1ps
`include "IRR.v"

module IRR_tb;

  // Parameters
  parameter SIM_TIME = 1000;

  // Signals
  reg sensitivityMode;
  reg [7:0] peripheralInterrupts;
  wire [7:0] interruptRequest;

  // Instantiate the IRR module
  IRR uut (
    .sensitivityMode(sensitivityMode),
    .peripheralInterrupts(peripheralInterrupts),
    .interruptRequest(interruptRequest)
  );

  // Initial stimulus
  initial begin
    // Initialize inputs
    sensitivityMode = 0;
    peripheralInterrupts = 8'b00000000;

    // Apply stimulus and monitor outputs
    repeat(SIM_TIME) begin
      // Apply random stimuli
      sensitivityMode = $random;
      peripheralInterrupts = $random;

      // Display inputs
      $display("Time=%0t | sensitivityMode=%b | peripheralInterrupts=%b", $time, sensitivityMode, peripheralInterrupts);

      // Wait for some time
      #1;

      // Display outputs
      $display("Time=%0t | interruptRequest=%b", $time, interruptRequest);
    end

    // End simulation
    $finish;
  end

endmodule
