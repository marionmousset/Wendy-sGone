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
    local image = love.graphics.newImage("player.png")
    player = Player.new(100, 100, image)

    boss = Boss

    table.insert(enemies, 1, Enemy());
end

function love.update(dt)
    Player.update(player, dt)
    Player.updateBullets(dt)

    local bullets = Player.getBullets()

    for i = #enemies, 1, -1 do
        enemies[i]:move(player.x, player.y, dt)

        for j = #bullets, 1, -1 do
            if enemies[i]:hit(bullets[j].x, bullets[j].y) then
                table.remove(bullets, j)
                break
            end
        end

        if enemies[i].life <= 0 then
            table.remove(enemies, i)
        end
    end

    for i = #bullets, 1, -1 do
        if boss and boss:hit(bullets[i].x, bullets[i].y) then
            table.remove(bullets, i)
            break
        end
        if boss and boss.life == 0 then
            boss = nil
        end
    end
    if boss then
        boss:move(player.x, player.y, dt)
    end
end

function love.draw()
    -- player draw
    if game.state["running"] then
        Player.draw(player)
        Player.drawBullets()
        for i = 1, #enemies do
            enemies[i]:draw()
        end
        if boss then
            boss:draw()
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
