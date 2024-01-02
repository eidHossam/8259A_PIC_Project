`include "src/IRR.v"
`include "src/ISR.v"
`include "src/Interrupt_Mask.v"
`include "src/R_W_Logic.v"


module Control_Logic (
    // In/Out for Bus_Control_Logic
    input wire           chip_select_n,
    input wire           read_enable_n,
    input wire           write_enable_n,
    input wire           A0,
    input wire   [7:0]   data_bus_in,
    output reg   [7:0]   data_bus_out,

    // In/Out for IRR_Module
    input wire   [7:0]   IRRperipheralInterrupts,
    
    input wire           eoi,
    
    //Input from CPU
    input wire INTA,
    
    //Output to CPU
    output reg INT
);
  
    //components
    wire [7:0]  internal_bus_buffer;
    wire ICW1;
    wire OCW1;
    wire OCW3;
    wire read_signal;
  
    // Instantiate modules
    Bus_Control_Logic bus_ctrl (
        .chip_select_n(chip_select_n),
        .read_enable_n(read_enable_n),
        .write_enable_n(write_enable_n),
        .A0(A0),
        .data_bus_in(data_bus_in),
        .internal_data_bus(internal_bus_buffer),
        .write_initial_command_word_1(ICW1),
        .write_operation_control_word_1(OCW1),
        .write_operation_control_word_3(OCW3),
        .read(read_signal)
    );
    
    // Internal Signals
    wire [7:0]      maskedInterruptRequest;
    wire [7:0]      ISR;
    wire [7:0]      interruptVector; //Holds the current interrupt to be serviced
    Priority_Resolver priority_res (
        .maskedInterruptRequest(maskedInterruptRequest),
        .ISR(ISR),
        .interruptVector(interruptVector)
    );
    
    reg  [7:0]  interruptMask;
    wire [7:0]  mask;                   //The current mask used
    wire [7:0]  interruptRequest;        
    Interrupt_Mask interrupt_mask (
        .interruptRequest(interruptRequest),
        .interruptMask(interruptMask),
        .irq(maskedInterruptRequest),
        .interruptMask_output(mask)
    );

    reg[7:0] int_no;
    reg internal_eoi;
    ISR isr_module (
        .int_no(int_no),
        .eoi(internal_eoi),
        .isr(ISR)
    );
    
    reg sensitivityMode;    //Register to hold the value of the sensitivity mode
    reg [7:0] clearInterruptRequest; //Clear the interrupt request flag
    reg [7:0] IRR_input;
    IRR irr_module (
        .sensitivityMode(sensitivityMode),
        .clearInterruptRequest(clearInterruptRequest),
        .peripheralInterrupts(IRR_input),
        .interruptRequest(interruptRequest)
    );

    
    //Virtual Vector addresses
    reg [15:0] address [7:0];
    
    //parameters for the OCW3
    parameter READ_IRR = 2'b10;
    parameter READ_ISR = 2'b11;

    //The state machine of the interrupt controller
    parameter IDLE          = 0;
    parameter PIC_INIT      = 1;
    parameter PIC_READY     = 2;
    parameter WAIT_CPU_ACK  = 3;
    parameter SEND_ADDRESS  = 4;
    parameter WAIT_EOI      = 5;
    parameter CLEAR_ISR     = 6;

    reg [2:0] current_state;
    reg prev_INTA;

    initial begin
        INT = 0;
        internal_eoi = 0;
        int_no = 8'b00000000;
        current_state = IDLE;
        address[0] = 16'h5A3F;
        address[1] = 16'h8D72;
        address[2] = 16'h1FAC;
        address[3] = 16'hB694;
        address[4] = 16'h2E1D;
        address[5] = 16'h7B5E;
        address[6] = 16'hF821;
        address[7] = 16'hC3D9;
    end

    always @* begin
        case (current_state)
            IDLE : if(ICW1 == 1)  current_state = PIC_INIT;
            PIC_INIT : begin
                sensitivityMode <= internal_bus_buffer[3];      //Configure the sensitivity mode based on ICW1[3]
                interruptMask <= 0;                             //Clear the interrupt mask.
                current_state <= PIC_READY;
            end
            PIC_READY: begin
                clearInterruptRequest <= 0;
                if(interruptVector != 0) //There is an interrupt to be serviced.
                begin
                    INT <= 1;        //Signal to the CPU that there is an interrupt to be serviced.
                    current_state <= WAIT_CPU_ACK;
                end
            end
            WAIT_CPU_ACK: begin
                INT <= 0;
                if(~INTA)
                begin
                    clearInterruptRequest <= interruptVector;    //Clear the interrupt bit in IRR
                    internal_eoi <= 0;
                    int_no <= interruptVector;                   //Set the bit in ISR

                    data_bus_out <= 8'b11001101;                 //Release a CALL instruction code onto the 8-bit Data bus
                                                                 //through its D7±0 pins.
                    current_state <= SEND_ADDRESS;
                end
            end
            SEND_ADDRESS: begin
                if(prev_INTA & ~INTA)
                begin
                    data_bus_out <= address[(interruptVector / 2)];
                    
                    if(prev_INTA & ~INTA)
                    begin
                        data_bus_out <= (address[(interruptVector / 2)] >> 8);
                        current_state <= WAIT_EOI;
                    end
                end
            end
            WAIT_EOI: begin
                //If we got a higher interrupt then resolve it first
                if(interruptVector < int_no)
                begin
                    clearInterruptRequest <= 0;
                    IRR_input <= int_no;
                    current_state <= WAIT_CPU_ACK;
                end
                else if(eoi)
                begin
                    current_state <= CLEAR_ISR;
                end
            end
            CLEAR_ISR: begin
                internal_eoi <= 1;
                current_state <= PIC_READY;
            end
        endcase

        if((current_state != IDLE && current_state != IDLE))
        begin
            if(OCW1) interruptMask <= data_bus_in;   //Set the masked as programmed by the CPU
            
            if(OCW3 & read_signal) 
            begin
                case (data_bus_in[1:0])
                   READ_IRR : data_bus_out <= interruptRequest;
                   READ_ISR : data_bus_out <= ISR;
                endcase
            end
        end

        prev_INTA = INTA; 
        IRR_input = IRRperipheralInterrupts;
    end

endmodule
