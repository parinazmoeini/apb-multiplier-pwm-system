//teastbench for system

module tb_mul_pwm ();

logic 		 PCLK;
logic 		 PRESETn;
logic [31:0]	 PADDR;
logic    	 PSEL;
logic            PENABLE;
logic 		 PWRITE;
logic [31:0]     PWDATA;
logic        	 PREADY;
logic [31:0] 	 PRDATA;
logic        	 PSLAVEERR;

logic [7:0] 	 PWM;

logic [31:0] 	 save_prdata;
//this is a param in 32 bit for saving data

APB_MUL_PWM DUT ( .PCLK(PCLK), .PRESETn(PRESETn), .PADDR(PADDR), .PSEL(PSEL), .PENABLE(PENABLE), .PWRITE(PWRITE), .PWDATA(PWDATA), .PREADY(PREADY), .PRDATA(PRDATA), .PSLAVEERR(PSLAVEERR), .PWM(PWM));
   
   always
     begin
        #5 PCLK = !PCLK;
     end
   
//this is the initial part at first all of them should be 0
   initial
     begin
        save_prdata=0;
	PCLK    = 0;
	PRESETn = 0;
	PADDR   = 0;
	PSEL    = 0;
	PENABLE = 0;
	PWRITE  = 0; 
	PWDATA  = 0;	
        #2;

	PRESETn = 1;

        @(negedge PCLK);
        @(negedge PCLK);
	
	PADDR   = 32'h00000000;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = 8;
        
        @(negedge PCLK);

	PADDR   = 32'h00000000;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = 8;

        @(negedge PCLK);

	PADDR   = 32'h00000004;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = 5;

        @(negedge PCLK);

	PADDR   = 32'h00000004;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = 5;
        
        @(negedge PCLK);
        
	PADDR   = 32'h0000000C;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = 1;
        
        @(negedge PCLK);

	PADDR   = 32'h0000000C;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = 1;
//end of mul
	@(negedge PCLK);
        
	PADDR   = 32'h0000000C;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = 0;
        
        @(negedge PCLK);

	PADDR   = 32'h0000000C;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = 0;
//mul disabled      
        @(PREADY==1'b1);

	@(negedge PCLK);
        
	PADDR   = 32'h00000008;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 0; 
	PWDATA  = 0;
        
        @(negedge PCLK);

	PADDR   = 32'h00000008;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 0; 
	PWDATA  = 0;
//pwm generation period
	@(negedge PCLK);
        save_prdata=PRDATA;
	PADDR   = 32'h00001000;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = save_prdata;
        
        @(negedge PCLK);

	PADDR   = 32'h00001000;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = save_prdata;
//pwm generation pulse
	@(negedge PCLK);
        
	PADDR   = 32'h00001004;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = save_prdata/2;
        
        @(negedge PCLK);

	PADDR   = 32'h00001004;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = save_prdata/2;
//pwm generation size
	@(negedge PCLK);
        
	PADDR   = 32'h00001008;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = save_prdata/4;
        
        @(negedge PCLK);

	PADDR   = 32'h00001008;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = save_prdata/4;
//enable
	@(negedge PCLK);
        
	PADDR   = 32'h0000100C;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = 1;
        
        @(negedge PCLK);

	PADDR   = 32'h0000100C;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = 1;

	PADDR   = 0;
	PSEL    = 0;
	PENABLE = 0;
	PWRITE  = 0; 
	PWDATA  = 0;
        
        #100;

	@(negedge PCLK);

	PADDR   = 32'h0000101C;
	PSEL    = 1;
	PENABLE = 0;
	PWRITE  = 1; 
	PWDATA  = 1;

	@(negedge PCLK);

	PADDR   = 32'h0000101C;
	PSEL    = 1;
	PENABLE = 1;
	PWRITE  = 1; 
	PWDATA  = 1;

        #1000;

        $stop;
     end
   
endmodule

