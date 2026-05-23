local Player = require("player")
local Enemy = require("src/enemy")
local Boss = require("src/boss")
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
    },
    anubis = false
}

local buttons = {
    { label = "Accept", x = 300, y = 400, w = 120, h = 40 },
    { label = "Refuse", x = 500, y = 400, w = 120, h = 40 },
}

local choiceMade = false
local imgAnubis1 = nil
local imgAnubis2 = nil
local imgRefuse1 = nil
local imgRefuse2 = nil
local imgRefuse3 = nil
local imgBeforeChoice = nil
local slideIndex = 1
local slideTimer = 0
local slideDuration = 3
local selectedBtn = 1

local function isHovered(btn)
    local mx, my = love.mouse.getPosition()
    return mx > btn.x and mx < btn.x + btn.w and
           my > btn.y and my < btn.y + btn.h
end

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

    imgBeforeChoice = love.graphics.newImage("anubis.png")
    imgAnubis1 = love.graphics.newImage("perdu1.png")
    imgAnubis2 = love.graphics.newImage("perdu2.png")
    imgRefuse1 = love.graphics.newImage("gagne1.png")
    imgRefuse2 = love.graphics.newImage("gagne2.png")
    imgRefuse3 = love.graphics.newImage("gagne3.png")
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

    if game.state["ended"] and choiceMade then
        slideTimer = slideTimer + dt
        if slideTimer >= slideDuration then
            slideTimer = 0
            slideIndex = slideIndex + 1
        end
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
        if not boss.active then
            if checkpointBackpack.show then Checkpoint.draw(checkpointBackpack) end
            if checkpointPlush.show then Checkpoint.draw(checkpointPlush) end
            if checkpointBoots.show then Checkpoint.draw(checkpointBoots) end
            if checkpointFrogHat.show then Checkpoint.draw(checkpointFrogHat) end
            love.graphics.print("Balles: " .. player.bulletsLeft .. " / " .. player.bulletsMax, 10, 10)
            for i = 1, #enemies do
                enemies[i]:draw()
            end
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
        local W = love.graphics.getWidth()
        local H = love.graphics.getHeight()

        if not choiceMade then
            local img = imgBeforeChoice
            local scaleX = W / img:getWidth()
            local scaleY = H / img:getHeight()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(img, 0, 0, 0, scaleX, scaleY)
            for _, btn in ipairs(buttons) do
                if isHovered(btn) then
                    love.graphics.setColor(0.8, 0.8, 0.8)
                else
                    love.graphics.setColor(0.5, 0.5, 0.5)
                end
                love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(btn.label, btn.x + 10, btn.y + 10)
            end
        else
            local slides
            if game.anubis then
                slides = { imgAnubis1, imgAnubis2 }
            else
                slides = { imgRefuse1, imgRefuse2, imgRefuse3 }
            end
            if slideIndex <= #slides then
                local img = slides[slideIndex]
                local scaleX = W / img:getWidth()
                local scaleY = H / img:getHeight()
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(img, 0, 0, 0, scaleX, scaleY)
            end
        end
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
    if key == "left" or key == "right" then
        if game.state["ended"] and not choiceMade then
            if selectedBtn == 1 then
                selectedBtn = 2
            else
                selectedBtn = 1
            end
        end
    end

    if key == "return" then
        if game.state["ended"] and not choiceMade then
            local btn = buttons[selectedBtn]
            if btn.label == "Accept" then
                game.anubis = true
                choiceMade = true
            elseif btn.label == "Refuse" then
                game.anubis = false
                choiceMade = true
            end
        end
    end
end