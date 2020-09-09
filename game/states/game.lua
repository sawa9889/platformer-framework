local Bullet = require("game.bullet")

local game = {}

function game:enter()
    self.sprite = AssetManager:getAnimation("player")
    self.sprite:setTag("idle")
    self.sprite:play()
    self.bg = AssetManager:getImage("city_background2")
    MusicPlayer:registerRhythmCallback("bar", function() table.insert(self.bullets, Bullet(40 * 1, 50, 0, 200, 10, {1,0,0})) end)
    MusicPlayer:registerRhythmCallback("onBeat", function() table.insert(self.bullets, Bullet(40 * 2, 50, 0, 200, 5, {0,0,1})) end)
    MusicPlayer:registerRhythmCallback("offBeat", function() table.insert(self.bullets, Bullet(40 * 3, 50, 0, 200, 5, {0,1,0})) end)
    MusicPlayer:registerRhythmCallback("beat", function() table.insert(self.bullets, Bullet(40 * 4, 50, 0, 200, 2, {1,1,0})) end)
    MusicPlayer:registerRhythmCallback("syncopated", function() table.insert(self.bullets, Bullet(40 * 5, 50, 0, 200, 2, {1,0.2,0})) end)
    MusicPlayer:registerRhythmCallback({3}, function() table.insert(self.bullets, Bullet(40 * 1, 50, 0, 200, 10, {1,0,1})) end)
    MusicPlayer:play("level1")
    self.soundA = AssetManager:getSound("jump")
    self.soundA:setVolume(0.1)
    self.soundB = AssetManager:getSound("jump")
    self.soundB:setVolume(0.9)

    self.bullets = {}
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
    if key == "t" then
        MusicPlayer:play("level1", "out-instant")
    end
    if key == "y" then
        MusicPlayer:play("level2", "out-in")
    end
end

function game:draw()
    love.graphics.draw(self.bg)
    self.sprite:draw(10, 10)

    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end

function game:update(dt)
    for _, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end
    love.graphics.setColor({1,1,1})
    self.sprite:update(dt)
end

return game