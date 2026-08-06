local Locale = require("locale")
local Room = require("room")

local TILE = 48
local COLS, ROWS = 10, 8
local AVATAR_SPEED = 220

local locale
local images = {}
local avatar = { x = 0, y = 0, col = 5, row = 4, path = {} }

local function drawCentered(img, x, y)
  love.graphics.draw(img, x, y, 0, 1, 1, img:getWidth() / 2, img:getHeight() / 2)
end

local function buildLocale()
  local w, h = love.graphics.getDimensions()
  local originX = (w - COLS * TILE) / 2
  local originY = (h - ROWS * TILE) / 2

  local room = Room.new({ id = "main", cols = COLS, rows = ROWS, tile = TILE, originX = originX, originY = originY })

  local l = Locale.new()
  l:addRoom(room)
  return l
end

function love.load()
  images.floor_a = love.graphics.newImage("assets/floor_a.png")
  images.floor_b = love.graphics.newImage("assets/floor_b.png")
  images.character_1 = love.graphics.newImage("assets/character_1.png")

  locale = buildLocale()
  local room = locale:getCurrentRoom()
  local startCase = room:getCase(avatar.col, avatar.row)
  avatar.x, avatar.y = startCase.x, startCase.y
end

function love.update(dt)
  if #avatar.path == 0 then return end

  local nextCase = avatar.path[1]
  local dx = nextCase.x - avatar.x
  local dy = nextCase.y - avatar.y
  local dist = math.sqrt(dx * dx + dy * dy)

  if dist > 2 then
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

function love.draw()
  love.graphics.clear(0.06, 0.08, 0.11)

  local room = locale:getCurrentRoom()
  for row = 0, room.rows - 1 do
    for col = 0, room.cols - 1 do
      local case = room:getCase(col, row)
      local tex = ((col + row) % 2 == 0) and images.floor_a or images.floor_b
      drawCentered(tex, case.x, case.y)
    end
  end

  drawCentered(images.character_1, avatar.x, avatar.y)
end