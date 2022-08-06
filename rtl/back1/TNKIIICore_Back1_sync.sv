//TNKIIICore_Back1_sync.sv
//Author: @RndMnkIII
//Date: 25/05/2022
`default_nettype none
`timescale 1ns/1ps

module TNKIIICore_Back1_sync(
    input  wire VIDEO_RSTn,
    input wire clk,
    input wire CK1,
    input wire RESET,
    //Flip screen control
    input wire INV,
    input wire INVn,
    //common video data bus
    input wire [7:0] VD_in,
    output logic [7:0] VD_out,
    //hps_io rom interface
	input wire         [24:0] ioctl_addr,
	input wire         [7:0] ioctl_data,
	input wire               ioctl_wr,
    //Registers
    input wire B1SY,
    input wire B1SX,

    //HACK SETTINGS
    input wire [7:0] hack_settings,
    input wire [3:0] dbg_B1Voffset, 
    input wire swap_px,
    //MSBs
    input wire B1Y8,
    input wire B1X8,

    //VIDEO/CPU Selector
    input wire V_C,

    //B address
    input wire H8,
    input wire [4:0] Y, //Y[7:3] in schematics
    input wire H2,
    input wire H1,
    input wire H0,
    input wire [7:0] X, 

    input wire [12:0] VA,
    input wire BACK1_VRAM_CSn,
    
    //A address
    input wire VFLGn,

    //side SRAM control
    input wire VRD,
    input wire VDG,
    input wire VOE,
    input wire VWE,

    //clocking
    input wire CK1n,
    input wire LA,
    input wire VLK,
    //input wire H3

    //Back1 data color
    input wire B1_COLBK, //from registers LS273 A4 (bit 6)
    input wire JMP_B1D7,
    output logic [7:0] B1D
);

    //RAM BANK Selection logic 
    logic B1B0,B1B1;
    // assign B1B0 = VA[0] | BACK1_VRAM_CSn; //active low signal
    // assign B1B1 = ~(VA[0] & ~BACK1_VRAM_CSn); //active low signal
    assign B1B0 = (!VA[0] && !BACK1_VRAM_CSn) ? 1'b0 : 1'b1; //active low signal
    assign B1B1 = ( VA[0] && !BACK1_VRAM_CSn) ? 1'b0 : 1'b1; //active low signal

    //Y Scroll Register, Adder section
    logic [2:0] XOR_YSR;
    logic [7:0] B1Y;
    assign XOR_YSR[2] = VD_in[2] ^ INVn;
    assign XOR_YSR[1] = VD_in[1] ^ INVn;
    assign XOR_YSR[0] = VD_in[0] ^ INVn;

    //*** Synchronous Hack ***
    reg [7:0] vdin_r;
    always @(posedge clk) begin
        vdin_r <= {VD_in[7:3],XOR_YSR};
    end

    ttl_74273_sync g2(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1SY), .D(vdin_r), .Q(B1Y)); //HACK

    logic [8:0] B1H;
    logic [2:0] B1Hn;
    logic c14_dum3;
    logic [1:0] c12_dum;
    //Y7~3 -> Y[4:0]
    ttl_74283_nodly c14 (.A({1'b1, B1Y[2:0]}),    .B({1'b1, H2,H1,H0}), .C_in(1'b0),     .Sum({c14_dum3,B1H[2:0]}),           .C_out()        );//TNKIII changes with respecto to AlphaMission, C_in = 1'b1
    //assign B1H[2:0] = {H2,H1,H0} + B1Y[2:0] - dbg_B1Voffset;
    //logic c13_cout;
    // ttl_74283_nodly c13 (.A(B1Y[6:3]),            .B(Y[3:0]),           .C_in(1'b0),     .Sum(B1H[6:3]),                      .C_out(c13_cout)); //TNKIII changes with respecto to AlphaMission C_in = 1'b1
    // ttl_74283_nodly c12 (.A({2'b11,B1Y8,B1Y[7]}), .B({2'b11, H8,Y[4]}), .C_in(c13_cout), .Sum({c12_dum,B1H[8:7]}),            .C_out()        );

    //*** HACK SETTINGS FOR SCREEN FLIP INSIDE CORE ***
    logic [5:0] const_plus1d;  
    assign const_plus1d = (hack_settings[0]) ? 6'b00_0001 : 6'b00_0000;
    assign B1H[8:3] = {B1Y8,B1Y[7:3]} + {H8,Y} + const_plus1d; //B1Y[8:3] - X - 1h
    //*** HACK SETTINGS FOR SCREEN FLIP INSIDE CORE ***

    assign B1Hn[0] = ~B1H[0];
    assign B1Hn[1] = ~B1H[1];
    assign B1Hn[2] = ~B1H[2];

    logic [8:0] B1HQ;
    //logic [2:0] d13_dum;
    logic [5:0] d13_q;
    ttl_74174_sync d13
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1n),
        //.Cen(CK1), //HACK
        .Clr_n(1'b1),
        .D({3'b111,B1Hn}),
        .Q(d13_q)
    );
    assign B1HQ[2:0] = d13_q[2:0];

    logic [5:0] d12_q;
    ttl_74174_sync d12
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1n),
        //.Cen(CK1), //HACK
        .Clr_n(1'b1),
        .D(B1H[8:3]),
        .Q(d12_q)
    );
    assign B1HQ[8:3] = d12_q[5:0];

    //X Scroll Register, Adder section
    reg [7:0] vdinX_r;
     always @(posedge clk) begin
        vdinX_r <= VD_in;
    end

    logic [7:0] B1X;
    ttl_74273_sync b12(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1SX), .D(vdinX_r), .Q(B1X)); //*** SYNCHRONOUS HACK ***
    logic [8:0] B1V;
    // logic a12_cout;
    // ttl_74283_nodly a12 (.A(B1X[3:0]),    .B(X[3:0]), .C_in(1'b0),         .Sum(B1V[3:0]), .C_out(a12_cout));
    // logic a11_cout;
    // ttl_74283_nodly a11 (.A(B1X[7:4]),    .B(X[7:4]), .C_in(a12_cout),     .Sum(B1V[7:4]), .C_out(a11_cout));
    // assign B1V[8] = B1X8 ^ a11_cout;

    //*** HACK SETTINGS FOR SCREEN FLIP INSIDE CORE ***
    logic [8:0] const_minus40d; //a2 complement of 0x28 (-40 decimal value)  
    assign const_minus40d = (hack_settings[0]) ? 9'b1_1101_1000 : 9'b0_0000_0000;
    assign B1V = {B1X8,B1X} + {1'b0,X} + const_minus40d; //B1X - X - 28h
    //assign B1V = {B1X8,B1X} + {1'b0,X} + {dbg_B1Voffset[2],dbg_B1Voffset[2],dbg_B1Voffset[2],dbg_B1Voffset[2],dbg_B1Voffset[2],dbg_B1Voffset[2],dbg_B1Voffset[2],dbg_B1Voffset[1],dbg_B1Voffset[0]};
    //*** HACK SETTINGS FOR SCREEN FLIP INSIDE CORE ***

    //2:1 Back1 SRAM bus addresses MUX
    //ttl_74157 A_2D({B3,A3,B2,A2,B1,A1,B0,A0})
    logic L4_CSn, L3_CSn; //SRAM chip select signal
    logic [12:0] A;
    logic dum1;

    //Switch between CPU/VIDEO access (V_C signal)
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) e12 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({1'b1,1'b1,VA[12],B1HQ[8],VA[11],B1HQ[7],VA[10],B1HQ[6]}), .Y(A[12:9]));

    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) e13 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[9],B1HQ[5],VA[8],B1HQ[4],VA[7],B1HQ[3],VA[6],B1V[8]}), .Y(A[8:5]));

    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) e14 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[5],B1V[7],VA[4],B1V[6],VA[3],B1V[5],VA[2],B1V[4]}), .Y(A[4:1]));

    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) d2 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[1],B1V[3],B1B0,VFLGn,B1B1,VFLGn,1'b1,1'b1}), .Y({A[0],L3_CSn,L4_CSn,dum1}));

    logic BACK1_SEL0, BACK1_SEL1;
    assign BACK1_SEL0 = ~(B1B0 | VDG);
    assign BACK1_SEL1 = ~(B1B1 | VDG);

    //data bus multiplexer from VD_in  
    logic [7:0] D0, D1, Din0, Din1;
    assign Din0 = (BACK1_SEL0 && VRD) ?  VD_in : 8'hFF;
    assign Din1 = (BACK1_SEL1 && VRD) ?  VD_in : 8'hFF;

    //--- 2X HM6264LP-15 8Kx8 150ns SRAM ---
    logic [7:0] back1_0_Q, back1_1_Q;
    logic [7:0] D0reg, D1reg;
    logic L4_CS, L3_CS;

    assign L3_CS = ~L3_CSn;
    assign L4_CS = ~L4_CSn;

    logic [11:0] h12_addr1;
    assign h12_addr1 = {B1HQ[8:3],B1V[8:3]};

    //LOW
    SRAM_dual_sync #(.ADDR_WIDTH(12)) L3
    (
        .ADDR0({VA[12:1]}), 
        .clk0(clk), 
        .cen0(L3_CS), 
        .we0(~VWE), 
        .DATA0(Din0), 
        .Q0(back1_0_Q),
        .ADDR1(h12_addr1), 
        .clk1(clk), 
        .cen1(~VFLGn), 
        .we1(1'b0), 
        .DATA1(8'hff),
        .Q1(D0reg)
    );
	 
//	     SRAM_dual_sync #(.ADDR_WIDTH(12)) L3
//    (
//        .ADDR0({A[12:1]}), 
//        .clk0(clk), 
//        .cen0(L3_CS), 
//        .we0(~VWE), 
//        .DATA0(Din0), 
//        .Q0(back1_0_Q),
//        .ADDR1(h12_addr1), 
//        .clk1(clk), 
//        .cen1(~VFLGn), 
//        .we1(1'b0), 
//        .DATA1(8'hff),
//        .Q1(D0reg)
//    );

    //HIGH
    SRAM_dual_sync #(.ADDR_WIDTH(12)) L4
    (
        .ADDR0({VA[12:1]}), 
        .clk0(clk), 
        .cen0(L4_CS), 
        .we0(~VWE), 
        .DATA0(Din1), 
        .Q0(back1_1_Q),
        .ADDR1(h12_addr1), 
        .clk1(clk), 
        .cen1(~VFLGn), 
        .we1(1'b0), 
        .DATA1(8'hff),
        .Q1(D1reg)
    );
//    SRAM_dual_sync #(.ADDR_WIDTH(12)) L4
//    (
//        .ADDR0({A[12:1]}), 
//        .clk0(clk), 
//        .cen0(L4_CS), 
//        .we0(~VWE), 
//        .DATA0(Din1), 
//        .Q0(back1_1_Q),
//        .ADDR1(h12_addr1), 
//        .clk1(clk), 
//        .cen1(~VFLGn), 
//        .we1(1'b0), 
//        .DATA1(8'hff),
//        .Q1(D1reg)
//    );
    assign D0 = (!VOE) ? back1_0_Q : 8'hff;
    assign D1 = (!VOE) ? back1_1_Q : 8'hff;
    assign VD_out = (BACK1_SEL0 && !VRD) ? D0 : ((BACK1_SEL1 && !VRD) ? D1 : 8'hff);

    //added delay using FF
    //ttl_74273_sync Dreg_dly(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(CK1), .D(D), .Q(Dreg));

    //Background tile ROM address generator
    //LOW BYTE
    logic [7:0] H2_Q;
    ttl_74273_sync H2ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(VLK), .D(D0reg), .Q(H2_Q));
//    ttl_74273_sync H2ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(VLK), .D(back1_0_Q), .Q(H2_Q));

    logic [7:0] G2_Q;
    ttl_74273_sync G2ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(LA), .D(H2_Q), .Q(G2_Q));

    logic [7:0] F2_Q;
    ttl_74273_sync F2ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1HQ[2]), .D(G2_Q), .Q(F2_Q));

    //HIGH BYTE
    logic [7:0] H3_Q;
    ttl_74273_sync H3ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(VLK), .D(D1reg), .Q(H3_Q));
//	 ttl_74273_sync H3ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(VLK), .D(back1_1_Q), .Q(H3_Q));

    logic [7:0] G3_Q;
    ttl_74273_sync G3ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(LA), .D(H3_Q), .Q(G3_Q));

    logic [7:0] F3_Q;
    ttl_74273_sync F3ic(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1HQ[2]), .D(G3_Q), .Q(F3_Q));

    logic CE3_A0;
    logic CE3_A1;
    assign CE3_A0 = B1HQ[1] ^ INV; //IC 11D Unit B
    assign CE3_A1 = B1HQ[2] ^ INV; //IC 11D Unit A

    //MBM27256-25 250ns 32Kx8 P10 BACK1 ROM ---
    //hps_io rom load interface
    //wire P12_D_cs = (ioctl_addr >= 25'h40_000) & (ioctl_addr < 25'h44_000);
    //wire P13_D_cs = (ioctl_addr >= 25'h44_000) & (ioctl_addr < 25'h48_000);
    wire BACK1_ROM_cs = (ioctl_addr >= 25'h40_000) && (ioctl_addr < 25'h48_000);
    
    // logic [7:0] P12D_D;
    // eprom_16K P12
    // (
    //     .ADDR({F3_Q[4], F2_Q[7:0], B1V[2:0], CE3_A1, CE3_A0}),
    //     .CLK(clk),
    //     .DATA(P12D_D),
    //     .ADDR_DL(ioctl_addr),
    //     .CLK_DL(clk),
    //     .DATA_IN(ioctl_data),
    //     .CS_DL(P12_D_cs),
    //     .WR(ioctl_wr)
    // );

    // logic [7:0] P13C_D;
    // eprom_16K P13
    // (
    //     .ADDR({F3_Q[4], F2_Q[7:0], B1V[2:0], CE3_A1, CE3_A0}),
    //     .CLK(clk),
    //     .DATA(P13C_D),
    //     .ADDR_DL(ioctl_addr),
    //     .CLK_DL(clk),
    //     .DATA_IN(ioctl_data),
    //     .CS_DL(P13_D_cs),
    //     .WR(ioctl_wr)
    // );
    logic [7:0] ROM_DATA;
        eprom_32K BACK1_ROM
    (
        .ADDR({F3_Q[5],F3_Q[4], F2_Q[7:0], B1V[2:0], CE3_A1, CE3_A0}),
        .CLK(clk),
        .DATA(ROM_DATA),
        .ADDR_DL(ioctl_addr),
        .CLK_DL(clk),
        .DATA_IN(ioctl_data),
        .CS_DL(BACK1_ROM_cs),
        .WR(ioctl_wr)
    );
    
    //assign ROM_DATA = (!F3_Q[5]) ? P12D_D : P13C_D;

    logic [1:0] a3_dummy;
    logic [3:0] A3_Q;
    ttl_74174_sync B1(
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(B1HQ[0]),
        .Clr_n(1'b1),
        .D({2'b11,F3_Q[3:0]}),
        .Q({a3_dummy,A3_Q[3:0]})
    );

    logic [3:0] A3bis_Q,A3bis2_Q,A3bis3_Q,A3bis4_Q,A3bis5_Q,A3bis6_Q,A3bis7_Q,A3bis8_Q,A3bis9_Q,A3bis10_Q,A3bis11_Q,A3bis12_Q,A3bis13_Q,A3bis14_Q,A3bis15_Q;

    always @(posedge clk) begin
        A3bis2_Q <= A3_Q;
        A3bis3_Q <= A3bis2_Q;
        A3bis4_Q <= A3bis3_Q;
        A3bis5_Q <= A3bis4_Q;
        A3bis6_Q <= A3bis5_Q;
        A3bis7_Q <= A3bis6_Q;
        A3bis8_Q <= A3bis7_Q;
        A3bis9_Q <= A3bis8_Q;
        A3bis10_Q <= A3bis9_Q;
        A3bis11_Q <= A3bis10_Q;
        A3bis12_Q <= A3bis11_Q;
        A3bis13_Q <= A3bis12_Q;
        A3bis14_Q <= A3bis13_Q;
        A3bis15_Q <= A3bis14_Q;
    end

    always_comb begin
        case (dbg_B1Voffset)
            4'b0000:  A3bis_Q = A3_Q;
            4'b0001:  A3bis_Q = A3bis2_Q;
            4'b0010:  A3bis_Q = A3bis3_Q;
            4'b0011:  A3bis_Q = A3bis4_Q;
            4'b0100:  A3bis_Q = A3bis5_Q;
            4'b0101:  A3bis_Q = A3bis6_Q;
            4'b0110:  A3bis_Q = A3bis7_Q;
            4'b0111:  A3bis_Q = A3bis8_Q;
            4'b1000:  A3bis_Q = A3bis9_Q;
            4'b1001:  A3bis_Q = A3bis10_Q;
            4'b1010:  A3bis_Q = A3bis11_Q;
            4'b1011:  A3bis_Q = A3bis12_Q;
            4'b1100:  A3bis_Q = A3bis13_Q;
            4'b1101:  A3bis_Q = A3bis14_Q;
            4'b1110:  A3bis_Q = A3bis15_Q;
            default: A3bis_Q = A3_Q;    
        endcase
    end

    //In the TNKIII PCB schematics there is a jumper to connect B1D7 to B1_COLBK (default) or A3_Q3.
    assign B1D[7] = (JMP_B1D7) ? B1_COLBK : A3bis_Q[3];
    assign {B1D[6],B1D[5],B1D[4]} = {A3bis_Q[2],A3bis_Q[1],A3bis_Q[0]};

    logic [7:0] B2_Q;
    ttl_74273_sync B2(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1HQ[0]), .D(ROM_DATA), .Q(B2_Q));
    logic [7:0] B2bis_Q,B2bis2_Q,B2bis3_Q,B2bis4_Q,B2bis5_Q,B2bis6_Q,B2bis7_Q,B2bis8_Q,B2bis9_Q,B2bis10_Q,B2bis11_Q,B2bis12_Q,B2bis13_Q,B2bis14_Q,B2bis15_Q;

    always @(posedge clk) begin
        B2bis2_Q <= B2_Q;
        B2bis3_Q <= B2bis2_Q;
        B2bis4_Q <= B2bis3_Q;
        B2bis5_Q <= B2bis4_Q;
        B2bis6_Q <= B2bis5_Q;
        B2bis7_Q <= B2bis6_Q;
        B2bis8_Q <= B2bis7_Q;
        B2bis9_Q <= B2bis8_Q;
        B2bis10_Q <= B2bis9_Q;
        B2bis11_Q <= B2bis10_Q;
        B2bis12_Q <= B2bis11_Q;
        B2bis13_Q <= B2bis12_Q;
        B2bis14_Q <= B2bis13_Q;
        B2bis15_Q <= B2bis14_Q;
    end

    always_comb begin
        case (dbg_B1Voffset)
            4'b0000:  B2bis_Q = B2_Q;
            4'b0001:  B2bis_Q = B2bis2_Q;
            4'b0010:  B2bis_Q = B2bis3_Q;
            4'b0011:  B2bis_Q = B2bis4_Q;
            4'b0100:  B2bis_Q = B2bis5_Q;
            4'b0101:  B2bis_Q = B2bis6_Q;
            4'b0110:  B2bis_Q = B2bis7_Q;
            4'b0111:  B2bis_Q = B2bis8_Q;
            4'b1000:  B2bis_Q = B2bis9_Q;
            4'b1001:  B2bis_Q = B2bis10_Q;
            4'b1010:  B2bis_Q = B2bis11_Q;
            4'b1011:  B2bis_Q = B2bis12_Q;
            4'b1100:  B2bis_Q = B2bis13_Q;
            4'b1101:  B2bis_Q = B2bis14_Q;
            4'b1110:  B2bis_Q = B2bis15_Q;
            default: B2bis_Q = B2_Q;    
        endcase
    end

    // ttl_74273_sync B2bis(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(CK1n), .D(B2_Q), .Q(B2bis_Q)); //HACK to add CK1 period delay to the data coming from ROM

    logic A2_S;
    assign A2_S = B1HQ[0] ^ INV; //IC 11D Unit C
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) A2 (.Enable_bar(1'b0), .Select((swap_px ? ~A2_S : A2_S)),
                .A_2D({B2bis_Q[7],B2bis_Q[3],B2bis_Q[6],B2bis_Q[2],B2bis_Q[5],B2bis_Q[1],B2bis_Q[4],B2bis_Q[0]}), .Y(B1D[3:0]));
endmodule