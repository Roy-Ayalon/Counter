module counter(
input clk,
input rst,
input enable,
output reg [7:0] count 
);

always @(posedge clk or negedge rst) begin
    if(~rst) begin
        count<= 1'b0;
    end
    else if(enable) begin
    count<=count+1'b1;
    end
  end
endmodule