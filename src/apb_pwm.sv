

module APB_PWM
(
   input logic 		PCLK,
   input logic 		PRESETn,
   input logic 	[31:0]	PADDR,
   input logic  	PSEL,
   input logic          PENABLE,
   input logic 		PWRITE,
   input logic  [31:0]  PWDATA,
   output logic        	PREADY,
   output logic [31:0] 	PRDATA,
   output logic        	PSLAVEERR,
   
   output logic	[7:0]	PWM
);

logic [31:0] pulse;
logic [31:0] period;
logic [7:0]  size;
logic        enable;

logic en_pulse, en_period, en_size, en_enable;
enum { IDLE, HIGH, LOW } state, next_state;

//counter 32 bit
logic restart;
logic [31:0] count;

//register
always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         pulse <= '0;
   else
      if (en_pulse == 1'b1)
         pulse <= PWDATA;
end

always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         period <= '0;
   else
      if (en_period == 1'b1)
         period <= PWDATA;
end

always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         size <= '0;
   else
      if (en_size == 1'b1)
         size <= PWDATA[7:0];
end

always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         enable <= '0;
   else
      if (en_enable == 1'b1)
         enable <= PWDATA[0];
end

//decoder part
always_comb
begin

en_pulse  = 1'b0;
en_period = 1'b0;
en_size   = 1'b0;
en_enable = 1'b0;

if ( (PENABLE == 1'b1) & (PWRITE == 1'b1) & (PSEL == 1'b1) )
   begin
      case ( PADDR[3:2] )
         2'b00: en_period = 1'b1;
         2'b01: en_pulse  = 1'b1;
         2'b10: en_size   = 1'b1;
         2'b11: en_enable = 1'b1;
      endcase
   end
end

assign PREADY    = PENABLE;

//read
always_comb
begin
PRDATA = '0;
if ( (PENABLE == 1'b1) & (PWRITE == 1'b0) & (PSEL == 1'b1) )
   begin
      case ( PADDR [3:2] )
         2'b00: PRDATA = period;
         2'b01: PRDATA = pulse;
         2'b10: PRDATA = {24'd0,size};
         2'b11: PRDATA = {31'd0,enable};
      endcase
   end
end

//error
always_comb
begin
PSLAVEERR = 0;
if ( ( (PENABLE == 1'b1) & (PSEL == 1'b1) ) & ( PADDR[11:0] >= 12'h00F ) )
   begin
      PSLAVEERR = 1;
   end
end

//sequential part for FSM
always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         state <= IDLE;
   else
         state <= next_state;
end

// COMBINATIONAL LOGIC
always_comb
begin

restart       = 0;
next_state    = IDLE;
PWM           = '0;

   case (state)
      IDLE:
        begin
           if (enable == 1'b1)
           begin
              next_state    = HIGH;
              restart = 1'b1;
           end
	end

      HIGH:
         begin
           PWM = size;
           if (enable == 1'b0)
               next_state = IDLE;
           else
               if ( count == pulse )
                  next_state = LOW;
               else
                  next_state = HIGH;
         end

      LOW:
         begin
         PWM = '0;
           if (enable == 1'b0)
               next_state = IDLE;
           else
               if ( count == period )
               begin
                  next_state = HIGH;
                  restart    = 1'b1;
               end
               else
                  next_state = LOW;
         end
    endcase
end

//counter
always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
      count = 0;
   else
       if (restart == 1'b1)
          count = 0;
       else
          count = count + 1;
end

endmodule

