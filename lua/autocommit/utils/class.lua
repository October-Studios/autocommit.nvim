-- Adapted from https://github.com/rxi/classic/blob/master/classic.lua
local Object = {}

Object.__index = Object

-- luacheck: push no unused args
function Object:init(...) end
-- luacheck: pop

function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find('__') == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end

-- luacheck: push no unused args
function Object:__tostring()
  return 'Object'
end
-- luacheck: pop

function Object:new(...)
  local obj = setmetatable({}, self)
  obj:init(...)
  return obj
end

function Object:__call(...)
  return self:new(...)
end

return Object
