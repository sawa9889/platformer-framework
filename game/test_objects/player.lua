Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PhysicsObject = require "engine.physics.physics_object"

Player =
    Class {
    __includes = PhysicsObject,
    init = function(self, x, y, colliderWidth, colliderHeight, hc)      
        self.position = Vector( x, y )
        self.collider = hc:rectangle(self.position.x, self.position.y, colliderWidth, colliderHeight)
        self.acceleration  = 10
        self.slowDownSpeed = 20
        self.jumpSpeed     = 0.5
        PhysicsProcessor:registerObject( self, 'player', 'RigidBody')
    end
}

return Player
