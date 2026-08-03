local Locale = require("locale")
local Room = require("room")

local TILE_W, TILE_H = 64, 32
local WALL_H = 96
local AVATAR_SPEED = 200

local WALL_RIGHT_OX, WALL_RIGHT_OY = 2, 114
local WALL_LEFT_OX, WALL_LEFT_OY = 34, 114
local PROP_Y_OFFSET = -10

local gameState = "menu"
local locale
local playButton = { w = 300, h = 80 }
local buttonFont

local images = {}
local avatar = { x = 0, y = 0, col = 5, row = 4, path = {} }

local function drawCentered(img, x, y)
  love.graphics.draw(img, x, y, 0, 1, 1, img:getWidth() / 2, img:getHeight() / 2)
end

local function buildLocale()
  local w, h = love.graphics.getDimensions()
  local cols, rows = 9, 9

  local minXrel = -(rows - 1) * (TILE_W / 2) - TILE_W / 2
  local maxXrel = (cols - 1) * (TILE_W / 2) + TILE_W / 2
  local minYrel = -WALL_H
  local maxYrel = (cols - 1 + rows - 1) * (TILE_H / 2) + TILE_H

  local widthSpan = maxXrel - minXrel
  local heightSpan = maxYrel - minYrel

  local originX = (w - widthSpan) / 2 - minXrel
  local originY = (h - heightSpan) / 2 - minYrel

  local room = Room.new({
    id = "main", cols = cols, rows = rows,
    tileW = TILE_W, tileH = TILE_H,
    originX = originX, originY = originY,
  })

  local l = Locale.new()
  l:addRoom(room)
  return l
end

local function updateLayout()
  locale = buildLocale()
  local room = locale:getCurrentRoom()

  local w, h = love.graphics.getDimensions()
  playButton.x = (w - playButton.w) / 2
  playButton.y = h / 2 + 100

  local startCase = room:getCase(5, 4)
  avatar.x, avatar.y = startCase.x, startCase.y
  avatar.col, avatar.row = startCase.col, startCase.row
  avatar.path = {}
end

function love.resize(_w, _h)
  updateLayout()
end

function love.load()
  local names = {
    "floor_iso_a", "floor_iso_b", "wall_right", "wall_left",
    "character_1", "title",
  }
  for _, name in ipairs(names) do
    images[name] = love.graphics.newImage("assets/" .. name .. ".png")
  end

  updateLayout()

  buttonFont = love.graphics.newFont(40)
end

function love.update(dt)
  if gameState ~= "playing" then return end
  if #avatar.path == 0 then return end

  local nextCase = avatar.path[1]
  local dx = nextCase.x - avatar.x
  local dy = nextCase.y - avatar.y
  local dist = math.sqrt(dx * dx + dy * dy)

  if dist > 4 then
    local step = AVATAR_SPEED * dt
    local t = math.min(1, step / dist)
    avatar.x = avatar.x + dx * t
    avatar.y = avatar.y + dy * t
  else
    avatar.x, avatar.y = nextCase.x, nextCase.y
    avatar.col, avatar.row = nextCase.col, nextCase.row
    table.remove(avatar.path, 1)
  end
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end

  if gameState == "menu" then
    if x >= playButton.x and x <= playButton.x + playButton.w
      and y >= playButton.y and y <= playButton.y + playButton.h then
      gameState = "playing"
    end
    return
  end

  local room = locale:getCurrentRoom()
  local targetCase = room:getCaseAtPixel(x, y)
  if targetCase and targetCase.walkable then
    local path = room:findPath(avatar.col, avatar.row, targetCase.col, targetCase.row)
    if path then
      avatar.path = path
    end
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

local function drawMenu()
  local w, h = love.graphics.getDimensions()
  drawCentered(images.title, w / 2, h / 2 - 100)

  love.graphics.setFont(buttonFont)
  love.graphics.rectangle("line", playButton.x, playButton.y, playButton.w, playButton.h)
  love.graphics.printf("Jouer", playButton.x, playButton.y + 15, playButton.w, "center")
end

local function drawRoom(room)
  for row = 0, room.rows - 1 do
    for col = 0, room.cols - 1 do
      local case = room:getCase(col, row)
      local tex = (col % 4 == 0 or row % 4 == 0) and images.floor_iso_a or images.floor_iso_b
      drawCentered(tex, case.x, case.y)
    end
  end

  local drawables = {}

  for row = 0, room.rows - 1 do
    for col = 0, room.cols - 1 do
      local case = room:getCase(col, row)
      if row == 0 then
        table.insert(drawables, {
          depth = col + row,
          draw = function()
            love.graphics.draw(images.wall_right, case.x, case.y, 0, 1, 1, WALL_RIGHT_OX, WALL_RIGHT_OY)
          end,
        })
      end
      if col == 0 then
        table.insert(drawables, {
          depth = col + row,
          draw = function()
            love.graphics.draw(images.wall_left, case.x, case.y, 0, 1, 1, WALL_LEFT_OX, WALL_LEFT_OY)
          end,
        })
      end
      if case.occupant then
        table.insert(drawables, {
          depth = col + row,
          draw = function()
            drawCentered(images[case.occupant], case.x, case.y + PROP_Y_OFFSET)
          end,
        })
      end
    end
  end

  local avatarCol, avatarRow = room:pixelToGrid(avatar.x, avatar.y)
  table.insert(drawables, {
    depth = avatarCol + avatarRow + 0.2,
    draw = function() drawCentered(images.character_1, avatar.x, avatar.y + PROP_Y_OFFSET) end,
  })
  table.sort(drawables, function(a, b) return a.depth < b.depth end)
  for _, d in ipairs(drawables) do
    d.draw()
  end
end

function love.draw()
  love.graphics.clear(0.06, 0.08, 0.11)
  if gameState == "menu" then
    drawMenu()
  else
    drawRoom(locale:getCurrentRoom())
  end
end