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

initial begin
clk = '0;
n_rst = '0;
#20 n_rst = '1;
forever #10 clk = ~clk;
end

initial begin
  env0 = new(vif);

  #200ns $finish;
end

endmodule
