package fifo_pkg;
   // parameters used throghout the code for the paprameterised FIFO buffer
   parameter WIDTH  = 4;
   parameter DEPTH  = 12;     
   parameter ALMOST_FULL_TH  = 2;   
   parameter ALMOST_EMPTY_TH  = 2;  
   parameter POINTER_W  = $clog2(DEPTH);

   // enum that defines the different types of transaction/test being performed 
    typedef enum logic [3:0]{
        READ_WRITE_TEST,
        N_RESET_LOW,
        N_RESET_HIGH,
        FULL_READ_WRITE,
        WRAP_AROUND_TEST,
        SAME_CYCLE_RW_TEST
    } test_type;
endpackage
