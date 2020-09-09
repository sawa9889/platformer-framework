Class = require "lib.hump.class"
Vector = require "lib.hump.vector"

Bullet = Class { -- TODO: I am temporary - delete me
    init = function(self, x, y, dx, dy, size, color)
        self.position = Vector(x, y)
        self.speed = Vector(dx, dy)
        self.size = size
        self.color = color
    end
}

function Bullet:update(dt)
    self.position = self.position + self.speed * dt
end

function Bullet:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.position.x, self.position.y, self.size) 
end

return Bullet
