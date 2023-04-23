----------------------------------------------------------------------
-- This example shows how to draw different shapes,
-- using the canvas widget.
----------------------------------------------------------------------

if app.apiVersion < 22 then
    return app.alert("This script requires Aseprite v1.3-rc2")
end

-- This script requires UI
if not app.isUIAvailable then
    return
end

local RegularColor = app.theme.color["text"]
local DisabledColor = app.theme.color["disabled"]

local Shape = {
    None = "",
    Line = "Line",
    Curve = "Curve",
    Triangle = "Triangle",
    Rect = "Rectangle",
    RoundedRect = "Rounded Rectangle",
    Oval = "Oval"
}

local dialog = Dialog("Canvas Shapes Demo")

dialog
:canvas{
    id = "canvas",
    label = "Canvas:",
    width = 160,
    height = 160,
    onpaint = function(ev)
        local gc = ev.context

        -- Declare a local method for drawing reference points using the disabled text color
        local fillReferencePoint = function(point, name)
            local textSize = gc:measureText(name)
            gc.color = DisabledColor

            gc:fillText(name, point.x - textSize.width / 2,
                        point.y - textSize.height - 4)

            gc:beginPath()
            gc:oval(point.x - 4, point.y - 4, 8, 8)
            gc:fill()
        end

        local strokeReferenceRectangle = function(rectangle)
            gc.color = DisabledColor
            gc:beginPath()
            gc:rect(rectangle)
            gc:stroke()
        end

        -- Draw the editor background with a border first
        gc:drawThemeRect("sunken_focused", Rectangle(0, 0, gc.width, gc.height))

        -- Clip to the area withing the drawn editor border
        -- All drawing operations after taht will only draw within the clipping region
        -- This assure that no shape will be drawn over the borders
        gc:beginPath()
        gc:rect(Rectangle(4, 4, gc.width - 8, gc.height - 8))
        gc:clip()

        local p1 = Point(dialog.data["p1-x"], dialog.data["p1-y"])
        local p2 = Point(dialog.data["p2-x"], dialog.data["p2-y"])
        local p3 = Point(dialog.data["p3-x"], dialog.data["p3-y"])

        local rectangle = Rectangle(p1.x, p1.y, dialog.data["width"],
                                    dialog.data["height"])

        local cp1 = Point(dialog.data["cp1-x"], dialog.data["cp1-y"])
        local cp2 = Point(dialog.data["cp2-x"], dialog.data["cp2-y"])

        -- Each shape has it's own code block for drawing
        -- When drawing multiple lines or shapes, `gc:beginPath()` is called to start a new sub-path
        -- This allows us to draw each subpath with different parameters - e.g. color, stroke width  

        if dialog.data.shape == Shape.Line then
            -- Draw the points first
            fillReferencePoint(p1, "P1")
            fillReferencePoint(p2, "P2")

            if dialog.data["parallel-line"] then
                local px = dialog.data["parallel-line-x"]
                local py = dialog.data["parallel-line-y"]

                gc.color = DisabledColor
                gc:beginPath()
                gc:moveTo(p1.x + px, p1.y + py)
                gc:lineTo(p2.x + px, p2.y + py)
                gc:stroke()
            end

            if dialog.data["perpendicular-line"] then
                -- Calculate the center of the line
                local cx = p1.x + ((p2.x - p1.x) / 2)
                local cy = p1.y + ((p2.y - p1.y) / 2)

                fillReferencePoint(Point(cx, cy), "")

                local ppx = cx - p1.x
                local ppy = cy - p1.y

                -- Draw the perpendicular line
                gc.color = DisabledColor
                gc:beginPath()
                gc:moveTo(cx + ppy, cy - ppx)
                gc:lineTo(cx - ppy, cy + ppx)
                gc:stroke()
            end

            -- Draw the line
            gc.color = RegularColor
            gc.strokeWidth = 2
            gc:beginPath()
            gc:moveTo(p1.x, p1.y)
            gc:lineTo(p2.x, p2.y)
            gc:stroke()
        elseif dialog.data.shape == Shape.Curve then
            -- Draw the points and control points first
            fillReferencePoint(p1, "P1")
            fillReferencePoint(p2, "P2")
            fillReferencePoint(cp1, "CP1")
            fillReferencePoint(cp2, "CP2")

            -- Draw the lines connecting to the control points
            gc.color = DisabledColor
            gc:beginPath()
            gc:moveTo(p1.x, p1.y)
            gc:lineTo(cp1.x, cp1.y)
            -- Calling `gc:moveTo` makes the sub-path jump to a new point without creating a line
            -- This way we can draw these two separate lines with a single `gc:stroke()` call
            gc:moveTo(p2.x, p2.y) 
            gc:lineTo(cp2.x, cp2.y)
            gc:stroke()

            -- Draw the curve
            gc.color = RegularColor
            gc.strokeWidth = 2
            gc:beginPath()
            gc:moveTo(p1.x, p1.y)
            gc:cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, p2.x, p2.y)
            gc:stroke()
        elseif dialog.data.shape == Shape.Triangle then
            -- Draw the points first
            fillReferencePoint(p1, "P1")
            fillReferencePoint(p2, "P2")
            fillReferencePoint(p3, "P3")

            -- Draw the triangle
            gc.color = RegularColor
            gc.strokeWidth = 2
            gc:beginPath()
            gc:moveTo(p1.x, p1.y)
            gc:lineTo(p2.x, p2.y)
            gc:lineTo(p3.x, p3.y)
            -- Calling `gc:closePath` connects draws a line between the last point (P3) and the first on (P1)
            gc:closePath()
            gc:stroke()
        elseif dialog.data.shape == Shape.Rect then
            -- Draw the point first
            fillReferencePoint(p1, "P1")

            -- Draw the rectangle
            gc.color = RegularColor
            gc.strokeWidth = 2
            gc:beginPath()
            gc:rect(rectangle)
            gc:stroke()
        elseif dialog.data.shape == Shape.RoundedRect then
            -- Draw the point first
            fillReferencePoint(p1, "P1")

            -- Draw the bounding rectangle for reference
            strokeReferenceRectangle(rectangle)

            -- Draw the rounded rectangle
            gc.color = RegularColor
            gc.strokeWidth = 2
            gc:beginPath()
            gc:roundedRect(rectangle, dialog.data["radius-x"],
                           dialog.data["radius-y"])
            gc:stroke()
        elseif dialog.data.shape == Shape.Oval then
            -- Draw the point first
            fillReferencePoint(p1, "P1")

            -- Draw the bounding rectangle for reference
            strokeReferenceRectangle(rectangle)

            -- Draw the oval, using the regular text color
            gc.color = RegularColor
            gc.strokeWidth = 2
            gc:beginPath()
            gc:oval(rectangle)
            gc:stroke()
        end
    end
}
:combobox{
    id = "shape",
    label = "Shape:",
    option = Shape.None,
    options = {
        Shape.None, Shape.Line, Shape.Curve, Shape.Triangle, Shape.Rect,
        Shape.RoundedRect, Shape.Oval
    },
    onchange = function()
        local shape = dialog.data.shape

        local usesP1 = shape == Shape.Line or shape == Shape.Curve or shape ==
                           Shape.Triangle or shape == Shape.Rect or shape ==
                           Shape.RoundedRect or shape == Shape.Oval
        local usesP2 = shape == Shape.Line or shape == Shape.Curve or shape ==
                           Shape.Triangle
        local usesP3 = shape == Shape.Triangle
        local usesControlPoints = shape == Shape.Curve
        local usesWidth = shape == Shape.Rect or shape == Shape.RoundedRect or
                              shape == Shape.Oval
        local usesHeight = shape == Shape.Rect or shape == Shape.RoundedRect or
                               shape == Shape.Oval
        local usesRadius = shape == Shape.RoundedRect
        local showParallel = shape == Shape.Line and dialog.data["parallel-line"]

        dialog
        :modify{id = "p1-x", visible = usesP1}
        :modify{id = "p1-y", visible = usesP1}
        :modify{id = "p2-x", visible = usesP2}
        :modify{id = "p2-y", visible = usesP2}
        :modify{id = "p3-x", visible = usesP3}
        :modify{id = "p3-y", visible = usesP3}
        :modify{id = "cp1-x", visible = usesControlPoints}
        :modify{id = "cp1-y", visible = usesControlPoints}
        :modify{id = "cp2-x", visible = usesControlPoints}
        :modify{id = "cp2-y", visible = usesControlPoints}
        :modify{id = "parallel-line", visible = shape == Shape.Line}
        :modify{id = "parallel-line-x", visible = shape == showParallel}
        :modify{id = "parallel-line-y", visible = shape == showParallel}
        :modify{id = "perpendicular-line", visible = shape == Shape.Line}
        :modify{id = "width", visible = usesWidth}
        :modify{id = "height", visible = usesHeight}
        :modify{id = "radius-x", visible = usesRadius}
        :modify{id = "radius-y", visible = usesRadius}

        if shape ~= Shape.None then dialog:repaint() end
    end
}
:slider{
    id = "p1-x",
    label = "P1 (X/Y):",
    min = 0,
    max = 160,
    value = 80,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "p1-y",
    min = 0,
    max = 160,
    value = 20,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "p2-x",
    label = "P2 (X/Y):",
    min = 0,
    max = 160,
    value = 20,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "p2-y",
    min = 0,
    max = 160,
    value = 140,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "p3-x",
    label = "P3 (X/Y):",
    min = 0,
    max = 160,
    value = 140,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "p3-y",
    min = 0,
    max = 160,
    value = 140,
    visible = false,
    onchange = function() dialog:repaint() end
}
:check{
    id = "parallel-line",
    label = "Parallel:",
    text = "Show",
    selected = false,
    visible = false,
    onclick = function()
        dialog
        :modify{id = "parallel-line-x", visible = dialog.data["parallel-line"]}
        :modify{id = "parallel-line-y", visible = dialog.data["parallel-line"]}

        dialog:repaint()
    end
}
:slider{
    id = "parallel-line-x",
    label = "Shift (X/Y):",
    min = -80,
    max = 80,
    value = 10,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "parallel-line-y",
    min = -80,
    max = 80,
    value = 10,
    visible = false,
    onchange = function() dialog:repaint() end
}
:check{
    id = "perpendicular-line",
    label = "Perpendicular:",
    text = "Show",
    selected = false,
    visible = false,
    onclick = function() dialog:repaint() end
}
:slider{
    id = "cp1-x",
    label = "CP1 (X/Y):",
    min = 0,
    max = 160,
    value = 20,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "cp1-y",
    min = 0,
    max = 160,
    value = 20,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "cp2-x",
    label = "CP2 (X/Y):",
    min = 0,
    max = 160,
    value = 140,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "cp2-y",
    min = 0,
    max = 160,
    value = 140,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "width",
    label = "Width:",
    min = 0,
    max = 160,
    value = 120,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "height",
    label = "Height:",
    min = 0,
    max = 160,
    value = 80,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "radius-x",
    label = "Radius (X/Y):",
    min = 0,
    max = 160,
    value = 10,
    visible = false,
    onchange = function() dialog:repaint() end
}
:slider{
    id = "radius-y",
    min = 0,
    max = 160,
    value = 10,
    visible = false,
    onchange = function() dialog:repaint() end
}

dialog:show()
