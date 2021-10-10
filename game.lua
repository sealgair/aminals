
dt = 1/60
g = 5 * dt

flags = {
  stop=0
}

player = {
  sprite=17,
  flipped=false,
  x=56, y=112,
  w=8, h=8,
  accel=4, speed=2.5,
  vx=0, vy=0,
}

function debug(val, opts)
  opts = opts or {}
  x = opts.x or 0
  y = opts.y or 0
  val = tostring(val)
  color(opts.bg or 5)
  rectfill(x, y, 1+(#tostring(val)*4), y+7)
  color(opts.fg or 6)
  print(val, x+1, y+1)
end

function wrap(min, v, max)
  d = max-min
  if (v < min) v += d
  if (v > max) v -= d
  return v
end

function bound(b, v, t)
  return max(b, min(v, t))
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
  self.x = wrap(0, self.x, 127)
  self.y = wrap(0, self.y, 127)
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
  player:update()
end

function _draw()
  rectfill(0,0,1287,127,12)
  map(0, 0, 0, 0, 127, 127)
  player:draw()
end
