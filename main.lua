local Player = require("player") -- charge player.lua

local player

function love.load()
end

function love.update(dt)
    -- player update
    Player.update(player, dt)
end

function love.draw()
    -- player draw
    Player.draw(player)
end
