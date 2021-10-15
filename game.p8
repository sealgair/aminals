pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
#include utils.lua
#include sprites.lua
#include players.lua
#include main.lua

__gfx__
00000000aa000660aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008aa066068aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aa446060aa44000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000044a6400044aa40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700004aaa4a004aaa4a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000aa44aa00aa44aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005550000000000
0000000000000aaa00000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555455000005000
00000000000099a0000099a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005545554500555500
000000e000000e000000000e000400e0000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000e000400e00004000e0444000e0000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0444000e0444000e0444000eef14400e0004000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ef14444eef14444eef14444e00f4444e0444044e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff444444ff444444ff4444440f444444ef1444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
044444400444444004444440004ff44070f444400444444000000000000000000000000000000000000000000000000000000000000000000000000000000000
004fff40004fff40004fff4000400f400f444f40ef44444e00000000000000000000000000000000000000000000000000000000000000000000000000000000
004000400004040000400040000000400044f040ff444eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa300000aa300000aa3000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
baab3000baab3000baab300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb300bbbbb30000bbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b03bbb30b0bbb300003bbb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0333bbb303bbbb00333bbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003333b30333bb0003333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00300b33000033b003000b3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
030033300000003b0030033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd0000000dd0000000000000dd00000000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dcdd00000dcdd0000dd00d00dcdd000000dddd00dd00dd000000000000000000000000000000000000000000000000000000000000000000000000000000000
99ddd000099ddd000dcdd0dd99dddd000dddddf0dcd2dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd0d00dddd0d99dddd2d0dddfdd0dddd2ff09ddddd0d00000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffddddd00fddddd0dddd22d00ffdd20dcd2df0009dddddd0dddd000000000000000000000000000000000000000000000000000000000000000000000000000
00ffdddd00ffdddd00ffddd0000fdd2d0dddff0090ffddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000
000ff9d0000f9dd0000ffddd0000dfdd99dd0000000ff9d0dd9ffddd000000000000000000000000000000000000000000000000000000000000000000000000
00090900000090000000ffdd0000000090000000000909000ddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbbb0099999900ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb399999944f44f44f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900
bbb33b3399994994ff44f44500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090
bb334343499494454f444f4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009009
434344459949495444f4454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090
4344445549949545f444f45500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900
44444555449454554f454f4500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04455550044545500454555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22d2d22d666665650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d2dd6665656550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22d2d2d6665565650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d22ddd66656555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22d6d6d6555565550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2dd6d6d565555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d6666d0055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414100004141414100004141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100005050505000005050505000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414100005050505000004141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100004040404000004040404000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404000004040404000004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
