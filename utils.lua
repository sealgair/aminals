-- global constants
dt = 1/60
g = 5 * dt

b = {l=0, r=1, u=2, d=3, o=4, x=5}

function printc(str, x, y, c)
  l = #tostr(str)*4
  h=l/2
  print(str, x-h, y, c)
end

function debug(val, opts)
  bx, by, bc = cursor()
  opts = opts or {}
  x = opts.x or 0
  y = opts.y or 0
  val = tostring(val)
  color(opts.bg or 5)
  rectfill(x, y, (#tostring(val)*4), y+6)
  color(opts.fg or 6)
  print(val, x+1, y+1)
  cursor(bx, by, bc)
end

function wrap(min, v, max)
  if (v < min) v = max-(min-v)+1
  if (v > max) v = min+(v-max)-1
  return v
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

function easeoutback(t, pow)
  pow = pow or 4
  return 1-(2*(t-.5))^4
end

function insert(t, v, i)
  for j=#t,i,-1 do
    t[j+1] = t[j]
  end
  t[i] = v
end

function sort(t, bigger)
  local r = {}
  for v in all(t) do
    local ins = false
    for i=1,#r do
      if bigger(v, r[i]) then
        insert(r, v, i)
        ins = true
        break
      end
    end
    if (not ins) add(r, v)
  end
  return r
end

function invert(tbl)
  new = {}
  for k, v in pairs(tbl) do
    new[v] = k
  end
  return new
end

function find(tbl, item)
  for k,v in pairs(tbl) do
    if (v == item) return k
  end
end

function lalign(s, n)
  s = tostring(s)
  while #s < n do
    s = s .. " "
  end
  return s
end

function tmap(tbl, fn)
  result = {}
  for k, v in pairs(tbl) do
    result[k] = fn(v)
  end
  return result
end


function coordtonum(x, y)
  return flr(x) | flr(y) >> 16
end

function numtocoords(n)
  x = n & 0xffffffff
  y = n << 16
  return x, y
end
