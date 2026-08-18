module apb_pwm_wrap (
   input logic clk_i,
   input logic rst_ni,
   //reset, active low, input

   APB_BUS.Slave apb_slave,
   
   output [7:0]  PWM
);

//-i refers to intence
APB_PWM apb_pwm_i (
   .PCLK     ( clk_i             ), 
    //Wrapper clk_i to APB_PWM PCLK

   .PRESETn  ( rst_ni            ),
    
   .PADDR    ( apb_slave.paddr   ),
   .PSEL     ( apb_slave.psel    ),
   .PENABLE  ( apb_slave.penable ),
   .PWRITE   ( apb_slave.pwrite  ),
   //pwrite = 1 Write
   //pwrite = 0 Read


   .PWDATA   ( apb_slave.pwdata  ),
   .PREADY   ( apb_slave.pready  ),
   //module APB_PWM make signal PREADY then puts it in interface
   //node takes it to master



   .PRDATA   ( apb_slave.prdata  ),
   .PSLAVEERR( apb_slave.pslverr ),
    //if address will be wrong APB_PWM builds error signal

   
   .PWM      ( PWM               )
    //output of PWM from APB_PWM connects to wrapper
);
   
endmodule

