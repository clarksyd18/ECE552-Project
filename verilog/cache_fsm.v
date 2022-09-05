`default_nettype none
module cache_fsm(
  //inputs from the entire subsytesm
  input wire rd, wr, //inputs from the cache ways
  input wire vld0, vld1, hit0, hit1, dirty0, dirty1,
  //inputs from internals from subsystem
  input wire victimway,
  input wire [3:0] busy, curr_state,
  //outputs for subsystem datapath
  output reg way_sel, en_both_ways, change_way, offset_sel_cache, offset_sel_mem, din_sel, toggle_victimway, tag_sel, fsm_hit,
  output reg [2:0] offset_fsm_cache, offset_fsm_mem,
  //outputs to cache
  output reg cache_wr, cache_cmp, cache_vld,
  //outputs to mem
  output reg mem_rd, mem_wr,
  //outputs from entire subsystem
  output reg stall, done,
  output reg [3:0] nxt_state
);
localparam IDLE         = 4'h0;
localparam RD_TAG_CHECK = 4'h1;
localparam WR_TAG_CHECK = 4'h2;
localparam RD_MEM       = 4'h3;
localparam RD_MEM2      = 4'h4;
localparam WB0          = 4'h5;
localparam WB1          = 4'h6;
localparam WB2          = 4'h7;
localparam WB3          = 4'h8;
localparam WR_CACHE0    = 4'h9;
localparam WR_CACHE1    = 4'hA;
localparam WR_CACHE2    = 4'hB;
localparam WR_CACHE3    = 4'hC;
localparam DONE         = 4'hD;
localparam WR_HIT       = 4'hE;
localparam WR_MISS      = 4'hF;

always @(*) begin
  way_sel          = 0;
  en_both_ways     = 0;
  change_way       = 0;
  offset_sel_cache = 0;
  offset_sel_mem   = 0;
  din_sel          = 0;
  toggle_victimway = 0;
  tag_sel          = 0;
  fsm_hit          = 0;

  offset_fsm_cache = 0;
  offset_fsm_mem   = 0;

  cache_wr  = 0;
  cache_cmp = 0;
  cache_vld = 0;

  mem_rd = 0;
  mem_wr = 0;

  stall     = 1;
  done      = 0;
  nxt_state = curr_state;

  case (curr_state)
  	IDLE: begin
      stall = (wr|rd);
      en_both_ways = 1;
      cache_cmp = 1;
      toggle_victimway = (~rd & wr) ? 1 :
                         (rd & ~wr) ? 1 : 0;
      nxt_state        = (~rd & wr) ? WR_TAG_CHECK :
                         (rd & ~wr) ? RD_TAG_CHECK : curr_state;
  	end

  	RD_TAG_CHECK: begin
      en_both_ways = 1;
      cache_cmp = 1;
      change_way = 1;

      way_sel = (~((hit0&vld0)|(hit1&vld1))) ? ((~vld0&~vld1) ? 0 :
                ((vld0 ^ vld1) ? vld0 : victimway)) : (hit1&vld1);
      nxt_state = (~((hit0&vld0)|(hit1&vld1))) ? ((~vld0&~vld1) ? RD_MEM :
                ((vld0 ^ vld1) ? RD_MEM : (((~victimway&dirty0)|(victimway&dirty1)) ? WB0 : RD_MEM))) : IDLE;
      done = (hit0&vld0)|(hit1&vld1);
      stall = ~done;
      fsm_hit = (hit0&vld0)|(hit1&vld1);
  	end

  	WB0: begin
      offset_sel_cache = 1;
      offset_sel_mem   = 1;
      offset_fsm_cache = 3'b000;
      offset_fsm_mem   = 3'b000;
      din_sel = 1;
      tag_sel = 1;
      cache_cmp = 1;
      mem_wr    = (busy[0]) ? 0          : 1;
      nxt_state = (busy[0]) ? curr_state : WB1;
  	end

    WB1: begin
      offset_sel_cache = 1;
      offset_sel_mem   = 1;
      offset_fsm_cache = 3'b010;
      offset_fsm_mem   = 3'b010;
      din_sel = 1;
      tag_sel = 1;
      cache_cmp = 1;
      mem_wr    = (busy[1]) ? 0          : 1;
      nxt_state = (busy[1]) ? curr_state : WB2;
  	end

    WB2: begin
      offset_sel_cache = 1;
      offset_sel_mem   = 1;
      offset_fsm_cache = 3'b100;
      offset_fsm_mem   = 3'b100;
      din_sel = 1;
      tag_sel = 1;
      cache_cmp = 1;
      mem_wr    = (busy[2]) ? 0          : 1;
      nxt_state = (busy[2]) ? curr_state : WB3;
  	end

    WB3: begin
      offset_sel_cache = 1;
      offset_sel_mem   = 1;
      offset_fsm_cache = 3'b110;
      offset_fsm_mem   = 3'b110;
      din_sel = 1;
      tag_sel = 1;
      cache_cmp = 1;
      mem_wr    = (busy[3]) ? 0          : 1;
      nxt_state = (busy[3]) ? curr_state : RD_MEM;
  	end

  	RD_MEM: begin
      offset_sel_mem = 1;
      offset_fsm_mem = 3'b000;
      mem_rd = 1;
      nxt_state = RD_MEM2;
  	end

  	RD_MEM2: begin
      offset_sel_mem = 1;
      offset_fsm_mem = 3'b010;
      mem_rd = 1;
      nxt_state = WR_CACHE0;
  	end

  	WR_CACHE0: begin
      offset_sel_cache = 1;
      offset_fsm_cache = 3'b000;
      offset_sel_mem   = 1;
      offset_fsm_mem   = 3'b100;
      din_sel  = 1;
      mem_rd   = 1;
      cache_wr = 1;
      nxt_state = WR_CACHE1;
  	end

    WR_CACHE1: begin
      offset_sel_cache = 1;
      offset_fsm_cache = 3'b010;
      offset_sel_mem   = 1;
      offset_fsm_mem   = 3'b110;
      din_sel  = 1;
      mem_rd   = 1;
      cache_wr = 1;
      nxt_state = WR_CACHE2;
    end

  	WR_CACHE2: begin
      offset_sel_cache = 1;
      offset_fsm_cache = 3'b100;
      din_sel  = 1;
      cache_wr = 1;
      nxt_state = WR_CACHE3;
  	end

    WR_CACHE3: begin
      offset_sel_cache = 1;
      offset_fsm_cache = 3'b110;
      din_sel  = 1;
      cache_wr = 1;
      cache_vld = 1;
      nxt_state = (wr) ? WR_MISS : DONE;
  	end

    DONE: begin
      cache_cmp = 1;
      done = 1;
      stall = 0;
      nxt_state = IDLE;
    end

  	WR_TAG_CHECK: begin
      en_both_ways = 1;
      cache_cmp  = 1;
      change_way = 1;

      way_sel = (~((hit0&vld0)|(hit1&vld1))) ? ((~vld0&~vld1) ? 0 :
                ((vld0 ^ vld1) ? vld0 : victimway)) : (hit1&vld1);
      nxt_state = (~((hit0&vld0)|(hit1&vld1))) ? ((~vld0&~vld1) ? RD_MEM :
                ((vld0 ^ vld1) ? RD_MEM : (((~victimway&dirty0)|(victimway&dirty1)) ? WB0 : RD_MEM))) : WR_HIT;
      fsm_hit = (hit0&vld0)|(hit1&vld1);
  	end

  	WR_HIT: begin
      cache_wr = 1;
      cache_cmp = 1;
      cache_vld = 1;
      done = 1;
      stall = 0;
      nxt_state = IDLE;
  	end

  	WR_MISS: begin
      cache_wr = 1;
      cache_cmp = 1;
      cache_vld = 1;
      nxt_state = DONE;
  	end

    default: begin
      nxt_state = IDLE;
    end

  endcase
end
endmodule
`default_nettype wire
