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
  attklen=0.2,
  attkcool=0.5,
  dying=0,
  spawned=0,
  cooldown=0,
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
  self:walk()
  self:attack()
end

function playerbase:walk()
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

function playerbase:attack()
  if btnp(b.x, self.p) and self.cooldown <= 0 then
    self.attacking = self.attklen
    self.cooldown = self.attklen + self.attkcool
  end
end

function playerbase:animstate()
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

function playerbase:update()
  self.sprite:advance(dt, self:animstate())
  self:control()
  self:move()

  for state in all{'attacking', 'dying', 'spawned', 'cooldown'} do
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

function playerbase:touched(signal, sender)
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
  if self.attacking > 0 and self.atkspr > 0 then
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

function shru:update()
  playerbase.update(self)
  if self.attacking > 0 then
    self.world:send_touch({
      x=self.x+self.w*self.facing, y=self.y, w=6, h=6
    }, "attack", self)
  end
end

forg = prototype({
  name='forg',
  sprite=makesprite{
    animations={
      idle={32},
      jump={33},
      lick={34},
    },
    palettes={
      {[11]=8, [3]=2, [10]=11},
      {[11]=10, [3]=9, [10]=14},
      {[11]=2, [3]=1, [10]=9},
    }
  },
  accel=8, speed=1.8,
  jump=0,
  attklen=0.5,
  atkspr=0,
  orientation=0,
  lookspeed=0.25*2,
  tonguelen=20,
  buzz=0,
}, playerbase)

function forg:animstate()
  if self.attacking > 0 then
    return "lick"
  elseif self.grounded then
    return "idle"
  else
    return "jump"
  end
end

function forg:walk()
  dir = dpad('x', self.p)
  if (dir != 0) self.facing = dir

  if btn(b.o, self.p) and (self.grounded or self.jump > 0) then
    if self.grounded then
      self.jump = 0.2
    else
      self.jump -= dt
    end
    self.vx = self.speed * self.facing
    self.vy = -self.speed/2
  else
    self.jump = 0
    self.vx = max(abs(self.vx) - self.accel*dt*2, 0) * sign(self.vx)
  end

  look = dpad('y', self.p)
  if (dir != 0) look += 1
  self.orientation = bound(0, self.orientation-look*self.lookspeed*dt, .25)
end

function forg:update()
  playerbase.update(self)
  if self.attacking > 0 then
    x, y = self:tonguepos()
    self.world:send_touch({
      x=x-self.facing, y=y-1, w=3, h=3
    }, "attack", self)
  end
end

function forg:tonguepos(d)
  d = d or self.tonguelen*easeoutback(self.attacking/self.attklen)
  x, y = self.x+4, self.y+3
  return x+d*self.facing*orx, y+d*ory
end

function forg:draw()
  playerbase.draw(self)
  orx = cos(self.orientation)
  ory = sin(self.orientation)

  x, y = self:tonguepos(8)
  circ(x, y, 0, 0)
  bm = 4
  if self.buzz > bm/2 then
    circ(x+1, y-1, 0, 7)
  end
  self.buzz +=1
  if (self.buzz > bm) self.buzz = 0

  if self.attacking > 0 then
    tx,ty  = self:tonguepos()
    line(self.x+4+2*self.facing, self.y+3, tx, ty, 8)
    circ(tx, ty, 1, 8)
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
      dive={52},
      peck={53},
      dying={54},
    },
    palettes={
      {[13]=3, [2]=11, [15]=7, [12]=1, [9]=10},
      {[13]=9, [2]=15, [15]=10, [12]=10, [9]=15},
      {[13]=7, [2]=6, [15]=6, [12]=13, [9]=5},
    }
  },
  speed=1.75,
  walkspeed=.75,
  flap=1,
  flapped=0,
  flaps=0,
  maxflaps=3,
  gravity=0.25
}, playerbase)

function brid:animstate()
  if self.dying > 0 then
    return 'dying'
  elseif self.grounded then
    if self.attacking > 0 then
      return 'peck'
    elseif self.walking then
      return 'walk'
    else
      return 'idle'
    end
  else
    if self.attacking > 0 then
      return 'dive'
    elseif self.flapped > 0 then
      return 'flap'
    else
      return 'glide'
    end
  end
end

function brid:walk()
  playerbase.walk(self)
  if self.grounded then
    self.flaps = 0
    self.vx = bound(-self.walkspeed, self.vx, self.walkspeed)
  elseif self.attacking > 0 then
    --dive
    dvx = max(self.speed - abs(self.vx), 0)
    self.vx += dvx*self.facing
    dvy = max(self.speed - abs(self.vy), 0)
    self.vy += dvy
  else
    --glide
    dv = max(self.speed*.5 - abs(self.vx), 0)
    self.vx += dv*self.facing
  end
  if btnp(b.o, self.p) and self.flapped <= 0 and self.flaps < self.maxflaps then
    self.flaps += 1
    self.vy = max(-self.flap, self.vy-self.accel)
    self.flapped = 0.3
  else
    self.flapped -= dt
  end
end

function brid:update()
  playerbase.update(self)
  if self.attacking > 0 then
    x, y = self.x+(self.w-2)*self.facing, self.y
    if not self.grounded then
      x-=self.facing
      y+=4
    end
    self.world:send_touch({x=x, y=y, w=6, h=6}, "attack", self)
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
