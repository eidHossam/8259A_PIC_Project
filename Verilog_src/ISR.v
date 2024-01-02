module ISR (
    input [7:0] int_no,  // Interrupt number being serviced
    input eoi,           // End of Interrupt signal
    output reg [7:0] isr  // In-Service Register output
);
  
  initial begin
    isr = 8'b00000000;
    isr = 0;
  end
    // Always block for asynchronous operation:
    always @* begin
        if (eoi) begin
            isr = 0;  // Reset the bit for the interrupt
        end else begin
            isr = 8'b00000000;
            isr = int_no;  // Set the bit for the interrupt being serviced
        end
    end

endmodule