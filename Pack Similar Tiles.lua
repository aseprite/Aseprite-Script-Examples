----------------------------------------------------------------------
-- Takes similar tiles from the given current sprite and convert it into
-- two sprites:
-- 1) One sprite will be the tilemap, an indexed sprite where each
--    pixel is a reference to the tileset
-- 2) Other sprite will be the tileset, where each tile grid is a
--    portion of the original sprite
----------------------------------------------------------------------

local spr = app.activeSprite
if not spr then
  app.alert("There is no sprite to export")
  return
end

local d = Dialog("Pack Similar Tiles")
d:number{ id="tile_w", label="Tile Width:", text="16", focus=true }
 :number{ id="tile_h", label="Tile Height:", text="16" }
 :number{ id="sheet_w", label="Sprite Sheet Width:", text="256" }
 :button{ id="ok", text="&OK", focus=true }
 :button{ text="&Cancel" }
 :show()

local data = d.data
if not data.ok then return end

local tile_w = data.tile_w
local tile_h = data.tile_h
local sheet_w = data.sheet_w

-- We will extract tiles from the active frame of the active sprite
local img = Image(spr.spec)
img:clear()
img:drawSprite(spr, app.activeFrame)

local tiles_w = img.width / tile_w
local tiles_h = img.height / tile_h

-- "images" will be an array with unique tiles, we use the addTile()
-- function to add a new tile if it doesn't matches any of the
-- existent tiles in the array.
local images = { }
local function addTile(newTileImg)
  for i,v in ipairs(images) do
    if v:isEqual(newTileImg) then
      return i -- Return the existent tile index that matches the "newTileImg"
    end
  end
  -- In this case this "newTileImg" is really a new unknown tile, so
  -- we add it and return the index of it.
  table.insert(images, newTileImg)
  return #images
end

-- Returns a possible color that could represent the given "img" tile
-- in the tilemap. It calculates the average RGB values from the four
-- corners of the tile.
local function getAvgTileColor(img)
  local pc = app.pixelColor
  local corners = { img:getPixel(0, 0),
                    img:getPixel(img.width-1, 0),
                    img:getPixel(0, img.height-1),
                    img:getPixel(img.width-1, img.height-1) }
  if img.colorMode == ColorMode.INDEXED then
    for i = 1,4 do
      local c = spr.palettes[1]:getColor(corners[i])
      corners[i] = pc.rgba(c.red, c.green, c.blue)
    end
  elseif img.colorMode == ColorMode.GRAY then
    for i = 1,4 do
      local v = pc.grayaV(corners[i])
      corners[i] = pc.rgba(v, v, v)
    end
  end
  local avg = { r=0, g=0, b=0 }
  for i,c in ipairs(corners) do
    avg.r = avg.r + pc.rgbaR(c)
    avg.g = avg.g + pc.rgbaG(c)
    avg.b = avg.b + pc.rgbaB(c)
  end
  return Color { r=avg.r/4, g=avg.g/4, b=avg.b/4 }
end

-- "newSprTilemap" will be the tilemap where each pixel is a reference
-- to the tileset.
local newSprTilemap = Sprite(tiles_w, tiles_h, ColorMode.INDEXED)
app.command.BackgroundFromLayer()
local newSprTilemapImage = newSprTilemap.cels[1].image
for j = 0,tiles_h-1 do
  for i = 0,tiles_w-1 do
    local tileImg = Image(tile_w, tile_h, img.colorMode)
    tileImg:putImage(img, -i*tile_w, -j*tile_h)
    local index = addTile(tileImg)
    newSprTilemapImage:putPixel(i, j, index)
  end
end

-- Here we create a pseudo-palette for the tilemap (it's only a
-- palette useful to identify different tiles in the tilemap, but it's
-- not useful for the user)
local pal = newSprTilemap.palettes[1]
if #images >= 1 and #images < 256 then
  pal:resize(#images+1)
end
for i,v in ipairs(images) do
  if i >= #pal then break end
  pal:setColor(i, getAvgTileColor(v))
end

-- Here we create the new sprite sheet with the tiles in "images" array
local sheet_tiles_w = math.floor(sheet_w / tile_w)
local sheet_tiles_h = math.floor(#images / sheet_tiles_w)
if #images / (sheet_tiles_w*sheet_tiles_h) > 0 then
  sheet_tiles_h = sheet_tiles_h+1
end
local sheet_h = sheet_tiles_h * tile_h
local newSprTileset = Sprite(sheet_w, sheet_h, spr.colorMode)
app.command.BackgroundFromLayer()
local sheetImg = Image(newSprTileset.spec)
for i,v in ipairs(images) do
  sheetImg:putImage(v,
                    math.floor((i-1) % sheet_tiles_w) * tile_w,
                    math.floor((i-1) / sheet_tiles_w) * tile_h)
end
newSprTileset:setPalette(spr.palettes[1])
newSprTileset.cels[1].image = sheetImg

if app.apiVersion >= 3 then
  newSprTilemap.filename = "tilemap"
  newSprTileset.filename = "tileset"
end

app.refresh()
