spritebase = {
  animations = {
    idle = {0}
  },
  palettes={},
  palette=0,
  state = 'idle',
  clock = 0,
}

function spritebase:getcell()
  anim = self.animations[self.state]
  return anim[1+flr((self.clock / anim.speed) * #anim)]
end

function spritebase:draw(x,y, opts)
  opts = opts or {}
  cell = self:getcell()
  palette = opts.palette or self.palette
  if (palette) pal(self.palettes[palette])
  spr(cell, x, y, opts.w or 1, opts.h or 1, opts.flipx, opts.flipy)
  pal()
end

function spritebase:advance(amt, state)
  amt = amnt or dt
  if (state != nil) self.state = state
  anim = self.animations[self.state]
  self.clock += amt
  if (self.clock >= anim.speed) self.clock = 0
end

function makesprite(otps)
  if (not otps.animations) otps = {animations=otps}
  for n, cells in pairs(otps.animations) do
    if cells.speed == nil then
      cells.speed = #cells * .15
    end
  end
  return prototype(otps, spritebase)
end
