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

function makeopacity(percent, l)
  l = l or 6
  if percent < 0.5 then
    return {1, 1+flr(l*(percent*2-1))}
  else
    return {1+flr(l*2*(.5-percent)), 1}
  end
end

function makeopacity(percent, steps)
  steps = steps or 6
  local margin = 1/(steps*2)
  if percent < margin then
    return {0, 1}
  elseif percent < 0.5 then
    percent *= 2 -- percent of lower half
    return {1, ceil((1-percent)*steps)}
  elseif percent > 1-margin then
    return {1, 0}
  else
    percent = (percent * 2)-1 -- percent of upper half
    return {ceil(percent*steps), 1}
  end
end

function loadpalette(s)
  local x = s%16*8
  local y = flr(s/16)*8
  local res = {}
  for p=1,3 do
    local plt = {}
    for c=0,7 do
      plt[sget(x,y+c)] = sget(x+p, y+c)
    end
    add(res, plt)
  end
  return res
end

function sprite:new(opts)
  -- if (not opts.animations) opts = {animations=opts}
  if opts.animations then
    for n, cells in pairs(opts.animations) do
      if (cells.speed == nil) cells.speed = #cells * .15
    end
  end
  if (opts.palettespr) opts.palettes = loadpalette(opts.palettespr)
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

function sprite:pal(opts)
  opts = opts or {}
  if (self:canpal()) palette = opts.palette or self.palette
  if palette then
    if (type(palette) == "number") palette = self.palettes[palette]
    pal(palette)
  end
  if self.bg then
    palt(0, false)
    palt(self.bg, true)
  end
end

function sprite:draw(x,y, opts)
  opts = opts or {}
  self.blink += 1
  local opacity = opts.opacity or self.opacity
  local on, off = unpack(opacity)
  local ox = opts.offx or 0
  local oy = opts.offy or 0
  if (self.blink > on + off) self.blink = 1
  if self.blink <= on then
    self:pal(opts)
    spr(self:getcell(), x + ox, y + oy, opts.w or 1, opts.h or 1, opts.flipx, opts.flipy)
    pal()
    palt()
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
