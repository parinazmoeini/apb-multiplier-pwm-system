`include "apb_node_include.sv"
//wrapper for the APB node and connected peripherals

module apb_node_wrap #(
    //APB bus configuration
    parameter APB_ADDR_WIDTH = 32,
    parameter APB_DATA_WIDTH = 32
) (
    input logic    clk_i,
    input logic    rst_ni,
    
    //incoming APB slave interface from the system
    APB_BUS.Slave  apb_slave,
    
    //APB master interfaces connected to the peripherals
    APB_BUS.Master apb_masters[`NB_MASTER-1:0]
);
    
    localparam NB_MASTER = `NB_MASTER;
    
    logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] s_start_addr;
    logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] s_end_addr;
    
    logic [NB_MASTER-1:0]                     penable;
    logic [NB_MASTER-1:0]                     pwrite;
    logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] paddr;
    logic [NB_MASTER-1:0]                     psel;
    logic [NB_MASTER-1:0][APB_DATA_WIDTH-1:0] pwdata;
    logic [NB_MASTER-1:0][APB_DATA_WIDTH-1:0] prdata;
    logic [NB_MASTER-1:0]                     pready;
    logic [NB_MASTER-1:0]                     pslverr;
    
    //configure address ranges for each peripheral
    assign s_start_addr[0] = `PWM0_START_ADDR;
    assign s_end_addr[0]   = `PWM0_END_ADDR;
    
    assign s_start_addr[1] = `MUL0_START_ADDR;
    assign s_end_addr[1]   = `MUL0_END_ADDR;
    
    
     //connect internal routing signals to each APB master interface
    for (genvar i = 0; i < NB_MASTER; i++) begin
        assign apb_masters[i].penable = penable[i];
        assign apb_masters[i].pwrite  = pwrite[i];
        assign apb_masters[i].paddr   = paddr[i];
        assign apb_masters[i].psel    = psel[i];
        assign apb_masters[i].pwdata  = pwdata[i];
        assign prdata[i]              = apb_masters[i].prdata;
        assign pready[i]              = apb_masters[i].pready;
        assign pslverr[i]             = apb_masters[i].pslverr;
    end
    
    apb_node #(
        .NB_MASTER      ( NB_MASTER         ),
        .APB_DATA_WIDTH ( APB_DATA_WIDTH    ),
        .APB_ADDR_WIDTH ( APB_ADDR_WIDTH    )
    ) apb_node_i (

	//connect incoming APB slave signals
        .penable_i      ( apb_slave.penable ),
        .pwrite_i       ( apb_slave.pwrite  ),
        .paddr_i        ( apb_slave.paddr   ),
	.psel_i         ( apb_slave.psel    ),
        .pwdata_i       ( apb_slave.pwdata  ),
        .prdata_o       ( apb_slave.prdata  ),
        .pready_o       ( apb_slave.pready  ),
        .pslverr_o      ( apb_slave.pslverr ),

         //output routing signals toward peripherals
        .penable_o      ( penable           ),
        .pwrite_o       ( pwrite            ),
        .paddr_o        ( paddr             ),
        .psel_o         ( psel              ),
        .pwdata_o       ( pwdata            ),
        .prdata_i       ( prdata            ),
        .pready_i       ( pready            ),
        .pslverr_i      ( pslverr           ),

        .START_ADDR_i   ( s_start_addr      ),
        .END_ADDR_i     ( s_end_addr        )
    );
    
endmodule

