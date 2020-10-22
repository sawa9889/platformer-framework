Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
-- Остаётся только для параметров и базового функционала любого физичного объекта, из него не вызываются upadte и draw всякие
PhysicsObject = Class {
    init = function(self, x, y, gravity, maxSpeed, isColliding)
        self.position    = Vector( x, y )
        self.speed       = Vector( 0, 0 )
        self.gravity     = gravity
        self.deltaVector = Vector( 0, 0 )

        self.isGrounded = false
        self.isColliding = isColliding and isColliding or true

        self.slowDownSpeed = 0.1
        self.maxSpeed      = maxSpeed
        self.maxGroundNormal = 0.05
        self.minGroundNormal = 0.005
        self.minMove         = 0.01
    end
    
}

function defaultCollisionReaction(object, delta)
    object.deltaVector = object.deltaVector + delta
end

return PhysicsObject