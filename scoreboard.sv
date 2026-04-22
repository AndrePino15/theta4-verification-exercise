`ifndef SCOREBOARD_C
`define SCOREBOARD_C
class scoreboard;
    virtual fifo_if vif;
    event drive_done;
    mailbox #(fifo_trans) drive_mailbox, score_mailbox;

    task run();
        
    endtask
endclass //scoreboard

`endif 