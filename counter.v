///////////////////
//      VER.#4
///////////////////

module counter 
#(
parameter WIDTH = 8
 )(
input                   clk,
input                   rst,
input                   inc,
output reg[WIDTH-1:0]   count
);



always @(posedge clk or negedge rst)
if(~rst) count<= '0;
else if (inc) count <= count+ {{WIDTH-1{1'b0}},1'b1};
   
endmodule