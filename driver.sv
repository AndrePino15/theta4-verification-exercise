`ifndef DRIVER_C
`define DRIVER_C

class driver;
    virtual fifo_if vif;
    event drive_done;
    mailbox #(fifo_trans) drv_mailbox;

    function new(virtual fifo_if vif, mailbox #(fifo_trans) drv_mailbox, event drive_done);
        this.vif = vif;
        this.drv_mailbox = drv_mailbox;
        this.drive_done = drive_done;
    endfunction

    task  run();

        // at every clock cycle the driver sends updates to the DUT
        
        forever begin
            fifo_trans item;
            drv_mailbox.get(item);
            item.print_wr("Driver");

            // update interface with new test values from the mailbox in the middle of the clock
            @(negedge vif.clk);
            vif.we = item.we;
            vif.re = item.re;
            vif.wrdata = item.wrdata;
            // waiting for the next clock edge for the values to be written
            @(posedge vif.clk);
            -> drive_done;
            $display("T=%0t [Driver] Driver_done flag triggered", $time);
        end
    endtask

endclass //driver

`endif
