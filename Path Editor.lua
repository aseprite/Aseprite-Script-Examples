local PointRadius = 5

-- Use the theme colors
local RegularColor = app.theme.color["text"]
local HighlightColor = app.theme.color["selected"]

local dialog = Dialog("Path Editor Example")

-- Hold mouse position in a variable
local mouse = Point(0, 0)

local points = {}
local grabbedPoint = nil

local lines = {}
local lineStart = nil

local get_distance = function(a, b)
    return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
end

local find_close_point = function(available_points, target_point, distance)
    for index, point in ipairs(available_points) do
        if get_distance(point, target_point) < distance then
            return index, point
        end
    end
end

local onpaint = function(ev)
    local context = ev.context

    -- Use the anti-aliasing option from the dialog
    context.antialias = dialog.data["antialias"]

    -- Draw the beckground of the editor first
    context:drawThemeRect("sunken_focused",
                          Rectangle(0, 0, context.width, context.height))

    -- Draw the new line with the highlight color
    if lineStart then
        context.color = HighlightColor

        context:beginPath()
        context:moveTo(lineStart.x, lineStart.y)
        context:lineTo(mouse.x, mouse.y)
        context:stroke()
    end

    -- Draw all lines
    for _, line in ipairs(lines) do
        context.color = RegularColor

        context:beginPath()
        context:moveTo(line.startPoint.x, line.startPoint.y)
        context:lineTo(line.endPoint.x, line.endPoint.y)
        context:stroke()
    end

    -- Draw all points
    for _, point in ipairs(points) do
        context:beginPath()

        -- Shift X and Y to draw the shape around the point
        local pointShape = Rectangle {
            x = point.x - PointRadius,
            y = point.y - PointRadius,
            width = PointRadius * 2,
            height = PointRadius * 2
        }

        context:roundedRect(pointShape, PointRadius, PointRadius)

        local isMouseOver = get_distance(mouse, point) < PointRadius
        local isLineStart = point == lineStart

        -- Highlight points close to the mouse position and ones that are a start of a new line
        if isMouseOver or isLineStart then
            context.color = HighlightColor
            context:fill()
        else
            context.color = RegularColor
            context:stroke()
        end
    end
end

local onmouseup = function(ev)
    local hoverPointIndex, hoverPoint = find_close_point(points, mouse,
                                                         PointRadius)

    if ev.button == MouseButton.LEFT then
        if lineStart and hoverPoint and hoverPoint ~= lineStart then
            local newLine = {startPoint = lineStart, endPoint = hoverPoint}
            table.insert(lines, newLine)
        end

        if ev.ctrlKey then
            local newPoint = {x = ev.x, y = ev.y}
            table.insert(points, newPoint)
        end

        grabbedPoint = nil
        lineStart = nil
    end

    if ev.button == MouseButton.RIGHT then
        if hoverPoint then
            table.remove(points, hoverPointIndex)

            local newLines = {}

            for _, line in ipairs(lines) do
                if line.startPoint ~= hoverPoint and line.endPoint ~= hoverPoint then
                    table.insert(newLines, line)
                end
            end

            lines = newLines
        end
    end

    dialog:repaint()
end

local onmousemove = function(ev)
    -- Save the delta from the previous mouse position, this will be used to move the grabbed point
    local delta = Point(ev.x - mouse.x, ev.y - mouse.y)

    -- Update the last, saved mouse position
    mouse = Point(ev.x, ev.y)

    -- Find the first, close point
    local _, hoverPoint = find_close_point(points, mouse, PointRadius)

    if ev.button == MouseButton.LEFT then
        if ev.shiftKey then
            if not lineStart and hoverPoint then
                lineStart = hoverPoint
            end
        else
            if grabbedPoint then
                grabbedPoint.x = grabbedPoint.x + delta.x
                grabbedPoint.y = grabbedPoint.y + delta.y
            elseif hoverPoint then
                grabbedPoint = hoverPoint
            end
        end
    end

    -- This could be optimized to only repaint the dialog when something changes
    -- For now the dialog is redrawn every time the mouse moves over it
    dialog:repaint()
end

dialog
:canvas{
    width = 200,
    height = 200,
    label = "Canvas:",
    onpaint = onpaint,
    onmouseup = onmouseup,
    onmousemove = onmousemove
}
:check{
    id = "antialias",
    label = "Anti-aliasing:",
    onclick = function() dialog:repaint() end
}
:separator{text = "Instructions:"}
:label{
    label = "Left-click:",
    text = "Move",
    enabled = false
}
:label{
    label = "Left-click + Ctrl:",
    text = "Add",
    enabled = false
}
:label{
    label = "Left-click + Shift:",
    text = "Connect",
    enabled = false
}
:label{
    label = "Right-click:",
    text = "Delete",
    enabled = false
}
:separator()
:button{
    text = "&Cancel",
    focus = true
}

dialog:show{wait = false}
