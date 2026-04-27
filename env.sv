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
        // creating the mailboxes
        score_mailbox = new();
        drv_mailbox = new();
        // creating the actual class modules of the testbench
        s0 = new(drv_mailbox, drive_done);
        d0 = new(vif, drv_mailbox, drive_done);
        m0 = new(vif, score_mailbox, monitor_done);
        sc0 = new(score_mailbox, monitor_done);
        this.vif = vif;
    endfunction //new()

    task run();
        fork
            d0.run();
            m0.run();
            sc0.run();
        join_none
        // start tests
        s0.test0();
        this.report();
        // Next test
        s0.test1();
        this.report();
        // Next test
        s0.test2();
        this.report();
        // Last test
        s0.test3();
        vif.we = '0;
        vif.re = '0;
        repeat (2) @(posedge vif.clk);
        sc0.report();
        // Display Final Scoreboard Report
        sc0.final_report();
    endtask //run

    task report();
        vif.we = '0;
        vif.re = '0;
        repeat (2) @(posedge vif.clk);
        // Get final report from the scoreboard
        sc0.report();
        $display("T=%0t [Env] Previous Test Complete! Applying reset to the DUT and moving on to the next test.", $time);
        // apply reset
        s0.reset();    
    endtask
endclass //env

`endif