module fifo_tb;

import fifo_pkg::*;
import tb_pkg::*;

logic clk, n_rst;
env env0;

fifo_if vif (.*);

fifo #(.WIDTH(WIDTH), 
        .DEPTH(DEPTH), 
        .ALMOST_FULL_TH(ALMOST_FULL_TH), 
        .ALMOST_EMPTY_TH(ALMOST_EMPTY_TH),
        .POINTER_W(POINTER_W)) 
        f0 
      (.clk(clk), .n_rst(n_rst), .we(vif.we), .re(vif.re),
        .rddata(vif.rddata), .wrdata(vif.wrdata), 
        .full(vif.full), .empty(vif.empty), 
        .almost_full(vif.almost_full), .almost_empty(vif.almost_empty));

// code for the starting the clock signal
initial begin
clk = '0;
forever #10 clk = ~clk;
end

// code for performing the initial reset of teh system
initial begin
n_rst = '0;
#20 n_rst = '1;
end

initial begin
  env0 = new(vif);
  $display("T=%0d [Testbench] Starting the simulation environment...", $time);
  env0.run();

  sc0.report();
  #200ns $finish;

end

endmodule
