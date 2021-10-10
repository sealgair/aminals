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
  if (v < min) v = max-(min-v)+1
  if (v > max) v = min+(v-max)-1
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
