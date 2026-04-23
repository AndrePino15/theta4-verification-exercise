`ifndef SEQUENCER_C
`define SEQUENCER_C

import fifo_pkg::*;

class sequencer;
    event drive_done;
    mailbox #(fifo_trans) drv_mailbox;

    function new(mailbox #(fifo_trans) drv_mailbox, event drive_done);
        this.drv_mailbox = drv_mailbox;
        this.drive_done = drive_done;
    endfunction

    task test0;
        fifo_trans item = new();
        // values to write to the FIFO
        item.we = 1;
        item.re = 1;
        item.wrdata = 32'hDEADBEEF;
        item.type = READ_WRITE_TEST;
        // expected outputs of the FIFO
        item.rddata = 32'hDEADBEEF;
        item.almost_empty = '1;
        item.full = '0;
        item.almost_full = '1;
        item.empty = '0;

        $display ("T=%0t [Sequencer] Sending new item to driver mailbox.", $time);
        drv_mailbox.put(item);
        @(drive_done);
    endtask
endclass //generator

`endif