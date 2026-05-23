local love = require("love")

local Boss = {
    level = 1,
    radius = 30,
    life = 20,
    x = 950,
    y = 530,

    draw = function (self)
        love.graphics.setColor(0.96, 0.12, 0.21)
        love.graphics.circle("fill", self.x, self.y, self.radius)
        love.graphics.setColor(1, 1, 1)
    end,

    move = function (self, player_x, player_y)
        if (player_x - self.x) + 50 > 0 then
            self.x = self.x + self.level
        elseif (player_x - self.x) - 50 < 0 then
            self.x = self.x - self.level
        end

        if (player_y - self.y) + 50 > 0 then
            self.y = self.y + self.level
        elseif (player_y - self.y) - 50 < 0 then
            self.y = self.y - self.level
        end
    end,
}

return Boss
