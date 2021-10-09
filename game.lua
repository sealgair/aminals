
-- system callbacks

function _init()
end

dt = 1/60
g = 4 * dt

flags = {
  stop=0
}

player = {
  sprite=17,
  flipped=false,
  x=56, y=112,
  w=8, h=8,
  accel=.5, speed=1.5,
  vx=0, vy=0,
}

function debug(val)
  val = tostring(val)
  color(5)
  rectfill(0, 121, 1+(#tostring(val)*4), 127)
  color(6)
  print(val, 1, 122)
end

function wrap(min, v, max)
  d = max-min
  if (v < min) v += d
  if (v > max) v -= d
  return v
end

function sign(v)
  if (v >= 0) return 1
  return -1
end

function mfget(x, y, f)
  return fget(mget(x/8, y/8), f)
end


function player:collides(x, y)
  for x=x, x+self.w-1 do
    for y=y, y+self.h-1 do
      if (mfget(x, y, flags.stop)) return true
    end
  end
  return false
end

function player:move()
  -- set desired new position
  nx = self.x + self.vx
  ny = self.y + self.vy

  -- collide with map tiles
  for x=flr(self.x), nx, sign(self.vx) do
    if self:collides(x, self.y) then
      self.vx = 0
      break
    end
    self.x = x
  end
  if (self.vx != 0) self.x = nx

  for y=flr(self.y), ny, sign(self.vy) do
    if self:collides(self.x, y) then
      self.vy = 0
      break
    end
    self.y = y
  end
  if (self.vy != 0) self.y = ny

  -- wrap around map
  self.x = wrap(0, self.x, 127)
  self.y = wrap(0, self.y, 127)
end

function player:update()
  self.vx = 0
  if (btn(0)) self.vx = -self.speed
  if (btn(1)) self.vx = self.speed
  if (self.vx != 0) self.flipped = self.vx > 0
  if self.touch then
    self.vy = 0
  else
    self.vy += g
  end
  self:move()
end

function player:draw()
  spr(self.sprite, self.x, self.y, 1, 1, self.flipped)
  -- debug(self.x ..', '..self.y)
end

function _update60()
  player:update()
end

function _draw()
  rectfill(0,0,1287,127,12)
  map(0, 0, 0, 0, 127, 127)
  player:draw()
end
