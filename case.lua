local Case = {}
Case.__index = Case

function Case.new(col, row, x, y, walkable)
  local self = setmetatable({}, Case)
  self.col = col
  self.row = row
  self.x = x
  self.y = y
  self.walkable = walkable
  self.occupant = nil
  return self
end

return Case