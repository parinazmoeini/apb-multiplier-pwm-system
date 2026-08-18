//wrapper module for the APB multiplier peripheral

module apb_mul_wrap (
   input logic clk_i,
   input logic rst_ni,
   //reset, active low, input

   APB_BUS.Slave apb_slave
);

APB_MUL_serial apb_mul_i (
   .PCLK     ( clk_i             ), 
   .PRESETn  ( rst_ni            ),

    //forward APB request signals
   .PADDR    ( apb_slave.paddr   ),
   .PSEL     ( apb_slave.psel    ),
   .PENABLE  ( apb_slave.penable ),
   .PWRITE   ( apb_slave.pwrite  ),
   .PWDATA   ( apb_slave.pwdata  ),

   //return APB response signals
   .PREADY   ( apb_slave.pready  ),
   .PRDATA   ( apb_slave.prdata  ),
   .PSLAVEERR( apb_slave.pslverr )
);
   
endmodule
