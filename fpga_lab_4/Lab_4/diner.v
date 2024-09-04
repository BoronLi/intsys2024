//************************************//
//          author:BoronLi            //
//          data:2024.9.4             //
//************************************//
module diner (clk, en, time_clr, time_done);
    input clk, en, time_clr;
    output time_done;

    reg [3:0] q = 0;

    assign time_done = (q==10);

    always @(posedge clk) begin
        if (time_clr) q = 0;
        else if(en) q = q + 1;
        else q = q;
    end
endmodule