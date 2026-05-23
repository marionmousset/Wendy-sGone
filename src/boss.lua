local love = require("love")

local Boss = {
    level = 1,
    radius = 30,
    life = 20,
    x = 50,
    y = 50,
    speed = 100,

    draw = function (self)
        if self.life > 0 then
            love.graphics.setColor(0.96, 0.12, 0.21)
            love.graphics.circle("fill", self.x, self.y, self.radius)
            love.graphics.setColor(1, 1, 1)
        end
    end,

    move = function (self, player_x, player_y, dt)
        if (player_x - self.x) + 50 > 0 then
            self.x = self.x + self.speed * dt
        elseif (player_x - self.x) - 50 < 0 then
            self.x = self.x - self.speed * dt
        end

        if (player_y - self.y) + 50 > 0 then
            self.y = self.y + self.speed * dt
        elseif (player_y - self.y) - 50 < 0 then
            self.y = self.y - self.speed * dt
        end
    end,

    hit = function (self, bullet_x, bullet_y)
        local dx = bullet_x - self.x
        local dy = bullet_y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance < self.radius + 5 then
            self.life = self.life - 1
            return true
        end
        return false
    end,
}

return Boss
