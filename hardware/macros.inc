`define MAKE_CONST(width, val) localparam [width-1:0] width``_``val = val;

`define REG(name, w_type, width, init)\
    reg [width-1:0] name;\
    w_type [width-1:0] name``_d;\
    always@(posedge CLK) begin\
    if(RST_N) name <= name``_d;\
    else name <= init;\
    end

`define CREG(name, width)\
    reg [width-1:0] name;

`define WIRE(name, width)\
    wire [width-1:0] name;

`define ZERO(name, width)\
    wire [width-1:0] name;\
    parameter name``_zero = 0;\
    assign name = name``_zero[width-1:0];

`define COUNTER(name, w_type, width, init)\
    reg [width-1:0] name;\
    w_type [width-1:0] name``_inc;\
    w_type [width-1:0] name``_dec;\
    always@(posedge CLK) begin\
    if(RST_N) begin\
        name <= name + name``_inc - name``_dec;\
    end\
    else name <= init;\
    end

`define FIFO_TEMPLATE(fifotype, w_type, r_type, name, depth, width)\
    w_type [width:0] name``_enq;\
    wire [width-1:0] name``_dout;\
    r_type name``_deq;\
    wire name``_notEmpty;\
    wire name``_notFull;\
    localparam name``_cntrwidth = `LOG2((depth));\
    fifotype#(.p1width(width),\
          .p2depth(depth),\
          .p3cntr_width(name``_cntrwidth)) name\
    (\
    .CLK(CLK),\
    .RST_N(RST_N),\
    .D_IN(name``_enq[width-1:0]),\
    .D_OUT(name``_dout),\
    .ENQ(name``_enq[width]),\
    .DEQ(name``_deq),\
    .EMPTY_N(name``_notEmpty),\
    .FULL_N(name``_notFull),\
    .CLR(1'b0)\
    );


`define LUTRAM_TEMPLATE(wtype, name, d, w) \
    localparam name``_aw = `LOG2(d); \
    reg [w-1:0] name [d-1:0]; \
    wtype [name``_aw+w:0] name``_wcmd; \
    wire name``_wen   = name``_wcmd[ w + name``_aw ]; \
    wire name``_waddr = name``_wcmd[ w + name``_aw - 1 : w ]; \
    integer name``_i;\
    initial for(name``_i=0; name``_i < d; name``_i=name``_i+1) name[name``_i] = 0; \
    always@(posedge CLK) begin \
        if(RST_N) begin \
        if(name``_wen) \
            name[ name``_waddr ] <= name``_wcmd[ w-1 : 0 ]; \
        end \
    end

`define LUTRAM_TEMPLATE_2W(wtype0, wtype1, name, d, w) \
    localparam name``_aw = `LOG2(d); \
    reg [w-1:0] name [d-1:0]; \
    wtype0 [name``_aw+w:0] name``_wcmd0; \
    wtype1 [name``_aw+w:0] name``_wcmd1; \
    wire name``_wen0   = name``_wcmd0[ w + name``_aw ]; \
    wire name``_wen1   = name``_wcmd1[ w + name``_aw ]; \
    wire name``_waddr0 = name``_wcmd0[ w + name``_aw - 1 : w ]; \
    wire name``_waddr1 = name``_wcmd1[ w + name``_aw - 1 : w ]; \
    integer name``_i;\
    initial for(name``_i=0; name``_i < d; name``_i=name``_i+1) name[name``_i] = 0; \
    always@(posedge CLK) begin \
        if(RST_N) begin \
        if(name``_wen0) \
            name[ name``_waddr0 ] <= name``_wcmd0[ w-1 : 0 ]; \
                if(name``_wen1) \
                    name[ name``_waddr1 ] <= name``_wcmd1[ w-1 : 0 ]; \
            end \
    end \

`define SEQ_ASSERT(cond,msg)\
    always@(negedge CLK) begin\
        if(RST_N && !(cond)) begin\
            $display(msg);\
            $finish(0);\
        end\
    end

`define COMB_ASSERT(cond,msg)\
    if(RST_N && !(cond)) begin\
        $display(msg);\
        $finish(0);\
    end


`define BRAM_TEMPLATE(wtype, name, d, w)                           \
    localparam name``_aw = `LOG2((d));                             \
    (* ram_style = "block" *)                                      \
    reg [(w)-1:0] name [(d)-1:0];                                  \
    wtype [1+name``_aw+(w):0] name``_acmd;                         \
    wtype [1+name``_aw+(w):0] name``_bcmd;                         \
    wire name``_en_a = name``_acmd[ 1 + (w) + name``_aw ];         \
    wire name``_en_b = name``_bcmd[ 1 + (w) + name``_aw ];         \
    wire name``_wen_a = name``_acmd[ (w) + name``_aw ];            \
    wire name``_wen_b = name``_bcmd[ (w) + name``_aw ];            \
    wire [name``_aw-1:0] name``_waddr_a = name``_acmd[ (w) + name``_aw - 1 : (w) ];\
    wire [name``_aw-1:0] name``_waddr_b = name``_bcmd[ (w) + name``_aw - 1 : (w) ];\
    reg [(w)-1:0] name``_aval;                                     \
    reg [(w)-1:0] name``_bval;                                     \
    always @(posedge CLK) begin                                    \
        if(RST_N) begin                                            \
            if(name``_en_a) begin                                  \
                if(name``_wen_a)                                   \
                name[ name``_waddr_a ] <= name``_acmd[ (w)-1 : 0 ];\
            end                                                    \
            name``_aval <= name[ name``_waddr_a ];                 \
            if(name``_en_b) begin                                  \
                if(name``_wen_b)                                   \
                name[ name``_waddr_b ] <= name``_bcmd[ (w)-1 : 0 ];\
            end                                                    \
            name``_bval <= name[ name``_waddr_b ];                 \
        end                                                        \
    end
