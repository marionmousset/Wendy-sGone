local Player = {}

local message = "interaction !"
local interactionActivated = false

local bullets = {}

function Player.new(x, y)
    local self = {}
    self.x = x
    self.y = y
    self.speed = 200 -- pixels per seconds
    self.facing  = "right"
    return self
end

function Player.interaction(player)
    interactionActivated = true
    -- interaction
end

function Player.shoot(player)
    local dirX, dirY = 0, 0
    local bx = player.x + 25  -- centre du joueur
    local by = player.y + 25

    if player.facing == "right" then dirX = 1
    elseif player.facing == "left" then dirX = -1
    elseif player.facing == "down" then dirY = 1
    elseif player.facing == "up" then dirY = -1
    end

    table.insert(bullets, {
        x = bx, y = by,
        dx = dirX * 400,
        dy = dirY * 400
    })
end

function Player.updateBullets(dt)
    print("nb balles: " .. #bullets)
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        if b.x < 0 or b.x > 800 or b.y < 0 or b.y > 600 then
            table.remove(bullets, i)
        end
    end
end

function Player.update(player, dt)
    -- gauche / droite
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
        player.facing = "right"
    elseif love.keyboard.isDown("q") then
        player.x = player.x - player.speed *dt
        player.facing = "left"
    end

    -- bas / haut
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
        player.facing = "down"
    elseif love.keyboard.isDown("z") then
        player.y = player.y - player.speed *dt
        player.facing = "up"
    end
end

function Player.drawBullets()
    love.graphics.setColor(1, 1, 0)
    for _, b in ipairs(bullets) do
        love.graphics.circle("fill", b.x, b.y, 5)
    end
    love.graphics.setColor(1, 1, 1)
end

function Player.draw(player)
    love.graphics.setColor(0.2, 0.7, 1)
    love.graphics.rectangle("fill", player.x, player.y, 50, 50)
    if (interactionActivated == true) then
        love.graphics.print(message, 100, 100)
    end

    if (player.facing == "right") then
        love.graphics.circle("fill", player.x + 50, player.y + 25, 25)
    elseif (player.facing == "left") then
        love.graphics.circle("fill", player.x, player.y + 25, 25)
    elseif (player.facing == "up") then
        love.graphics.circle("fill", player.x + 25, player.y, 25)
    elseif (player.facing == "down") then
        love.graphics.circle("fill", player.x + 25, player.y + 50, 25)
    end
    love.graphics.setColor(1, 1, 1)
end

return Player