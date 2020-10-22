Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PhysicsObject = require "engine.physics.physics_object"

PhysicsProcessor = Class {
    init = function(self, HC)
        self.HC = HC
        self.globalGravity = Vector( 0, 0.05)
        self.objects = {}
        self.layers = {}
        self.objectsTypes = {}
    end
}

function PhysicsProcessor:addType(typeName, newType )
    self.objectsTypes[typeName] = newType 
end

function PhysicsProcessor:registerObjectType( typeName, gravity, maxSpeed, isColliding  )
    local newType = {   
        gravity = gravity and gravity or self.globalGravity,
        maxSpeed = maxSpeed and maxSpeed or 10,
        isColliding = isColliding and isColliding or true,
    }
    self:addType(typeName, newType)
end


function PhysicsProcessor:allLayerNames()
    local newCollidedLayers = {}
    for ind, layer in pairs(self.layers) do
        table.insert( newCollidedLayers, layer.name )
    end
    return newCollidedLayers
end

function PhysicsProcessor:addLayer(layerName, newLayer )
    self.layers[layerName] = newLayer 
end

function PhysicsProcessor:registerLayer( layerName, gravity )
    -- Добавляет в обработчика всех колизий новый слой, с указанной гравитацией и двумя пустыми списками - CollidedLayers, ActionLayers
    local newLayer = {  
                        gravityEnabled = gravity and gravity or true,
                        collidedLayers = {},
                        actionLayers = {},
                     }
    self:addLayer(layerName, newLayer)
end

function PhysicsProcessor:addCollidedLayers( layerName, collidedLayersNames )
    for _, name in pairs(collidedLayersNames) do
        if isIn(self.layers, name) and not isIn( self.layers[layerName].collidedLayers, name) then
            table.insert( self.layers[layerName].collidedLayers, name )
        end
    end
end

function PhysicsProcessor:addActionLayers( layerName, actionLayersNames )
    for _, name in pairs(actionLayersNames) do
        if isIn(self.layers, name) and not isIn( self.layers[layerName].actionLayers, name)then
            table.insert( self.layers[layerName].actionLayers, name )
        end
    end
end

function PhysicsProcessor:registerObject( object, x, y, layer, type, linkedTo)
    -- Добавляется объект в список физичных объектов
    table.insert( self.objects, object )
    -- Указывается Тип лейера для коллайдера
    object.collider.layer = layer
    -- Настраивается физичность объекта в соответствии с указанным типом: 

    -- SolidBody - Твёрдый объект, который не подвержен гравитации и не отталкивается - гравитация 0,0, чек на игнор взаимодействий и отталкиваний
    -- RigidBody - тело, подверженное гравитации. Отталкивается. - никаких изменений

    PhysicsObject.init( object, x, y, 
                        self.objectsTypes[type].gravity, 
                        self.objectsTypes[type].maxSpeed, 
                        self.objectsTypes[type].isColliding )
    -- По сути инитится PhysicsObject в нужном объекте с указанными параметрами
end

function PhysicsProcessor:destroyObject( object )
    self.HC:remove(object.collider)
    table.remove(self.objects, getIndex(self.objects, object))
end

function PhysicsProcessor:calculateCollisions()
-- Найти объект с линкованными коллайдерами и пройтись по всем разом, рассчитывая с единым дельта вектором для всех
    for ind, object in pairs(self.objects) do
        -- Взять все коллизии объекта
        local collisions = self.HC:collisions(object.collider)
        for shape, delta in pairs(collisions) do
            -- Найти объект с которым сколлизировал среди зарегистрированных
            local collidedObject
            for ind, physicsObject in pairs(self.objects) do
                collidedObject = physicsObject.collider == shape and physicsObject or collidedObject
            end
            -- Для найденного объекта определить слой и определить находится ли он в группах коллизирующих или взаимодействующих слоёв основного объекта
            if collidedObject then
                -- Если с данным слоем основной объект коллизирует, используем его функцию коллизий или базовую 
                if isIn(self.layers[object.collider.layer].collidedLayers, collidedObject.collider.layer) and object.isColliding then
                    if object.regiterCollision then
                        object.registerCollision(object, collidedObject, delta)
                    else
                        defaultCollisionReaction(object, delta)
                    end
                end
                if isIn(self.layers[object.collider.layer].actionLayers, collidedObject.collider.layer) then
                    
                    if object.registerAction then
                        object.registerAction(object, collidedObject, delta)
                    end
                end
            end
        end
    end
end

------------------------------------------------------Moving Processor
function PhysicsProcessor:moveAllObjects(dt)
    for ind, object in pairs(self.objects) do 
        self:addAcceleration(object, Vector(0, 0)) 
        self:collisionsResult(object)
        self:move(object, object.speed)
        object.deltaVector = Vector( 0, 0)
    end
end

function PhysicsProcessor:move(object, moveVector )
    object.position = object.position + moveVector
    object.collider:move(moveVector)
end

function PhysicsProcessor:addAcceleration(object, acceleration)
    -- Блок накидывания скорости объекту
    if (object.speed.x + acceleration.x) <= object.maxSpeed then
        object.speed.x = object.speed.x + acceleration.x
    else
        object.speed.x = direction.x * object.maxSpeed
    end
    object.speed.y = object.speed.y + acceleration.y

    -- Блок снижения скорости (гравитация и трение о поверхность воздух, вся фигня)
    local slowDownDirection = object.speed.x >= 0 and -1 or 1
    if -slowDownDirection * (object.speed.x + slowDownDirection * object.slowDownSpeed ) > 0 then
        object.speed.x = object.speed.x + slowDownDirection * object.slowDownSpeed
    else
        object.speed.x = 0
    end

    if not object.isGrounded and object.speed.y <= object.maxSpeed  then
        object.speed = object.speed + object.gravity
    end
end

function PhysicsProcessor:collisionsResult(object)
    if math.abs(object.deltaVector.x) > object.maxGroundNormal then
        self:move(object, Vector(object.deltaVector.x/2,0))
    end

    if math.abs(object.deltaVector.y) > object.maxGroundNormal then
        
        object.speed.y = (object.speed.y < 0 or object.deltaVector.y < 0) and 0 or self.speed.y
        self:move(object, Vector(0,object.deltaVector.y/2))
        object.isGrounded = object.deltaVector.y < -object.minGroundNormal
    end
    
    if math.abs(object.deltaVector.y) < object.minGroundNormal and self.isGrounded then
        object.isGrounded = false
    end  
end


function PhysicsProcessor:update( dt )

    -- Производится вызов трёх отдельны модулей:
    -- Модуль просчёта взаимодействия объектов
    -- Модуль движения всех объектов зарегистрированных в игре
    -- Модуль действий с анимацией
    self:calculateCollisions()
    self:moveAllObjects(dt)
    --self.movingProcessor:update( dt )
end

return PhysicsProcessor
