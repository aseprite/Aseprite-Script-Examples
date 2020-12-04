-- This example shows how to move the selected cels by a specific delta X/Y value.

local spr = app.activeSprite
if not spr then return app.alert "No active sprite" end

local function contains(array, item)
  for _,value in ipairs(array) do
    if value == item then
      return true
    end
  end
  return false
end

local layers = {}
local cels = {}
for _,cel in ipairs(app.range.cels) do
  if cel.layer.isEditable and
     cel.layer.isVisible then
    if not contains(layers, cel.layer) then
      table.insert(layers, cel.layer)
    end
    table.insert(cels, cel)
  end
end

local dlg = Dialog("Move Cels")
dlg:label{ text="Selected Layers: " .. #layers }:newrow()
   :label{ text="Selected Cels: " .. #cels }
   :entry{ id="x", label="X", text="0", focus=true }
   :entry{ id="y", label="Y", text="0" }
   :button{ id="ok", text="OK", focus=true }
   :button{ text="Cancel" }
dlg:show()

local data = dlg.data
if data.ok then
  app.transaction(
    function()
      local delta = { x=tonumber(data.x), y=tonumber(data.y) }
      for _,cel in ipairs(cels) do
        cel.position = Point(cel.position.x + delta.x,
                             cel.position.y + delta.y)
      end
    end)
end
