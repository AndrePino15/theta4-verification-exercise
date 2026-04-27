`ifndef FIFO_TRANS_C
`define FIFO_TRANS_C
/* This class contains the transaction item object format to use in the mailboxes */

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
    test_type trans_type;

    function 
    void print_wr(string tag="");
        $display ("T=%0t [%s] Received mailbox item: we=%d re=%d wrdata=0x%0h", $time, tag, we, re, wrdata);
    endfunction

    function 
    void print_rd(string tag="");
        $display ("T=%0t [%s] Received mailbox item: we=%d re=%d rddata=0x%0h", $time, tag, we, re, rddata);
    endfunction

    function 
    void print_vif(string tag="");
        $display ("T=%0t [%s] Interface sampled: we=%d re=%d wrdata=0x%0h rddata=0x%0h", $time, tag, we, re, wrdata, rddata);
    endfunction

endclass //fifo_trans
`endif
