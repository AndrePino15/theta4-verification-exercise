module fifo #(
   parameter WIDTH  = 4, 
   parameter DEPTH  = 12,     
   parameter ALMOST_FULL_TH  = 2,   
   parameter ALMOST_EMPTY_TH  = 2,  
   parameter POINTER_W  = $clog2(DEPTH)   
)
(
   input logic clk,     // posedge clock
   input logic n_rst,   // active low reset
   input logic we,      // write enable
   input logic re,      // read enable
   input logic [WIDTH-1:0] wrdata,  // new data to be written to the FIFO
   output logic [WIDTH-1:0] rddata, //returns data from the FIFO
   output logic full,           //status flag: data cannot be written to the FIFO
   output logic almost_full,    //status flag: when number of FIFO entries is greater than FIFO depth minus threshold, flah is high
   output logic empty,          //status flag: data read from the FIFO is not defined
   output logic almost_empty    //status flag: when number of FIFO entries is less than threshold, flag is high
);

logic [WIDTH-1:0] ram [DEPTH];      // declaration  of the actual size of the FIFO memory. #DEPTH elements each #WIDTH long
logic [POINTER_W-1:0] wptr;         // write pointer of the FIFO
logic [POINTER_W-1:0] rptr;         // read pointer of the FIFO
logic [POINTER_W-1:0] next_wptr;    // next write pointer
logic [POINTER_W-1:0] next_rptr;    //next read pointer
logic [POINTER_W-1:0] count;        // unkown yet
      

always_ff @(posedge clk) 
   begin
   if (!n_rst) 
      begin      
      wptr  <= '0;
      rptr  <= '0;      
      count <= '0;
      end
   else 
      begin                    
      if (we && !full)
         begin             
         ram[wptr] <= wrdata ;      // writing to FIFO
         wptr <= next_wptr;
         end

      if (re && !empty) 
         begin  
         rddata <= ram[rptr];      // reading from FIFO
         rptr <= next_rptr;
         end

      if (we && !full) 
         begin       
         count <= count + 1;    // increasing count if data was written to the FIFO
         end                    
      else if (re && !empty) 
         begin    
         count <= count - 1;    // decreasing count if data was read from the FIFO 
         end
      end
   end

always_comb
  begin
  if (count == DEPTH)   // logic for FULL flag
    full = 1'b1;
  else 
    full = 1'b0;
  if (count == 1)       //logic for empty flag
    empty = 1'b1;
  else
    empty = 1'b0;
  if (count > DEPTH - ALMOST_FULL_TH)   // logic for almost_full flag
    almost_full = 1'b1;
  else
    almost_full = 1'b0;
  if (count < ALMOST_EMPTY_TH)      // logic for almost_empty flag
    almost_empty = 1'b1;
  else
    almost_empty = 1'b0;
  if (wptr == DEPTH-1)      // handling of wrapped around write pointer case
    next_wptr = '0;
  else
    next_wptr = wptr + 1;
  if (rptr == DEPTH-1)      // handling of wrapped around read pointer case
    next_rptr =  '0;
  else
    next_rptr = rptr + 1;
  end

endmodule