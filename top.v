module top(
    input clk,
    input rst,
    input enable_in,
    output [1:0]  people_led,
    output [2:0]  car_led,
    output [7:0] sel,
    output [7:0] dis_left,
	  output [7:0] dis 

);


//parameter [31:0] CNT1S = 32'd100;   //1HZ div clk
//parameter [19:0] CNT_MAX = 32'd10;   //1HZ div clk
//parameter [31:0] CNT_DIS = 32'd10;   //1HZ div clk
parameter [31:0] CNT1S = 32'd100_000_000;   //1HZ div clk
parameter [19:0] CNT_MAX = 32'd9999;   //key fileter
parameter [31:0] CNT_DIS = 32'd25_000;   //display frequency

wire [5:0] in_data;
reg [31:0] cnt1s;

reg enable;
wire enable_flag;
wire [5:0] p_cnt_h;
wire [5:0] p_cnt_l;
wire [5:0] m_cnt_h;
wire [5:0] m_cnt_l;
reg [31:0] cnt_sel;
reg [3:0] sel_reg;
wire work_en;
wire rstn;
assign rstn = !rst;

reg  [2:0] m_led;
reg  [1:0] p_led;
wire [5:0] m_cnt;
wire [5:0] p_cnt;
reg [5:0] cnt;

always@(posedge clk or negedge rstn)
    if(!rstn)
        cnt1s <= 32'b0;
    else if ( cnt1s == CNT1S && enable  )
        cnt1s <= 32'b1;
    else if ( enable )
        cnt1s <= cnt1s + 1'b1;
 
always@(posedge clk or negedge rstn)
    if(!rstn)
        cnt <= 6'd35;
    else if ( cnt1s == CNT1S && enable && cnt==6'd0 )
        cnt <= 6'd35;
    else if ( cnt1s == CNT1S && enable )
        cnt <= cnt - 1'b1;

assign work_en = (cnt1s == CNT1S && enable ) ? 1'b1 : 1'b0;
// main load
// cnt : 40 -> 30 > 25 -> 5  --> 40
always@(posedge clk or negedge rstn) 
    if(!rstn)
        m_led <= 3'b100;    //red,green,yellow
    else if ( cnt > 6'd25 )
        m_led <= 3'b100;
    else if ( cnt > 6'd20 ) begin
        if( work_en )
             m_led <= {!m_led[2],2'b0};
    end
    else if ( cnt > 6'd5 )
        m_led <= 3'b010;
    else if ( cnt > 6'd0) begin
        if( work_en)
             m_led <= {2'b0,!m_led[0]};
    end
assign m_cnt = (cnt>6'd19) ? (cnt-6'd20) : (cnt>6'd4) ?  (cnt-6'd5) : cnt;

assign m_cnt_h = (m_cnt/6'd10);
assign m_cnt_l = (m_cnt%6'd10);

            
always@(posedge clk or negedge rstn) 
    if(!rstn)
        p_led <= 2'b01;   //red,green
    else if ( cnt > 6'd25 )
        p_led <= 2'b01;
    else if ( cnt > 6'd20 ) begin
        if(work_en)
            p_led <= {1'b0,!p_led[0]};
    end
    else
        p_led <= 2'b10;
assign p_cnt = ( cnt > 6'd20) ? (cnt - 6'd20 ) : cnt;
assign p_cnt_h = (p_cnt/6'd10);
assign p_cnt_l = (p_cnt%6'd10);
always@(posedge clk or negedge rstn)
    if(!rstn)
        enable <= 1'b0;
    else if ( enable_flag )
        enable <= !enable;

key_filter  #(CNT_MAX)
  u_enable (
   .sys_clk ( clk),
   .sys_rst_n ( rstn),
   .key_in  (!enable_in),
   .key_flag (enable_flag));


always@(posedge clk or negedge rstn)
    if(!rstn)
        cnt_sel <= 32'b0;
    else if ( cnt_sel == CNT_DIS )
        cnt_sel <= 32'b0;
    else
        cnt_sel <= cnt_sel + 1'b1;

always@(posedge clk or negedge rstn)
    if(!rstn)
        sel_reg <= 4'b1;
    else if ( cnt_sel == CNT_DIS )
        sel_reg <= {sel_reg[2:0],sel_reg[3]};


assign in_data = (sel_reg[3])? p_cnt_h:(sel_reg[2])? p_cnt_l:(sel_reg[1])? m_cnt_h:m_cnt_l;
dis_led u1 (
    .in_data ( in_data[3:0] ),
    .out_data (dis ));
assign sel = {sel_reg[3:2],4'b0,sel_reg[1:0]};

assign people_led = p_led;
assign car_led    = m_led;
assign dis_left = dis;

endmodule

