-- debug utilites

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

function tprint(tbl, i)
  i = i or ''
  print(i.."#"..#tbl)
  for k, v in pairs(tbl) do
    if type(v) == 'table' then
      print(k.." {table}:")
      tprint(v, i .. ' ')
    else
      if type(v) == 'boolean' then
        v = v and 'true' or 'false'
      end
      print(i..k..": "..v)
    end
  end
end
