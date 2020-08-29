local game = {}

function game:enter()
    self.sprite = AssetManager:getAnimation("player")
    self.sprite:setTag("idle")
    self.sprite:play()
    self.bg = AssetManager:getImage("city_background2")
    self.music = AssetManager:getSound("barroom_ballet")
    self.music:play()
    self.music:setVolume(0.5)
    self.music:setLooping(true)
    self.soundA = AssetManager:getSound("jump")
    self.soundA:setVolume(0.1)
    self.soundB = AssetManager:getSound("jump")
    self.soundB:setVolume(0.9)
end

function game:mousepressed(x, y)
end

function game:mousereleased(x, y)
end

function game:keypressed(key)
    if key == "z" then
        self.soundA:play()
    end
    if key == "x" then
        self.soundB:play()
    end
end

function game:draw()
    love.graphics.draw(self.bg)
    self.sprite:draw(10, 10)
end

function game:update(dt)
    self.sprite:update(dt)
end

return game