`ifndef FIFO_TRANS_C
`define FIFO_TRANS_C
/* This class contains the transaction item object format to use in the mailboxes */
import fifo_pkg::*;

class fifo_trans;
    logic we;
    logic re;
    logic almost_full;
    logic almost_empty;
    logic full;
    logic empty;
    logic [WIDTH-1:0] wrdata;
    logic [WIDTH-1:0] rddata;
    // Extra fields to provide more information: TIME and TRANSACTION TYPE
    test_type type;
    logic int [15:0] time; 

endclass //fifo_trans
`endif