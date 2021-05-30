----------------------------------------------------------------------
-- It's exactly like the "Merge Down" command but the resulting layer
-- will contain the name of the layer at the top (instead of the
-- bottom one)
----------------------------------------------------------------------

local lay = app.activeLayer
if not lay then return app.alert "There is no active layer" end
app.transaction(
   function()
     local name = app.activeLayer.name
     app.command.MergeDownLayer()
     app.activeLayer.name = name
   end)
