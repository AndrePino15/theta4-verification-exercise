`ifndef SEQUENCER_C
`define SEQUENCER_C

class sequencer;
    event drive_done;
    mailbox #(fifo_trans) drv_mailbox;

    function new(mailbox #(fifo_trans) drv_mailbox, event drive_done);
        this.drv_mailbox = drv_mailbox;
        this.drive_done = drive_done;
    endfunction

    task test0;
        fifo_trans item;

        // values to write to the FIFO
        item  = new();
        item.we = 1;
        item.re = 0;
        item.wrdata = 4'hA;
        item.trans_type = READ_WRITE_TEST;
        $display ("T=%0t [Sequencer] Sending WRITE item to driver mailbox.", $time);
        drv_mailbox.put(item);
        // wait for item to be consumed by driver
        @(drive_done);

        // prepare item for read operation
        item = new();
        item.we = 0;
        item.re = 1;
        item.trans_type = READ_WRITE_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox.", $time);
        drv_mailbox.put(item);
        @(drive_done);
    endtask
endclass //generator

`endif
