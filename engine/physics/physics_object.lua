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

        self.maxSpeed      = maxSpeed
    end,
    maxGroundNormal = 0.05,
    minGroundNormal = 0.005,
    minMove         = 0.01
}

function defaultCollisionReaction(object, delta)
    object.deltaVector = object.deltaVector + delta
end

function PhysicsObject:move( moveVector )
    self.position = self.position + moveVector
    self.collider:move(moveVector)
end

return PhysicsObject