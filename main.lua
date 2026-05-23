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
    love.window.setMode(1920, 1080)
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
    if #enemies == 0 then
        boss.active = true

        Player.update(player, dt)

        local left   = love.graphics.getWidth() / 2 - 200
        local right  = love.graphics.getWidth() / 2 + 200 - 50
        local top    = love.graphics.getHeight() / 2 - 100
        local bottom = love.graphics.getHeight() / 2 + 300 - 50

        player.x = math.max(left, math.min(right,  player.x))
        player.y = math.max(top, math.min(bottom, player.y))
    end
    if boss and boss.active then
        boss:updateBones(dt, player)
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
        if boss and boss.active then
            boss:draw()
            boss:drawBones()
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
