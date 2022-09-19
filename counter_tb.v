`timescale 1ns/1ns


module counter_tb;

//////////////////////////
//      PARAMETERS          
//////////////////////////
parameter WIDTH=8;
parameter INC_SIZE=1;
parameter DEC_SIZE=1;


//////////////////////////
//      REG & WIRE
//////////////////////////
reg                     clk;
wire [WIDTH-1:0]        count;
reg                     rst_n;
reg  [INC_SIZE-1:0]     inc;
reg  [DEC_SIZE-1:0]     dec;


//////////////////////
//      DUT
//////////////////////
counter #(
.WIDTH(WIDTH),
.INC_SIZE(INC_SIZE),
.DEC_SIZE(DEC_SIZE)) c0(
.clk(clk),
.count(count),
.inc(inc),
.dec(dec),
.rst_n(rst_n));

///////////////////////////
//      CHECKER
///////////////////////////
initial begin @(posedge rst_n)
repeat(10) @(posedge clk);
inc={INC_SIZE{1'b1}};
repeat((2**WIDTH)-1) @(posedge clk);
inc='0;
repeat(5) @(posedge clk);
if(((2**WIDTH)-1)==count) $display("PASS");
else $display("FAIL");
repeat(5) @(posedge clk);
inc={INC_SIZE{1'b1}};
repeat(1) @(posedge clk);
inc='0;
repeat(1) @(posedge clk);
dec={DEC_SIZE{1'b1}};
repeat((2**WIDTH)-1) @(posedge clk);
dec='0;
repeat(5) @(posedge clk);
if(((2**WIDTH)-1)==count) $display("PASS");
else $display("FAIL");
repeat(5) @(posedge clk);
$finish;
end



///////////////////////////
//          CLOCK
///////////////////////////
always #1 clk=~clk;


/////////////////////////////////////////
//      Assign rst & clk
/////////////////////////////////////////
initial begin
clk=0;
rst_n=0;
end

//////////////////////////
//  reset updating
//////////////////////////
initial begin
repeat(3) @(posedge clk);
rst_n=1;
repeat(3) @(posedge clk);
rst_n=0;
repeat(3) @(posedge clk);
rst_n=1;
end


///////////////////////////////////
//      Creating waves
///////////////////////////////////
initial begin
$dumpfile("counter_tb.vcd"); 
$dumpvars(0, counter_tb);
end

endmodule

