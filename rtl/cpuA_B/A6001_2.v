//Author: @RndMnkIII
//Date: 22/05/2022
//Derived from ATHENA PAL
`default_nettype none
`timescale 1ns/10ps

module A6001_2 (
    //inputs
    input  wire  AMRn, //1
    input  wire  AE_addr, //2 
    input  wire  A_addr13, //3
    input  wire  A_addr12,  //4
    input  wire  A_addr11, //5
    input  wire  BMRn,     //6
    input  wire  BE_addr, //7
    input  wire  B_addr13, //8
    input  wire  B_addr12, //9 
    input  wire  B_addr11, //10
    input  wire  ARDn, //11
    input  wire  BRDn, //13
    input  wire  AB_Sel, //22
	output wire  VA12, //21
    output wire  FRONT_VIDEO_CSn, //14 FC
    output wire  VRDn, //17
    output wire  SIDE_VRAM_CSn, //19 SC
    output wire  DISC, //19 DISC
    output wire  BACK1_VRAM_CSn //23 B1C
);  
    //                1 1 1 1  1 | 1     |
    //Address:        5 4 3 2  1 | 0 9 8 | 7 6 5 4  3 2 1 0
    //16'hD000-D7FF   1 1 0 1  0 | x x x | x x x x  x x x x cpuA SHARED FRONT VIDEO RAM 2Kbytes
    //16'hC800-CFFF   1 1 0 0  1 | x x x | x x x x  x x x x cpuB SHARED RAM             2Kbytes
    assign  FRONT_VIDEO_CSn = ~((~AMRn & ~AE_addr & ~A_addr13 &  A_addr12 &  ~A_addr11 & ~AB_Sel ) |
                                (~BMRn & ~BE_addr & ~B_addr13 & ~B_addr12 &   B_addr11 &  AB_Sel )); //FIX

    assign  VRDn = ~((~ARDn & ~AB_Sel ) | (~BRDn &  AB_Sel ));

    //                1 1 1 1  1 | 1     |
    //Address:        5 4 3 2  1 | 0 9 8 | 7 6 5 4  3 2 1 0 
    //16'hF800-FFFF   1 1 1 1  1 | x x x | x x x x  x x x x SHARED SIDE_VIDEO_RAM cpuA 2Kbytes
    //16'hF800-FFFF   1 1 1 1  1 | x x x | x x x x  x x x x SHARED SIDE_VIDEO_RAM cpuB 2Kbytes
    //19
    assign  SIDE_VRAM_CSn = ~((~AMRn & ~AE_addr & A_addr13 & A_addr12 & A_addr11 & ~AB_Sel ) |
                              (~BMRn & ~BE_addr & B_addr13 & B_addr12 & B_addr11 &  AB_Sel ));

    //                1 1 1 1  1 | 1     |
    //Address:        5 4 3 2  1 | 0 9 8 | 7 6 5 4  3 2 1 0
    //16'hC800-CFFF   1 1 0 0  1 | x x x | x x x x  x x x x VIDEO ATTRIB. W, SPRITE AND BACKGROUND SCROLL REGISTERS, tile and tile palette bank cpuA
    assign  DISC = ~(~AMRn & ~AE_addr & ~A_addr13 & ~A_addr12 &  A_addr11 & ~AB_Sel );

    //                1 1  1 1  1 | 1     |
    //Address:        5 4  3 2  1 | 0 9 8 | 7 6 5 4  3 2 1 0
    //16'hD800-DFFF   1 1  0 1  1 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuA
	//16'hE000-E7FF   1 1  1 0  0 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuA
	//16'hE800-EFFF   1 1  1 0  1 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuA
	//16'hF000-F7FF   1 1  1 1  0 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuA
	//
    //16'hD000-D7FF   1 1  0 1  0 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuB
    //16'hD800-DFFF   1 1  0 1  1 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuB
	//16'hE000-E7FF   1 1  1 0  0 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuB
	//16'hE800-EFFF   1 1  1 0  1 | x x x | x x x x  x x x x BACK1 VIDEO RAM BANK cpuB
    assign  BACK1_VRAM_CSn = ~((~AMRn & ~AE_addr & ~A_addr13 &  A_addr12 &  A_addr11 & ~AB_Sel ) |
	                           (~AMRn & ~AE_addr &  A_addr13 & ~A_addr12 & ~A_addr11 & ~AB_Sel ) |
							   (~AMRn & ~AE_addr &  A_addr13 & ~A_addr12 &  A_addr11 & ~AB_Sel ) |
							   (~AMRn & ~AE_addr &  A_addr13 &  A_addr12 & ~A_addr11 & ~AB_Sel ) |

                               (~BMRn & ~BE_addr & ~B_addr13 &  B_addr12 & ~B_addr11 &  AB_Sel ) |
							   (~BMRn & ~BE_addr & ~B_addr13 &  B_addr12 &  B_addr11 &  AB_Sel ) |
							   (~BMRn & ~BE_addr &  B_addr13 & ~B_addr12 & ~B_addr11 &  AB_Sel ) |
	                           (~BMRn & ~BE_addr &  B_addr13 & ~B_addr12 &  B_addr11 &  AB_Sel ));

    //Based on Athena A6001-2 equations
    assign VA12 = ~(( AB_Sel &  B_addr12            ) |
                    (~AB_Sel & ~A_addr12 & ~A_addr11) |
                    (~AB_Sel &  A_addr12 &  A_addr11));
endmodule