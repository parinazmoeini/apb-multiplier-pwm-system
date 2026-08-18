module APB_MUL_serial
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
   output logic        	PSLAVEERR
);

logic [15:0] a;
logic [15:0] b;

logic  	     en;
logic en_a, en_b, en_en;

logic [31:0] a_reg;
logic [15:0] b_reg;
logic	[31:0]	result;

//states
typedef enum logic [1:0] {IDLE,RUN,DONE} statetype;
statetype state, nextstate;

logic shift,load,done;
logic [3:0] counter;


//registers
always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         a <= 16'd0;
   else
      if (en_a == 1'b1)
         a <= PWDATA[15:0];
end

always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         b <= 16'd0;
   else
      if (en_b == 1'b1)
         b <= PWDATA[15:0];
end

always_ff @ (posedge PCLK, negedge PRESETn)
begin
   if ( PRESETn == 1'b0 )
         en <= 1'b0;
   else
      if (en_en == 1'b1)
         en <= PWDATA[0];
end

//decoder part
always_comb
begin

en_a  = 1'b0;
en_b = 1'b0;
en_en   = 1'b0;

if ( (PENABLE == 1'b1) & (PWRITE == 1'b1) & (PSEL == 1'b1) )
   begin
      case ( PADDR[3:2] )
        2'b00: en_a = 1'b1;
        2'b01: en_b  = 1'b1;         
        2'b11: en_en = 1'b1;
	default:begin
		en_a=0;
		en_b=0; 
		en_en=0;
	end
      endcase
   end
end


//read
always_comb
begin
PRDATA = '0;
if ( (PENABLE == 1'b1) & (PWRITE == 1'b0) & (PSEL == 1'b1) )
   begin
      case ( PADDR [3:2] )
         2'b00: PRDATA = {16'd0,a};
         2'b01: PRDATA = {16'd0,b};
         2'b10: PRDATA = result;
         2'b11: PRDATA = {31'd0,en};
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

//multipication FSM
//state register part
always_ff@(posedge PCLK, negedge PRESETn)
begin
	if(!PRESETn) state<=IDLE;
	else
		state<=nextstate;
end

//output register
always_ff@(posedge PCLK, negedge PRESETn)
begin
	if(!PRESETn) result<=32'd0;
	else
		if(load) result<=32'd0;
		else
			if(b_reg[0]==1'b1) result<=result+a_reg;
		
end

//left shift
always_ff@(posedge PCLK, negedge PRESETn)
begin
	if(!PRESETn) a_reg<=32'd0;
	else
		if(load) a_reg<={16'd0,a};
		else
			if(shift) a_reg<={a_reg[30:0],1'b0};
		
end

//right shift
always_ff@(posedge PCLK, negedge PRESETn)
begin
	if(!PRESETn) b_reg<=16'd0;
	else
		if(load) b_reg<=b;
		else
			if(shift) b_reg<={1'b0,b_reg[15:1]};
		
end

//combinational logic (states FSM)
always_comb
begin
load=0;
shift=0;
done=0;
	case(state)
		IDLE: begin
			if(en)begin
 				nextstate=RUN;
				load=1'b1;				
			end
			else nextstate=IDLE;
		end
		RUN: begin
			shift=1'b1;
			if(counter==4'd15) nextstate=DONE;
			else nextstate=RUN;
		end
		DONE:begin
			done=1'b1;
			nextstate=IDLE;
		end
		default: nextstate=IDLE;
	endcase
end

assign PREADY    = done;

//counter
always_ff@(posedge PCLK, negedge PRESETn)
begin
	if(!PRESETn) counter<=4'd0;
	else
		if(load==1'b1) counter<=4'd0;
		else if(counter==4'd15) counter<=4'd0;
		else counter<=counter+1;
end
endmodule
