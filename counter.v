///////////////////
//      VER.#5
///////////////////

module counter 
#(
parameter WIDTH = 8,
parameter INC_SIZE = 1,
parameter DEC_SIZE = 1
 )(
input                       clk,
input                       rst_n,
input  reg[INC_SIZE-1:0]    inc,
input  reg[INC_SIZE-1:0]    dec,
output reg[WIDTH-1:0]       count
);



always @(posedge clk or negedge rst_n)
if(~rst_n) count<= '0;
else if (inc | dec) 
if(inc)
count <= count + {{WIDTH-1{1'b0}},{1'b1}};
else
count<= count-{{WIDTH-1{1'b0}},{1'b1}};
   
endmodule