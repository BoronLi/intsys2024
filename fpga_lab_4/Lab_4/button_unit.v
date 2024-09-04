//************************************//
//          author:BoronLi            //
//          data:2024.9.4             //
//************************************//
module button_unit (clk, reset, ButtonIn, ButtonOut);
    input clk, reset;
    input ButtonIn;
    output ButtonOut;
    
    wire synch_d1, synch_out;
    wire time_clr, time_done;
    wire out_c, out_and;

    dffr U1(.clk(clk), .d(ButtonIn),
            .r(0), .q(synch_d1));
    dffr U2(.clk(clk), .d(synch_d1),
            .r(0), .q(synch_out));
    counter_n #(.n(1000000), .counter_bits(21)) U3(
                .clk(clk), .en(1),
                .r(0), .q(), .co(pulse1KHz));
    diner U4(.clk(clk), .en(pulse1KHz),
             .time_clr(time_clr), .time_done(time_done));
    control_button U5(.clk(clk), .in(synch_out), .reset(reset),
               .time_clr(time_clr), .time_done(time_done), .out(out_c));
    dffr U6(.clk(clk), .d(out_c), .r(0), .q(out_and));
    assign ButtonOut = ((!out_and) & out_c);

endmodule