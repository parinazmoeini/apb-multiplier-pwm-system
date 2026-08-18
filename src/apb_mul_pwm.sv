module APB_MUL_PWM
(
   input logic 		   PCLK,
   input logic 		   PRESETn,

   input logic 	[31:0]	   PADDR,
   input logic  	   PSEL,
   input logic             PENABLE,
   input logic 		   PWRITE,
   input logic  [31:0]     PWDATA,
   output logic        	   PREADY,
   output logic [31:0] 	   PRDATA,
   output logic            PSLAVEERR,

   output logic [7:0] 	   PWM 
);


APB_BUS s_apb_slave ();
APB_BUS s_master_bus   [1:0]();

assign s_apb_slave.paddr   = PADDR;
assign s_apb_slave.pwdata  = PWDATA;
assign s_apb_slave.pwrite  = PWRITE;
assign s_apb_slave.psel    = PSEL;
assign s_apb_slave.penable = PENABLE;
assign PRDATA              = s_apb_slave.prdata;
assign PREADY              = s_apb_slave.pready;
assign PSLAVEERR           = s_apb_slave.pslverr;

apb_node_wrap #(
     .APB_ADDR_WIDTH ( 32 ),
     .APB_DATA_WIDTH ( 32 )
) apb_node_i (
     .clk_i               ( PCLK        ),
     .rst_ni              ( PRESETn     ),

     .apb_slave           ( s_apb_slave ),

     .apb_masters         ( s_master_bus   )
    );

apb_pwm_wrap apb_pwm_wrap_i (
     .clk_i(PCLK),
     .rst_ni(PRESETn),
     
     .apb_slave(s_master_bus[0]),
     
     .PWM(PWM)
);

// instantiate mul
apb_mul_wrap apb_mul_wrap_i(
     .clk_i(PCLK),
     .rst_ni(PRESETn),
     
     .apb_slave(s_master_bus[1])
);

endmodule
