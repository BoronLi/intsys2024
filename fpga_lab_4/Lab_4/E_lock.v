//************************************//
//          author:BoronLi            //
//          data:2024.9.4             //
//************************************//
module E_lock (
    clk, reset, reset_in, B0_in, B1_in, sel, LED, Digital
);
    input clk;
    input reset;
    input reset_in;
    input B0_in;
    input B1_in;
    output sel;
    output LED;
    output [6:0] Digital;
    
    wire [2:0] state;

    assign sel = 1;

    button_unit reset_inst (.clk(clk), .reset(reset), .ButtonIn(reset_in), .ButtonOut(reset_s));
    button_unit B0_inst    (.clk(clk), .reset(reset), .ButtonIn(B0_in),    .ButtonOut(B0));
    button_unit B1_inst    (.clk(clk), .reset(reset), .ButtonIn(B1_in),    .ButtonOut(B1));

    FSM         fsm_inst   (.clk(clk), .reset(reset), .B0(B0), .B1(B1), .reset_s(reset_s), .state(state), .out(LED));
    dorcodor    dor_inst   (.din(state), .HEX(Digital));

endmodule