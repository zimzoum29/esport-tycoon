local Locale = {}
Locale.__index = Locale

function Locale.new()
  local self = setmetatable({}, Locale)
  self.rooms = {}
  self.currentRoom = nil
  return self
end

function Locale:addRoom(room)
  self.rooms[room.id] = room
  if not self.currentRoom then
    self.currentRoom = room
  end
end

function Locale:getCurrentRoom()
  return self.currentRoom
end

function Locale:switchTo(roomId)
  local room = self.rooms[roomId]
  if room then
    self.currentRoom = room
  end
  return self.currentRoom
end

return Locale