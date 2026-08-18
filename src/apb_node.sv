
module apb_node #(
        parameter int unsigned NB_MASTER      = 2,
	//two peripherals are connected to this node

        parameter int unsigned APB_DATA_WIDTH = 32,
        parameter int unsigned APB_ADDR_WIDTH = 32
)(
        //slave
        input logic 					 penable_i,
        input logic 					 pwrite_i,
        input logic [APB_ADDR_WIDTH-1:0] 		 paddr_i,
        input logic                                      psel_i,
        input logic [APB_DATA_WIDTH-1:0] 		 pwdata_i,
        output logic [APB_DATA_WIDTH-1:0] 		 prdata_o,
        output logic 					 pready_o,
        output logic 					 pslverr_o,

        //master
        output logic [NB_MASTER-1:0] 			 penable_o,
        output logic [NB_MASTER-1:0] 			 pwrite_o,
        output logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] paddr_o,
        output logic [NB_MASTER-1:0] 			 psel_o,
        output logic [NB_MASTER-1:0][APB_DATA_WIDTH-1:0] pwdata_o,
	//the first dim is for selection between two slave so this two dim signal will be written as:
	//pwdata_o[0] with 32 bit and pwdata_o[1] with 32 bit        


	 //these are response of prepherals to node
	input logic  [NB_MASTER-1:0][APB_DATA_WIDTH-1:0]  prdata_i,
        input logic  [NB_MASTER-1:0] 			 pready_i,
        input logic  [NB_MASTER-1:0] 			 pslverr_i,

        //configuration start and end address of each prepheral
        input logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0]  START_ADDR_i,
        input logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0]  END_ADDR_i
    );

//combinational address decoder
    always_comb begin
        psel_o = '0;

        for (int unsigned i = 0; i < NB_MASTER; i++)
            psel_o[i]  =  psel_i & (paddr_i >= START_ADDR_i[i]) && (paddr_i <= END_ADDR_i[i]);
    end

//this part decodes the incoming APB address at first no peripheral is selected by default
//then check every peripheral address range and then enable only the matched peripheral
	
//route APB signals between the master and the selected peripheral
    always_comb begin
        //default outputs when no peripheral is selected
        penable_o = '0;
        pwrite_o  = '0;
        paddr_o   = '0;
        pwdata_o  = '0;
        prdata_o  = '0;
        pready_o  = 1'b0;
        pslverr_o = 1'b0;
        

	//check which peripheral is currently selected
        for (int unsigned i = 0; i < NB_MASTER; i++) begin
            // master j was selected because the address matched int the generate statement above
            if (psel_o[i]) begin
                // master out - slave in
                penable_o[i] = penable_i;
                pwrite_o[i]  = pwrite_i;
                paddr_o[i]   = paddr_i;
                pwdata_o[i]  = pwdata_i;
                // master in - slave out
                prdata_o     = prdata_i[i];
                pready_o     = pready_i[i];
                pslverr_o    = pslverr_i[i];
            end
        end
    end
endmodule

