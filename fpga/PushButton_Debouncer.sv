module PushButton_Debouncer(
    input clk,
    input PB,  // "PB" is the glitchy, asynchronous to clk, active low push-button signal
	 input reset,

    // from which we make three outputs, all synchronous to the clock
    output reg PB_state = 0,  // 1 as long as the push-button is active (down)
    output PB_down,  // 1 for one clock cycle when the push-button goes down (i.e. just pushed)
    output PB_up   // 1 for one clock cycle when the push-button goes up (i.e. just released)
);

// First use two flip-flops to synchronize the PB signal the "clk" clock domain
reg PB_sync_0;
reg PB_sync_1;  
always @(posedge clk) 
begin
	if (reset)
	begin
		PB_sync_0 <= 0;
		PB_sync_1 <= 0;
	end
	else
	begin
		PB_sync_0 <= ~PB;  // invert PB to make PB_sync_0 active high
		PB_sync_1 <= PB_sync_0;
	end
end
// Next declare a 16-bits counter
reg [19:0] PB_cnt;

// When the push-button is pushed or released, we increment the counter
// The counter has to be maxed out before we decide that the push-button state has changed

wire PB_idle 		= (PB_state==PB_sync_1);
wire PB_cnt_max 	= &PB_cnt;	// true when all bits of PB_cnt are 1's

always @(posedge clk)
if(reset)
begin
	PB_cnt 	<= 0;
	PB_state <= 0;
end
else
begin
	if(PB_idle)
		 PB_cnt <= 0;  // nothing's going on
	else
	begin
		 PB_cnt <= PB_cnt + 19'd1;  // something's going on, increment the counter
		 if(PB_cnt_max) 
				PB_state <= ~PB_state;  // if the counter is maxed out, PB changed!
	end
end

assign PB_down = ~PB_idle & PB_cnt_max & ~PB_state;
assign PB_up   = ~PB_idle & PB_cnt_max &  PB_state;
endmodule