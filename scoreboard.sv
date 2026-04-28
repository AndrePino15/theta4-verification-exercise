`ifndef SCOREBOARD_C
`define SCOREBOARD_C

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
    int pass_count, fail_count, tests_passed, tests_failed;
    fifo_trans item;

    covergroup fifo_cg;
        // definition of coverpoints for all variables in the transaction type
        // Enable variables
        cp_we: coverpoint item.we {
            bins enabled = {1};
            bins disabled = {0};
        }
        cp_re: coverpoint item.re {
            bins enabled = {1};
            bins disabled = {0};
        }
        // Data variables
        cp_wdata: coverpoint item.wrdata {
            bins zero = {0};
            bins low  = {[1:WIDTH/2]};
            bins high = {[8:WIDTH-1]};
        }
        cp_rddata: coverpoint item.rddata {
            bins zero = {0};
            bins low  = {[1:WIDTH/2]};
            bins high = {[8:WIDTH-1]};
        }
        // Flag variables
        cp_empty: coverpoint item.empty {
            bins set = {1};
            bins not_set = {0};
        }
        cp_almost_empty: coverpoint item.almost_empty {
            bins set = {1};
            bins not_set = {0};
        }
        cp_almost_full: coverpoint item.almost_full {
            bins set = {1};
            bins not_set = {0};
        }
        cp_full: coverpoint item.full {
            bins set = {1};
            bins not_set = {0};
        }

        // cross cover case definitions: Trying to get as many corner cases as possible
        // First cross cover: checking for cases when we try tor ead when its empty or write to a full FIFO
        cx_we_full:         cross cp_we, cp_full;
        cx_we_almost_full:  cross cp_we, cp_almost_full;
        cx_re_empty:        cross cp_re, cp_empty;
        cx_re_almost_empty: cross cp_re, cp_almost_empty;
        // test for same cycle read and write test
        cx_same_cycle_wr:   cross cp_we, cp_re;
    endgroup

    function new( mailbox #(fifo_trans) score_mailbox, event monitor_done);
        this.score_mailbox = score_mailbox;
        this.monitor_done = monitor_done;
        fifo_cg = new();    // instantiate covergroup in constructor so that we never forget to initalise it
    endfunction

    task run();
    fail_count = 0;
    pass_count = 0;
    tests_passed = 0;
    tests_failed = 0;
    forever begin
        logic [WIDTH-1:0] ref_data;
        // wait for monitor to update mailbox with new results
        score_mailbox.get(item);
        item.print_sc("Scoreboard");

        if (item.trans_type == N_RESET_LOW) begin
            ref_buffer.delete();
            $display("T=%0t [Scoreboard] Reset detected, clearing reference buffer", $time);
            continue;   // skip the rest of the test as in reset there is no need to check, only after it goes back up to 1.
        end

        // 0)   Sample covergroup after each transaction with the monitor is complete and has new values from the DUT
        fifo_cg.sample();

        // 1)   Update reference FIFO with read and write operations  
        if (item.we && (ref_buffer.size() < DEPTH)) begin
            ref_buffer.push_back(item.wrdata);
            $display("T=%0t [Scoreboard] Data written to reference FIFO. ref=0x%0h", $time, item.wrdata);
        end
        else if (item.we && (ref_buffer.size() == DEPTH)) begin
            $display("T=%0t [Scoreboard] Ref FIFO is full, can't hold more data.", $time);
        end
        
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
        else if (item.re && (ref_buffer.size() == 0)) begin
            $display("T=%0t [Scoreboard] Read attempted when FIFO is empty: rddata=0x%0h (undefined behaviour, value doesn't matter)", $time, item.rddata);
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

        if (fail_count > 0)
            tests_failed = tests_failed+1;
        else
            tests_passed = tests_passed+1;
        // reset the values for pass_count and fail_count
        pass_count = '0;
        fail_count = '0;
    endtask

    task final_report();
        $display("===================================");
        $display("===== SCOREBOARD FINAL REPORT =====");
        $display("TOTAL TESTS PASSED: %0d", tests_passed);
        $display("TOTAL TESTS FAILED: %0d", tests_failed);
        if (tests_failed == 0) begin
            $display("ALL TESTS PASSED");
            $display("DUT is verified and working as expected according to the specification.");
        end
        else begin
            $display("FAILURES DETECTED");
            $display("The DUT design contains errors that need fixing for correct behaviour.");
        end
        $display("===================================");
        
    endtask
    
endclass //scoreboard

`endif 
