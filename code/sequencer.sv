`ifndef SEQUENCER_C
`define SEQUENCER_C

class sequencer;    
    event drive_done;
    mailbox #(fifo_trans) drv_mailbox;

    function new(mailbox #(fifo_trans) drv_mailbox, event drive_done);
        this.drv_mailbox = drv_mailbox;
        this.drive_done = drive_done;
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

        $display("T=%0t [Sequencer] Sequencer Done.", $time);
    endtask

    task reset;
        fifo_trans item;

        $display("T=%0t [Sequencer] Initiating Reset Operation to the DUT.", $time);

        // Test goes on from the DUT settings from the past test, so reset required.
        item = new();
        item.trans_type = N_RESET_LOW;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. n_rst=0, rest undefined", $time);
        drv_mailbox.put(item);
        @(drive_done);

        // apply reset 
        item = new();
        item.trans_type = N_RESET_HIGH;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. n_rst=1, rest undefined", $time);
        drv_mailbox.put(item);
        @(drive_done);
        
        $display("T=%0t [Sequencer] Sequencer Done.", $time);
    endtask
    
    task test1;
        fifo_trans item;
        $display("T=%0t [Sequencer] Initiating Test 1: Full Read and Write of FIFO", $time);
        
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

        $display("T=%0t [Sequencer] Sequencer Done.", $time);
    endtask

    task test2;
        fifo_trans item;
        $display("T=%0t [Sequencer] Initiating Test 2: Wrap Around Test", $time);
        
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

        // attempt to write when FIFO is already full twice
        item = new();
        item.we = 1;
        item.re = 0;
        item.wrdata = 4'h5;
        item.trans_type = FULL_READ_WRITE;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
        drv_mailbox.put(item);
        @(drive_done);

        item = new();
        item.we = 1;
        item.re = 0;
        item.wrdata = 4'h6;
        item.trans_type = FULL_READ_WRITE;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
        drv_mailbox.put(item);
        @(drive_done);

        // Loop of reading one writing another time sequentially to test a full wrap around of the pointers.
        for (int i = 0; i < DEPTH+2; i++) begin
            // start read to free up a space and move the pointer
            item = new();
            item.we = 0;
            item.re = 1;
            item.trans_type = FULL_READ_WRITE;
            $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
            drv_mailbox.put(item);
            @(drive_done);
            // write an another value to make srue the FIFO is always full and that the write pointer also behaves as expected
            item = new();
            item.we = 1;
            item.re = 0;
            item.wrdata = i;
            item.trans_type = FULL_READ_WRITE;
            $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
            drv_mailbox.put(item);
            @(drive_done);
        end

        // Final read loop to get FIFO back to empty. Attempt to read when empty as well.
        for (int i = 0; i < DEPTH ; i++) begin
            item = new();
            item.we = 0;
            item.re = 1;
            item.trans_type = FULL_READ_WRITE;
            $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
            drv_mailbox.put(item);
            @(drive_done);
        end

        // Finally, attempt to read when everything is empty
        item = new();
        item.we = 0;
        item.re = 1;
        item.trans_type = FULL_READ_WRITE;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
        drv_mailbox.put(item);
        @(drive_done);

        $display("T=%0t [Sequencer] Sequencer Done", $time);
    endtask

    task test3;
        fifo_trans item;
        $display("T=%0t [Sequencer] Initiating Test 3: Same Cycle Read & Write", $time);

        item = new();
        item.we = 1;
        item.re = 0;
        item.wrdata = 4'h5;
        item.trans_type = SAME_CYCLE_RW_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
        drv_mailbox.put(item);
        @(drive_done);

        item = new();
        item.we = 1;
        item.re = 1;
        item.wrdata = 4'h6;
        item.trans_type = SAME_CYCLE_RW_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
        drv_mailbox.put(item);
        @(drive_done);

        // try a second time to test reproducibility
        item = new();
        item.we = 1;
        item.re = 1;
        item.wrdata = 4'h7;
        item.trans_type = SAME_CYCLE_RW_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
        drv_mailbox.put(item);
        @(drive_done);

        item = new();
        item.we = 0;
        item.re = 1;
        item.trans_type = SAME_CYCLE_RW_TEST;
        $display ("T=%0t [Sequencer] Sending new item to driver mailbox. we=%d re=%d wrdata=0x%0h", $time, item.we, item.re, item.wrdata);
        drv_mailbox.put(item);
        @(drive_done);

        $display("T=%0t [Sequencer] Sequencer Done.", $time);
    endtask
endclass //generator

`endif
