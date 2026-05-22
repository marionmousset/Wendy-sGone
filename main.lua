local Player = require("player") -- charge player.lua
local Enemy = require("src/enemy") -- charge enemy.lua

local player

local enemies = {}

local game = {
    difficulty = 1,
    state = {
        menu = false,
        paused = false,
        running = true,
        ended = false,
    }
}

function love.load()
    player = Player.new(100, 100) -- x, y

    table.insert(enemies, 1, Enemy());
end

function love.update(dt)
    -- player update
    Player.update(player, dt)

    for i = 1, #enemies do
        enemies[i]:move(player.x, player.y)
    end
end

function love.draw()
    -- player draw
    if game.state["running"] then
        Player.draw(player)
        for i = 1, #enemies do
            enemies[i]:draw()
        end
    end
end

function love.keypressed(key)
    if key == "e" then
        Player.interaction(player)
    end

    if key == "space" then
        Player.shoot(player)
    end
end
