local Player = require("player")
local Enemy = require("src/enemy")
local Boss = require("src/boss")
local Intro = require("intro")
local Checkpoint = require("checkpoint")
local Map = require("map")
local Camera = require("camera")
local Tree = require("tree")

local player
local enemies = {}
local boss
local map
local camera

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
    Tree.load(imageTree, imageMap)  -- <-- passe imageMap ici

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
    table.insert(enemies, 1, Enemy())
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
        local respawn = {x = 100, y = 100}  -- position de départ par défaut
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
        Camera.detach()

        -- UI fixe hors caméra
        love.graphics.print("Balles: " .. player.bulletsLeft .. " / " .. player.bulletsMax, 10, 10)
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