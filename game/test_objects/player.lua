Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PhysicsObject = require "engine.physics.physics_object"

Player =
Class {
    init = function(self, x, y, hc)     
        self.collider = hc:rectangle(self.position.x, self.position.y, 10, 12)
        self.acceleration  = 10
        self.slowDownSpeed = 20
        self.jumpSpeed     = 0.5
        PhysicsProcessor:registerObject( self, x, y, 'player', 'RigidBody')
    end
}

return Player
