local Player = {}

local message = "interaction !"
local interactionActivated = false

local bullets = {}

function Player.new(x, y, imagePlayer)
    local self = {}
    self.x = x
    self.y = y
    self.speed = 200 -- pixels per seconds
    self.facing  = "right"
    self.image = imagePlayer
    self.scaleX = 128 / self.image:getWidth()
    self.scaleY = 128 / self.image:getHeight()
    self.life = 50
    self.damageCooldown = 0
    self.bulletsMax = 10
    self.bulletsLeft = 10
    self.reloading = false
    self.alcohol = 20
    self.flashTimer = 0
    self.flashInterval = 3
    self.flashAlpha = 0
    self.imageBoss = love.graphics.newImage("skull.png")
    self.isBossFight = false
    return self
end

function Player.setBossFight(player, active)
    player.isBossFight = active
end

function Player.interaction(player)
    interactionActivated = true
    -- interaction
end

function Player.reload(player)
    if player.reloading then return end
    player.bulletsLeft = player.bulletsMax
end

function Player.shoot(player)
    if player.bulletsLeft <= 0 or player.reloading then return end

    local baseAngles = {
        right = 0,
        left  = math.pi,
        down  = math.pi / 2,
        up    = -math.pi / 2
    }

    local angle = baseAngles[player.facing]
    local spread = math.rad(20)

    local angles = {
        angle - spread,
        angle,
        angle + spread
    }

    for _, a in ipairs(angles) do
        table.insert(bullets, {
            x = player.x,
            y = player.y,
            dx = math.cos(a) * 400,
            dy = math.sin(a) * 400
        })
    end

    player.bulletsLeft = player.bulletsLeft - 1
end

function Player.updateBullets(dt)
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        if b.x < 0 or b.x > 1920 or b.y < 0 or b.y > 1080 then
            table.remove(bullets, i)
        end
    end
end

function Player.touchingEnemy(player, enemy, dt)
    local px = player.x  -- déjà le centre car image centrée
    local py = player.y
    local dx = px - enemy.x
    local dy = py - enemy.y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance < enemy.radius + 30 then  -- rayon ennemi + rayon joueur
        if player.damageCooldown <= 0 then
            player.life = player.life - 10
            player.damageCooldown = 1
            print("TOUCHE ! life: " .. player.life)
        end
        return true
    end
    return false
end

function Player.update(player, dt)
    if player.damageCooldown > 0 then
        player.damageCooldown = player.damageCooldown - dt
    end

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
    local img
    if player.isBossFight then
        img = player.imageBoss
        player.scaleX = 64 / img:getWidth()
        player.scaleY = 64 / img:getHeight()
    else
        img = player.image
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, player.x, player.y, 0, player.scaleX, player.scaleY, img:getWidth()/2, img:getHeight()/2)
    -- love.graphics.setColor(0.2, 0.7, 1)
    -- love.graphics.rectangle("fill", player.x, player.y, 50, 50)
    if (interactionActivated == true) then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(message, 100, 100)
    end
    love.graphics.setColor(1, 1, 1)
    -- if (player.facing == "right") then
    --     love.graphics.circle("fill", player.x + 50, player.y + 25, 25)
    -- elseif (player.facing == "left") then
    --     love.graphics.circle("fill", player.x, player.y + 25, 25)
    -- elseif (player.facing == "up") then
    --     love.graphics.circle("fill", player.x + 25, player.y, 25)
    -- elseif (player.facing == "down") then
    --     love.graphics.circle("fill", player.x + 25, player.y + 50, 25)
    -- end
    if player.flashAlpha > 0 then
        love.graphics.setColor(1, 1, 1, player.flashAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.setColor(1, 1, 1)
end

function Player.getBullets()
    return bullets
end

return Player