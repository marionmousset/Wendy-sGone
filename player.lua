local Player = {}

-- position of rectangle (main charactere)
local x = 100
local y = 100

local speed  = 200 -- pixels per seconds

function Player.update(player, dt)
    if love.keyboard.isDown("d") then
        x = x + speed * dt
    elseif love.keyboard.isDown("q") then
        x = x - speed *dt
    end

    if love.keyboard.isDown("s") then
        y = y + speed * dt
    elseif love.keyboard.isDown("z") then
        y = y - speed *dt
    end
end

function Player.draw(player)
    love.graphics.setColor(0.2, 0.7, 1)
    love.graphics.rectangle("fill", x, y, 50, 50)
end

-- function love.keypressed(key)
--     message = key .. " was pressed!"
-- end

-- function love.draw()
--     love.graphics.print(message, 100, 100)
-- end

return Player