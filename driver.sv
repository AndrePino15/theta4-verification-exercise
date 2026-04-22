`ifndef DRIVER_C
`define DRIVER_C
import fifo_pkg::*;

class driver;
    virtual fifo_if vif;
    event drive_done;
    mailbox #(fifo_trans) drive_mailbox;

    task  run();
        // at every clock cycle the driver sends updates to the DUT
        @(posedfe vif.clk);
        forever begin
            fifo_trans item;

            drive_mailbox.get(item);
            
            
        end
    endtask

endclass //driver

`endif