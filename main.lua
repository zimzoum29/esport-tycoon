local TILE = 48
local COLS = 12
local ROWS = 8
local AVATAR_SPEED = 200

local gameState = "menu"
local ORIGIN_X, ORIGIN_Y
local playButton = { w = 200, h = 50 }
local titleFont, buttonFont

local images = {}
local avatar = { x = 0, y = 0, targetX = 0, targetY = 0 }

local function tilePos(col, row)
  return ORIGIN_X + col * TILE + TILE / 2, ORIGIN_Y + row * TILE + TILE / 2
end

local function drawCentered(img, x, y)
  love.graphics.draw(img, x, y, 0, 1, 1, img:getWidth() / 2, img:getHeight() / 2)
end

local function updateLayout()
  local w, h = love.graphics.getDimensions()
  ORIGIN_X = (w - COLS * TILE) / 2
  ORIGIN_Y = (h - ROWS * TILE) / 2
  playButton.x = (w - playButton.w) / 2
  playButton.y = h / 2 + 60
end

function love.resize(w, h)
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
  avatar.x, avatar.y = tilePos(5, 4)
  avatar.targetX, avatar.targetY = avatar.x, avatar.y

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
  else
    avatar.targetX, avatar.targetY = x, y
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

local function drawGame()
  for row = 0, ROWS - 1 do
    for col = 0, COLS - 1 do
      local x, y = tilePos(col, row)
      local isBorder = row == 0 or row == ROWS - 1 or col == 0 or col == COLS - 1
      if isBorder then
        drawCentered(images.wall, x, y)
      else
        local tex = ((col + row) % 2 == 0) and images.floor_a or images.floor_b
        drawCentered(tex, x, y)
      end
    end
  end

  local dx, dy = tilePos(0, 4)
  drawCentered(images.door, dx, dy)

  for _, col in ipairs({ 3, 6, 9 }) do
    local x, y = tilePos(col, 2)
    drawCentered(images.desk_computer, x, y)
  end
  local px, py = tilePos(10, 1)
  drawCentered(images.plant, px, py)
  local vx, vy = tilePos(9, 1)
  drawCentered(images.vending_machine, vx, vy)
  local b1x, b1y = tilePos(1, 5)
  drawCentered(images.box_stack, b1x, b1y)
  local b2x, b2y = tilePos(2, 6)
  drawCentered(images.box_stack, b2x, b2y)

  drawCentered(images.character_1, avatar.x, avatar.y)
end

function love.draw()
  love.graphics.clear(0.06, 0.08, 0.11)
  if gameState == "menu" then
    drawMenu()
  else
    drawGame()
  end
end