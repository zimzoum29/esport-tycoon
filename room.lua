local Case = require("case")

local Room = {}
Room.__index = Room

function Room.new(config)
  local self = setmetatable({}, Room)
  self.id = config.id
  self.cols = config.cols
  self.rows = config.rows
  self.tile = config.tile
  self.originX = config.originX
  self.originY = config.originY
  self.grid = {}

  for row = 0, self.rows - 1 do
    self.grid[row] = {}
    for col = 0, self.cols - 1 do
      local x = self.originX + col * self.tile + self.tile / 2
      local y = self.originY + row * self.tile + self.tile / 2
      local isBorder = row == 0 or row == self.rows - 1 or col == 0 or col == self.cols - 1
      self.grid[row][col] = Case.new(col, row, x, y, not isBorder)
    end
  end

  return self
end

function Room:getCase(col, row)
  local rowData = self.grid[row]
  return rowData and rowData[col]
end

function Room:getCaseAtPixel(px, py)
  local col = math.floor((px - self.originX) / self.tile)
  local row = math.floor((py - self.originY) / self.tile)
  return self:getCase(col, row)
end

function Room:placeProp(col, row, assetName)
  local case = self:getCase(col, row)
  if case then
    case.occupant = assetName
    case.walkable = false
  end
end

return Room