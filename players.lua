dielen = 1.5

poison = sprite:new{
  animations={idle={13}},
  opacity={1,1},
}

playerbase = {
  x=56, y=112,
  w=8, h=8,
  facing=-1,
  accel=5, speed=1,
  gravity=1,
  vx=0, vy=0,
  p=0,
  atkspr=95,
  attacking=0,
  attklen=0.2,
  attkcool=0.5,
  dying=0,
  spawned=0,
  cooldown=0,
  poisoned=0,
  slipping=0,
  jumping=false,
  deaths=0,
  kills=0,
}

function playerbase:new(world, p, x, y, palette)
  return prototype({
    world=world,
    spawn={x=x, y=y},
    p=p, x=x, y=y,
    kills=0, deaths=0, spawned=0, -- new game overrides
    sprite=self.sprite:new({palette=palette})
  }, self)
end

function playerbase:collides(x, y, w, h)
  w = w or self.w
  h = h or self.h
  for x=x, x+w-1 do
    for y=y, y+h-1 do
      if (mfget(wrap(0, x, 127), wrap(0, y, 127), flags.stop)) return x,y
    end
  end
  return false
end

function playerbase:move()
  -- gravity pulls
  self.vy += g * self.gravity
  self.x += self.vx
  sx = sgn(self.vx)

  -- collide with map tiles
  while self:collides(self.x, self.y) do
    self.vx = 0
    self.x -= sx
  end

  self.y += self.vy
  sy = sgn(self.vy)
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
  if self.dying <= 0 then
    self:walk()
    self:action()
  end
end

function playerbase:walk(dir)
  local dir = dir or dpad('x', self.p)
  self.walking = dir != 0
  local slip = 1
  if (self.slipping > 0) slip = .03
  if dir == 0 then
    -- speed down
    if (not self.jumping) self.vx = max(abs(self.vx) - self.accel*slip*dt*2, 0) * sgn(self.vx)
  else
    self.facing = dir
    -- speed up
    self.vx = mid(-self.speed, self.vx + self.accel*slip*dir*dt, self.speed)
  end
end

function playerbase:action()
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

function playerbase:states()
  return {'attacking', 'dying', 'spawned', 'cooldown', 'poisoned', 'slipping'}
end

function playerbase:hitbox(w, h)
  hb = {
    x=self.x,
    y=self.y,
    w=(w or 6),
    h=(h or 6),
  }
  if self.facing > 0 then
    --right
    hb.x += self.w
  else
    --left
    hb.x -= hb.w+1
  end
  return hb
end

function playerbase:hitsignal()
  return "attack"
end

function playerbase:update()
  self.sprite:advance(dt, self:animstate())
  self:control()
  self:move()

  for state in all(self:states()) do
    if self[state] > 0 then
      self[state] -= dt
      if self[state] <= 0 then
        self[state] = 0
        self:statecomplete(state)
      end
    end
  end

  if self.attacking > 0 then
    for htibox in all(pack(self:hitbox())) do
      touches = self.world:send_touch(htibox, self:hitsignal(), self)
      if (#touches > 0) self:attacked(touches)
    end
  end
end

function playerbase:attacked(touches)
  -- hook
end

function playerbase:isvulnerable()
  return self.spawned <= 0
end

function playerbase:respawn()
  self.deaths += 1
  self.killer.kills += 1
  self.killer = nil

  self.x, self.y = self.world:spawnpoint()
  self.spawned = 2
end

function playerbase:die(killer)
  self.killer = killer
  self.dying = dielen
  self.poisoner = nil
  self.vx = 0
end

function playerbase:poison(poisoner)
  self.poisoned = 5
  self.poisoner = poisoner
end

function playerbase:cure(poisoner)
  self.poisoned = 0
  self.poisoner = nil
end

function playerbase:slip(sender)
  self.slipping = 0.3
end

function playerbase:touched(signal, sender)
  if self:isvulnerable() then
    if signal == "attack" then
      self:die(sender)
    elseif signal == "poison" then
      self:poison(sender)
    elseif signal == "slip" then
      self:slip(sender)
    end
  end
end

function playerbase:statecomplete(state)
  if state == "dying" then
    self:respawn()
  elseif state == "poisoned" then
    self:die(self.poisoner)
  end
end

function playerbase:drawsprite(x, y, opts)
  self.sprite:draw(x, y, opts)
end

function playerbase:draw(x, y)
  x = x or self.x
  y = y or self.y
  flipx=self.facing == 1

  if self.poisoned > 0 then
    poison:draw(x, y-4)
  end

  opts = {flipx=flipx}
  if self.spawned > 0 then
    opts.opacity = makeopacity(1 - self.spawned / 2)
  end
  self:drawsprite(x, y, opts)
  if self.attacking > 0 and self.atkspr > 0 then
    spr(self.atkspr, x+self.w*self.facing, y, 1, 1, flipx)
  end

  -- uncomment to draw hitboxes
  -- if self.attacking > 0 then
  --   for hb in all(pack(self:hitbox())) do
  --     rect(hb.x, hb.y, hb.x+hb.w, hb.y+hb.h, 7)
  --   end
  -- end
end

shru = prototype({
  name='shru',
  sprite=sprite:new{
    animationstr=[[
    idle=16,16,16,16,16,16,18,speed:1.5
    walk=16,17
    attacking=19,20,speed:0.2
    dash=21
    dying=22
    ]],
    palettespr=127,
  },
  accel=8, speed=2.5,
  dashing=0, dashcool=0,
}, playerbase)

function shru:animstate()
  if self.dashing > 0 then
    return "dash"
  else
    return playerbase.animstate(self)
  end
end

function shru:isvulnerable()
  return playerbase.isvulnerable(self) and self.dashing <= 0
end

function shru:states()
  states = playerbase.states(self)
  add(states, 'dashing')
  add(states, 'dashcool')
  return states
end

function shru:statecomplete(state)
  playerbase.statecomplete(self, state)
  if state == 'dashing' then
    self.facing = -self.facing
  end
end

function shru:walk()
  playerbase.walk(self)
  if btnp(b.o, self.p) and self.dashcool <= 0 then
    self.vy -= 1
    self.dashing = 0.2
    self.dashcool = 1
  end
  if (self.dashing > 0) self.vx = self.speed*self.facing
end

forg = prototype({
  name='forg',
  sprite=sprite:new{
    animationstr=[[
    idle=32
    jump=33
    lick=34
    dying=35
    ]],
    palettespr=126
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
  if self.dying > 0 then
    return "dying"
  elseif self.attacking > 0 then
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
    self.vx = max(abs(self.vx) - self.accel*dt*2, 0) * sgn(self.vx)
  end

  look = dpad('y', self.p)
  if (dir != 0) look += 1
  self.orientation = mid(0, self.orientation-look*self.lookspeed*dt, .25)
end

function forg:hitbox()
  x, y = self:tonguepos()
  hb = {
    x=x-self.facing, y=y-1, w=3, h=3
  }
  if (self.facing < 0) hb.x -= hb.w
  return hb
end

function forg:tonguepos(d)
  d = d or self.tonguelen*easeoutback(self.attacking/self.attklen)
  x, y = self.x+4, self.y+3
  return x+d*self.facing*orx, y+d*ory
end

function forg:draw()
  playerbase.draw(self)
  if self.dying <= 0 then
    orx = cos(self.orientation)
    ory = sin(self.orientation)

    x, y = self:tonguepos(8)
    pset(x, y, 0)
    bm = 4
    if self.buzz > bm/2 then
      pset(x+1, y-1, 7)
    end
    self.buzz +=1
    if (self.buzz > bm) self.buzz = 0

    if self.attacking > 0 then
      tx,ty  = self:tonguepos()
      line(self.x+4+2*self.facing, self.y+3, tx, ty, 8)
      circ(tx, ty, 1, 8)
    end
  end
end

brid = prototype({
  name='brid',
  sprite=sprite:new{
    animationstr=[[
      idle=48
      walk=48,49
      flap=51
      glide=50
      dive=52
      peck=53
      dying=54
    ]],
    palettespr=125
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
    self.vx = mid(-self.walkspeed, self.vx, self.walkspeed)
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

function brid:hitbox()
  hb = playerbase.hitbox(self)
  hb.x -= 2*self.facing
  if (not self.grounded) hb.y+=6
  return hb
end

function brid:update()
  playerbase.update(self)
  if self.attacking > 0 then
    x, y = self.x+(self.w-2)*self.facing, self.y
    if not self.grounded then
      x-=self.facing
      y+=4
    end
  end
end

waps = prototype({
  sprite=sprite:new{
    animationstr=[[
      idle=60,61,speed:0.05555
      attacking=62
      dying=63
    ]],
    palettespr=123,
  },
  name='waps',
  accel=10, speed=1,
  gravity=0,
  -- locked=true,
}, playerbase)

function waps:die()
  playerbase.die(self)
  self.gravity = 1
end

function waps:respawn()
  playerbase.respawn(self)
  self.gravity = 0
end

function waps:walk()
  playerbase.walk(self)
  dir = dpad('y', self.p)

  if dir==0 then
    self.vy = max(abs(self.vy) - self.accel*dt*2, 0) * sgn(self.vy)
  else
    self.vy = mid(-self.speed, self.vy + self.accel*dir*dt, self.speed)
  end
  self.walking = false
end

function waps:hitsignal()
  return "poison"
end

function waps:touched(signal, sender)
  playerbase.touched(self, signal, sender)
  sender:cure(self)
end

trut = prototype({
  name='trut',
  sprite=sprite:new{
    animationstr=[[
      idle=1
      walk=1,2
      attacking=1
      defending=3,4,once:1
      dying=7
    ]],
    palettespr=124,
  },
  headsprite=sprite:new{
    animationstr=[[
      idle=5
      attacking=6
    ]],
  },
  necklen=0,
  attklen=1.5,
  defending=0,
  defcool=1,
  speed=.5,
}, playerbase)
trut.headsprite.palettes = trut.sprite.palettes

function trut:new(world, p, x, y, palette)
  new = playerbase.new(self, world, p, x, y, palette)
  new.headsprite = new.headsprite:new({palette=palette})
  return new
end

function trut:states()
  states = playerbase.states(self)
  add(states, 'defending')
  add(states, 'defcool')
  return states
end

function trut:animstate()
  if self.defending > 0 then
    return 'defending'
  else
    return playerbase.animstate(self)
  end
end

function trut:action()
  playerbase.action(self)
  if self.attacking > 0 and not btn(b.x, self.p) then
    self.attacking = 0
    self.cooldown = self.attkcool
  end
  if btnp(b.o, self.p) and self.defcool <= 0 then
    self.defending = 2
    self.defcool = 2.5
  end
  if self.defending > 0 and not btn(b.o, self.p) then
    self.defending = 0
    self.defcool = 0.5
  end
end

function trut:isvulnerable()
  return playerbase.isvulnerable(self) and self.defending <= 0
end

function trut:drawsprite(x, y, opts)
  if self.defending + self.dying <= 0 then
    self.headsprite:draw(x+self.necklen*self.facing, y, opts)
  end
  playerbase.drawsprite(self, x, y, opts)
end

function trut:update()
  as=32
  nl=6
  if self.attacking > 0 then
    self.necklen =  min(self.necklen+as*dt, nl)
  else
    self.necklen =  max(self.necklen-as*dt, 0)
  end
  self.headsprite:advance(dt, self:animstate())
  playerbase.update(self)
end

function trut:attacked(touches)
  self.attacking = 0
  self.cooldown = self.attkcool
end

function trut:hitbox()
  hb = playerbase.hitbox(self, 4, 4)
  hb.y += 2
  hb.x += (self.necklen-2)*self.facing
  return hb
end

mant = prototype({
  name='mant',
  sprite=sprite:new{
    animationstr=[[
      idle=42
      walk=42,43
      windup=44
      wound=45
      attacking=46
      hiding=45
      dying=47
    ]],
    palettespr=122,
  },
  windlen=0.5,
  attkcool=0.75,
  hiding=false,
  windup=0,
  fade=0,
}, playerbase)

function mant:animstate()
  state = playerbase.animstate(self)
  if state != "dying" and state != "attacking" then
    if self.hiding then
      return "hiding"
    elseif self.windup > self.windlen then
      return "wound"
    elseif self.windup > 0 then
      return "windup"
    end
  end
  return state
end

function mant:update()
  playerbase.update(self)
  if self.dying > 0 or self.vx != 0 or self.attacking > 0 then
    self.hiding = false
    self.fade = 0
  end
  if self.hiding then
    if self.fade > 0 then
      self.fade -= dt
      self.sprite.opacity = makeopacity(self.fade/.5)
    end
  else
    self.sprite.opacity = {1,0}
  end
end

function mant:action()
  if not self.hiding and btnp(b.o, self.p) then
    self.hiding = true
    self.fade = 0.5
  end
  if self.cooldown <= 0 then
    if btn(b.x, self.p) then
      self.windup += dt
      self.vx = 0
    else
      if self.windup > self.windlen then
         self.attacking = self.attklen
         self.cooldown = self.attacking + self.attkcool
       end
      self.windup = 0
    end
  end
end

sulg = prototype({
  name='sulg',
  sprite=sprite:new{
    animationstr=[[
      idle=24
      walk=24,25,speed:0.4
      attacking=26
      dying=27
    ]],
    palettespr=121,
  },
  vspike=28,
  hspike=29,
  accel=3,
  speed=.6,
  slime={},
  slimetime=8,
  spikelen=0,
  attklen=1.5,
  atkspr=0,
}, playerbase)

function sulg:update()
  playerbase.update(self)
  for k, v in pairs(self.slime) do
    v -= dt
    if (v <= 0) v = nil
    self.slime[k] = v
    if v then
      x, y = numtocoords(k*8)
      self.world:send_touch({x=x, y=y-2, w=8, h=2}, "slip", self)
    end
  end
  if self.grounded then
    x = self.x+4
    y = self.y+8
    if mfget(x, y, flags.stop) then
      self.slime[coordtonum((x)/8, y/8)] = self.slimetime
    end
  end

  time=32
  if self.attacking > 0 then
    self.spikelen = min(self.spikelen+time*dt, 8)
  else
    self.spikelen = max(self.spikelen-time*dt, 0)
  end
end

function sulg:action()
  playerbase.action(self)
  if self.attacking > 0 and not btn(b.x, self.p) then
    self.attacking = 0
    self.cooldown = self.attkcool
  end
end

function sulg:walk()
  if self.attacking > 0 then
    self.vx = max(abs(self.vx) - .3*dt, 0) * sgn(self.vx)
  else
    playerbase.walk(self)
  end
end

function sulg:hitbox()
  vhb = {x=self.x+2, y=self.y+4-self.spikelen, w=4,h=self.spikelen}
  hhb = {x=self.x+2-self.spikelen, y=self.y+2, w=self.spikelen*2+2,h=4}
  return vhb, hhb
end

function sulg:draw()
  self.sprite:pal()
  if self.spikelen > 0 then
    l = (self.spikelen)/8
    spr(self.vspike, self.x, self.y+4-self.spikelen, 1, l, self.facing == 1)
    spr(self.hspike, self.x+2-self.spikelen, self.y, l, 1)
    spr(self.hspike, self.x-2+self.spikelen, self.y, l, 1, true)
  end
  for k, v in pairs(self.slime) do
    x, y = numtocoords(k*8)
    s = 30
    if (v < self.slimetime/3) s = 31
    spr(s, x, y)
  end
  pal()
  playerbase.draw(self)
end

spir = prototype({
  name='spir',
  sprite=sprite:new{
    bg=12,
    animationstr=[[
      idle=55
      walk=55,56
      corner=38
      rev_corner=37
      edge=57
      wall_idle=39
      wall_walk=39,40
      wall_edge=41
      spinning=58
      dying=22
    ]],
    palettespr=120,
  },
  jumpspeed=1.5,
  vfacing=-1,
  gravity=0,
  wall=0,
  flipx=false,
  jumping=false,
  webs={},
}, playerbase)

function spir:edgecheck()
  local x, y = self.x, self.y
  if (self.facing < 0) x -= 1
  if (self.facing > 0) x += 6
  if (self.vfacing < 0) y -= 1
  if (self.vfacing > 0) y += 6
  return {x, y, 3, 3}
end

function spir:update()
  if self.jumping then
    self.gravity = 1
  else
    self.gravity = 0
  end
  playerbase.update(self)
  if self.spinning and not self.jumping then
    add(self.webs, {
      self.spinning, self:webpoint(), strength=20
    })
    self.spinning = nil
  end
  webs = {}
  for web in all(self.webs) do
    web.strength -= dt
    if (web.strength > 0) add(webs, web)
  end
  self.webs = webs
end

function spir:move()
  if self.spinning then
    local wx, wy = unpack(self.spinning)
    local x, y = self.x+4, self.y
    local dx, dy = x- wx, y-wy
    local dist = pythag(dx, dy)
  end
  playerbase.move(self)
end

function spir:webpoint()
  local x, y = self.x+4, self.y+4
  if self.edge then
    x += 4*self.edge[1]
    y += 4*self.edge[2]
  else
    x += 4*self.facing
    if (self.grounded) y += 3
    if (self.roofed) y -= 4
  end
  return {x, y}
end

function spir:action()
  bo, bx = btnp(b.o, self.p), btnp(b.x, self.p)
  if self.spinning and bo then
    self.spinning = nil
  elseif not self.jumping and (bo or bx) then
    self.jumping = true
    self.vfacing = 1
    local jx, jy = false, false
    if self.edge then
      local ex, ey = unpack(self.edge)
      self.vx += -self.jumpspeed * ex
      self.vy += -self.jumpspeed * ey
      jx, jy = true, true
    else
      if self.grounded then
        self.vy -= self.jumpspeed
        jy = true
      elseif self.roofed then
        self.vy += self.jumpspeed - g*dt
        jy = true
      end
      if self.wall != 0 then
        self.vx += self.jumpspeed * -self.facing
        jx = true
      end
    end
    if jx and jy then
      self.vx /= sqrt2
      self.vy /= sqrt2
    end
    if bx and #self.webs < 5 then
      self.spinning = self:webpoint()
    end
  end
end

function spir:walk()
  local diry = dpad('y', self.p)
  local dirx = dpad('x', self.p)

  self.jumping = not self:collides(self.x-1, self.y-1, self.w+2, self.h+2)
  if self.jumping then
    self.edge = nil
    playerbase.walk(self)
    return
  end

  if self.edge then
    local cx, cy, cw = unpack(self.edge)
    if (dirx != cx) dirx = 0
    if (diry != cy) diry = 0
    if (diry+dirx != 0) then
      self.x += dirx*3
      self.y += diry*3
      self.edge = nil
    else
      return
    end
  end

  local w = self:collides(self.x-1, self.y, self.w+2, self.h)
  if w then
    self.wall = sgn(w-self.x)
    self.facing = self.wall
  else
    self.wall = 0
  end

  self.roofed = self:collides(self.x, self.y-1)

  if (self.flipx) dirx = -dirx

  if self.wall != 0 then
    if (diry == 0 and not self.roofed) diry = dirx * -self.wall
    if not self.grounded and not self.roofed then
      dirx = 0
    end
  else
    diry = 0
  end

  playerbase.walk(self, dirx)
  self.walking = diry + dirx != 0

  if diry == 0 then
    -- speed down
    self.vy = max(abs(self.vy) - self.accel*dt*2, 0) * sgn(self.vy)
    if (self.grounded) self.vfacing = 1
    if (self.roofed) self.vfacing = -1
  else
    self.vfacing = diry
    -- speed up
    self.vy = mid(-self.speed, self.vy + self.accel*diry*dt, self.speed)
  end

  -- check for edge
  if dirx+diry != 0 then
    local edge = self:edgecheck()
    if not self:collides(unpack(edge)) then
      -- snap to grid
      local x,y = flr(self.x/8), flr(self.y/8)
      if self.wall == 0 then
        self.edge = {-self.facing, self.vfacing, self.wall}
        if (self.facing > 0) x += 1
      else
        self.edge = {self.facing, -self.vfacing, self.wall}
        if (self.vfacing > 0) y += 1
        self.vfacing *= -1
      end
      self.x, self.y = x*8, y*8
      self.vx = 0
      self.vy = 0
    end
  end
end

function spir:animstate()
  local state = playerbase.animstate(self)
  if (state == "dying") return state
  if (self.spinning) return "spinning"
  if (self.edge) state = "edge"
  if self.wall != 0 then
    state = "wall_" .. state
    if (self.grounded or self.roofed) then
      state = "corner"
      -- todo: track direction we came from?
      if (self.vfacing == self.facing) state = "rev_corner"
    end
  end
  return state
end

function spir:drawsprite(x, y, opts)
  opts = opts or {}
  if self.wall != 0 then
    opts.flipx = self.wall > 0
    opts.flipy = self.vfacing > 0
  elseif self.roofed then
    opts.flipy = true
  end
  if self.edge then
    opts.offx = 3 * self.facing
    opts.offy = 3 * self.vfacing
    if self.wall == 0 then
      opts.offx *= -1
    end
  end
  if self.spinning then
    opts.flipx = false
    opts.flipy = false
    local sx, sy = unpack(self.spinning)
    line(sx,sy,self.x+4,self.y, 6)
    -- print(sx..','..sy..':'..self.spinning.length, 1, 1, 10)
  end
  for web in all(self.webs) do
    local p1, p2 = unpack(web)
    local x1, y1 = unpack(p1)
    local x2, y2 = unpack(p2)
    line(x1, y1, x2, y2, 6)
  end
  playerbase.drawsprite(self, x, y, opts)
end

--[[ TODO:
fung
]]
