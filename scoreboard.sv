`ifndef SCOREBOARD_C
`define SCOREBOARD_C

import fifo_pkg::*;

class scoreboard;
    event monitor_done;
    mailbox #(fifo_trans) score_mailbox;

    // reference model FIFO queue and flags. Uses SV built-in Queue
    logic [WIDTH-1:0] ref_buffer [$];
    logic ref_almost_full;
    logic ref_almost_empty;
    logic ref_full;
    logic ref_empty;
    // pass/fails count variables for final scoreboard report
    int pass_count, fail_count;

    function new( mailbox #(fifo_trans) score_mailbox, event monitor_done);
        this.score_mailbox = score_mailbox;
        this.monitor_done = monitor_done;
    endfunction

    task run();
    fail_count = 0;
    pass_count = 0;
    forever begin
        fifo_trans item;
        logic [WIDTH-1:0] ref_data;
        // wait for monitor to update mailbox with new results
        @(monitor_done);
        score_mailbox.get(item);
        item.print("Scoreboard");

        // 1)   Update reference FIFO with read and write operations  
        if (item.we && (ref_buffer.size() < DEPTH))
            ref_buffer.push_back(item.wrdata);
        
        if (item.re && (ref_buffer.size() > 0)) begin
            ref_data = ref_buffer.pop_front();
            if (ref_data == item.rddata) begin
                $display("T=%0t [Scoreboard] Pass! Data read correclty. ref=0x%0h, rddata=0x%0h", $time, ref_data, item.rddata);
                pass_count++;
            end
            else begin
                $display("T=%0t [Scoreboard] Fail... Incorrect data read from FIFO. ref=0x%0h, rddata=0x%0h", $time, ref_data, item.rddata);
                fail_count++;
            end
        end

        // 2)   Compute flags
        ref_empty = (ref_buffer.size() == 0);
        ref_full = (ref_buffer.size() == DEPTH);
        ref_almost_empty = (ref_buffer.size() < ALMOST_EMPTY_TH);
        ref_almost_full = (ref_buffer.size() > (DEPTH-ALMOST_FULL_TH));

        // 3) Check if flags are the same n reference model and DUT output
        // EMPTY flag check
        if (ref_empty !== item.empty) begin  // !== used since it always returns 0 or 1 even if the arguments have X in them
            $display("T=%0t [Scoreboard] Fail... Incorrect empty flag. ref=%0h, empty=%0h", $time, ref_empty, item.empty);
            fail_count++;
        end
        else begin
            $display("T=%0t [Scoreboard] Pass! Correct empty flag in DUT. ref=%0h, empty=%0h", $time, ref_empty, item.empty);
            pass_count++;
        end
        // FULL flag check
        if (ref_full !== item.full) begin
            $display("T=%0t [Scoreboard] Fail... Incorrect full flag. ref=%0h, full=%0h", $time, ref_full, item.full);
            fail_count++;
        end
        else begin
            $display("T=%0t [Scoreboard] Pass! Correct full flag in DUT. ref=%0h, full=%0h", $time, ref_full, item.full);
            pass_count++;
        end
        // ALMOST_EMPTY flag check
        if (ref_almost_empty !== item.almost_empty) begin
            $display("T=%0t [Scoreboard] Fail... Incorrect almost_empty flag. ref=%0h, almost_empty=%0h", $time, ref_almost_empty, item.almost_empty);
            fail_count++;
        end
        else begin
            $display("T=%0t [Scoreboard] Pass! Correct almost_empty flag in DUT. ref=%0h, almost_empty=%0h", $time, ref_almost_empty, item.almost_empty);
            pass_count++;
        end
        // ALMOST_FULL flag check
        if (ref_almost_full !== item.almost_full) begin
            $display("T=%0t [Scoreboard] Fail... Incorrect almost_full flag. ref=%0h, almost_full=%0h", $time, ref_almost_full, item.almost_full);
            fail_count++;
        end
        else begin
            $display("T=%0t [Scoreboard] Pass! Correct almost_full flag in DUT. ref=%0h, almost_full=%0h", $time, ref_almost_full, item.almost_full);
            pass_count++;
        end
    end
    endtask

    task report();
        $display("================================");
        $display("===== SCOREBOARD REPORT =====");
        $display("PASS: %0d  FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL CHECKS PASSED");
        else
            $display("FAILURES DETECTED");
        $display("================================");
    endtask
    
endclass //scoreboard

`endif 