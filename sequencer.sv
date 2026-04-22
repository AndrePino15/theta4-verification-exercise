`ifndef SEQUENCER_C
`define SEQUENCER_C
class seqiencer;
    virtual fifo_if vif;
    event drive_done;
    mailbox #(fifo_trans) drive_mailbox;

    task test0;

    endtask
endclass //generator

`endif