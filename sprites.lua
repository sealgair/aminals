sprite = {
  animations = {
    idle = {0}
  },
  palettes={},
  palette=0,
  state = 'idle',
  clock = 0,
  opacity = {1, 0},
  blink = 1,
}

function sprite:new(opts)
  -- if (not opts.animations) opts = {animations=opts}
  if opts.animations then
    for n, cells in pairs(opts.animations) do
      if (cells.speed == nil) cells.speed = #cells * .15
    end
  end
  return prototype(opts, self)
end

function sprite:getcell()
  anim = self.animations[self.state]
  if (anim) return anim[1+flr((self.clock / (anim.speed+dt)) * #anim)]
end

function sprite:canpal()
  anim = self.animations[self.state]
  cell = self:getcell()
  if (anim.nopal) return anim.nopal[cell] == nil
  return true
end

function sprite:draw(x,y, opts)
  opts = opts or {}
  self.blink += 1
  opacity = opts.opacity or self.opacity
  on, off = unpack(opacity)
  if (self.blink > on + off) self.blink = 1
  if self.blink <= on then
    if (self:canpal()) palette = opts.palette or self.palette
    if palette then
      if (type(palette) == "number") palette = self.palettes[palette]
      pal(palette)
    end
    spr(self:getcell(), x, y, opts.w or 1, opts.h or 1, opts.flipx, opts.flipy)
    pal()
  end
end

function sprite:advance(amt, state)
  amt = amnt or dt
  if state != nil and self.state != state and self.animations[state] then
    self.clock = 0
    self.state = state
  end
  anim = self.animations[self.state]
  self.clock += amt
  if (self.clock >= anim.speed) then
    if anim.once then
      self.clock = anim.speed
    else
      self.clock = 0
    end
  end
end
