matchend = 10

flags = {
  stop=0
}

player_colors = {8, 12, 11, 10}
places = {'1st', '2nd', '3rd', '4th'}
medals = {
  {10,9}, {7,6}, {9,4}, {6,5}
}

playerselect = {
  options = {
    {shru, forg},
    {brid, trut},
  },
  chosen = {
    coord(0,0),
    coord(0,0),
    coord(0,0),
    coord(0,0),
  },
  selected = {
    coord(0,0),
    coord(0,0),
    coord(0,0),
    coord(0,0),
  },
  palettes = {0,1,2,3},
}

function playerselect:start()
  for p=1,4 do
    self.chosen[p] = coord(0,0)
  end
  gamestate = self
end

function playerselect:update()
  for player=1,4 do
    chosen = self.chosen[player]
    selected = self.selected[player]


    if btnp(b.o, player-1) then
      chosen.x, chosen.y = 0, 0
      self.palettes[player] = player-1
    end

    if btnp(b.x, player-1) then
      if chosen == selected and chosen != coord(0, 0) then
        players = {}
        for p, pos in pairs(self.chosen) do
          if pos != coord(0,0) then
            players[p] = {
              player=self.options[pos.y][pos.x],
              palette=self.palettes[p]
            }
          end
        end
        game:start(players)
      else
        chosen.x, chosen.y = selected.x, selected.y
      end
    end
    dx = dpad('x', player-1, true)
    dy = dpad('y', player-1, true)
    if dx+dy != 0 then
      if (selected == coord(0, 0)) then
        -- join the game
        selected.x, selected.y = 1, 1
      elseif chosen == coord(0, 0) then
        -- hasn't decided
        selected.x = wrap(1, selected.x+dx, 2)
        selected.y = wrap(1, selected.y+dy, 2)
      else
        -- choose color
        repeat
          self.palettes[player] = wrap(0, self.palettes[player]+dy, 3)
          duped = false
          for op=1,4 do
            if (op != player and self.chosen[op] == chosen and
                self.palettes[op] == self.palettes[player]) then
              duped = true
            end
          end
        until not duped
      end
    end
  end

  for row in all(self.options) do
    for col in all(row) do
      col.sprite:advance()
    end
  end
end

function playerselect:draw()
  rectfill(0, 0, 127, 127, 0)
  print("choose your aminal", 28, 5, 8)

  y = 30
  for r, row in pairs(self.options) do
    x = 23
    for c, col in pairs(row) do
      rect(x, y, x+15, y+15, 6)
      rect(x+1, y+1, x+14, y+14, 6)
      rect(x+2, y+2, x+13, y+13, 7)

      rc = coord(c, r)
      drawn = 0
      for player=1,4 do
        selected = self.selected[player]
        chosen = self.chosen[player]
        color(player_colors[player])
        if rc == chosen then
          drawn += 1
          if (drawn == 1) line(x+2, y+1, x+13, y+1) -- top: p1
          if (drawn < 3) line(x+2, y+14, x+13, y+14) -- bottom: p1 p2
          if (drawn%2 == 1) line(x+1, y+2, x+1, y+13) -- left: p1 p3
          if (drawn != 3) line(x+14, y+2, x+14, y+13) -- right: p1 p2 p4
        end
        if rc == selected then
          print(player, x+(player-1)*4, y-6)
        end
      end
      rectfill(x+3, y+3, x+12, y+12, 12)
      col:drawsprite(x+4, y+4)
      print(col.name, x+1, y+17, 7)
      x += 64
    end
    y += 50

  end

  for player=1,4 do
    chosen = self.chosen[player]
    px = 1 + (player-1)%2 * 114
    py = 1
    if (player > 2) py += 114
    rect(px, py, px+12, py+12, 9)
    color(player_colors[player])
    print(player, px+5, py+4)

    if chosen != coord(0,0) then
      choice = self.options[chosen.y][chosen.x],
      rectfill(px+1, py+1, px+11, py+11, 12)
      choice:drawsprite(px+2, py+2, {palette=self.palettes[player]})
    end
  end
end

game = {
  objects={},
  score=0,
}
function game:start(players)
  self.spawns = {}
  for x=1,16 do
    for y=1,16 do
      if not mfget(x*8, y*8, flags.stop) and mfget(x*8, (y+1)*8, flags.stop) then
        add(self.spawns, {x*8, y*8})
      end
    end
  end
  self.objects = {}
  for p, popts in pairs(players) do
    x, y = self:spawnpoint()
    add(self.objects, popts.player:new(self, p-1, x, y, popts.palette))
  end
  gamestate = self
end

function game:spawnpoint()
  return unpack(rnd(self.spawns))
end

function game:update()
  self.score = 0
  for o in all(self.objects) do
    self.score += o.deaths or 0
    o:update()
  end
  if self.score >= matchend then
    victory:start(self.objects)
  end
end

function game:send_touch(box, signal, sender)
  touches = {}
  for o in all(self.objects) do
    if o != sender and intersects(box, o) then
      o:touched(signal, sender)
      add(touches, o)
    end
  end
  return touches
end

function game:draw()
  rectfill(0,0,1287,127,12)
  map(0, 0, 0, 0, 127, 127)
  for i, o in pairs(self.objects) do
    o:draw()
  end
  rectfill(56, 0, 71, 7, 2)
  printc(self.score, 64, 1, 10)
end

victory = {}

function victory:start(players)
  self.players = players
  sort(self.players, function(a, b)
    return a:score() > b:score()
  end)
  gamestate = self
end

function victory:update()
  if btnp(b.x) then
    players = {}
    for player in all(self.players) do
      players[player.p+1] = {player=player}
    end
    game:start(players)
  end
  if (btnp(b.o)) playerselect:start()
end

function victory:outline(player, x, y)
  for ox in all{-1,0,1} do
    for oy in all{-1,0,1} do
      if (ox == 0 or oy == 0) player:drawsprite(x+ox,y+oy, {palette={12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12}})
    end
  end
  player:drawsprite(x,y)
end

function victory:draw()
  rectfill(0,0,127,127,1)
  rectfill(0,0,127,24,2)
  rectfill(0,24,127,25,10)
  colw = 128/#self.players
  for p, player in pairs(self.players) do
    x = (p-1) * colw
    if (x > 0) line(x,26,x,116,7)
    xm = x + colw/2
    printc(places[p], xm, 8, player_colors[player.p+1])
    circfill(xm, 24, 9, medals[p][1])
    circfill(xm, 24, 8, medals[p][2])
    circfill(xm, 24, 6, 12)
    player:drawsprite(xm-4, 20)
    printc('kills: '..player.kills, xm, 38, 8)
    printc('deaths: '..player.deaths, xm, 48, 66)
  end

  line(0, 116, 127, 116, 7)
  print("❎ retry    🅾️ change aminals", 8, 120, 6)
end

gamestate = playerselect

-- system callbacks

function _init()
end

function _update60()
  gamestate:update()
end

function _draw()
  gamestate:draw()
end
