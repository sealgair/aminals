-- global constants
dt = 1/60
g = 5 * dt

b = {l=0, r=1, u=2, d=3, o=4, x=5}

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


function prototype(a, b)
  mt = {__index = b}
  for k, v in pairs(b) do
    if (sub(k, 0, 2) == "__") mt[k] = v
  end
  setmetatable(a, mt)
  return a
end

coordinate = {
  __eq = function(a, b)
    return a.x == b.x and a.y == b.y
  end,
  __tostring = function(self)
    return self.x .. ", " .. self.y
  end,
}

function coord(x, y)
  return prototype({x=x, y=y}, coordinate)
end

function dpad(axis, player, press)
  player = player or 0
  axes = {
    x={0,1},
    y={2,3},
  }
  axis = axes[axis]

  fn = btn
  if (press) fn = btnp
  if (fn(axis[1], player)) return -1
  if (fn(axis[2], player)) return 1
  return 0
end

function intersects(a, b)
  return (a.x+a.w > b.x and b.x+b.w > a.x) and
      (a.y+a.h > b.y and b.y+b.h > a.y)
end
