player = {
  x=56, y=112,
  w=8, h=8,
  facing=-1,
  accel=5, speed=1,
  gravity=1,
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
  -- gravity pulls
  self.vy += g * self.gravity

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

  self.grounded = self:collides(self.x, self.y+1)
end

function player:control()
  dir = 0
  if (btn(0)) dir = -1
  if (btn(1)) dir = 1

  if dir==0 then
    -- speed down
    self.vx = max(abs(self.vx) - self.accel*dt*2, 0) * sign(self.vx)
  else
    self.facing = dir
    -- speed up
    self.vx = bound(-self.speed, self.vx + self.accel*dir*dt, self.speed)
  end
end

function player:update()
  self:control()
  self:move()
end

function player:draw(x, y)
  x = x or self.x
  y = y or self.y
  spr(self.sprite, x, y, 1, 1, self.facing == 1)
end

shru = prototype({
  name='shru',
  sprite=16,
  accel=8, speed=2.5,
}, player)

forg = prototype({
  name='forg',
  sprite=32,
  accel=8, speed=1.8,
  jump=0,
}, player)

function forg:control()
  dir = 0
  if (btn(0)) dir = -1
  if (btn(1)) dir = 1
  if (dir != 0) self.facing = dir

  if btn(5) and (self.grounded or self.jump > 0) then
    if self.grounded then
      self.jump = 0.2
    else
      self.jump -= dt
    end
    self.vx = self.speed * self.facing
    self.vy = -self.speed
  else
    self.jump = 0
    self.vx = max(abs(self.vx) - self.accel*dt*2, 0) * sign(self.vx)
  end
end

brid = prototype({
  name='brid',
  sprite=48,
  speed=1.75,
  walk=.75,
  flap=1,
  flapped=0,
  flaps=0,
  maxflaps=3,
  gravity=0.25
}, player)

function brid:control()
  player.control(self)
  if self.grounded then
    self.flaps = 0
    self.vx = bound(-self.walk, self.vx, self.walk)
  else
    --fall forward
    self.vx = bound(-self.speed, self.vx+self.accel*self.facing*.04, self.speed)
  end
  if btnp(5) and self.flapped <= 0 and self.flaps < self.maxflaps then
    self.flaps += 1
    self.vy = max(-self.flap, self.vy-self.accel)
    self.flapped = 0.3
  else
    self.flapped -= dt
  end
end

waps = prototype({
  sprite=1,
  name='waps',
  accel=10, speed=1,
  gravity=0
}, player)

function waps:control()
  player.control(self)
  dir = 0
  if (btn(2)) dir = -1
  if (btn(3)) dir = 1

  if dir==0 then
    self.vy = max(abs(self.vy) - self.accel*dt*2, 0) * sign(self.vy)
  else
    self.vy = bound(-self.speed, self.vy + self.accel*dir*dt, self.speed)
  end
end


--[[ TODO:
turt
sper
funj
]]
