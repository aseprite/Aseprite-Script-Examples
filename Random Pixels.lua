----------------------------------------------------------------------
-- Randomize pixels of the active cel/image.
--
-- It works for all color modes (RGB/GRAY/INDEXED).
----------------------------------------------------------------------

if app.apiVersion < 1 then
  return app.alert("This script requires Aseprite v1.2.10-beta3")
end

local cel = app.activeCel
if not cel then
  return app.alert("There is no active image")
end

math.randomseed(os.time())

-- The best way to modify a cel image is to clone it (the new cloned
-- image will be an independent image, without undo information).
-- Then we can change the cel image generating only one undoable
-- action.
local img = cel.image:clone()

-- For RGB mode we change the RGB values keeping the Alpha value intact
if img.colorMode == ColorMode.RGB then
  local rgba = app.pixelColor.rgba
  local rgbaA = app.pixelColor.rgbaA
  for it in img:pixels() do
    it(rgba(math.random(256)-1,
            math.random(256)-1,
            math.random(256)-1, rgbaA(it())))
  end
-- For GRAY mode we change the grayscale value keeping the Alpha value intact
elseif img.colorMode == ColorMode.GRAY then
  local graya = app.pixelColor.graya
  local grayaA = app.pixelColor.grayaA
  for it in img:pixels() do
    it(graya(math.random(256)-1, grayaA(it())))
  end
-- For INDEXED mode we change the color index of non-transparent
-- pixels with a ranom index that is not transparent too
elseif img.colorMode == ColorMode.INDEXED then
  local n = #app.activeSprite.palettes[1]
  if n > 2 then
    local mask = img.spec.transparentColor
    for it in img:pixels() do
      -- For pixels that are not the mask
      if it() ~= mask then
        -- We try to put a new index value that is not the mask color
        -- (for transparent layers, because the background layer can
        -- have the mask color as a solid color)
        local c = math.random(n)-1
        if cel.layer.isTransparent then
          while c == mask do
            c = math.random(n)-1
          end
        end
        it(c) -- Here we set the pixel value
      end
    end
  end
end

-- Here we change the cel image, this generates one undoable action
cel.image = img

-- Here we redraw the screen to show the modified pixels, in a future
-- this shouldn't be necessary, but just in case...
app.refresh()
