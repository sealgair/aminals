playerbase = {
  x=56, y=112,
  w=8, h=8,
  facing=-1,
  accel=5, speed=1,
  gravity=1,
  vx=0, vy=0,
  p=0,
  atkspr=79,
  attacking=0,
  dying=0,
  spawned=0,
}

function playerbase:new(world, p, x, y, palette)
  return prototype({
    world=world,
    spawn={x=x, y=y},
    p=p, x=x, y=y,
    sprite=prototype({palette=palette}, self.sprite)
  }, self)
end

function playerbase:collides(x, y)
  for x=x, x+self.w-1 do
    for y=y, y+self.h-1 do
      if (mfget(wrap(0, x, 127), wrap(0, y, 127), flags.stop)) return true
    end
  end
  return false
end

function playerbase:move()
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

function playerbase:control()
  dir = dpad('x', self.p)
  self.walking = dir != 0
  if dir == 0 then
    -- speed down
    self.vx = max(abs(self.vx) - self.accel*dt*2, 0) * sign(self.vx)
  else
    self.facing = dir
    -- speed up
    self.vx = bound(-self.speed, self.vx + self.accel*dir*dt, self.speed)
  end
end

function playerbase:animstate()
  return 'idle'
end

function playerbase:update()
  self.sprite:advance(dt, self:animstate())
  self:control()
  self:move()

  for state in all{'attacking', 'dying', 'spawned'} do
    if self[state] > 0 then
      self[state] -= dt
      if self[state] <= 0 then
        self[state] = 0
        self:statecomplete(state)
      end
    end
  end
end

function playerbase:isvulnerable()
  return self.spawned <= 0
end

function playerbase:touched(signal)
  if signal == "attack" and self:isvulnerable() then
    self.dying = 0.5
  end
end

function playerbase:statecomplete(state)
  if state == "dying" then
    self.x=self.spawn.x
    self.y=self.spawn.y
    self.spawned = 2
  end
end

function playerbase:draw(x, y)
  x = x or self.x
  y = y or self.y
  flipx=self.facing == 1
  self.sprite:draw(x, y, {flipx=flipx})
  if self.attacking > 0 then
    spr(self.atkspr, x+self.w*self.facing, y, 1, 1, flipx)
  end
end

shru = prototype({
  name='shru',
  sprite=makesprite{
      animations={
        idle={16,16,16,16,16,16,18, speed=1.5},
        walk={16,17},
        attacking={19,20, speed=0.2},
        dying={21},
      },
      palettes={
        {[4]=5, [15]=6, [1]=11},
        {[4]=1, [15]=13, [1]=9, [14]=4},
        {[4]=7, [15]=7, [1]=8},
      },
  },
  accel=8, speed=2.5,
}, playerbase)

function shru:animstate()
  if self.dying > 0 then
    return 'dying'
  elseif self.attacking > 0 then
    return 'attacking'
  elseif self.walking then
    return 'walk'
  else
    return 'idle'
  end
end

function shru:control()
  playerbase.control(self)
  if btnp(b.x, self.p) then
    self.attacking = 0.2
  end
end

function shru:update()
  playerbase.update(self)
  if self.attacking > 0 then
    self.world:send_touch({
      x=self.x+self.w*self.facing, y=self.y, w=6, h=6
    }, "attack")
  end
end

forg = prototype({
  name='forg',
  sprite=makesprite{
    animations={
      idle={32}
    },
    palettes={
      {[11]=8, [3]=2, [10]=11},
      {[11]=10, [3]=9, [10]=14},
      {[11]=2, [3]=1, [10]=9},
    }
  },
  accel=8, speed=1.8,
  jump=0,
}, playerbase)

function forg:control()
  dir = dpad('x', self.p)
  if (dir != 0) self.facing = dir

  if btn(b.o, self.p) and (self.grounded or self.jump > 0) then
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
  sprite=makesprite{
    animations={
      idle={48},
      walk={48,49},
      flap={51},
      glide={50},
    },
    palettes={
      {[13]=3, [2]=11, [15]=7, [12]=1, [9]=10},
      {[13]=9, [2]=15, [15]=10, [12]=10, [9]=15},
      {[13]=7, [2]=6, [15]=6, [12]=13, [9]=5},
    }
  },
  speed=1.75,
  walk=.75,
  flap=1,
  flapped=0,
  flaps=0,
  maxflaps=3,
  gravity=0.25
}, playerbase)

function brid:animstate()
  if self.grounded then
    if self.walking then
      return 'walk'
    else
      return 'idle'
    end
  else
    if self.flapped > 0 then
      return 'flap'
    else
      return 'glide'
    end
  end
end

function brid:control()
  playerbase.control(self)
  if self.grounded then
    self.flaps = 0
    self.vx = bound(-self.walk, self.vx, self.walk)
  else
    --glide
    dv = max(self.speed*.5 - abs(self.vx), 0)
    self.vx += dv*self.facing
    -- self.vx = bound(-self.speed, self.vx+self.accel*self.facing*.04, self.speed)
  end
  if btnp(b.o, self.p) and self.flapped <= 0 and self.flaps < self.maxflaps then
    self.flaps += 1
    self.vy = max(-self.flap, self.vy-self.accel)
    self.flapped = 0.3
  else
    self.flapped -= dt
  end
end

waps = prototype({
  sprite=makesprite{
    animations={
      idle={1, 2, speed=1/18}
    },
    palettes={
      {[10]=9, [4]=0, [9]=5, [8]=4, [6]=7},
      {[10]=11, [4]=2, [9]=4, [8]=3, [6]=9},
      {[10]=13, [4]=1, [9]=6, [8]=10, [6]=6},
    }
  },
  name='waps',
  accel=10, speed=1,
  gravity=0
}, playerbase)

function waps:control()
  playerbase.control(self)
  dir = dpad('y', self.p)

  if dir==0 then
    self.vy = max(abs(self.vy) - self.accel*dt*2, 0) * sign(self.vy)
  else
    self.vy = bound(-self.speed, self.vy + self.accel*dir*dt, self.speed)
  end
end


--[[ TODO:
trut
spid
mant
sulg
funj
]]
