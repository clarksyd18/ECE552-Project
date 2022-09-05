/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
  // Outputs
  DataOut, Done, Stall, CacheHit, err,
  // Inputs
  Addr, DataIn, Rd, Wr, createdump, clk, rst
  );
  
  input wire [15:0] Addr;
  input wire [15:0] DataIn;
  input wire        Rd;
  input wire        Wr;
  input wire        createdump;
  input wire        clk;
  input wire        rst;
  
  output wire [15:0] DataOut;
  output wire        Done;
  output wire        Stall;
  output wire        CacheHit;
  output wire        err;

  // signals from caches
  wire [4:0] tag_out0, tag_out1;
  wire [15:0] data_out0, data_out1;
  wire  hit0, hit1;
  wire  dirty0, dirty1;
  wire  vld0, vld1;
  wire  err0, err1;

  // signals from fsm
  wire  way_sel, en_both_ways, change_way, offset_sel_cache, offset_sel_mem, din_sel, toggle_victimway, tag_sel;
  wire  [2:0] offset_fsm_cache, offset_fsm_mem;
  wire  cache_wr, cache_cmp, cache_vld, mem_rd, mem_wr;

  // signals from mem
  wire [3:0] busy;

  // signals to fsm
  wire [3:0] curr_state;
  wire [3:0] nxt_state;

  dff_Nb #(.N(4)) sreg(.Q(curr_state),.D(nxt_state),.clk(clk),.rst(rst));

  // way logic
  wire victimway, curr_way;
  wire nxt_victimway, nxt_way, en0, en1;

  assign nxt_victimway = (toggle_victimway) ? ~victimway : victimway;
  assign nxt_way       = (change_way)       ? way_sel    : curr_way;

  assign en0 = ~curr_way | en_both_ways;
  assign en1 =  curr_way | en_both_ways;

  wire real_en0, real_en1;
  assign real_en0 = en0 & (Rd|Wr);
  assign real_en1 = en1 & (Rd|Wr);

  dff vway(.q(victimway),.d(nxt_victimway),.clk(clk),.rst(rst));
  dff cway(.q(curr_way),.d(nxt_way),.clk(clk),.rst(rst));

  // combined signals from caches
  wire [4:0]  cache_tag_out;
  wire [15:0] cache_data_out, mem_data_out;

  assign cache_tag_out  = (nxt_way) ? tag_out1  : tag_out0;
  assign cache_data_out = (nxt_way) ? data_out1 : data_out0;

  assign DataOut = cache_data_out;

  wire nxt_hit, curr_hit, fsm_hit;
  assign nxt_hit  = (Done) ? 1'b0 : (curr_hit|fsm_hit);
  assign CacheHit = fsm_hit | curr_hit;
  //assign CacheHit = (Done) ? fsm_hit : curr_hit;
  dff hit_flop (.q(curr_hit),.d(nxt_hit),.clk(clk),.rst(rst));

  cache_fsm i_cache_fsm (
    .rd(Rd),.wr(Wr),
    .vld0(vld0),.vld1(vld1),.hit0(hit0),.hit1(hit1),.dirty0(dirty0),.dirty1(dirty1),
    .victimway(victimway),
    .busy(busy),.curr_state(curr_state),
    .way_sel(way_sel),.en_both_ways(en_both_ways),.change_way(change_way),.offset_sel_cache(offset_sel_cache),
    .offset_sel_mem(offset_sel_mem),.din_sel(din_sel),.toggle_victimway(toggle_victimway),.tag_sel(tag_sel),.fsm_hit(fsm_hit),
    .offset_fsm_cache(offset_fsm_cache),.offset_fsm_mem(offset_fsm_mem),
    .cache_wr(cache_wr),.cache_cmp(cache_cmp),.cache_vld(cache_vld),
    .mem_rd(mem_rd),.mem_wr(mem_wr),
    .stall(Stall),.done(Done),
    .nxt_state(nxt_state)
  );

  // address busses
  wire [15:0] mem_addr;

  wire [4:0] tag_cache, tag_mem;
  wire [7:0] index;
  wire [2:0] offset_cache, offset_mem;

  assign tag_cache = Addr[15:11];
  assign tag_mem   = (tag_sel) ? cache_tag_out : tag_cache;

  assign index = Addr[10:3];

  assign offset_cache = (offset_sel_cache) ? offset_fsm_cache : Addr[2:0];
  assign offset_mem   = (offset_sel_mem)   ? offset_fsm_mem   : Addr[2:0];

  assign mem_addr = {tag_mem,index,offset_mem};

  // data bus
  wire [15:0] din_cache, din_mem;
  assign din_cache = (din_sel) ? mem_data_out   : DataIn;
  assign din_mem   = (din_sel) ? cache_data_out : DataIn;

  /* data_mem = 1, inst_mem = 0 *
   * needed for cache parameter */
  parameter memtype = 0;
  cache #(0 + memtype) c0(// Outputs
                         .tag_out              (tag_out0),
                         .data_out             (data_out0),
                         .hit                  (hit0),
                         .dirty                (dirty0),
                         .valid                (vld0),
                         .err                  (err0),
                         // Inputs
                         .enable               (real_en0),
                         .clk                  (clk),
                         .rst                  (rst),
                         .createdump           (createdump),
                         .tag_in               (tag_cache),
                         .index                (index),
                         .offset               (offset_cache),
                         .data_in              (din_cache),
                         .comp                 (cache_cmp),
                         .write                (cache_wr),
                         .valid_in             (cache_vld));
  cache #(2 + memtype) c1(// Outputs
                         .tag_out              (tag_out1),
                         .data_out             (data_out1),
                         .hit                  (hit1),
                         .dirty                (dirty1),
                         .valid                (vld1),
                         .err                  (err1),
                         // Inputs
                         .enable               (real_en1),
                         .clk                  (clk),
                         .rst                  (rst),
                         .createdump           (createdump),
                         .tag_in               (tag_cache),
                         .index                (index),
                         .offset               (offset_cache),
                         .data_in              (din_cache),
                         .comp                 (cache_cmp),
                         .write                (cache_wr),
                         .valid_in             (cache_vld));

  wire mem_err;

  four_bank_mem mem(// Outputs
                    .data_out          (mem_data_out),
                    .stall             (),
                    .busy              (busy),
                    .err               (mem_err),
                    // Inputs
                    .clk               (clk),
                    .rst               (rst),
                    .createdump        (createdump),
                    .addr              (mem_addr),
                    .data_in           (din_mem),
                    .wr                (mem_wr),
                    .rd                (mem_rd));
  
  // your code here
  
  assign err = (mem_err&(mem_wr|mem_rd)) | (err0&real_en0) | (err1&real_en1);
   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
