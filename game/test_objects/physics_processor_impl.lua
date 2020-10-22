Class = require "lib.hump.class"

PhysicsProcessorImpl = Class {
    __includes = PhysicsProcessor,
    init = function(self, HC)
        PhysicsProcessor.init(self, HC)

        self:registerLayer('player')
        self:registerLayer('terrain')
        self:registerObjectType('SolidBody', Vector(0, 0), 0, false )
        self:registerObjectType('RigidBody', nil, 2, true)

        self:addCollidedLayers( 'player', { 'terrain' } )
        print('123')
    end,
}

return PhysicsProcessorImpl 