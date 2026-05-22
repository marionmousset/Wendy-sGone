local Player = {}

function Player.new(x, y)
    local self = {}
    self.x = x
    self.y = y
    self.speed = 200 -- pixels per seconds
    return self
end

function Player.update(player, dt)
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    elseif love.keyboard.isDown("q") then
        player.x = player.x - player.speed *dt
    end

    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    elseif love.keyboard.isDown("z") then
        player.y = player.y - player.speed *dt
    end
end

function Player.draw(player)
    love.graphics.setColor(0.2, 0.7, 1)
    love.graphics.rectangle("fill", player.x, player.y, 50, 50)
end

-- function love.keypressed(key)
--     message = key .. " was pressed!"
-- end

-- function love.draw()
--     love.graphics.print(message, 100, 100)
-- end

return Player