`ifndef MONITOR_C
`define MONITOR_C

class monitor;
    virtual fifo_if vif;
    event monitor_done;
    mailbox #(fifo_trans) score_mailbox;

    function new(virtual fifo_if vif, mailbox #(fifo_trans) score_mailbox, event monitor_done);
        this.vif = vif;
        this.score_mailbox = score_mailbox;
        this.monitor_done = monitor_done;
    endfunction

    task run();
        fifo_trans item;
        forever begin
            @(posedge vif.clk)
            #5ns;   // added delay to sample outputs only after they settle post clock edge
            item = new();
            item.we = vif.we;
            item.re = vif.re;
            item.wrdata = vif.wrdata;
            item.rddata = vif.rddata;
            item.empty = vif.empty;
            item.almost_empty = vif.almost_empty;
            item.almost_full = vif.almost_full;
            item.full = vif.full;

            item.print_rd("Monitor");
            score_mailbox.put(item);
            -> monitor_done;
        end
    endtask
endclass
`endif