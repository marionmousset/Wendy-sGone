local Player = require("player") -- charge player.lua
local Enemy = require("src/enemy") -- charge enemy.lua
local Boss = require("src/boss") -- charge boss.lua

local player

local enemies = {}

local boss

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

    boss = Boss

    table.insert(enemies, 1, Enemy());
end

function love.update(dt)
    -- player update
    Player.update(player, dt)
    Player.updateBullets(dt)

    for i = 1, #enemies do
        enemies[i]:move(player.x, player.y)
    end
    boss:move(player.x, player.y)
end

function love.draw()
    -- player draw
    if game.state["running"] then
        Player.draw(player)
        Player.drawBullets()
        for i = 1, #enemies do
            enemies[i]:draw()
        end
        boss:draw()
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
