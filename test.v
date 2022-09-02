module counter_tb;
reg clk;
wire [7:0] count;
reg rst;

//////////////////////////////////////
//conection to counter
//////////////////////////////////////
counter c0(.clk(clk),
.count(count),
.rst(rst));


/////////////////////////

initial begin
$dumpfile("counter_tb.vcd"); 
$dumpvars(0, counter_tb);
end


always #1 clk=~clk;

initial begin
clk<=0;
rst<=0;

repeat(3) @(posedge clk);
rst<=1;
repeat(3) @(posedge clk);
rst<=0;
repeat(3) @(posedge clk);
rst<=1;
end

endmodule
