pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

field = {}

red = {}
green = {}
blue = {}

t = 0

function sqr(x)
  return x * x
end

function _init()
  local to_init = {}
  add(to_init, red)
  add(to_init, blue)
  add(to_init, green)
  add(to_init, field)

  for i,f in pairs(to_init) do
    for y = 0,128 do
      f[y] = {}
      for x = 0,128 do
        --local dist = sqrt(sqr(64 - x) + sqr(64 - y))
        --field[y][x] = dist
        f[y][x] = 0
      end
    end
  end

  poke(0x5F2D, 1)
end

col = 0

function get_field()
  if col == 0 then
    return red
  elseif col == 1 then
    return green
  elseif col == 2 then
    return blue
  end
end

function get_other_fields()
  if col == 0 then
    return { green, blue}
  elseif col == 1 then
    return { red, blue}
  elseif col == 2 then
    return { red, green}
  end
end

function _update60()
  if btnp(0) then
    col = (col - 1) % 3
  end
  if btnp(1) then
    col = (col + 1) % 3
  end

  t += 1
  local left_pressed = band(1, stat(34)) != 0
  local right_pressed = band(2, stat(34)) != 0

  if left_pressed or right_pressed then
    local c_x = stat(32)
    local c_y = stat(33)

    local maxrad = 12
    local k = 3
    local mult = 0
    if left_pressed then
      mult = k
    elseif right_pressed then
      mult = -2*k
    end

    local x_min = max(0, c_x - maxrad)
    local x_max = min(127, c_x + maxrad)
    local y_min = max(0, c_y - maxrad)
    local y_max = min(127, c_y + maxrad)

    local to_write = get_field()
    local other_fields = get_other_fields()

    for y = y_min,y_max do
      for x = x_min,x_max do
        local dist = sqrt(sqr(c_x - x) + sqr(c_y - y))
        local delta = (1 / (1 + dist)) * mult
        local new = to_write[y][x] + delta
        to_write[y][x] = max(0, min(100, new))

        for i,other_field in pairs(other_fields) do
          local new = other_field[y][x] - delta
          other_field[y][x] = max(0, min(100, new))
        end

      end
    end
  end

end

function _draw()
  --local thresh = 10 + 1 * sin(t / 60)
  for yy = 0,63 do
    local thresh = 10 + 1 * sin((yy + t) / 60)
    for xx = 0,63 do
      if rnd() > 0.85 then
        local x = xx * 2
        if rnd() < 0.5 then
          x = x + 1
        end

        local y = yy * 2
        if rnd() < 0.5 then
          y += 1
        end

        local r = red[y][x]
        local g = green[y][x]

        local col = 7

        local maxval = max(r, g)

        if abs(maxval - thresh) < 1 then
          col = 0
        elseif maxval > thresh then
          if rnd(r + g) < r then
          --if r > g then
            col = 14
          else
            col = 13
          end
        end

        --local f = field[y][x]
        --local col = 7
        --if abs(f - thresh) < 1 then
        --  col = 2
        --end

        --if f > thresh then
        --  if rnd() < 0.995 then
        --    col = 0
        --  end
        --end

        rectfill(x, y, x+1, y+1, col)
      end
    end
  end

  -- cursor
  local c_x = stat(32)
  local c_y = stat(33)
  rectfill(c_x, c_y, c_x+1, c_y+1, 1)

  -- fps
  local fps = stat(7)
  print(fps, 10, 10, 2)

  local left_pressed = band(1, stat(34))
  local right_pressed = band(2, stat(34))

  --if left_pressed then
   -- print("l", 30, 10, 2)
  --end
  --if right_pressed then
    --print("r", 40, 10, 2)
  --end

  print(stat(34), 30, 20, 2)

  print(col, 40, 20, 2)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
