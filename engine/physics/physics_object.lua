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
    minMove		    = 0.01
}

function defaultCollisionReaction(object, delta)
    object.deltaVector = object.deltaVector + delta
end

function PhysicsObject:move( moveVector )
    self.position = self.position + moveVector
    self.collider:move(moveVector)
end

-- function PhysicsObject:addSpeedInDirection(acceleration, direction, dt)

--     -- Блок накидывания скорости объекту
--     local changeSpeedVector = Vector(direction.x * acceleration.x*dt, direction.y * acceleration.y)
--     if direction.x * (self.speed.x + changeSpeedVector.x) <= self.maxSpeed then
--         self.speed.x = self.speed.x + changeSpeedVector.x
--     else
--         self.speed.x = direction.x * self.maxSpeed
--     end
--     self.speed.y = self.speed.y + changeSpeedVector.y

--     -- Блок снижения скорости (гравитация и трение о поверхность воздух, вся фигня)
--     local slowDownDirection = self.speed.x >= 0 and -1 or 1
--     if -slowDownDirection * (self.speed.x + slowDownDirection * self.slowDownSpeed * dt) > 0 then
--         self.speed.x = self.speed.x + slowDownDirection * self.slowDownSpeed * dt
--     else
--         self.speed.x = 0
--     end

--     if not self.isGrounded then
--         self.speed = self.speed + self.gravity * dt
--     end
-- end

-- function PhysicsObject:calcAllCollisionsResult()
    
--     if math.abs(self.deltaVector.x) > self.maxGroundNormal then
--         self:move(Vector(self.deltaVector.x/2,0))
--     end

--     if math.abs(self.deltaVector.y) > self.maxGroundNormal then
        
--         self.speed.y = (self.speed.y < 0 or self.deltaVector.y < 0) and 0 or self.speed.y
--         self:move(Vector(0,self.deltaVector.y/2))
--         self.isGrounded = self.deltaVector.y < -self.minGroundNormal
--     end
    
--     if math.abs(self.deltaVector.y) < self.minGroundNormal and self.isGrounded then
--         self.isGrounded = false
--     end

--     self:additionalCollide()
    
-- end

return PhysicsObject