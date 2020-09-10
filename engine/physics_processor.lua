Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PhysicsObject = require "game.physics.physics_object"
Images = require "resource.images"

PhysicsProcessor = Class {
    init = function(self, movingProcessor)
        self.movingProcessor = MovingProcessor
        self.globalGravity = Vector( 0, 1)
        self.objects = {}
        self.layers = {}
        self.objectsTypes = {}
    end
}

function PhysicsProcessor:addType( newType )
    table.insert( self.objectsTypes, newType )
end

function PhysicsProcessor:registerObjectType( typeName, gravity, maxSpeed, isColliding  )
	local newType = {	
					    name = typeName,
					    gravity = gravity and gravity or self.globalGravity
					    maxSpeed = maxSpeed and maxSpeed or 10,
					    isColliding = isColliding and isColliding or true,
					 }
	self:addLayer(newType)
end


function PhysicsProcessor:allLayerNames()
	local newCollidedLayers = {}
    for ind, layer in pairs(self.layers) do
    	table.insert( newCollidedLayers, layer.name )
    end
    return newCollidedLayers
end

function PhysicsProcessor:addLayer( newLayer )
    table.insert( self.layers, newLayer )
end

function PhysicsProcessor:registerLayer( layerName, gravity )
	-- Добавляет в обработчика всех колизий новый слой, с указанной гравитацией и двумя пустыми списками - CollidedLayers, ActionLayers
	local newLayer = {	
					    name = layerName,
					    gravityEnabled = gravity and gravity or true
					    collidedLayers = {},
					    actionLayers = {},
					 }
	self:addLayer(newLayer)
end

function PhysicsProcessor:addCollidedLayers( layerName, collidedLayersNames )
    for _, name in pairs(collidedLayersNames) do
        if not isIn(self.layers, name) and isIn( self.layers[layerName].collidedLayers, name) then
        	table.insert( self.layers[layerName].collidedLayers, name )
    	end
    end
end

function PhysicsProcessor:addActionLayers( layerName, actionLayersNames )
    for _, name in pairs(actionLayersNames) do
        if not isIn(self.layers, name) and isIn( self.layers[layerName].actionLayers, name)then
        	table.insert( self.layers[layerName].actionLayers, name )
    	end
    end
end

function PhysicsProcessor:registerObject( object, layer, type, linkedTo)
	-- Добавляется объект в список физичных объектов
	table.insert( self.objects, object )
	-- Указывается Тип лейера для коллайдера
	self.collider.layer = layer
	-- Настраивается физичность объекта в соответствии с указанным типом: 

	-- SolidBody - Твёрдый объект, который не подвержен гравитации и не отталкивается - гравитация 0,0, чек на игнор взаимодействий и отталкиваний
	-- RigidBody - тело, подверженное гравитации. Отталкивается. - никаких изменений
	PhysicsObject.init( object, self.objectsTypes[type].gravity, self.objectsTypes[type].maxSpeed, self.objectsTypes[type].isColliding )
	-- По сути инитится PhysicsObject в нужном объекте с указанными параметрами
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
                collidedObject = physicsObject.collider == shape and physicsObject or collideObject
            end

    		-- Для найденного объекта определить слой и определить находится ли он в группах коллизирующих или взаимодействующих слоёв основного объекта
            if collidedObject then  
    			-- Если с данным слоем основной объект коллизирует, используем его функцию коллизий или базовую 
  				if isIn(self.layers[object.collider.layer].collidedLayers, collidedObject.collider.layer) and object.isColliding then
  					if object.regiterCollision then
  						object.regiterCollision(object, collideObject, delta)
  					else
  						object.defaultCollisionReaction(object, delta)
  					end
  				end
  				if isIn(self.layers[object.collider.layer].actionLayers, collidedObject.collider.layer) then
  					if object.registerAction then
                		object.registerAction(object, collideObject, delta)
                	end
  				end
            end
        end
    end
end

function PhysicsProcessor:update( dt )

	-- Производится вызов трёх отдельны модулей:
	-- Модуль просчёта взаимодействия объектов
	-- Модуль движения всех объектов зарегистрированных в игре
	-- Модуль действий с анимацией
	self:calculateCollisions()
	self.movingProcessor:update( dt )
end

return PhysicsProcessor
