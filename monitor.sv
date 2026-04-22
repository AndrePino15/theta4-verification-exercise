`ifndef MONITOR_C
`define MONITOR_C
class monitor;
    virtual fifo_if vif;
    event drive_done;
    mailbox #(fifo_trans) score_mailbox;

    task run();
        forever begin
            @(drive_done);
            

        end
    endtask
endclass
`endif