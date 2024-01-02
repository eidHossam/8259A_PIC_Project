module Control_Logic_Testbench;

  // Inputs
  reg chip_select_n;
  reg read_enable_n;
  reg write_enable_n;
  reg A0;
  reg [7:0] data_bus_in;

  reg [7:0] IRRperipheralInterrupts;
  reg eoi;
  reg INTA;

  // Outputs
  wire [7:0] data_bus_out;
  wire INT;

  // Instantiate the module under test
  Control_Logic uut (
    .chip_select_n(chip_select_n),
    .read_enable_n(read_enable_n),
    .write_enable_n(write_enable_n),
    .A0(A0),
    .data_bus_in(data_bus_in),
    .data_bus_out(data_bus_out),
    .IRRperipheralInterrupts(IRRperipheralInterrupts),
    .eoi(eoi),
    .INTA(INTA),
    .INT(INT)
  );

  // Initial stimulus
  initial begin
    // Initialize inputs
    chip_select_n = 1;
    read_enable_n = 1;
    write_enable_n = 1;
    A0 = 0;
    data_bus_in = 8'h00;
    IRRperipheralInterrupts = 8'h00;
    eoi = 0;
    INTA = 1;
    #10
    
    // Apply stimulus

    //First of all, we need to initialize the PIC by sending an ICW1 and setting the PIC to be level sensitive.
    chip_select_n = 0;
    read_enable_n = 1;
    write_enable_n = 0;
    A0 = 0;
    data_bus_in = 8'h18;
    eoi = 0;
    INTA = 1;
    #10

    //Sending an OCW1 to change the interrupt mask to  8'b00001010, and sending interrupts on lines [0 : 3].
    data_bus_in = 8'b00000000;
    A0 = 1;
    #10

    data_bus_in = 8'b00000000;
    A0 = 0;
    IRRperipheralInterrupts = 8'h81;
    #10
    
    IRRperipheralInterrupts = 8'h00;
    INTA = 0;   //Sending the first acknowledgement from the CPU.
    #10
    
    //Sending the following 2 pulses on INTA line to send the ISR vector.
    INTA = 1;
    #10
    INTA = 0;
    #10
    INTA = 1;
    #10
    INTA = 0;
    #10

    //Sending an OCW3 and a read enable signal to be able to read the status of the IRR register.
    INTA = 1;
    read_enable_n = 0;
    write_enable_n = 0;
    A0 = 0;
    data_bus_in = 8'b00001010;
    #10
    
    //Reading the status of the ISR register.
    data_bus_in = 8'b00001011;
    #10
    
    data_bus_in = 8'b00000000;    
    #10

    //Sending an end of interrupt signal to inform the PIC that the execution of the interrupt service has completed.
    eoi = 1;
    #10


    //test case when we are executing an interrupt and a higher interrupt comes in
    eoi = 0;
    A0 = 0;
    data_bus_in = 8'h00;
    #10
    
    INTA = 0;   //Sending the first acknowledgement from the CPU.
    #10

    //Sending the following 2 pulses on INTA line to send the ISR vector.
    INTA = 1;
    #10
    INTA = 0;
    #10
    INTA = 1;
    #10
    INTA = 0;
    #10
    
    IRRperipheralInterrupts = 8'h01;  //A higher interrupt
    #10
    
    INTA = 0;   //Sending the first acknowledgement from the CPU.
    #10

    //Sending the following 2 pulses on INTA line to send the ISR vector.
    INTA = 1;
    #10
    INTA = 0;
    #10
    INTA = 1;
    #10
    INTA = 0;
    #10
    

    //Sending an end of interrupt signal to inform the PIC that the execution of the interrupt service has completed.
    eoi = 1;
    #10


    // Wait for simulation to finish
    #100 $finish;
  end

endmodule
