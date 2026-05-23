local love = require("love")

function Enemy()
    return {
        level = 1,
        radius = 20,
        life = 10,
        x = -10,
        y = -50,

        move = function (self, player_x, player_y)
            if player_x - self.x > 0 then
                self.x = self.x + self.level
            elseif player_x - self.x < 0 then
                self.x = self.x - self.level
            end

            if player_y - self.y > 0 then
                self.y = self.y + self.level
            elseif player_y - self.y < 0 then
                self.y = self.y - self.level
            end
        end,

        draw = function (self)
            if self.life > 0 then
                love.graphics.setColor(1, 0.5, 0.7)
                love.graphics.circle("fill", self.x, self.y, self.radius)
                love.graphics.setColor(1, 1, 1)
            end
        end,

        hit = function (self, bullet_x, bullet_y)
            if bullet_x - (self.x + self.radius) == 0 then -- when the bullet comes from the right
                self.life = self.life - 1
            elseif bullet_x + (self.x - self.radius) == 0 then --when the bullet comes from the left
                self.life = self.life - 1
            elseif bullet_y - (self.y - self.radius) == 0 then  --when the bullet the bottom
                self.life = self.life - 1
            elseif bullet_y + (self.y + self.radius) == 0 then --when the bullet comes from the top
                self.life = self.life - 1
            end
        end,
    }
end

return Enemy