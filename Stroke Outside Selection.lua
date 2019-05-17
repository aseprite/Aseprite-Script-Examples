----------------------------------------------------------------------
-- Stroke the border outside the selection
----------------------------------------------------------------------

local spr = app.activeSprite
if not spr then return end

local sel = spr.selection
if sel.isEmpty then return end

local oldSelection = Selection()
oldSelection:add(sel)   -- TODO we should have a Selection(sel) way to copy selections

app.transaction(
  function()
    app.command.ModifySelection{ modifier="expand", quantity=1, brush="circle" }
    app.command.ModifySelection{ modifier="border", quantity=1 }
    app.command.Stroke()

    -- Restore the old selection
    spr.selection = oldSelection
  end)

app.refresh()
