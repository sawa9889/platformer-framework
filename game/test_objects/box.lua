Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PhysicsObject = require "engine.physics.physics_object"

Box =
Class {
    init = function(self, x, y, width, height, hc, PhysicsProcessor)     
        self.collider = hc:rectangle(x, y, width, height)
        PhysicsProcessor:registerObject( self, x, y, 'terrain', 'SolidBody')
    end
}

function Box:update( dt )
end

function Box:draw()
end

function Box:drawDebug()
end

return Box
