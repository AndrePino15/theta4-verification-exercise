`ifndef ENV_C
`define ENV_C

class env;
    sequencer s0;
    driver d0;
    monitor m0;
    scoreboard sc0;

    event drive_done, monitor_done;
    virtual fifo_if vif;
    mailbox #(fifo_trans) score_mailbox;
    mailbox #(fifo_trans) drv_mailbox;

    function new(virtual fifo_if vif);
        s0 = new(drv_mailbox, drive_done);
        d0 = new(vif, drv_mailbox, drive_done);
        m0 = new(vif, score_mailbox, monitor_done);
        sc0 = new(score_mailbox, monitor_done);
    endfunction //new()

    task run();
        fork
            s0.test0();
            d0.run();
            m0.run();
            sc0.run();
        join_any
    endtask //run
endclass //env

`endif