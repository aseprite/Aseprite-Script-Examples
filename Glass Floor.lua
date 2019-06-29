----------------------------------------------------------------------
-- Creates a new layer that looks like a glass floor flattening the
-- selected layers in the timeline.
----------------------------------------------------------------------

do
  local spr = app.activeSprite
  if not spr then return app.alert "There is no active sprite" end

  app.transaction(
    function()
      local bounds = Rectangle()
      local layers = app.range.layers
      local newLayer = spr:newLayer()
      newLayer.name = "Glass Floor"
      newLayer.opacity = 128

      for _,frame in ipairs(spr.frames) do
        for _,layer in ipairs(layers) do
          local img = Image(spr.spec)
          for _,l in ipairs(layers) do
            local layerCel = l:cel(frame)
            if layerCel then
              img:drawImage(layerCel.image, layerCel.position)
              bounds = bounds:union(layerCel.bounds)
            end
          end

          spr:newCel(newLayer, frame, img, Point(0, 0))
        end
      end

      local oldFrame = app.activeFrame
      app.activeLayer = newLayer
      for _,cel in ipairs(newLayer.cels) do
        app.activeFrame = cel.frame
        app.command.Flip{ target="mask", orientation="vertical" }
        cel.position = Point(cel.position.x,
                             cel.position.y + 2*(bounds.y + bounds.height - spr.height/2))
      end
      app.activeFrame = oldFrame
    end)
end
