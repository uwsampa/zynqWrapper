module BRAMFIFO
#(
    parameter p1width = 32,
    parameter p2depth = 1024,
    parameter p3cntr_width = 10
)
(
    input CLK,
    input RST_N,
    input [p1width-1:0] D_IN,
    output [p1width-1:0] D_OUT,
    input ENQ,
    input DEQ,
    output EMPTY_N,
    output FULL_N,
    output [p3cntr_width-1:0] COUNT,
    input CLR
);

    reg [p3cntr_width-1:0] wptr, wptr_d, wptr_p1; // reg
    reg [p3cntr_width-1:0] rptr, rptr_d, rptr_p1; // reg
    reg [p3cntr_width-1:0] dcount, dcount_d;      // reg

    (* ram_style = "block" *) reg [p1width-1:0] mem [p2depth-1:0];
    reg [p1width-1:0] mem_d; // comb
    reg [p1width-1:0] dout_r; // register
    reg               inhibit, inhibit_d;

    reg               mem_wen; // comb
    reg               nempty, nempty_d;
    reg               nfull, nfull_d;


    always@(posedge CLK) begin
        if(RST_N && !CLR) begin
            wptr    <= wptr_d;
            rptr    <= rptr_d;
            nfull   <= nfull_d;
            nempty  <= nempty_d;
            inhibit <= inhibit_d;
            dcount  <= dcount_d;
            if(mem_wen) mem[wptr] <= D_IN;
        end
        else begin
            rptr    <= {p3cntr_width{1'b0}};
            wptr    <= {p3cntr_width{1'b0}};
            nfull   <= 1'b1;
            nempty  <= 1'b0;
            inhibit <= 1'b0;
            dcount  <= {p3cntr_width{1'b0}};
        end
    end


    always@(*) begin

        wptr_d    = wptr;
        rptr_d    = rptr;
        nfull_d   = nfull;
        nempty_d  = nempty;
        mem_wen   = 1'b0;
        inhibit_d = 1'b0;
        wptr_p1   = (wptr + 1) % p2depth;
        rptr_p1   = (rptr + 1) % p2depth;
        dcount_d  = dcount;

        if(ENQ) begin
            wptr_d  = wptr_p1;
            mem_wen = 1'b1;
        end

        if(DEQ) begin
            rptr_d = rptr_p1;
        end

        if(ENQ && DEQ) begin
            nfull_d  = nfull;
            nempty_d = nempty;
            if(wptr == rptr) inhibit_d = 1'b1;
        end
        else if(DEQ && !ENQ) begin
            nfull_d  = 1'b1;
            nempty_d = rptr_p1 != wptr;
            dcount_d = dcount-1;
        end
        else if(ENQ && !DEQ) begin
            nfull_d  = wptr_p1 != rptr;
            nempty_d = 1'b1;
            dcount_d = dcount+1;
        end

    end

    assign D_OUT = mem[rptr];
    assign EMPTY_N = nempty && !inhibit;
    assign FULL_N = nfull;
    assign COUNT = dcount;

    //synopsys translate off
    always@(negedge CLK) begin
        if(RST_N) begin
            if(ENQ && !FULL_N) begin
                $display("ERROR, enqueuing to full BRAMFIFO");
                $finish(0);
            end

            if(DEQ && !EMPTY_N) begin
                $display("ERROR, dequeuing to empty BRAMFIFO");
                $finish(0);
            end
        end
    end
    //synopsys translate on

endmodule
