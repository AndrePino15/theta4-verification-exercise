interface fifo_if (input logic clk);

import fifo_pkg::WIDTH;

    logic n_rst;
    logic we;
    logic re;
    logic almost_full;
    logic almost_empty;
    logic full;
    logic empty;
    logic [WIDTH-1:0] wrdata;
    logic [WIDTH-1:0] rddata;

endinterface //fifo_if