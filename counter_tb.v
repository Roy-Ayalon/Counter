`timescale 1ns/1ns


module counter_tb;

//////////////////////////
//      PARAMETERS          
//////////////////////////
parameter WIDTHX=8;


//////////////////////////
//      REG & WIRE
//////////////////////////
reg                 clk;
wire [WIDTHX-1:0]   count;
reg                 rst;
reg                 inc;


//////////////////////
//      DUT
//////////////////////
counter #(.WIDTH(WIDTHX)) c0(
.clk(clk),
.count(count),
.inc(inc),
.rst(rst));


///////////////////////////
//          CLOCK
///////////////////////////
always #1 clk=~clk;


/////////////////////////////////////////
//      Assign rst & clk
/////////////////////////////////////////
initial begin
clk=0;
rst=0;
end

//////////////////////////
//  reset updating
//////////////////////////
initial begin
repeat(3) @(posedge clk);
rst=1;
repeat(3) @(posedge clk);
rst=0;
repeat(3) @(posedge clk);
rst=1;
end


///////////////////////////
//      CHECKER
///////////////////////////
initial begin
repeat(10) @(posedge clk);
inc=1;
repeat({WIDTHX{1'b1}}) @(posedge clk);
inc=0;
repeat(5) @(posedge clk);
if({WIDTHX{1'b1}}==count) $display("PASS");
else $display("FAIL");
repeat(5) @(posedge clk);
$finish;
end


///////////////////////////////////
//      Creating waves
///////////////////////////////////
initial begin
$dumpfile("counter_tb.vcd"); 
$dumpvars(0, counter_tb);
end

endmodule

