`timescale 1ns / 1ns

// =============================================================================
// Self-checking testbench for counter.
//
// Verifies the four behaviors of the parameterized up/down counter:
//   * Reset:    count == 0 while rst_n == 0
//   * Increment: inc=1 -> count increments by 1 each cycle
//   * Decrement: dec=1, inc=0 -> count decrements by 1 each cycle
//   * Wrap:     overflow at 2^WIDTH-1 and underflow at 0 both wrap correctly
//
// End-of-test prints one of three banners (father's style):
//   - print_pass  -> all checks matched          (PASS)
//   - print_fail  -> a count mismatch was caught (FAIL)
//   - print_error -> watchdog timeout            (ERROR)
//
// Stimulus uses #1 after every @(posedge clk) per lesson #4
// (active-region race avoidance on iverilog).
// =============================================================================

module counter_tb;

// -----------------------------------------------------------------------------
// Parameter / Define
// -----------------------------------------------------------------------------

parameter WIDTH      = 8;
parameter INC_SIZE   = 1;
parameter DEC_SIZE   = 1;
parameter SIM_LENGTH = 20000;

localparam [WIDTH-1:0] MAX_COUNT = {WIDTH{1'b1}};   // 2^WIDTH - 1

// -----------------------------------------------------------------------------
// Register / Wires
// -----------------------------------------------------------------------------

reg                   clk;
reg                   rst_n;
reg  [INC_SIZE-1:0]   inc;
reg  [DEC_SIZE-1:0]   dec;
wire [WIDTH-1:0]      count;

// -----------------------------------------------------------------------------
// Clock
// -----------------------------------------------------------------------------

always #5 clk = ~clk;

// -----------------------------------------------------------------------------
// Watchdog -> ERROR banner if the test hangs
// -----------------------------------------------------------------------------

initial begin
    #SIM_LENGTH;
    $display("WATCHDOG: simulation exceeded %0d time units", SIM_LENGTH);
    print_error;
    $finish(2);
end

// -----------------------------------------------------------------------------
// Test sequence
// -----------------------------------------------------------------------------

initial begin
    $display("TEST STARTED");

    // Init
    clk   = 1'b0;
    rst_n = 1'b0;
    inc   = '0;
    dec   = '0;

    // ---- T1: reset behavior -----------------------------------------------
    $display("[T1] reset asserted -> count should be 0");
    repeat (3) @(posedge clk); #1;
    t_check(8'h00, "count_under_reset");
    rst_n = 1'b1;
    @(posedge clk); #1;
    t_check(8'h00, "count_after_reset_release");

    // ---- T2: increment to MAX_COUNT ---------------------------------------
    $display("[T2] inc=1 for %0d cycles -> reach MAX_COUNT=%0d", MAX_COUNT, MAX_COUNT);
    inc = 1'b1;
    repeat (MAX_COUNT) @(posedge clk);
    #1;
    t_check(MAX_COUNT, "count_at_max");

    // ---- T3: overflow wrap -------------------------------------------------
    $display("[T3] one more inc at MAX_COUNT -> wrap to 0");
    @(posedge clk); #1;
    t_check(8'h00, "count_after_overflow");
    inc = 1'b0;

    // ---- T4: underflow wrap ------------------------------------------------
    $display("[T4] dec=1 at count=0 -> wrap to MAX_COUNT");
    dec = 1'b1;
    @(posedge clk); #1;
    t_check(MAX_COUNT, "count_after_underflow");

    // ---- T5: decrement all the way back to 0 ------------------------------
    $display("[T5] dec=1 for %0d more cycles -> reach 0", MAX_COUNT);
    repeat (MAX_COUNT) @(posedge clk);
    #1;
    t_check(8'h00, "count_back_to_zero");
    dec = 1'b0;

    // ---- T6: mid-run reset -------------------------------------------------
    $display("[T6] mid-run reset while incrementing -> count returns to 0");
    inc = 1'b1;
    repeat (5) @(posedge clk); #1;
    rst_n = 1'b0;
    @(posedge clk); #1;
    t_check(8'h00, "count_after_mid_run_reset");
    rst_n = 1'b1;
    inc   = 1'b0;

    repeat (3) @(posedge clk);
    print_pass;
    $display("TEST FINISHED");
    $finish;
end

// -----------------------------------------------------------------------------
// Checker task
// -----------------------------------------------------------------------------

task t_check;
    input [WIDTH-1:0] expected;
    input [255:0]     label;
    begin
        if (count !== expected) begin
            $display("Check DATA FAILED at %0t (%0s):", $time, label);
            $display("   ERROR - expected = 0x%0h (%0d)", expected, expected);
            $display("   ERROR - actual   = 0x%0h (%0d)", count, count);
            repeat (2) @(posedge clk);
            print_fail;
            $finish;
        end
        $display("  PASS  %0s : count = %0d", label, count);
    end
endtask

// -----------------------------------------------------------------------------
// Banner tasks (father's style)
// -----------------------------------------------------------------------------

task print_pass;
    begin
        $display(" #####    ##    ####   ####  ");
        $display(" #    #  #  #  #      #      ");
        $display(" #    # #    #  ####   ####  ");
        $display(" #####  ######      #      # ");
        $display(" #      #    # #    # #    # ");
        $display(" #      #    #  ####   ####  ");
        $display("UVM TEST PASSED");
    end
endtask

task print_fail;
    begin
        $display(" ######   ##   # #      ");
        $display(" #       #  #  # #      ");
        $display(" #####  #    # # #      ");
        $display(" #      ###### # #      ");
        $display(" #      #    # # #      ");
        $display(" #      #    # # ###### ");
        $display("UVM TEST FAILED");
    end
endtask

task print_error;
    begin
        $display(" ###### #####  #####   ####  #####  ");
        $display(" #      #    # #    # #    # #    # ");
        $display(" #####  #    # #    # #    # #    # ");
        $display(" #      #####  #####  #    # #####  ");
        $display(" #      #   #  #   #  #    # #   #  ");
        $display(" ###### #    # #    #  ####  #    # ");
        $display("UVM TEST ERROR");
    end
endtask

// -----------------------------------------------------------------------------
// DUT
// -----------------------------------------------------------------------------

counter #(
    .WIDTH   (WIDTH),
    .INC_SIZE(INC_SIZE),
    .DEC_SIZE(DEC_SIZE)
) c0 (
    .clk   (clk),
    .rst_n (rst_n),
    .inc   (inc),
    .dec   (dec),
    .count (count)
);

// -----------------------------------------------------------------------------
// Waves
// -----------------------------------------------------------------------------

initial begin
    $dumpfile("counter_tb.vcd");
    $dumpvars(0, counter_tb);
end

endmodule
