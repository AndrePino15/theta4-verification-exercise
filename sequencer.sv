`ifndef SEQUENCER_C
`define SEQUENCER_C

class sequencer;    
    event drive_done, sequencer_done;
    mailbox #(fifo_trans) drv_mailbox;

    function new(mailbox #(fifo_trans) drv_mailbox, event drive_done, event sequencer_done);
        this.drv_mailbox = drv_mailbox;
        this.drive_done = drive_done;
        this.sequencer_done = sequencer_done;
    endfunction

    task test0;     // Simple Read and Write
        fifo_trans item;

        $display("T=%0t [Sequencer] Initiating Test 0: Simple Read & Write", $time);

        // values to write to the FIFO
        item  = new();
        item.we = 1;
        item.re = 0;
        item.wrdata = 4'hA;
        item.trans_type = READ_WRITE_TEST;
        $display ("T=%0t [Sequencer] Sending WRITE item to driver mailbox. we=%d re=%d wrdata=0x%0h rddata=0x%0h", $time, item.we, item.re, item.wrdata, item.rddata);
        drv_mailbox.put(item);
        // wait for item to be consumed by driver
        @(drive_done);

        // prepare item for read operation
        item = new();
        item.we = 0;
        item.re = 1;
        item.trans_type = READ_WRITE_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h rddata=0x%0h", $time, item.we, item.re, item.wrdata, item.rddata);
        drv_mailbox.put(item);
        @(drive_done);

        // prepare next item for write operation
        item = new();
        item.we = 1;
        item.re = 0;
        item.wrdata = 4'hB;
        item.trans_type = READ_WRITE_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h rddata=0x%0h", $time, item.we, item.re, item.wrdata, item.rddata);
        drv_mailbox.put(item);
        @(drive_done);

        // prepare next item for final read operation
        item = new();
        item.we = 0;
        item.re = 1;
        item.trans_type = READ_WRITE_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h rddata=0x%0h", $time, item.we, item.re, item.wrdata, item.rddata);
        drv_mailbox.put(item);
        @(drive_done);

        // sequencer finished, so set finsished flag
        -> sequencer_done;
        $display("T=%0t [Sequencer] Sequencer done flag triggered.", $time);
    endtask

    task test1;
        fifo_trans item;

        $display("T=%0t [Sequencer] Initiating Test 1: Active Low Reset Check", $time);

        // Test goes on from the DUT settings from the past test, so reset required.
        item = new();
        item.n_rst = 0;
        item.trans_type = RESET_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. n_rst=%d, rest undefined", $time, item.n_rst);
        drv_mailbox.put(item);
        @(drive_done);

        // apply reset 
        item = new();
        item.n_rst = 1;
        item.trans_type = RESET_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. n_rst=%d, rest undefined", $time, item.n_rst);
        drv_mailbox.put(item);
        @(drive_done);
        
        // sequencer finished, finsished flag set
        -> sequencer_done;
        $display("T=%0t [Sequencer] Sequencer done flag triggered.", $time);
    endtask
    
    task test2;
        fifo_trans item;
        $display("T=%0t [Sequencer] Initiating Test 2: Full Read and Write of FIFO", $time);
        
        // Write the full FIFO. Wrting values 0 to DEPTH-1;
        for (int i = 0; i < DEPTH ; i++) begin
            item = new();
            item.we = 1;
            item.re = 0;
            item.wrdata = i;
            item.trans_type = FULL_READ_WRITE;
            $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
            drv_mailbox.put(item);
            @(drive_done);
        end

        // read from the full FIFO. Output should be countdown from DEPTH-1 to 0;
        for (int i = 0; i < DEPTH ; i++) begin
            item = new();
            item.we = 0;
            item.re = 1;
            item.trans_type = FULL_READ_WRITE;
            $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
            drv_mailbox.put(item);
            @(drive_done);
        end

        // sequencer finished, finsished flag set
        -> sequencer_done;
        $display("T=%0t [Sequencer] Sequencer done flag triggered.", $time);
    endtask

    task test3;
        fifo_trans item;
        $display("T=%0t [Sequencer] Initiating Test 3: Full Read and Write of FIFO", $time);
        
        // Write the full FIFO. Wrting values 0 to DEPTH-1;
        for (int i = 0; i < DEPTH+2 ; i++) begin
            item = new();
            item.we = 1;
            item.re = 0;
            item.wrdata = i;
            item.trans_type = FULL_READ_WRITE;
            $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
            drv_mailbox.put(item);
            @(drive_done);
        end

        // read from the full FIFO. Output should be countdown from DEPTH-1 to 0;
        for (int i = 0; i < DEPTH ; i++) begin
            item = new();
            item.we = 0;
            item.re = 1;
            item.trans_type = FULL_READ_WRITE;
            $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
            drv_mailbox.put(item);
            @(drive_done);
        end

        // sequencer finished, finsished flag set
        -> sequencer_done;
        $display("T=%0t [Sequencer] Sequencer done flag triggered.", $time);
    endtask
endclass //generator

`endif
