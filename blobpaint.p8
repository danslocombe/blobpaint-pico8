pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

field = {}
t = 0

function sqr(x)
  return x * x
end

function _init()
  for y = 0,128 do
    field[y] = {}
    for x = 0,128 do
      local dist = sqrt(sqr(64 - x) + sqr(64 - y))
      --field[y][x] = dist
      field[y][x] = 0
    end
  end

  poke(0x5F2D, 1)
end

function _update60()
  t += 1
  local left_pressed = band(1, stat(34)) != 0
  local right_pressed = band(2, stat(34)) != 0

  if left_pressed or right_pressed then
    local c_x = stat(32)
    local c_y = stat(33)

    local maxrad = 12
    local k = 30
    local mult = 0
    if left_pressed then
      mult = k
    elseif right_pressed then
      mult = -k
    end

    local x_min = max(0, c_x - maxrad)
    local x_max = min(127, c_x + maxrad)
    local y_min = max(0, c_y - maxrad)
    local y_max = min(127, c_y + maxrad)

    for y = y_min,y_max do
      for x = x_min,x_max do
        local dist = sqr(c_x - x) + sqr(c_y - y)
        field[y][x] += (1 / (0.5 + dist)) * mult
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

        local f = field[y][x]
        local col = 7
        if abs(f - thresh) < 1 then
          col = 2
        end

        if f > thresh then
          if rnd() < 0.995 then
            col = 0
          end
        end

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
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
