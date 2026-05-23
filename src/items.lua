local love = require("love")

local love = require("love")

function Item(type, x, y)
    return {
        type = type,  -- "alcohol" ou "pill"
        x = x,
        y = y,
        radius = 10,
        collected = false,
        imgAlcohol = love.graphics.newImage("beer.png"),
        imgPill = love.graphics.newImage("pill.png"),

        draw = function(self)
            local img
            local scaleX
            local scaleY
            if not self.collected then
                if self.type == "alcohol" then
                    img = self.imgAlcohol
                    scaleX = 64 / img:getWidth()
                    scaleY = 64 / img:getHeight()
                    love.graphics.draw(img, self.x, self.y, 0, scaleX, scaleY, img:getWidth()/2, img:getHeight()/2)
                else
                    img = self.imgPill
                    scaleX = 64 / img:getWidth()
                    scaleY = 64 / img:getHeight()
                    love.graphics.draw(img, self.x, self.y, 0, scaleX, scaleY, img:getWidth()/2, img:getHeight()/2)
                end
            end
        end,

        checkPickup = function(self, player_x, player_y)
            local dx = player_x + 25 - self.x
            local dy = player_y + 25 - self.y
            local dist = math.sqrt(dx * dx + dy * dy)
            return dist < self.radius + 25
        end,
    }
end

return Item
