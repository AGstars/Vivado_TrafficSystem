
`timescale 1ns/1ns
module tb;

reg clk,rstn;
wire [7:0] led;
wire [7:0] sel;
reg enable;
wire [2:0] m_led;
wire [1:0] p_led;

initial begin
    clk=0;
    rstn=0;
    enable=1;
#5;
    rstn=1;
#10000;
    enable=0;
#10000;
    enable=1;
#10000;
#100000;
#90000;

#10000;
$finish;
end

always # 10 clk <= ~clk;

top dut(
    .clk (clk),
    .rst (!rstn),
    .people_led (p_led),
    .car_led  (m_led),
    .enable_in (!enable),
    .dis ( led ),
    .sel (sel));



endmodule 

