pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
#include utils.lua
#include sprites.lua
#include players.lua
#include main.lua

--[[
…∧░➡️⧗▤⬆️☉🅾️◆
█★⬇️✽●♥웃⌂⬅️
▥❎🐱ˇ▒♪😐
]]--
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001522100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000122225210000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000225252220000000000000000
0000000000035300000353007003530000000000b9000000b9000000000000000000000000000000000000000000000000000000521321320000000000000000
0000000000353530003535300735353700035300bbbbbbb00bbbbbb0000353000000000000000000000000000000000000000000252222250000000000000000
000000000033333b0033333b7033333000353530000bbbbbb00bbbbb003535300000000000000000000000000000000000000000122522520005550000000000
00000000000333000003330000033307003333300000000000000000bb3333300000000000000000000000000000000000000000012213210555455000005000
0000000000b000b0000b0b0000000000000333000000000000000000bbb333bb0000000000000000000000000000000000000000001231205545554500555500
000000e000000e000000000e000400e0000000e00000000e00000000000000000770000007700000000000000000000000000000000000002dd22dd200d22d22
0004000e000400e00004000e0444000e0000000e0000000e0000000000000000017000000170000000000000000000000000a0000000000002200d2000000220
0444000e0444000e0444000eef14400e0004000e000000e0000000000000000000d0000000d000000000000000000000000aa000000000000000020000020020
ef14444eef14444eef14444e00f4444e0444044e044444e00000000000000000ddd00000ddd22000000d2200000000000000a0000000a0000020000000000000
ff444444ff444444ff4444440f444444ef144444ef1444400000000000000000dd220000dddd220000ddd220000000000000aa00aaaaaaa00000000000000000
044444400444444004444440004ff44070f44440ff4444000444444000000000ddd22d00dddddd000dddddd00d0ddd000000aa00aaaa00000000020000000020
004fff40004fff40004fff4000400f400f444f40004ff400ef44444e000000000dddddd000dddd000ddddddd0ddd22d00000aa00a00000000000000000000000
004000400004040000400040000000400044f04000040040ff444eee0000000000dddddd00ddddd0ddddddddddd2222d000aaa00000000000000000000000000
0aa300000aa300000aa30000000000000040000000000000000000000000000000000000cbb8cccc0ab000000ab0000000ab0000b00ab000000ab00000000000
baab3000baab3000baab3000000000000000000000000000000000000000000000000000abba8ccc0bbb00000bbb000000bb0000bb0bb000070bb00b00000b00
bbbbb300bbbbb30000bb3000000000000000000000000000000000000000000000000000aaaaa8cc000b0000000b00000b0b00bb0bbb00bb7000b0bf00b0b000
b03bbb30b0bbb300003bb300000000000000000000000000000000000000000000000000ac8aaa8c00bb0bb000bb0bb0bbbb0bbf00bb0bbf0b0bbbbf0b00b0fb
0333bbb303bbbb00333bbb30033330000000000000000000000000000000000000000000c888aaa800bbbbff00bbbbffb0bbbbf0000bbbf0bbbbbbf00bb00fbb
003333b30333bb0003333bb33bbb33300000000000000000000000000000000000000000cc8888a8000fff00000fff00000fff00000fff00b000ffb0b0b00fb0
00300b33000033b003000b33bbbbbb330000000000000000000000000000000000000000cc8cca8800b000b000b000b000b000b000b000b0000b000bbbbffbb0
030033300000003b003003303333bbb30000000000000000000000000000000000000000c8cc888c0b00000b00b000b000b0000b00b0000b00b0000b0bbbbb00
00dd0000000dd0000000000000dd00000000dddd00000000000000000000000000000000000000000000000000000000aa000660aa0000000aa0066000000000
0dcdd00000dcdd0000dd00d00dcdd000000dddd00dd00dd00000000000000000000000000000000000000000000000008aa066068aa0000008aa660600000000
99ddd000099ddd000dcdd0dd99dddd000dddddf0dcd2dd00000000000000000000000000000000000000000000000000aa446060aa4400000aa460600a900000
0ddddd0d00dddd0d99dddd2d0dddfdd0dddd2ff09ddddd0d000000000000000000000000000000000000000000000000044a6400044aa400004a6400aa000000
0ffddddd00fddddd0dddd22d00ffdd20dcd2df0009dddddd0dddd000000000000000000000000000000000000000000004aaa4a004aaa4a000aa44000a440000
00ffdddd00ffdddd00ffddd0000fdd2d0dddff0090ffddddddddddd0000000000000000000000000000000000000000000aa44aa00aa44aa00004aa004aaa0aa
000ff9d0000f9dd0000ffddd0000dfdd99dd0000000ff9d0dd9ffddd000000000000000000000000000000000000000000000aaa00000aaa000aaaa000aa644a
00090900000090000000ffdd0000000090000000000909000dddffdd0000000000000000000000000000000000000000000099a0000099a00999aa000006aa40
0bbbbbb0099999900ffffff000000000000000000000000000000000000000000000000000000000000000000000000000009999999999999999999999990000
bbbbbbb399999944f44f44f400000000000000000000000000000000000000000000000000000000000000000000000000099222222222222222222222299000
bbb33b3399994994ff44f44500000000000000000000000000000000000000000000000000000000000000000000000000092222222222222222222222224000
bb334343499494454f444f4400000000000000000000000000000000000000000000000000000000000000000000000000092222222222222222222222224000
434344459949495444f4454500000000000000000000000000000000000000000000000000000000000000000000000000092222222222222222222222224000
4344445549949545f444f45500000000000000000000000000000000000000000000000000000000000000000000000000092222222222222222222222224000
44444555449454554f454f4500000000000000000000000000000000000000000000000000000000000000000000000000044222222222222222222222244000
04455550044545500454555000000000000000000000000000000000000000000000000000000000000000000000000000004444444444444444444444440000
02222220066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22d2d22d6666656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0000
2d2d2dd666565655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00a
22d2d2d6665565650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0
d22ddd66656555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a
22d6d6d655556555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000
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
