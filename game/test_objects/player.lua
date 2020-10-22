Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PhysicsObject = require "engine.physics.physics_object"

Player =
Class {
    init = function(self, x, y, hc, PhysicsProcessor)     
        self.collider = hc:rectangle(x, y, 35, 25)
        PhysicsProcessor:registerObject( self, x, y, 'player', 'RigidBody')
    end
}


function Player:update( dt )
end

function Player:draw()
    self:drawDebug()
end

function Player:drawDebug()
    -- local x = self.position.x
    -- local y = self.position.y
    -- local width, height = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

    -- love.graphics.setColor(0, 255, 0)
    -- love.graphics.line(x, y, x + self.speed.x * 10, y + self.speed.y * 10)

    love.graphics.setColor(255, 0, 0)
    if self.deltaVector then
        print(self.position, self.deltaVector )
        local normDeltaVector = self.deltaVector:normalized()
        love.graphics.line(
            self.position.x,
            self.position.y,
            self.position.x + normDeltaVector.x * 10,
            self.position.y + normDeltaVector.y * 10
        )
    -- Сделать ещё дебаг
    love.graphics.setColor(0, 0, 255)
        local perpendicularDeltaVector = self.deltaVector:perpendicular():normalized()
        love.graphics.line(
            self.position.x,
            self.position.y,
            self.position.x + perpendicularDeltaVector.x * 10,
            self.position.y + perpendicularDeltaVector.y * 10
        )
    end

    love.graphics.setColor(255, 255, 255)
end


return Player
