----------------------------------------------------------------------
-- Randomize colors in the palette.
----------------------------------------------------------------------

local spr = app.activeSprite
if not spr then
  return app.alert("There is no active sprite")
end

-- Each Palette:setColor() call will be grouped in one undoable
-- transaction. In this way the Edit > Undo History will contain only
-- one item that can be undone.
app.transaction(
  function()
    math.randomseed(os.time())
    local pal = spr.palettes[1]
    for i = 0,#pal-1 do
      -- Here we change each color of the palette with random RGB
      -- values from 0-255 for each Red, Green, Blue component.
      pal:setColor(i, Color{ r=math.random(256)-1,
                             g=math.random(256)-1,
                             b=math.random(256)-1 })
    end
  end)

-- Here we redraw the screen to show the new palette, in a future this
-- shouldn't be necessary, but just in case...
app.refresh()
