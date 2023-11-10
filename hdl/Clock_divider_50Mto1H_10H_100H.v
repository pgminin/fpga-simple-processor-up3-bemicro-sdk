// Verilog project: Verilog code for clock divider on FPGA
// Top level Verilog code for clock divider on FPGA
module Clock_divider_50Mto1H_10H_100H(reset,clock_in_50M,clock_out_1H,clock_out_10H,clock_out_100H
    );
input reset;
input clock_in_50M; // input clock on FPGA
output reg clock_out_1H; // output clock after dividing the input clock by divisor
output reg clock_out_10H; // output clock after dividing the input clock by divisor
output reg clock_out_100H; // output clock after dividing the input clock by divisor

reg[27:0] counter1=28'd0;
parameter DIVISOR1 = 28'd50000000;
reg[27:0] counter10=28'd0;
parameter DIVISOR10 = 28'd5000000;
reg[27:0] counter100=28'd0;
parameter DIVISOR100 = 28'd500000;
// The frequency of the output clk_out
//  = The frequency of the input clk_in divided by DIVISOR
// For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
// You will modify the DIVISOR parameter value to 28'd50.000.000
// Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz
always @(posedge clock_in_50M)
begin
 if(reset) counter1 <= 28'd0;
 else counter1 <= counter1 + 28'd1;
 if(counter1>=(DIVISOR1-1))
  counter1 <= 28'd0;
 clock_out_1H <= (counter1<DIVISOR1/2)?1'b1:1'b0;
end

always @(posedge clock_in_50M)
begin
 if(reset) counter10 <= 28'd0;
 else counter10 <= counter10 + 28'd1;
 if(counter10>=(DIVISOR10-1))
  counter10 <= 28'd0;
 clock_out_10H <= (counter10<DIVISOR10/2)?1'b1:1'b0;
end

always @(posedge clock_in_50M)
begin
 if(reset) counter100 <= 28'd0;
 else counter100 <= counter100 + 28'd1;
 if(counter100>=(DIVISOR100-1))
  counter100 <= 28'd0;
 clock_out_100H <= (counter100<DIVISOR100/2)?1'b1:1'b0;
end
endmodule