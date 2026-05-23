local love = require("love")

function Enemy()
    return {
        level = 1,
        radius = 20,
        life = 10,
        x = 10,
        y = 50,
        speed = 50,
        img = love.graphics.newImage("enemy.png"),

        move = function (self, player_x, player_y, dt)
            if player_x - self.x > 0 then
                self.x = self.x + self.speed * dt
            elseif player_x - self.x < 0 then
                self.x = self.x - self.speed * dt
            end

            if player_y - self.y > 0 then
                self.y = self.y + self.speed * dt
            elseif player_y - self.y < 0 then
                self.y = self.y - self.speed * dt
            end
        end,

        draw = function (self)
            if self.life > 0 then
                local scaleX = 64 / self.img:getWidth()
                local scaleY = 64 / self.img:getHeight()
                love.graphics.draw(self.img, self.x, self.y, 0, scaleX, scaleY, self.img:getWidth()/2, self.img:getHeight()/2)
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
end

return Enemy