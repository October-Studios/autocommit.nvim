-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local autocommit_require = require('autocommit_require')
local require = autocommit_require.require

local component_t = {
  mod = function(component)
    local ok, loaded_component = pcall(require, 'autocommit.' .. component[1])
    if ok then
      component.component_name = component[1]
      if type(loaded_component) == 'table' then
        loaded_component = loaded_component(component)
      elseif type(loaded_component) == 'function' then
        component[1] = loaded_component
      end
      return loaded_component
    end
  end,
}

local function component_loader(component)
  local loaded_component = component_t.mod(component)
  if loaded_component then
    return loaded_component
  end
end

local function load_table(comp)
  local component = { comp }
  component_loader(component)
end

return {
  load_table = load_table,
}
