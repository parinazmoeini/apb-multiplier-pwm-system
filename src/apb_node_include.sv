
interface APB_BUS
#(
    parameter APB_ADDR_WIDTH = 32,
    parameter APB_DATA_WIDTH = 32
);

    logic [APB_ADDR_WIDTH-1:0]                                        paddr;
    logic [APB_DATA_WIDTH-1:0]                                        pwdata;
    logic                                                             pwrite;
    logic                                                             psel;
    logic                                                             penable;
    logic [APB_DATA_WIDTH-1:0]                                        prdata;
    logic                                                             pready;
    logic                                                             pslverr;

   //master
   modport Master
   (
      output      paddr,  pwdata,  pwrite, psel,  penable,
      input       prdata,          pready,        pslverr
   );

   //slave
   modport Slave
   (
      input      paddr,  pwdata,  pwrite, psel,  penable,
      output     prdata,          pready,        pslverr
   );

endinterface


`define NB_MASTER  2

// MASTER PORT 0
`define PWM0_START_ADDR          32'h0000_1000
`define PWM0_END_ADDR            32'h0000_1FFF

// MASTER PORT 1
`define MUL0_START_ADDR          32'h0000_0000
`define MUL0_END_ADDR            32'h0000_0FFF



