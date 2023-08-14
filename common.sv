// sequence item enum declaration

typedef enum bit [2:0]{
    SINGLE = 3'b000,
    INCR = 3'b001,
    WRAP4 = 3'b010,
    INCR4 = 3'b011,
    WRAP8 = 3'b100,
    INCR8 = 3'b101,
    WRAP16 = 3'b110,
    INCR16 = 3'b111
} burst_t;

//tran enum declaration
typedef enum bit [1:0]{
    IDLE = 2'b00,
    BUSY = 2'b01,
    NONSEQ = 2'b10,
    SEQ = 2'b11
}trans_t;

typedef enum bit [1:0]{
    OKAY = 2'b00,
    ERROR = 2'b01,
    RETRY = 2'b10,
    SPLIT = 2'b11
}error_t;

//common class functions
`define NEW_COMP\
function new (string name = "", uvm_component parent = null);\
    super.new(name,parent);\
endfunction 

`define NEW_OBJ\
function new (string name = "");\
    super.new(name);\
endfunction 

class ahb_common;
    static int total_tx;
    static int num_matches;
    static int num_mismatches;
endclass