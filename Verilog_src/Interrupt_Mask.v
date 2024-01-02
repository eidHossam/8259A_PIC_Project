module Interrupt_Mask (
    input wire [7:0] interruptRequest,
    input wire [7:0] interruptMask,
    output reg [7:0] irq,
    output reg [7:0] interruptMask_output
);
   
    initial begin
        interruptMask_output = 0;
    end
    
    always @* begin
        // Combinational logic to mask interrupts
        irq = interruptRequest & ~interruptMask;
        interruptMask_output = interruptMask;
    end

endmodule
