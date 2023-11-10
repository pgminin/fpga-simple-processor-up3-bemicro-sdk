//fpga4student.com
// FPGA projects, Verilog projects, VHDL projects
// Verilog code for button debouncing on FPGA
// debouncing module 
module debounce_f4s(input pb_1,slow_clk,output pb_out);
//wire slow_clk;
wire Q1,Q2,Q2_bar,Q3,Q3_bar,Q0;
//clock_div u1(clk,slow_clk);
my_dff d0(slow_clk, pb_1,Q0 );

my_dff d1(slow_clk, Q0,Q1 );
my_dff d2(slow_clk, Q1,Q2 );
my_dff d3(slow_clk, Q2,Q3 );
assign Q2_bar = ~Q2;
assign Q3_bar = ~Q3;
//assign pb_out = ~Q1 & Q2_bar & Q3_bar;
assign pb_out = ~Q1 & Q2_bar & Q3_bar;
endmodule
// Slow clock for debouncing 
module clock_div(input Clk_100M, output reg slow_clk

    );
    reg [26:0]counter=0;
    always @(posedge Clk_100M)
    begin
        counter <= (counter>=499999)?0:counter+1;
        slow_clk <= (counter < 250000)?1'b0:1'b1;
    end
endmodule
// D-flip-flop for debouncing module 
module my_dff(input DFF_CLOCK, D, output reg Q);

    always @ (posedge DFF_CLOCK) begin
        Q <= D;
    end

endmodule