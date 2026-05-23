local Player = require("player")
local Enemy = require("src/enemy")
local Boss = require("src/boss")
local Intro = require("intro")
local Item = require("src/items")
local Checkpoint = require("checkpoint")
local Map = require("map")
local Camera = require("camera")
local Tree = require("tree")

local player
local enemies = {}
local boss
local map
local camera

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

    local imageMap = love.graphics.newImage("map.png")
    map = Map.new(imageMap)
    camera = Camera.new(imageMap:getWidth() * 2, imageMap:getHeight() * 2)

    local imageTree = love.graphics.newImage("tree.png")
    Tree.load(imageTree, imageMap)

    local imageBoots = love.graphics.newImage("boots.png")
    local imageFrogHat = love.graphics.newImage("froghat.png")
    local imageBackpack = love.graphics.newImage("backpack.png")
    local imagePlush = love.graphics.newImage("plush.png")
    checkpointBoots = Checkpoint.new(2800, 800, imageBoots)
    checkpointFrogHat = Checkpoint.new(1200, 1820, imageFrogHat)
    checkpointBackpack = Checkpoint.new(2800, 2850, imageBackpack)
    checkpointPlush = Checkpoint.new(1200, 3300, imagePlush)

    boss = Boss
    enemies = {}
    local spawnPoints = {
        {500, 500}, {800, 500}, {1200, 500}, {1600, 500},
        {2000, 500}, {2400, 500}, {3000, 500}, {3400, 500},
        {1500, 1400}, {2500, 1400}, {1000, 2500}, {2000, 2500},
    }
    for _, pos in ipairs(spawnPoints) do
        table.insert(enemies, Enemy(pos[1], pos[2]))
    end
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
    if Intro.isDone() and not game.state["running"] and not game.state["ended"] then
        startGame()
    end

    if not game.state["running"] then return end
    Player.update(player, dt)
    Player.updateBullets(dt)
    Tree.checkCollision(player)

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
        Player.setBossFight(player, true)
        Player.update(player, dt)
        local left   = love.graphics.getWidth() / 2 - 200
        local right  = love.graphics.getWidth() / 2 + 200 - 50
        local top    = love.graphics.getHeight() / 2 - 100
        local bottom = love.graphics.getHeight() / 2 + 300 - 50
        player.x = math.max(left, math.min(right, player.x))
        player.y = math.max(top, math.min(bottom, player.y))
    end

    if boss and boss.active then
        boss:updateBones(dt, player)
    end

    if player.life <= 0 then
        local checkpoints = {checkpointBoots, checkpointFrogHat, checkpointBackpack, checkpointPlush}
        local respawn = {x = 100, y = 100}
        for i = 1, checkpointsData.count do
            local cp = checkpoints[i]
            if cp then
                respawn.x = cp.x
                respawn.y = cp.y
            end
        end
        player.x = respawn.x
        player.y = respawn.y
        player.life = 50
        player.damageCooldown = 0
    end

    Camera.update(camera, player.x, player.y)
end

function love.draw()
    if Intro.isActive() then
        Intro.draw()
        return
    end
    if game.state["running"] then
        Camera.attach(camera)
            Map.draw(map)
            Tree.draw()
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
        Camera.detach()

        -- flash overlay plein écran
        if player.flashAlpha > 0 then
            love.graphics.setColor(1, 1, 1, player.flashAlpha)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1, 1)
        end

        -- UI fixe hors caméra
        love.graphics.print("Balles: " .. player.bulletsLeft .. " / " .. player.bulletsMax, 10, 10)
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