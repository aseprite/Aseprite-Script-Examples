-- This example shows how to create a new sprite stacking all the
-- other sprites each in one layer.

if #app.sprites < 1 then
  return app.alert "You should have at least one sprite opened"
end

local bounds = Rectangle()
for i,sprite in ipairs(app.sprites) do
  bounds = bounds:union(sprite.bounds)
end

local function getTitle(filename)
  return filename:match("^.+/(.+)$")
end

local newSprite = Sprite(bounds.width, bounds.height)
local firstLayer = newSprite.layers[1]
newSprite:deleteCel(newSprite.cels[1])
for i,sprite in ipairs(app.sprites) do
  if sprite ~= newSprite then
    while #newSprite.frames < #sprite.frames do
      newSprite:newEmptyFrame()
    end
    local newLayer = newSprite:newLayer()
    newLayer.name = getTitle(sprite.filename)
    for j,frame in ipairs(sprite.frames) do
      local cel = newSprite:newCel(newLayer, frame)
      cel.image:drawSprite(sprite, frame)
    end
  end
end
newSprite:deleteLayer(firstLayer)
app.activeFrame = 1
