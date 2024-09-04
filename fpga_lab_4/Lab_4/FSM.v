//************************************//
//          author:BoronLi            //
//          data:2024.9.4             //
//************************************//
module FSM(clk, reset, B0, B1, reset_s, state, out);
    input clk, reset;
    input B0, B1, reset_s;
    output out;
    output reg [2:0] state;

    reg [2:0] next_state;

    always @(posedge clk) begin  
   
        if (reset_s) begin
            state <= 3'b000;
        end
        if (B0) begin
            case (state)
                3'b000: state <= 3'b001;
                3'b001: state <= 3'b000;
                3'b010: state <= 3'b011;
                3'b011: state <= 3'b001;
                3'b100: state <= 3'b011;
                3'b101: state <= 3'b001;
                default: state <= 3'b000;
            endcase
        end
        if (B1) begin
            case (state)
                3'b000: state <= 3'b000;
                3'b001: state <= 3'b010;
                3'b010: state <= 3'b000;
                3'b011: state <= 3'b100;
                3'b100: state <= 3'b101;
                3'b101: state <= 3'b000;
                default: state <= 3'b000;
            endcase
        end
    end

    assign out = (state == 3'b101) ? 1 : 0; 

endmodule








    //     always @(posedge clk) begin
    //     case (state)
    //         3'b000: begin
    //             if (B1) begin
    //                 state <= 3'b000;
    //             end
    //             if (B0) begin
    //                 state <= 3'b001;
    //             end
    //         end
    //         3'b001: begin
    //             if (B1) begin
    //                 state <= 3'b010;
    //             end
    //             if (B0) begin
    //                 state <= 3'b000;
    //             end
    //         end
    //         3'b010: begin
    //             if (B1) begin
    //                 state <= 3'b000;
    //             end
    //             if (B0) begin
    //                 state <= 3'b011;
    //             end
    //         end
    //         3'b011: begin
    //             if (B1) begin
    //                 state <= 3'b100;
    //             end
    //             if (B0) begin
    //                 state <= 3'b001;
    //             end
    //         end
    //         3'b100: begin
    //             if (B1) begin
    //                 state <= 3'b101;
    //             end
    //             if (B0) begin
    //                 state <= 3'b011;
    //             end
    //         end
    //         3'b101: begin
    //             if (B1) begin
    //                 state <= 3'b000;
    //             end
    //             if (B0) begin
    //                 state <= 3'b001;
    //             end
    //         end                
    //         default: begin
    //             state <= 3'b000;
    //         end
    //     endcase
    // end