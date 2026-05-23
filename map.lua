local Map = {}

function Map.new(imageMap)
    local self = {}
    self.image = imageMap
    self.scale = 2  -- zoom x2
    self.x = 0
    self.y = 0
    return self
end

function Map.update(map, dt)
end

function Map.draw(map)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(map.image, map.x, map.y, 0, map.scale, map.scale)
end

return Map