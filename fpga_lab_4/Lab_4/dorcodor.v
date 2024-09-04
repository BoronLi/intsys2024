//************************************//
//          author:BoronLi            //
//          data:2024.9.4             //
//************************************//
module dorcodor(din, HEX);
 input [2:0] din;
 output reg [6:0] HEX;

 always @* begin
	  case (din)
			3'b000 : HEX = ~7'b1000000;
			3'b001 : HEX = ~7'b1111001;
			3'b010 : HEX = ~7'b0100100;
			3'b011 : HEX = ~7'b0110000;
			3'b100 : HEX = ~7'b0011001;
			3'b101 : HEX = ~7'b0010010;
			3'b110 : HEX = ~7'b0000010;
			3'b111 : HEX = ~7'b1111000;
			default: HEX = ~7'b0000000;
	  endcase
 end
endmodule