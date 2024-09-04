//************************************//
//          author:BoronLi            //
//          data:2024.9.4             //
//************************************//
module dffr (clk, d, r, q);
    parameter n = 1;
    input r, clk;
    input [n-1:0] d;
    output [n-1:0] q;
    reg [n-1:0] q;
    
    always @(posedge clk) begin
        if(r) q = {n{1'b0}};
        else q = d;
    end
endmodule