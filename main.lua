local Locale = require("locale")
local Room = require("room")

local TILE = 48
local AVATAR_SPEED = 200

local gameState = "menu"
local locale
local playButton = { w = 200, h = 50 }
local titleFont, buttonFont

local images = {}
local avatar = { x = 0, y = 0, targetX = 0, targetY = 0 }

local function drawCentered(img, x, y)
  love.graphics.draw(img, x, y, 0, 1, 1, img:getWidth() / 2, img:getHeight() / 2)
end

local function buildLocale()
  local w, h = love.graphics.getDimensions()
  local cols, rows = 12, 8
  local originX = (w - cols * TILE) / 2
  local originY = (h - rows * TILE) / 2

  local room = Room.new({
    id = "main", cols = cols, rows = rows, tile = TILE,
    originX = originX, originY = originY,
  })

  room:placeProp(3, 2, "desk_computer")
  room:placeProp(6, 2, "desk_computer")
  room:placeProp(9, 2, "desk_computer")
  room:placeProp(10, 1, "plant")
  room:placeProp(9, 1, "vending_machine")
  room:placeProp(1, 5, "box_stack")
  room:placeProp(2, 6, "box_stack")

  local l = Locale.new()
  l:addRoom(room)
  return l
end

local function updateLayout()
  locale = buildLocale()
  local room = locale:getCurrentRoom()

  local w, h = love.graphics.getDimensions()
  playButton.x = (w - playButton.w) / 2
  playButton.y = h / 2 + 60

  local startCase = room:getCase(5, 4)
  avatar.x, avatar.y = startCase.x, startCase.y
  avatar.targetX, avatar.targetY = avatar.x, avatar.y
end

function love.resize(_w, _h)
  updateLayout()
end

function love.load()
  local names = {
    "floor_a", "floor_b", "wall", "door", "desk_computer",
    "plant", "vending_machine", "box_stack", "character_1",
  }
  for _, name in ipairs(names) do
    images[name] = love.graphics.newImage("assets/" .. name .. ".png")
  end

  updateLayout()

  titleFont = love.graphics.newFont(48)
  buttonFont = love.graphics.newFont(20)
end

function love.update(dt)
  if gameState ~= "playing" then return end

  local dx = avatar.targetX - avatar.x
  local dy = avatar.targetY - avatar.y
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist > 4 then
    local step = AVATAR_SPEED * dt
    local t = math.min(1, step / dist)
    avatar.x = avatar.x + dx * t
    avatar.y = avatar.y + dy * t
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
  local case = room:getCaseAtPixel(x, y)
  if case and case.walkable then
    avatar.targetX, avatar.targetY = case.x, case.y
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

local function drawMenu()
  local w, h = love.graphics.getDimensions()
  love.graphics.setFont(titleFont)
  love.graphics.printf("ESPORT TYCOON", 0, h / 2 - 120, w, "center")

  love.graphics.setFont(buttonFont)
  love.graphics.rectangle("line", playButton.x, playButton.y, playButton.w, playButton.h)
  love.graphics.printf("Jouer", playButton.x, playButton.y + 15, playButton.w, "center")
end

local function drawRoom(room)
  for row = 0, room.rows - 1 do
    for col = 0, room.cols - 1 do
      local case = room:getCase(col, row)
      local isBorder = row == 0 or row == room.rows - 1 or col == 0 or col == room.cols - 1
      if isBorder then
        drawCentered(images.wall, case.x, case.y)
      else
        local tex = ((col + row) % 2 == 0) and images.floor_a or images.floor_b
        drawCentered(tex, case.x, case.y)
      end
    end
  end

  local doorCase = room:getCase(0, 4)
  drawCentered(images.door, doorCase.x, doorCase.y)

  for row = 0, room.rows - 1 do
    for col = 0, room.cols - 1 do
      local case = room:getCase(col, row)
      if case.occupant then
        drawCentered(images[case.occupant], case.x, case.y)
      end
    end
  end

  drawCentered(images.character_1, avatar.x, avatar.y)
end

function love.draw()
  love.graphics.clear(0.06, 0.08, 0.11)
  if gameState == "menu" then
    drawMenu()
  else
    drawRoom(locale:getCurrentRoom())
  end
end