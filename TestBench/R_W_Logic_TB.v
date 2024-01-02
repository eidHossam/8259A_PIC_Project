
module Control_Bus_Logic;

  // Inputs
  reg chip_select_n;
  reg read_enable_n;
  reg write_enable_n;
  reg A0;
  reg [7:0] data_bus_in;

  // Outputs
  wire [7:0] internal_data_bus;
  wire write_initial_command_word_1;
  wire write_operation_control_word_1;
  wire write_operation_control_word_3;
  wire read;

  // Instantiate the module
  Bus_Control_Logic dut (
    .chip_select_n(chip_select_n),
    .read_enable_n(read_enable_n),
    .write_enable_n(write_enable_n),
    .A0(A0),
    .data_bus_in(data_bus_in),
    .internal_data_bus(internal_data_bus),
    .write_initial_command_word_1(write_initial_command_word_1),
    .write_operation_control_word_1(write_operation_control_word_1),
    .write_operation_control_word_3(write_operation_control_word_3),
    .read(read)
  );

  // Stimulus generation
  initial begin
    // Initialize inputs
    chip_select_n = 1;
    read_enable_n = 1;
    write_enable_n = 1;
    A0 = 0;
    data_bus_in = 8'b00000000;
    #10
    // Apply stimulus
    // test write data input 1101 0000
    chip_select_n = 0;        // select chip to make operation (read or write)
    write_enable_n = 0;       // enable write
    data_bus_in = 8'b11010000 ;     // input 1101 0000
    A0 = 0;                    // address[0] = 0  (this comes from processor)
    #10;
    
    write_enable_n = 0;        // enable write
    A0 = 1;                     // address[0] = 1  (this comes from processor)
    read_enable_n = 1;          // disable read
    #10;
    
    // test write data input 0000 1000
    write_enable_n = 0;         // enable write
    A0 = 0;                     // address[0] = 0  (this comes from processor)
    read_enable_n = 1;          // disable read
    data_bus_in = 8'b00001000;   // input 0000 1000
    #10;
    
    //test read
    write_enable_n = 1;
    A0 = 1;
    read_enable_n = 0;
    #10;

    
    #10 $finish;
  end

  // Monitor outputs
  always @* begin
    $display("internal_data_bus = %b", internal_data_bus);
    $display("write_initial_command_word_1 = %b", write_initial_command_word_1);
    $display("write_operation_control_word_1 = %b", write_operation_control_word_1);
    $display("write_operation_control_word_3 = %b", write_operation_control_word_3);
    $display("read = %b", read);
  end

endmodule

