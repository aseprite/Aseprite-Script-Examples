-- Export each tag into a different sprite sheet

local spr = app.activeSprite
if not spr then return print('No active sprite') end

local path,title = spr.filename:match("^(.+[/\\])(.-).([^.]*)$")
local msg = { "Do you want to export/overwrite the following files?" }

for i,tag in ipairs(spr.tags) do
  local fn = path .. title .. '-' .. tag.name
  table.insert(msg, '-' .. fn .. '.[png|json]')
end

if app.alert{ title="Export Sprite Sheets", text=msg,
              buttons={ "&Yes", "&No" } } ~= 1 then
  return
end

for i,tag in ipairs(spr.tags) do
  local fn = path .. '/' .. title .. '-' .. tag.name
  app.command.ExportSpriteSheet{
    ui=false,
    type=SpriteSheetType.HORIZONTAL,
    textureFilename=fn .. '.png',
    dataFilename=fn .. '.json',
    dataFormat=SpriteSheetDataFormat.JSON_ARRAY,
    tag=tag.name,
    listLayers=false,
    listTags=false,
    listSlices=false,
  }
end
