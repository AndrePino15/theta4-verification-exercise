module fifo_tb;

import fifo_pkg::*;
logic clk, n_rst;

fifo_if if (.*);

fifo #(.WIDTH(WIDTH), 
        .DEPTH(DEPTH), 
        .ALMOST_FULL_TH(ALMOST_FULL_TH), 
        .ALMOST_EMPTY_TH(ALMOST_EMPTY_TH),
        .POINTER_W.(POINTER_W)) 
        f0 
      (.clk(clk), .n_rst(n_rst), .we(if.we), .re(if.re),
        .rddata(if.rddata), .wrdata(if.wrdata), 
        .full(if.full), .empty(if.empty), 
        .almost_full(if.almost_full), .almost_empty(almost_empty));

initial begin
clk = '0;
n_rst = '0;
#20 n_rst = '1;
forever #10 clk = ~clk;

end

endmodule