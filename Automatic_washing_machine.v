`timescale 1ms / 1ms
module washingmachine(
    i_clk, i_lid, i_start, i_cancel, i_coin, i_mode_1, i_mode_2, i_mode_3,
    o_idle, o_ready, o_soak, o_wash, o_rinse, o_spin, o_coinreturn, o_waterinlet,
    o_done, hex0, hex1, hex2, hex3, hex4, hex5
);
input i_clk, i_start, i_cancel, i_coin, i_lid, i_mode_1, i_mode_2, i_mode_3;
output o_idle, o_ready, o_soak, o_wash, o_rinse, o_spin, o_waterinlet;
output o_coinreturn, o_done;
output reg [0:6] hex0, hex1, hex2, hex3, hex4, hex5;

parameter IDLE = 6'b000001,
          READY = 6'b000010,
          SOAK = 6'b000100,
          WASH = 6'b001000,
          RINSE = 6'b010000,
          SPIN = 6'b100000;

// i_clk = 50 MHz means 1sec = 50 * 10^6 clock cycles

/* Washing Modes:
   mode1 - cloth < 2kg
       Soak: 2 seconds (2 * 50 * 10^6 = 100,000,000)
       Wash: 2 seconds (2 * 50 * 10^6 = 100,000,000)
       Rinse: 2 seconds (2 * 50 * 10^6 = 100,000,000)
       Spin: 2 seconds (2 * 50 * 10^6 = 100,000,000)

   mode2 - 2kg < cloth < 4kg
       Soak: 5 seconds (5 * 50 * 10^6 = 250,000,000)
       Wash: 5 seconds (5 * 50 * 10^6 = 250,000,000)
       Rinse: 5 seconds (5 * 50 * 10^6 = 250,000,000)
       Spin: 5 seconds (5 * 50 * 10^6 = 250,000,000)

   mode3 - 4kg < cloth < 6kg
       Soak: 10 seconds (10 * 50 * 10^6 = 500,000,000)
       Wash: 10 seconds (10 * 50 * 10^6 = 500,000,000)
       Rinse: 10 seconds (10 * 50 * 10^6 = 500,000,000)
       Spin: 10 seconds (10 * 50 * 10^6 = 500,000,000)

   (The values have been set significantly lower than real-world scenarios for easier demonstration in the lab.)
*/

reg [5:0] PS, NS;
reg soak_done, wash_done, rinse_done, spin_done;
wire soak_up, wash_up, rinse_up, spin_up;
wire soak_pause, wash_pause, rinse_pause, spin_pause;
reg [30:0] soakcounter, washcounter, rinsecounter, spincounter; // 30 bits can count up to 1,073,741,824

//------- Timer pause logic when lid is open ------------------
assign soak_pause = (PS == SOAK) && (i_lid);
assign wash_pause = (PS == WASH) && (i_lid);
assign rinse_pause = (PS == RINSE) && (i_lid);
assign spin_pause = (PS == SPIN) && (i_lid);
assign soak_up = (PS == SOAK) && (i_mode_1 || i_mode_2 || i_mode_3);
assign wash_up = (PS == WASH);
assign rinse_up = (PS == RINSE);
assign spin_up = (PS == SPIN);

//---------- SOAK DONE LOGIC ------------------------------
always @(i_mode_1, i_mode_2, i_mode_3, soakcounter) begin
    if (i_mode_1)
        soak_done = (soakcounter == 100000000) ? 1'b1 : 1'b0;
    else if (i_mode_2)
        soak_done = (soakcounter == 250000000) ? 1'b1 : 1'b0;
    else if (i_mode_3)
        soak_done = (soakcounter == 500000000) ? 1'b1 : 1'b0;
end

//---------- WASH DONE LOGIC ------------------------------
always @(i_mode_1, i_mode_2, i_mode_3, washcounter) begin
    if (i_mode_1)
        wash_done = (washcounter == 100000000) ? 1'b1 : 1'b0;
    else if (i_mode_2)
        wash_done = (washcounter == 250000000) ? 1'b1 : 1'b0;
    else if (i_mode_3)
        wash_done = (washcounter == 500000000) ? 1'b1 : 1'b0;
end

//---------- RINSE DONE LOGIC ------------------------------
always @(i_mode_1, i_mode_2, i_mode_3, rinsecounter) begin
    if (i_mode_1)
        rinse_done = (rinsecounter == 100000000) ? 1'b1 : 1'b0;
    else if (i_mode_2)
        rinse_done = (rinsecounter == 250000000) ? 1'b1 : 1'b0;
    else if (i_mode_3)
        rinse_done = (rinsecounter == 500000000) ? 1'b1 : 1'b0;
end

//---------- SPIN DONE LOGIC ------------------------------
always @(i_mode_1, i_mode_2, i_mode_3, spincounter) begin
    if (i_mode_1)
        spin_done = (spincounter == 100000000) ? 1'b1 : 1'b0;
    else if (i_mode_2)
        spin_done = (spincounter == 250000000) ? 1'b1 : 1'b0;
    else if (i_mode_3)
        spin_done = (spincounter == 500000000) ? 1'b1 : 1'b0;
end

//----------- SOAK TIMER ------------------------------------
always @(posedge i_clk) begin
    if (i_start)
        soakcounter <= 0;
    if (soak_done)
        soakcounter <= 0;
    else if (soak_pause)
        soakcounter <= soakcounter;
    else if (soak_up)
        soakcounter <= soakcounter + 1'b1;
end

//----------- WASH TIMER ------------------------------------
always @(posedge i_clk) begin
    if (i_start)
        washcounter <= 0;
    else if (wash_done)
        washcounter <= 0;
    else if (wash_pause)
        washcounter <= washcounter;
    else if (wash_up)
        washcounter <= washcounter + 1'b1;
end

//----------- RINSE TIMER ------------------------------------
always @(posedge i_clk) begin
    if (i_start)
        rinsecounter <= 0;
    else if (rinse_done)
        rinsecounter <= 0;
    else if (rinse_pause)
        rinsecounter <= rinsecounter;
    else if (rinse_up)
        rinsecounter <= rinsecounter + 1'b1;
end

//----------- SPIN TIMER ------------------------------------
always @(posedge i_clk) begin
    if (i_start)
        spincounter <= 0;
    else if (spin_done)
        spincounter <= 0;
    else if (spin_pause)
        spincounter <= spincounter;
    else if (spin_up)
        spincounter <= spincounter + 1'b1;
end

//---------------- Present state logic ----------------------
always @(posedge i_clk) begin
    if (i_start)
        PS <= IDLE;
    else if (i_cancel)
        PS <= IDLE;
    else
        PS <= NS;
end

//----------- Next state decoder logic ----------------------
always @(*) begin
    case (PS)
        IDLE: begin
            // display IdLE
            hex0 = 7'b1111111;
            hex1 = 7'b1111111;
            hex2 = 7'b0110000;
            hex3 = 7'b1110001;
            hex4 = 7'b1000010;
            hex5 = 7'b1111001;
            if (~i_coin && !i_lid && !i_cancel)
                NS <= READY;
            else
                NS <= PS;
        end
        READY: begin
            hex0 = 7'b1111111;
            hex1 = 7'b1000100;
            hex2 = 7'b1000010;
            hex3 = 7'b0001000;
            hex4 = 7'b0110000;
            hex5 = 7'b1111010;
            // display rEAdy
            if (!i_lid && !i_cancel && (i_mode_1 || i_mode_2 || i_mode_3))
                NS <= SOAK;
            else
                NS <= PS;
        end
        SOAK: begin
            // display SoAk
            hex0 = 7'b1111111;
            hex1 = 7'b1111111;
            hex2 = 7'b1111000;
            hex3 = 7'b0001000;
            hex4 = 7'b1100010;
            hex5 = 7'b0100100;
            if (!i_lid && !i_cancel && soak_done)
                NS <= WASH;
            else
                NS <= PS;
        end
        WASH: begin
            // display WASh
            hex0 = 7'b1111111;
            hex1 = 7'b1111111;
            hex2 = 7'b1101000;
            hex3 = 7'b0100100;
            hex4 = 7'b0001000;
            hex5 = 7'b1100001;
            if (!i_lid && !i_cancel && wash_done)
                NS <= RINSE;
            else
                NS <= PS;
        end
        RINSE: begin
            // display rInSE
            hex0 = 7'b1111111;
            hex1 = 7'b0110000;
            hex2 = 7'b0100100;
            hex3 = 7'b1101010;
            hex4 = 7'b1111001;
            hex5 = 7'b1111010;
            if (!i_lid && !i_cancel && rinse_done)
                NS <= SPIN;
            else
                NS <= PS;
        end
        SPIN: begin
            // display SPIn
            hex0 = 7'b1111111;
            hex1 = 7'b1111111;
            hex2 = 7'b1101010;
            hex3 = 7'b1111001;
            hex4 = 7'b0011000;
            hex5 = 7'b0100100;
            if (!i_lid && !i_cancel && spin_done)
                NS <= IDLE;
            else
                NS <= PS;
        end
        default: NS <= IDLE;
    endcase
end

//--------- output logic ------------
assign o_idle = (PS == IDLE);
assign o_ready = (PS == READY);
assign o_soak = (PS == SOAK);
assign o_wash = (PS == WASH);
assign o_rinse = (PS == RINSE);
assign o_spin = (PS == SPIN);
assign o_waterinlet = (PS == SOAK) || (PS == WASH) || (PS == RINSE);
assign o_coinreturn = (PS == READY) && (i_cancel);
assign o_done = (PS == SPIN) && (spin_done);

endmodule
