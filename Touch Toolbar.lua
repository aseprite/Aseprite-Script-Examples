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
