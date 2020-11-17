pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

field = {}

red = {}
green = {}
blue = {}

blob = {}

t = 0

function sqr(x)
  return x * x
end

function _init()
  --printh("Starting")
  local to_init = {}
  add(to_init, red)
  add(to_init, blue)
  add(to_init, green)
  add(to_init, field)

  for i=0,128*128 do
    blob[i] = 0
  end

  --for i,f in pairs(to_init) do
  --  for y = 0,128 do
  --    f[y] = {}
  --    for x = 0,128 do
  --      --local dist = sqrt(sqr(64 - x) + sqr(64 - y))
  --      --field[y][x] = dist
  --      f[y][x] = 0
  --    end
  --  end
  --end

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

function get_index(x, y)
  return x + y * 128
  --local mem_address = 0x4300 + x * 1 + y * (128)
  --return mem_address
end

function get_cursor_bounds(maxrad)
    local c_x = stat(32)
    local c_y = stat(33)
    local x_min = max(0, c_x - maxrad)
    local x_max = min(127, c_x + maxrad)
    local y_min = max(0, c_y - maxrad)
    local y_max = min(127, c_y + maxrad)
    return {x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max, c_x = c_x, c_y = c_y}
end

function _update60()
  if btnp(0) then
    col = (col - 1) % 5
  end
  if btnp(1) then
    col = (col + 1) % 5
  end

  t += 1
  local left_pressed = band(1, stat(34)) != 0
  local right_pressed = band(2, stat(34)) != 0

  if left_pressed or right_pressed then
    t -= 1

    local brush_mult = 4
    local brush_const = 1
    local brush_div = 10
    local brush_type = 0
    if col == 2 then
      brush_mult = 1
      brush_const = 0.51
      brush_div = 100
      brush_type = 1
    elseif col == 3 then
      brush_mult = 20
      brush_const = 0.51
      brush_type = 0
      col = 0
    elseif col == 4 then
      brush_type = 2
    end

    local k = brush_mult
    local mult = 0
    if left_pressed then
      mult = k
    elseif right_pressed then
      mult = -2*k
    end


    local maxrad = 12
    local bounds = get_cursor_bounds(maxrad)

    local to_write = get_field()
    local other_fields = get_other_fields()

    for y = bounds.y_min,bounds.y_max do
      for x = bounds.x_min,bounds.x_max do
        local dist = sqrt(sqr(bounds.c_x - x) + sqr(bounds.c_y - y))
        --if delta > 1 then
        if true then
          local addr = get_index(x, y)
          local existing_data = blob[addr]
          local existing_r = (existing_data & 0x0000.FFFF) << 8
          local existing_g = (existing_data & 0xFFFF.0000) >> 8

          local new_r, new_g

          if brush_type == 0 then
            local delta = (mult / (brush_const + dist))
            local delta_r, delta_g
            local k = brush_div
            if col == 0 then
              delta_r = delta
              delta_g = 0
              --delta_g = -delta * existing_g / k
            else
              --delta_r = -delta * existing_r / k
              delta_r = 0
              delta_g = delta
            end

            new_r = max(0, min(100, existing_r + delta_r))
            new_g = max(0, min(100, existing_g + delta_g))
          elseif brush_type == 1 then
            new_r = existing_r
            new_g = existing_g
            local delta = dist-2
            if delta < 0 then
              new_g = 100
            else
              new_g = 10
            end
            --elseif delta < 4 then
              --new_g = ((delta)) * 100
            --end
          else
            new_r = existing_r
            new_g = existing_g
            local delta = dist-2
            if delta < 0 then
              new_g = 100
              new_r = 0
            elseif delta < 2 then
              --new_g = max(10, existing_g)
              --new_r = 0
            end
          end

          --printh(tostr(new, true))
          local towrite_r = (new_r >> 8)
          local towrite_g = (new_g << 8) & 0xFFFF
          blob[addr] = towrite_r | towrite_g

        end
        --printh(tostr(to_write, true))

        --local new = to_write[y][x] + delta

        --to_write[y][x] = max(0, min(100, new))

        --for i,other_field in pairs(other_fields) do
        --  local new = other_field[y][x] - delta
        --  other_field[y][x] = max(0, min(100, new))
        --end

      end
    end
  end

end

function _draw()
  --local thresh = 10 + 1 * sin(t / 60)
  local pressed = stat(34) != 0

  local ymin = 0
  local ymax = 63
  local xmin = 0
  local xmax = 63
  local prob = 0.85

  if pressed then
    prob = 0.5
    local bounds = get_cursor_bounds(24)
    ymin = flr(bounds.y_min / 2)
    ymax = flr(bounds.y_max / 2)
    xmin = flr(bounds.x_min / 2)
    xmax = flr(bounds.x_max / 2)
  end

  for yy = ymin,ymax do
    local thresh = 10 + 1 * sin((yy + t) / 60)
    for xx = xmin,xmax do
      if rnd() > prob then
        local x = xx * 2
        if rnd() < 0.5 then
          x = x + 1
        end

        local y = yy * 2
        if rnd() < 0.5 then
          y += 1
        end

        --local r = red[y][x]
        --local g = green[y][x]
        local addr = get_index(x, y)
        local existing_data = blob[addr]
        local r = (existing_data & 0x0000.FFFF) << 8
        local g = (existing_data & 0xFFFF) >> 8

        local col = 7

        local maxval = max(r, g)
        local minval = min(r, g)

        if abs(maxval - thresh) < 1 then
          col = 0
        --elseif abs(maxval-minval) < 1 then
          --col = 0
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

  --print(stat(34), 30, 20, 2)
  print("brush: ", 10, 20)
  print(col, 40, 20, 2)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
