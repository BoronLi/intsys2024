//************************************//
//          author:BoronLi            //
//          data:2024.9.4             //
//************************************//
module control_button(clk, in, reset, time_done, out, time_clr);
    input clk, in, reset, time_done;
    output reg out;
    output reg time_clr;
    reg [1:0] state;

    always @(posedge clk) begin
        if (reset) begin
            time_clr = 1;
            state <= 2'b00;
            out <= 0;
        end else begin
            case (state)
                2'b00: begin
                    if (in) begin
                        time_clr = 0;
                        state <= 2'b01;
                        out <= 1;
                    end
                end
                2'b01: begin
                    if (time_done) begin
                        time_clr = 1;
                        state <= 2'b10;
                        out <= 1;
                    end 
                end
                2'b10: begin
                    if (!in) begin
                        time_clr = 0;
                        state <= 2'b11;
                        out <= 1;
                    end
                end
                2'b11: begin
                    if (time_done) begin
                        time_clr = 1;
                        state <= 2'b00;
                        out <= 0;
                    end
                end
            endcase
        end
    end
endmodule
