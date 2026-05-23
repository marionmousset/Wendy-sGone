local Camera = {}

function Camera.new(mapWidth, mapHeight)
    local self = {}
    self.x = 0
    self.y = 0
    self.mapWidth = mapWidth
    self.mapHeight = mapHeight
    return self
end

function Camera.update(camera, playerX, playerY)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- centrer sur le joueur
    local cx = playerX - screenW / 2
    local cy = playerY - screenH / 2

    -- clamp pour ne pas sortir de la map
    camera.x = math.max(0, math.min(cx, camera.mapWidth - screenW))
    camera.y = math.max(0, math.min(cy, camera.mapHeight - screenH))
end

function Camera.attach(camera)
    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)
end

-- function Camera.attach(camera)
--     love.graphics.push()
--     local screenW = love.graphics.getWidth()
--     local screenH = love.graphics.getHeight()
--     local scaleX = screenW / camera.mapWidth
--     local scaleY = screenH / camera.mapHeight
--     local scale = math.min(scaleX, scaleY)
--     love.graphics.scale(scale, scale)
-- end

function Camera.detach()
    love.graphics.pop()
end

return Camera