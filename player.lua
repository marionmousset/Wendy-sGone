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
end

return Player