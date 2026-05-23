local love = require("love")

local bossMusic = nil

local Boss = {
    level = 1,
    radius = 30,
    life = 50,
    x = 50,
    y = 50,
    speed = 100,
    active = false,
    bones = {},
    phase = 1,
    phaseTimer = 0,
    phaseDurations = { 8, 12, 15, 20, 70},
    boneTimer = 0,
    boneIntervals = { 1.9, 1.7, 1.5, 1, 0.5 },
    boneSpeeds    = { 200, 280, 360, 440, 460 },
    boneCounts    = { 1, 1, 2, 3, 4 },

    draw = function (self)
        if self.life > 0 then
            love.graphics.setColor(0.96, 0.12, 0.21)
            love.graphics.circle("fill", self.x, self.y, self.radius)
            love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 200, love.graphics.getHeight() / 2 - 100, 400, 400)
            love.graphics.setColor(1, 1, 1)
        end
    end,

    updatePhase = function(self, dt)
        self.phaseTimer = self.phaseTimer + dt
        if self.phase < 5 and self.phaseTimer >= self.phaseDurations[self.phase] then
            self.phase = self.phase + 1
            self.phaseTimer = 0
            print("Phase " .. self.phase) -- debug
            if self.phase == 5 then
                bossMusic = love.audio.newSource("fightofyourlife.mp3", "stream")
                bossMusic:setLooping(true)
                love.audio.play(bossMusic)
            end
        end
    end,

    spawnBone = function(self)
        local speed = self.boneSpeeds[self.phase]
        local side = math.random(1, 4)
        local arenaX = love.graphics.getWidth() / 2 - 200
        local arenaY = love.graphics.getHeight() / 2 - 100
        local bone = {}

        if side == 1 then
            bone = { x = 0, y = math.random(arenaY, arenaY + 400), dx = speed, dy = 0, w = 20, h = 10 }
        elseif side == 2 then
            bone = { x = love.graphics.getWidth(), y = math.random(arenaY, arenaY + 400), dx = -speed, dy = 0, w = 20, h = 10 }
        elseif side == 3 then
            bone = { x = math.random(arenaX, arenaX + 400), y = 0, dx = 0, dy = speed, w = 10, h = 20 }
        elseif side == 4 then
            bone = { x = math.random(arenaX, arenaX + 400), y = love.graphics.getHeight(), dx = 0, dy = -speed, w = 10, h = 20 }
        end

        table.insert(self.bones, bone)
    end,

    updateBones = function(self, dt, player)
        self:updatePhase(dt)

        if self.phase <= 5 and self.phaseTimer < self.phaseDurations[5] then
        self.boneTimer = self.boneTimer + dt
        if self.boneTimer >= self.boneIntervals[self.phase] then
            for k = 1, self.boneCounts[self.phase] do
                self:spawnBone()
            end
            self.boneTimer = 0
        end
    end

        local arenaX = love.graphics.getWidth() / 2 - 200
        local arenaY = love.graphics.getHeight() / 2 - 100

        for i = #self.bones, 1, -1 do
            local b = self.bones[i]
            b.x = b.x + b.dx * dt
            b.y = b.y + b.dy * dt

            if b.x < player.x + 50 and b.x + b.w > player.x and
                   b.y < player.y + 50 and b.y + b.h > player.y then
                player.life = player.life - 1
                table.remove(self.bones, i)
            end
        end
    end,

    drawBones = function(self)
        love.graphics.setColor(1, 1, 1)
        for _, b in ipairs(self.bones) do
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
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
}

return Boss
