----------------------------------------------------------------------
-- Takes a sprite for a tile sheet and splits
--    each tile onto its own layer.
----------------------------------------------------------------------
local spr = app.activeSprite

-- Checks for a valid sprite
if not spr then
  app.alert("There is no sprite to export")
  return
end

-- Dialog prompt to get dimensions for an individual sprite
local d = Dialog("Split Tiles to Layers")
d:label{ id="help", label="", text="Set the width and height to split tiles by:" }
 :number{ id="tile_w", label="Tile Width:", text="8", focus=true }
 :number{ id="tile_h", label="Tile Height:", text="8" }
 :button{ id="ok", text="&OK", focus=true }
 :button{ text="&Cancel" }
 :show()

-- Data validation
local data = d.data
if not data.ok then return end

--[[
  Tile Splitter Class
  @param {Number} tile_w The width in pixels for an individual tile
  @param {Number} tile_w The height in pixels for an individual tile
  @param {Sprite} spr The sprite sheet to split
  @return {Table} TileSplitter instance
]]--
function TileSplitter(tile_w,tile_h,spr)
  local self = {}
        self.tile_w = tile_w
        self.tile_h = tile_h
        self.spr = spr
  local rows = math.floor(self.spr.height/self.tile_h)
  local cols = math.floor(self.spr.width/self.tile_w)

  --[[
    Copies a single tile to a new layer and names that layer
    @param {Number} row The row of the tile to copy
    @param {Number} col The column of the tile to copy
    @param {Number} count The overall tile number to be copies (used for naming)
  ]]--
  self.copyTileToLayer=function(row, col, count)
    -- Select an area of the current sprite
    spr.selection:select(Rectangle(col*self.tile_w, row*self.tile_h, self.tile_w, self.tile_h))

    -- Copy and paste the selection
    app.command.CopyMerged()
    app.command.NewLayer()
    app.command.Paste()

    -- Rename the layer
    app.activeLayer.name = "Tile "..count

    spr.selection:deselect()
  end

  --[[
    Iterates over each tile in the sheet to paste it onto its own layer.
    Sets the originally active/baselayer invisible once done.
  ]]--
  self.splitTiles=function()
    local baseLayer = app.activeLayer

    local tileCount = 0

    for j = 0,rows-1 do
      for i = 0,cols-1 do
        tileCount = tileCount+1
        self.copyTileToLayer(j,i,tileCount)
      end
    end

    baseLayer.isVisible = false
  end

  return self
end

-- Initializes the splitter for transforming the tilesheet to tiles
local splitter=TileSplitter(data.tile_w, data.tile_h, spr)

-- Call method to split image to tiles as one transaction,
--  allow a single undo
app.transaction(
  function()
    splitter.splitTiles()
end)
