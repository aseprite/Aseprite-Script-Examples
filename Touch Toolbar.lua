----------------------------------------------------------------------
-- A customizable toolbar that can be useful in touch-like devices
-- (e.g. on a Microsoft Surface).
--
-- Feel free to add new commands and modify it as you want.
----------------------------------------------------------------------

local dlg = Dialog("Touch Toolbar")
dlg
  :button{text="Undo",onclick=function() app.command.Undo() end}
  :button{text="Redo",onclick=function() app.command.Redo() end}
  :button{text="|<",onclick=function() app.command.GotoFirstFrame() end}
  :button{text="<",onclick=function() app.command.GotoPreviousFrame() end}
  :button{text=">",onclick=function() app.command.GotoNextFrame() end}
  :button{text=">|",onclick=function() app.command.GotoLastFrame() end}
  :button{text="+",onclick=function() app.command.NewFrame() end}
  :button{text="-",onclick=function() app.command.DeleteFrame() end}
  :show{wait=false}
