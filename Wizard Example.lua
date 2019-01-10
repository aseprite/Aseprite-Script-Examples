-- This example shows how to create a sequence of dialogs that are
-- like pages of a wizard-like interface.

-- Create three dialogs, one for each page
local dlg1 = Dialog("Wizard (Step 1)")
local dlg2 = Dialog("Wizard (Step 2)")
local dlg3 = Dialog("Wizard (Step 3)")
local dlgs = { dlg1, dlg2, dlg3 }

local function finalOK()
  print("Data 1 = " .. dlg1.data.data1)
  print("Data 2 = " .. dlg2.data.data2)
  print("Data 3 = " .. dlg3.data.data3)
end

local function cancelWizard(dlg)
  dlg:close()
end

local function prevPage(dlg)
  dlg:close()
  for i = 2,#dlgs do
    if dlg == dlgs[i] then
      local newDlg = dlgs[i-1]
      newDlg.bounds = Rectangle(dlg.bounds.x, dlg.bounds.y,
                                newDlg.bounds.width, newDlg.bounds.height)
      newDlg:show{ wait=false }
      return
    end
  end
end

local function nextPage(dlg)
  dlg:close()
  for i = 1,#dlgs do
    if dlg == dlgs[i] then
      if i == #dlgs then
        finalOK()
      else
        local newDlg = dlgs[i+1]
        newDlg.bounds = Rectangle(dlg.bounds.x, dlg.bounds.y,
                                  newDlg.bounds.width, newDlg.bounds.height)
        newDlg:show{ wait=false }
      end
      return
    end
  end
end

local function addFooter(dlg, first, last)
  dlg:separator()
  if first then
    dlg:button{ text="&Cancel",onclick=function() cancelWizard(dlg) end }
  else
    dlg:button{ text="&Previous",onclick=function() prevPage(dlg) end }
  end

  local nextText
  if last then nextText = "&Finish" else nextText = "&Next" end
  dlg:button{ text=nextText, onclick=function() nextPage(dlg) end }
end

-- Create each dialog with its data fields
dlg1:separator{ text="Page 1" }:entry{ label="Data 1", id="data1" }
dlg2:separator{ text="Page 2" }:entry{ label="Data 2", id="data2" }
dlg3:separator{ text="Page 3" }:entry{ label="Data 3", id="data3" }

-- Create the common buttons on all pages (it's the Previous/Next buttons)
for i = 1,#dlgs do
  addFooter(dlgs[i], (i == 1), (i == #dlgs))
end

dlg1:show{ wait=false }
