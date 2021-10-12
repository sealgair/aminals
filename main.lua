
flags = {
  stop=0
}

playerselect = {
  options = {
    {shru, forg},
    {brid, waps},
  },
  chosen = {0, 0},
  selected = {1, 1},
}

function playerselect:update()
  if (btnp(4)) self.chosen = {0, 0}
  if btnp(5) then
    if self.chosen[1] == self.selected[1] and self.chosen[2] == self.selected[2] then
      r = self.selected[1]
      c = self.selected[2]
      game:start(self.options[c][r])
      gamestate = game
    else
      self.chosen = {self.selected[1], self.selected[2]}
    end
  end

  x=0
  y=0
  if (btnp(0)) x-=1
  if (btnp(1)) x+=1
  if (btnp(2)) y-=1
  if (btnp(3)) y+=1
  self.selected[1] = wrap(1, self.selected[1]+x, 2)
  self.selected[2] = wrap(1, self.selected[2]+y, 2)

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
      rect(x+2, y+2, x+13, y+13, 7)

      color(6)
      if c == self.selected[1] and r == self.selected[2] then
        color(9)
        rect(x+1, y+1, x+14, y+14)
      end
      if c == self.chosen[1] and r == self.chosen[2] then
        color(8)
        rect(x+1, y+1, x+14, y+14)
      end
      col.sprite:draw(x+4, y+4)
      print(col.name, x+1, y+17)
      x += 64
    end
    y += 50
  end
end

game = {
  objects = {}
}
function game:start(player)
  add(self.objects, player)
end

function game:update()
  for o in all(self.objects) do
    o:update()
  end
end

function game:draw()
  rectfill(0,0,1287,127,12)
  map(0, 0, 0, 0, 127, 127)
  for o in all(self.objects) do
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
