module fifo_tb;

import fifo_pkg::*;
import tb_pkg::*;

logic clk, n_rst;
env env0;

fifo_if vif (.clk(clk), .n_rst(n_rst));

fifo #(.WIDTH(WIDTH), 
        .DEPTH(DEPTH), 
        .ALMOST_FULL_TH(ALMOST_FULL_TH), 
        .ALMOST_EMPTY_TH(ALMOST_EMPTY_TH),
        .POINTER_W(POINTER_W)) 
        f0 
      (.clk(vif.clk), .n_rst(vif.n_rst), .we(vif.we), .re(vif.re),
        .rddata(vif.rddata), .wrdata(vif.wrdata), 
        .full(vif.full), .empty(vif.empty), 
        .almost_full(vif.almost_full), .almost_empty(vif.almost_empty));

// code for the starting the clock signal
initial begin
clk = '0;
forever #10 clk = ~clk;
end

initial begin
  // 1) starting by reseting the system
  n_rst = '0;
  repeat (2) @(posedge clk);  // hold for 2 clock cycles to make sure the DUT resets.
  n_rst = '1;
  @(posedge clk);   // waiting another clock cycle to settle the reset

  // 2) Start the environment
  env0 = new(vif);
  $display("T=%0d [Testbench] Starting the simulation environment...", $time);
  env0.run();
  #200ns;

  // 3) Get the final report from the Scoreboard and finish simulation
  sc0.report();
  $finish;
end

endmodule
