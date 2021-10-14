
flags = {
  stop=0
}

playerselect = {
  options = {
    {shru, forg},
    {brid, waps},
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
  player_colors = {8, 12, 11, 10},
  palettes = {0,1,2,3},
}

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
            add(players, {
              player=self.options[pos.y][pos.x],
              palette=self.palettes[p]
            })
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
        color(self.player_colors[player])
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
      col.sprite:draw(x+4, y+4)
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
    color(self.player_colors[player])
    print(player, px+5, py+4)

    if chosen != coord(0,0) then
      choice = self.options[chosen.y][chosen.x],
      rectfill(px+1, py+1, px+11, py+11, 12)
      choice.sprite:draw(px+2, py+2, {palette=self.palettes[player]})
    end
  end
end

game = {
  objects = {}
}
function game:start(players)
  starts = {
    {8, 16},
    {8, 112},
  }
  for p, popts in pairs(players) do
    x, y = unpack(starts[p])
    add(self.objects, popts.player:new(self, p-1, x, y, popts.palette))
  end
  gamestate = self
end

function game:update()
  for o in all(self.objects) do
    o:update()
  end
end

function game:send_touch(box, signal)
  touches = {}
  for o in all(self.objects) do
    if (intersects(box, o)) o:touched(signal)
  end
end

function game:draw()
  rectfill(0,0,1287,127,12)
  map(0, 0, 0, 0, 127, 127)
  for i, o in pairs(self.objects) do
    o:draw()
  end
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
