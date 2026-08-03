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

function Room:findPath(fromCol, fromRow, toCol, toRow)
  local target = self:getCase(toCol, toRow)
  if not target or not target.walkable then return nil end

  local visited = { [fromCol .. "," .. fromRow] = true }
  local cameFrom = {}
  local queue = { { col = fromCol, row = fromRow } }
  local directions = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }

  local qi = 1
  local found = false
  while qi <= #queue do
    local current = queue[qi]
    qi = qi + 1
    if current.col == toCol and current.row == toRow then
      found = true
      break
    end
    for _, d in ipairs(directions) do
      local nc, nr = current.col + d[1], current.row + d[2]
      local key = nc .. "," .. nr
      local neighbor = self:getCase(nc, nr)
      if neighbor and neighbor.walkable and not visited[key] then
        visited[key] = true
        cameFrom[key] = current
        table.insert(queue, { col = nc, row = nr })
      end
    end
  end

  if not found then return nil end

  local path = {}
  local cur = { col = toCol, row = toRow }
  while not (cur.col == fromCol and cur.row == fromRow) do
    table.insert(path, 1, self:getCase(cur.col, cur.row))
    cur = cameFrom[cur.col .. "," .. cur.row]
  end
  return path
end

return Room