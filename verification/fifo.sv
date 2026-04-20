module fifo #(
   parameter WIDTH  = 4, 
   parameter DEPTH  = 12,     
   parameter ALMOST_FULL_TH  = 2,   
   parameter ALMOST_EMPTY_TH  = 2,  
   parameter POINTER_W  = $clog2(DEPTH)   
)
(
   input logic clk,
   input logic n_rst,                     
   input logic we,  
   input logic re,  
   input logic [WIDTH-1:0] wrdata,  
   output logic [WIDTH-1:0] rddata,  
   output logic full, 
   output logic almost_full, 
   output logic empty, 
   output logic almost_empty
);

logic [WIDTH-1:0] ram [DEPTH];  
logic [POINTER_W-1:0] wptr;  
logic [POINTER_W-1:0] rptr;  
logic [POINTER_W-1:0] next_wptr;  
logic [POINTER_W-1:0] next_rptr;  
logic [POINTER_W-1:0] count;  
      

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
         ram[wptr] <= wrdata ;  
         wptr <= next_wptr;
         end

      if (re && !empty) 
         begin  
         rddata <= ram[rptr];       
         rptr <= next_rptr;
         end

      if (we && !full) 
         begin       
         count <= count + 1;
         end                    
      else if (re && !empty) 
         begin    
         count <= count - 1;         
         end
      end
   end

always_comb
  begin
  if (count == DEPTH)
    full = 1'b1;
  else 
    full = 1'b0;
  if (count == 1)
    empty = 1'b1;
  else
    empty = 1'b0;
  if (count > DEPTH - ALMOST_FULL_TH)
    almost_full = 1'b1;
  else
    almost_full = 1'b0;
  if (count < ALMOST_EMPTY_TH)
    almost_empty = 1'b1;
  else
    almost_empty = 1'b0;
  if (wptr == DEPTH-1)
    next_wptr = '0;
  else
    next_wptr = wptr + 1;
  if (rptr == DEPTH-1)
    next_rptr =  '0;
  else
    next_rptr = rptr + 1;
  end

endmodule