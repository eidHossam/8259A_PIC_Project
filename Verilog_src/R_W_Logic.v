module Bus_Control_Logic (
    input   wire           chip_select_n,
    input   wire           read_enable_n,
    input   wire           write_enable_n,
    input   wire           A0,
    input   wire   [7:0]   data_bus_in,

    // Internal Bus
    output  reg   [7:0]   internal_data_bus,
    output  wire           write_initial_command_word_1,
    output  wire           write_operation_control_word_1,
    output  wire           write_operation_control_word_3,
    output  wire           read
);

    //
    // Internal Signals
    //
    reg   prev_write_enable_n;
    wire  write_flag;
    reg   stable_address;

    //
    // Write Control
    //
    always @* begin
        if (~write_enable_n & ~chip_select_n)
            internal_data_bus <= data_bus_in;
        else
            internal_data_bus <= internal_data_bus;
    end

    always @* begin
        if (chip_select_n)
            prev_write_enable_n <= 1'b1;
        else
            prev_write_enable_n <= write_enable_n;
    end
    assign write_flag = ~prev_write_enable_n & write_enable_n;


    // Generate write request flags
    assign write_initial_command_word_1   = ~write_enable_n & ~A0 & internal_data_bus[4];
    assign write_operation_control_word_1 = ~write_enable_n & A0;
    assign write_operation_control_word_3 = ~write_enable_n & ~A0 & ~internal_data_bus[4] & internal_data_bus[3];

    //
    // Read Control
    //
    assign read = ~read_enable_n  & ~chip_select_n;

endmodule
