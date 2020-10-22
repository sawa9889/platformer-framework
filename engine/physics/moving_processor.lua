Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
tracks  = require "resource/tracks"

MovingProcessor = Class {
    init = function(self, objects)
        self.objects = objects
    end,
}


function MovingProcessor:update( dt )
    self:setVelocityForFrame(dt)
    self:calcAllCollisionsResult()
    self:move( self.speed )
    self:updateAnimation(dt)
    self.deltaVector = Vector( 0, 0)
end

function MovingProcessor:setVelocityForFrame( dt )
    self:addSpeedInDirection(Vector(0, 0), Vector(0,0), dt)
end

function MovingProcessor:updateAnimation( dt )
    -- Функция для добавления всякого что выполняется после всех действий со скоростью и перемещение, например анимация
end

function MovingProcessor:addSpeedInDirection(acceleration, direction, dt)

    -- Блок накидывания скорости объекту
    local changeSpeedVector = Vector(direction.x * acceleration.x*dt, direction.y * acceleration.y)
    if direction.x * (self.speed.x + changeSpeedVector.x) <= self.maxSpeed then
        self.speed.x = self.speed.x + changeSpeedVector.x
    else
        self.speed.x = direction.x * self.maxSpeed
    end
    self.speed.y = self.speed.y + changeSpeedVector.y

    -- Блок снижения скорости (гравитация и трение о поверхность воздух, вся фигня)
    local slowDownDirection = self.speed.x >= 0 and -1 or 1
    if -slowDownDirection * (self.speed.x + slowDownDirection * self.slowDownSpeed * dt) > 0 then
        self.speed.x = self.speed.x + slowDownDirection * self.slowDownSpeed * dt
    else
        self.speed.x = 0
    end

    if not self.isGrounded then
        self.speed = self.speed + self.gravity * dt
    end
end

function MovingProcessor:move( moveVector )
    self.position = self.position + moveVector
    self.collider:move(moveVector)
end

return MovingProcessor