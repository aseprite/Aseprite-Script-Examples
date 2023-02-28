----------------------------------------------------------------------
-- This example shows how to create custom widgets using the canvas.
---------------------------------------------------------------------

local dlg = Dialog("Custom Widgets")

local mouse = {position = Point(0, 0), leftClick = false}

local focusedWidget = nil

local customButton = {
    bounds = Rectangle(5, 5, 80, 40),
    state = {
        normal = {part = "button_normal", color = "button_normal_text"},
        hot = {part = "button_hot", color = "button_hot_text"},
        selected = {part = "button_selected", color = "button_selected_text"},
        focused = {part = "button_focused", color = "button_normal_text"}
    },
    text = "Custom Button",
    onclick = function() print("Clicked <Custom Button>") end
}

local doubleButtonLeft = {
    bounds = Rectangle(5, 50, 60, 20),
    state = {
        normal = {
            part = "drop_down_button_left_normal",
            color = "button_normal_text"
        },
        hot = {part = "drop_down_button_left_hot", color = "button_hot_text"},
        selected = {
            part = "drop_down_button_left_selected",
            color = "button_selected_text"
        },
        focused = {
            part = "drop_down_button_left_focused",
            color = "button_normal_text"
        }
    },
    text = "Search",
    onclick = function() print("Clicked <Search Button Left>") end
}

local doubleButtonRight = {
    bounds = Rectangle(65, 50, 20, 20),
    state = {
        normal = {
            part = "drop_down_button_right_normal",
            color = "button_normal_text"
        },
        hot = {part = "drop_down_button_right_hot", color = "button_hot_text"},
        selected = {
            part = "drop_down_button_right_selected",
            color = "button_selected_text"
        },
        focused = {
            part = "drop_down_button_right_focused",
            color = "button_normal_text"
        }
    },
    icon = "tool_zoom",
    onclick = function() print("Clicked <Search Button Right>") end
}

local sunkenMagicWand = {
    bounds = Rectangle(90, 5, 65, 65),
    state = {
        normal = {part = "sunken_normal", color = "button_normal_text"},
        selected = {part = "sunken_focused", color = "button_normal_text"},
        focused = {part = "sunken_focused", color = "button_normal_text"}
    },
    icon = "tool_magic_wand",
    onclick = function() print("Clicked <Sunken Magic Wand>") end
}

local customWidgets = {
    customButton, doubleButtonLeft, doubleButtonRight, sunkenMagicWand
}

dlg:canvas{
    id = "canvas",
    width = 160,
    height = 75,
    onpaint = function(ev)
        local ctx = ev.context

        -- Draw each custom widget
        for _, widget in ipairs(customWidgets) do
            local state = widget.state.normal

            if widget == focusedWidget then
                state = widget.state.focused
            end

            local isMouseOver = widget.bounds:contains(mouse.position)

            if isMouseOver then
                state = widget.state.hot or state

                if mouse.leftClick then
                    state = widget.state.selected
                end
            end

            ctx:drawThemeRect(state.part, widget.bounds)

            local center = Point(widget.bounds.x + widget.bounds.width / 2,
                                 widget.bounds.y + widget.bounds.height / 2)

            if widget.icon then
                -- Assuming default icon size of 16x16 pixels
                local size = Rectangle(0, 0, 16, 16)

                ctx:drawThemeImage(widget.icon, center.x - size.width / 2,
                                   center.y - size.height / 2)
            elseif widget.text then
                local size = ctx:measureText(widget.text)

                ctx.color = app.theme.color[state.color]
                ctx:fillText(widget.text, center.x - size.width / 2,
                             center.y - size.height / 2)
            end
        end
    end,
    onmousemove = function(ev)
        -- Update the mouse position
        mouse.position = Point(ev.x, ev.y)

        dlg:repaint()
    end,
    onmousedown = function(ev)
        -- Update information about left mouse button being pressed
        mouse.leftClick = ev.button == MouseButton.LEFT

        dlg:repaint()
    end,
    onmouseup = function(ev)
        -- When releasing left mouse button over a widget, call `onclick` method
        if mouse.leftClick then
            for _, widget in ipairs(customWidgets) do
                local isMouseOver = widget.bounds:contains(mouse.position)

                if isMouseOver then
                    widget.onclick()

                    -- Last clicked widget has focus on it
                    focusedWidget = widget
                end
            end
        end

        -- Update information about left mouse button being released
        mouse.leftClick = false

        dlg:repaint()
    end
}

dlg:show{wait = false}
