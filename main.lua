local Player = require("player") -- charge player.lua
local Enemy = require("src/enemy") -- charge enemy.lua
local Boss = require("src/boss") -- charge boss.lua
local Intro  = require("intro")
local Items = require("src/items")
local Checkpoint = require("checkpoint")

local player

local enemies = {}

local boss

local items = {}
local checkpointBoots
local checkpointFrogHat
local checkpointBackpack
local checkpointPlush
local checkpointsData = { count = 0, total = 4 }

local game = {
    difficulty = 1,
    state = {
        menu = false,
        paused = false,
        running = false,
        ended = false,
    }
}

local function startGame()
    game.state["running"] = true
    local image = love.graphics.newImage("player.png")
    player = Player.new(100, 100, image)

    local imageBoots = love.graphics.newImage("boots.png")
    local imageFrogHat = love.graphics.newImage("froghat.png")
    local imageBackpack = love.graphics.newImage("backpack.png")
    local imagePlush = love.graphics.newImage("plush.png")
    checkpointBoots = Checkpoint.new(100, 100, imageBoots)
    checkpointFrogHat = Checkpoint.new(300, 300, imageFrogHat)
    checkpointBackpack = Checkpoint.new(500, 500, imageBackpack)
    checkpointPlush = Checkpoint.new(700, 700, imagePlush)

    boss = Boss
    enemies = {}
    table.insert(enemies, 1, Enemy())
    table.insert(items, Item("alcohol", 300, 300))
    table.insert(items, Item("pill", 500, 400))
end

function love.load()
    love.graphics.setDefaultFilter("linear", "linear")
    Intro.load()
end

function love.update(dt)
    if Intro.isActive() then
        Intro.update(dt)
    end
    -- Transition to gameplay the frame the intro finishes
    if Intro.isDone() and not game.state["running"] and not game.state["ended"] then
        startGame()
    end

    if not game.state["running"] then return end
    Player.update(player, dt)
    Player.updateBullets(dt)

    local bullets = Player.getBullets()

    for i = #items, 1, -1 do
        local item = items[i]
        if not item.collected and item:checkPickup(player.x, player.y) then
            if item.type == "alcohol" then
                player.alcohol = math.min(100, player.alcohol + 20)
            elseif item.type == "pill" then
                player.alcohol = math.max(0, player.alcohol - 20)
            end
            item.collected = true
            table.remove(items, i)
        end
    end

    if player.alcohol < 30 then
        player.flashTimer = player.flashTimer + dt
        if player.flashTimer >= player.flashInterval then
            player.flashAlpha = 1
            player.flashInterval = 4 + (player.alcohol / 30) * 5
            player.flashTimer = 0
        end
    end

    if player.flashAlpha > 0 then
        player.flashAlpha = player.flashAlpha - dt * 3
        if player.flashAlpha < 0 then player.flashAlpha = 0 end
    end

    for i = #enemies, 1, -1 do
        enemies[i]:move(player.x, player.y, dt)

        Player.touchingEnemy(player, enemies[i], dt)

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

        boss.active = true
        Player.setBossFight(player, true)

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

    if player.life <= 0 then
        game.state["running"] = false
        game.state["ended"] = true
    end
end

function love.draw()
    if Intro.isActive() then
        Intro.draw()
        return
    end
    if game.state["running"] then
        Player.draw(player)
        Player.drawBullets()
        if checkpointBackpack.show then
            Checkpoint.draw(checkpointBackpack)
        end
        if checkpointPlush.show then
            Checkpoint.draw(checkpointPlush)
        end
        if checkpointBoots.show then
            Checkpoint.draw(checkpointBoots)
        end
        if checkpointFrogHat.show then
            Checkpoint.draw(checkpointFrogHat)
        end
        love.graphics.print("Balles: " .. player.bulletsLeft .. " / " .. player.bulletsMax, 10, 10)
        for i = 1, #enemies do
            enemies[i]:draw()
        end
        if boss and boss.active then
            boss:draw()
            boss:drawBones()
        end
        for _, item in ipairs(items) do
            item:draw()
        end
        love.graphics.print("Alcoolémie: " .. player.alcohol .. "%", 10, 30)
    end

    if game.state["ended"] then
        Player.draw(player)
    end
end

function love.keypressed(key)
    if Intro.isActive() then
        Intro.keypressed(key)
        return
    end
    if key == "e" then
        Player.interaction(player, checkpointBackpack, checkpointBoots, checkpointFrogHat, checkpointPlush, checkpointsData)
    end

    if key == "space" then
        Player.shoot(player)
    end

    if key == "r" then
        Player.reload(player)
    end
end
