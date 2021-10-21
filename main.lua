matchend = 10
pointsmatch = true -- otherwise time
highscore_idle = 120

flags = {
  stop=0
}

player_colors = {8, 12, 11, 10}
places = {'1st', '2nd', '3rd', '4th'}
medals = {
  {10,9}, {7,6}, {9,4}, {6,5}
}

-- menu items

function initmenu()
  local matchtypemap = {
    [true] =  {5,  10, 20, 50}, -- points
    [false] = {1,  3,  5,  10}, -- minutes
  }
  local mtype = "minute"
  if (pointsmatch) mtype = "point"
  menuitem(1, matchend.." "..mtype.." match", function(mask)
    local l = mask & 1 > 0
    local r = mask & 2 > 0
    local x = mask & 16 > 0

    local matchvals = matchtypemap[pointsmatch]
    local i = find(matchvals, matchend) or 2
    if x then
      pointsmatch = not pointsmatch
      matchvals = matchtypemap[pointsmatch]
      matchend = matchvals[i]
    end

    if (l) i -= 1
    if (r) i += 1
    i = wrap(1, i, #matchvals)
    matchend = matchvals[i]
    savesettings()
    initmenu()
    return true
  end)
end

menuitem(2, "clear high scores", function(mask)
  if (mask & 0b00001) clearscores()
  return true
end)

-- chose player screen

playerselect = {
  options = {
    {shru, forg},
    {brid, trut},
  },
  chosen = {
    coord(0,0),
    coord(0,0),
    coord(0,0),
    coord(0,0),
  },
  selected = {
    coord(0,0),
    coord(0,0),
    coord(0,0),
    coord(0,0),
  },
  palettes = {0,1,2,3},
  idle = 0,
}

function playerselect:start()
  self.idle = 0
  for p=1,4 do
    self.chosen[p] = coord(0,0)
  end
  gamestate = self
end

function playerselect:update()
  self.idle += dt
  if (self.idle > highscore_idle) return highscores:start()
  if (btn() != 0) self.idle = 0

  for player=1,4 do
    local chosen = self.chosen[player]
    local selected = self.selected[player]

    if btnp(b.o, player-1) then
      chosen.x, chosen.y = 0, 0
      self.palettes[player] = player-1
    end

    if btnp(b.x, player-1) then
      if chosen == selected and chosen != coord(0, 0) then
        local players = {}
        for p, pos in pairs(self.chosen) do
          if pos != coord(0,0) then
            players[p] = {
              player=self.options[pos.y][pos.x],
              palette=self.palettes[p]
            }
          end
        end
        game:start(players)
      else
        chosen.x, chosen.y = selected.x, selected.y
      end
    end
    local dx = dpad('x', player-1, true)
    local dy = dpad('y', player-1, true)
    if dx+dy != 0 then
      if (selected == coord(0, 0)) then
        -- join the game
        selected.x, selected.y = 1, 1
      elseif chosen == coord(0, 0) then
        -- hasn't decided
        selected.x = wrap(1, selected.x+dx, 2)
        selected.y = wrap(1, selected.y+dy, 2)
      else
        -- choose color
        repeat
          self.palettes[player] = wrap(0, self.palettes[player]+dy, 3)
          duped = false
          for op=1,4 do
            if (op != player and self.chosen[op] == chosen and
                self.palettes[op] == self.palettes[player]) then
              duped = true
            end
          end
        until not duped
      end
    end
  end

  for row in all(self.options) do
    for col in all(row) do
      col.sprite:advance()
    end
  end
end

function playerselect:draw()
  cls(5)
  print("choose your aminal", 28, 5, 9)

  local y = 30
  for r, row in pairs(self.options) do
    local x = 23
    for c, col in pairs(row) do
      rect(x, y, x+15, y+15, 6)
      rect(x+1, y+1, x+14, y+14, 6)
      rect(x+2, y+2, x+13, y+13, 7)

      local rc = coord(c, r)
      local drawn = 0
      for player=1,4 do
        selected = self.selected[player]
        chosen = self.chosen[player]
        color(player_colors[player])
        if rc == chosen then
          drawn += 1
          if (drawn == 1) line(x+2, y+1, x+13, y+1) -- top: p1
          if (drawn < 3) line(x+2, y+14, x+13, y+14) -- bottom: p1 p2
          if (drawn%2 == 1) line(x+1, y+2, x+1, y+13) -- left: p1 p3
          if (drawn != 3) line(x+14, y+2, x+14, y+13) -- right: p1 p2 p4
        end
        if rc == selected then
          print(player, x+(player-1)*4, y-6)
        end
      end
      rectfill(x+3, y+3, x+12, y+12, 12)
      col:drawsprite(x+4, y+4)
      print(col.name, x+1, y+17, 15)
      x += 64
    end
    y += 50

  end

  for player=1,4 do
    chosen = self.chosen[player]
    px = 1 + (player-1)%2 * 113
    py = 1
    if (player > 2) py += 113
    rect(px, py, px+12, py+12, 13)
    color(player_colors[player])
    print(player, px+5, py+4)

    if chosen != coord(0,0) then
      choice = self.options[chosen.y][chosen.x],
      rectfill(px+1, py+1, px+11, py+11, 12)
      choice:drawsprite(px+2, py+2, {palette=self.palettes[player]})
    end
  end
end


-- the game itself

game = {
  objects={},
  score=0,
  clock=0,
}
function game:start(players)
  self.clock = 0
  self.spawns = {}
  for x=1,16 do
    for y=1,16 do
      if not mfget(x*8, y*8, flags.stop) and mfget(x*8, (y+1)*8, flags.stop) then
        add(self.spawns, {x*8, y*8})
      end
    end
  end
  self.objects = {}
  for p, popts in pairs(players) do
    x, y = self:spawnpoint()
    add(self.objects, popts.player:new(self, p-1, x, y, popts.palette))
  end
  gamestate = self
end

function game:spawnpoint()
  return unpack(rnd(self.spawns))
end

function game:update()
  self.clock += dt
  self.score = 0
  for o in all(self.objects) do
    self.score += o.deaths or 0
    o:update()
  end
  if self.score >= matchend then
    victory:start(self.objects, self.clock)
  end
end

function game:send_touch(box, signal, sender)
  touches = {}
  for o in all(self.objects) do
    if o != sender and intersects(box, o) then
      o:touched(signal, sender)
      add(touches, o)
    end
  end
  return touches
end

function game:draw()
  cls(12)
  map(0, 0, 0, 0, 127, 127)
  for i, o in pairs(self.objects) do
    o:draw()
  end
  spr(76, 48, 0, 4, 1)
  local s
  if (pointsmatch) then
    s = matchend - self.score
  else
    local time = matchend * 60 - self.clock
    s = flr(time / 60) .. ":" .. flr(time % 60)
  end
  printc(s, 64, 1, 10)
end


-- match end screen

victory = {}

function victory:start(players, time)
  self.idle = 0
  self.gametime = time
  self.players = players
  self.totalkills = 0
  for p in all(self.players) do
    self.totalkills += p.kills
  end
  self.players = sort(self.players, function(a, b)
    return self:makescore(a) > self:makescore(b)
  end)
  for place, player in pairs(self.players) do
    savestats(player, time, place)
  end

  self.needs_initials = is_highscore(self:makescore(self.players[1]))
  self.highscore = self.needs_initials
  self.initials = ""
  self.initial = "a"
  self.blink = 0

  gamestate = self
end

function victory:makescore(player)
  local kpm = player.kills / (self.gametime/60)
  local ktd = player.kills - player.deaths
  local kpc = player.kills / self.totalkills
  return max(0, ceil(kpm * 800 + ktd * 500 + kpc * 2000))
end

function victory:update()
  self.idle += dt
  if (self.idle > highscore_idle) return highscores:start()
  if self.needs_initials then
    local winner = self.players[1]
    self.blink += dt
    if (self.blink >= 1) self.blink = 0
    if btnp(b.x, winner.p) then
      if self.initial == "`" then
        if (self.initials != "") save_score(self.initials, winner, self:makescore(winner))
        self.needs_initials = false
      else
        self.initials = self.initials .. self.initial
        if (#self.initials >= 3) self.initial = "`"
      end
    elseif btnp(b.o, winner.p) and #self.initials > 1 then
      self.initial = sub(self.initials, #self.initials, #self.initials)
      self.initials = sub(self.initials, 1, #self.initials-1)
    else
      m = dpad('y', winner.p, true)
      if m != 0 then
        i = ord(self.initial)
        i = wrap(96, i-m, 122)
        self.initial = chr(i)
        self.blink = 0
      end
    end
  else
    if btnp(b.x) then
      local players = {}
      for player in all(self.players) do
        players[player.p+1] = {player=player}
      end
      game:start(players)
    end
    if (btnp(b.o)) playerselect:start()
  end
end

function victory:outline(player, x, y)
  for ox in all{-1,0,1} do
    for oy in all{-1,0,1} do
      if (ox == 0 or oy == 0) player:drawsprite(x+ox,y+oy, {palette={12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12}})
    end
  end
  player:drawsprite(x,y)
end

function victory:draw()
  rectfill(0,0,127,127,1)
  rectfill(0,0,127,24,2)
  rectfill(0,24,127,25,10)
  colw = 128/#self.players
  for p, player in pairs(self.players) do
    x = (p-1) * colw
    if (x > 0) line(x,26,x,116,7)
    xm = x + colw/2
    printc(places[p], xm, 8, player_colors[player.p+1])
    circfill(xm, 24, 9, medals[p][1])
    circfill(xm, 24, 8, medals[p][2])
    circfill(xm, 24, 6, 12)
    player:drawsprite(xm-4, 20)
    printc('ate: '..player.kills, xm, 38, 8)
    printc('fed: '..player.deaths, xm, 48, 2)
    printc(self:makescore(player).." pts", xm, 58, 10)
  end

  line(0, 116, 127, 116, 7)
  if (self.highscore) print("player "..(self.players[1].p+1).." got a high score!", 12, 2, 10)
  if self.needs_initials then
    getinitials = "enter your initials: " .. self.initials
    local i = self.initial
    if (i == '`') i = " end"
    if (self.blink < 0.5) getinitials = getinitials .. i
    print(getinitials, 13, 120, 7)
  else
    print("❎ retry    🅾️ change aminals", 8, 120, 6)
  end
end

-- highscores screen
aminals = {
  shru,
  forg,
  brid,
  trut,
  waps,
  -- {name='mant'},
  -- {name='spir'},
  -- {name='sulg'},
  -- {name='fung'},
}
animal_names = tmap(aminals, function(a) return a.name end)
animal_ids = invert(animal_names)
-- todo: rename those arrays

function name2bits(initials, aid)
  local a,b,c = ord(initials, 1, 3)
  local num = aid | a << 8 | b >> 8 | c >> 16
  return num
end

byte = 255
function bits2name(bits)
  local aid = bits & byte
  local initials = {
    chr(bits >> 8 & byte),
    chr(bits << 8 & byte),
    chr(bits << 16 & byte),
  }
  name = ""
  for i in all(initials) do
    if (i != nil) name = name .. i
  end
  return name, aid
end

function is_highscore(score)
  return score > dget(19)
end

function save_score(initials, player, score)
  local namebits = name2bits(initials, animal_ids[player.name])

  local saved = false
  for i=0,18,2 do
    local onamebits = dget(i)
    local oscore = dget(i+1)
    if score > oscore then
      dset(i, namebits)
      dset(i+1, score)
      score = oscore
      namebits = onamebits
      saved = saved or i+1/2
    end
  end
  return saved
end

function get_scores()
  local scores = {}
  for i=0,18,2 do
    local namebits = dget(i)
    local initials, aid = bits2name(namebits)
    local score = dget(i+1)
    add(scores, {
      name=initials,
      aminal=animal_names[aid],
      score=score,
    })
  end
  return scores
end

function dinc(i, v)
  dset(i, v + dget(i))
end

function savestats(player, time, place)
  local id = animal_ids[player.name]
  local idx = 20 + (id-1)*4

  -- kills & deaths in first slot
  local kd = player.kills | player.deaths >> 16
  dinc(idx, kd)

  -- total time in second
  idx += 1
  dinc(idx, time)

  -- wins & losses in third
  idx += 1
  local v = 1
  if (place > 1) v = 1 >> 16
  dinc(idx, v)

  -- todo: something else in fourth?
end

function getstats(aminal)
  local id = animal_ids[aminal]
  local idx = 20 + (id-1)*4
  local stats = {name=aminal}

  -- kills & deaths in first slot
  local kd = dget(idx)
  stats.kills = kd & 0xffff
  stats.deaths = kd << 16

  -- total time in second
  idx += 1
  stats.time = dget(idx)

  -- wins & losses in third
  idx += 1
  wl = dget(idx)
  stats.wins = wl & 0xffff
  stats.losses = wl << 16

  -- todo: something else in fourth?

  return stats
end

function initscores()
  cartdata("chasec_jouts")
  players = {forg, brid, shru, trut}
  if dget(19) == 0 then
    for i=1,10 do
      save_score("aml", players[i%4+1], i * 1000)
    end
  end
end

function clearscores()
  for i=0,10 do
    dset(i, 0)
  end
end

highscores = {
  clock = 0,
  show_scores = true,
}

function highscores:start()
  self.clock = 0
  gamestate = self
end

function highscores:draw()
  if self.show_scores then
    self:drawscores()
  else
    self:drawstats()
  end
end

function highscores:drawscores()
  cls()
  color(11)
  print("high scores", 42, 2)
  line(0, 10, 127, 10)
  for s, score in pairs(get_scores()) do
    if s  % 2 == 0 then
      color(3)
    else
      color(11)
    end
    if (s > self.clock * 5) break
    n = "#"
    if (s < 10) n = " " .. n
    print(n..s.." "..score.name .. "  " .. score.aminal .. "  " .. score.score, 4, 4 + 10*s)
  end
end

function highscores:drawstats()
  -- 128 pixels is 32 characters per line
  cls(1)
  color(7)
  print("aminal stats", 40, 2)
  line(0,17,127,17)
  color(12)
  print("ate  fed  won  lost mins", 18, 10)
  rectfill(0,18,11,127)
  function num(n)
    return lalign(min(n, 9999), 5)
  end
  for a, aminal in pairs(aminals) do
    if (a > self.clock * 3) break
    if a % 2 == 0 then
      color(12)
    else
      color(13)
    end
    local s = getstats(aminal.name)
    aminal:drawsprite(2, 7+12*a)
    print(num(s.kills) .. num(s.deaths) .. num(s.wins) .. num(s.losses) .. num(flr(s.time/60)), 18, 9+12*a)
  end
end

function highscores:update()
  self.clock += dt
  if self.clock > 30 then
    self.clock = 0
    self.show_scores = not self.show_scores
  end
  if (btn(b.x) or btn(b.o)) playerselect:start()
end

-- game settings

function savesettings()
  local mv = matchend
  if (not pointsmatch) mv *= -1
  dset(63, mv)
end

function loadsettings()
  mv = dget(63)
  pointsmatch = mv > 0
  matchend = abs(mv)
end

-- system callbacks

function _init()
  initscores()
  loadsettings()
  initmenu()
  gamestate = playerselect
end

function _update60()
  gamestate:update()
end

function _draw()
  gamestate:draw()
end
