
dt = 1/60
g = 5 * dt

flags = {
  stop=0
}

playerselect = {
  options = {
    {17, 32},
    {49, 1},
  },
  chosen = {0, 0},
  selected = {1, 1},
  names = {
    {'shru', 'forg'},
    {'brid', 'waps'},
  }
}

function playerselect:update()
  if (btnp(4)) self.chosen = {0, 0}
  if btnp(5) then
    if self.chosen[1] == self.selected[1] and self.chosen[2] == self.selected[2] then
      r = self.selected[1]
      c = self.selected[2]
      player.sprite = self.options[c][r]
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
end

function playerselect:draw()
  rectfill(0, 0, 127, 127, 0)
  print("choose your player", 28, 5, 8)

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
      spr(col, x+4, y+4)
      print(self.names[r][c], x+1, y+17)
      x += 64
    end
    y += 50
  end
end

game = {}
function game:update()
  player:update()
end

function game:draw()
  rectfill(0,0,1287,127,12)
  map(0, 0, 0, 0, 127, 127)
  player:draw()
end

gamestate = playerselect


player = {
  sprite=17,
  flipped=false,
  x=56, y=112,
  w=8, h=8,
  accel=8, speed=2.5,
  vx=0, vy=0,
}


function player:collides(x, y)
  for x=x, x+self.w-1 do
    for y=y, y+self.h-1 do
      if (mfget(wrap(0, x, 127), wrap(0, y, 127), flags.stop)) return true
    end
  end
  return false
end

function player:move()
  -- collide with map tiles
  self.x += self.vx
  sx = sign(self.vx)
  while self:collides(self.x, self.y) do
    self.vx = 0
    self.x -= sx
  end
  self.y += self.vy
  sy = sign(self.vy)
  while self:collides(self.x, self.y) do
    self.vy = 0
    self.y -= sy
  end

  -- wrap around map
  self.x = wrap(-7, self.x, 127)
  self.y = wrap(-7, self.y, 127)
end

function player:update()
  dir = 0
  if (btn(0)) dir = -1
  if (btn(1)) dir = 1

  if dir==0 then
    -- speed down
    self.vx = max(abs(self.vx) - self.accel*dt*2, 0) * sign(self.vx)
  else
    -- speed up
    self.vx = bound(-self.speed, self.vx + self.accel*dir*dt, self.speed)
  end
  if (self.vx != 0) self.flipped = self.vx > 0
  self.vy += g
  self:move()
end

function player:draw()
  spr(self.sprite, self.x, self.y, 1, 1, self.flipped)
  -- debug(self.x ..', '..self.y)
  -- debug((self.touchx or '') ..', '.. (self.touchy or ''), {y=8})
end

-- system callbacks

function _init()
end

function _update60()
  gamestate:update()
end

function _draw()
  gamestate:draw()
end
