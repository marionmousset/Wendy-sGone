local Checkpoint = {}

function Checkpoint.new(x, y, imageCheckpoint)
    local self = {}
    self.x = x
    self.y = y
    self.image = imageCheckpoint
    self.scaleX = 62 / self.image:getWidth()
    self.scaleY = 62 / self.image:getHeight()
    self.show = true
    return self
end

function Checkpoint.changeCheckpointData(checkpointData)
    checkpointData = checkpointData + 1
end

function Checkpoint.update(checkpoint, dt)
end

function Checkpoint.draw(checkpoint)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(checkpoint.image, checkpoint.x, checkpoint.y, 0, checkpoint.scaleX, checkpoint.scaleY, checkpoint.image:getWidth()/2, checkpoint.image:getHeight()/2)
end

return Checkpoint