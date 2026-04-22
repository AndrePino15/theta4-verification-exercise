interface fifo_if (input logic clk, n_rst);

import fifo_pkg::WIDTH;

    logic we;
    logic re;
    logic almost_full;
    logic almost_empty;
    logic full;
    logic empty;
    logic [WIDTH-1:0] wrdata;
    logic [WIDTH-1:0] rddata;

endinterface //fifo_if