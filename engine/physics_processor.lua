Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PhysicsObject = require "game.physics.physics_object"
Images = require "resource.images"

PhysicsProcessor = Class {
    init = function(self, CollisionProcessor, MovingProcessor, Animator)
        self.CollisionProcessor = CollisionProcessor
        self.MovingProcessor = MovingProcessor
        self.Animator = Animator
        self.objects = {}
        self.layers = {}
    end
}

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
        if findIn(self.layers, name) ~= -1 and findIn( self.layers[layerName].collidedLayers, name) == -1 then
        	table.insert( self.layers[layerName].collidedLayers, name )
    	end
    end
end

function PhysicsProcessor:addActionLayers( layerName, actionLayersNames )
    for _, name in pairs(actionLayersNames) do
        if findIn(self.layers, name) ~= -1 and findIn( self.layers[layerName].actionLayers, name) == -1 then
        	table.insert( self.layers[layerName].actionLayers, name )
    	end
    end
end

function PhysicsProcessor:registerObject( object, layer, type, linkedTo)
	-- Создаётся коллайдер связанный с данным объектом
	table.insert( self.objects, object )
	-- Указывается Тип лейера для коллайдера
	self.collider.layer = layer
	-- Настраивается физичность объекта в соответствии с указанным типом: 

	-- SolidBody - Твёрдый объект, который не подвержен гравитации и не отталкивается - гравитация 0,0, чек на игнор взаимодействий и отталкиваний
	if type == 'SolidBody' then
		PhysicsObject.init( object, { 0, 0 }, 0, false )

	-- RigidBody - тело, подверженное гравитации. Отталкивается. - никаких изменений
	elseif type == 'RigidBody' then
		PhysicsObject.init( object, { 0, 1 }, 10 )

	-- TriggerBody - не подвержено гравитации и не отталкивает. Но регистрирует столкновения - Гравитация 0,0, чек на игнор отталкиваний
	elseif type == 'TriggerBody' then
		PhysicsObject.init( object, { 0, 0 }, 0, false )
	end
	
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
            for ind, secondObject in pairs(self.objects) do
                collidedObject = secondObject.collider == shape and secondObject or collideObject
            end

    		-- Для найденного объекта определить слой и определить находится ли он в группах коллизирующих или взаимодействующих слоёв основного объекта
            if collidedObject then  
    			local collideIndex = findIn(self.layers[object.collider.layer].collidedLayers, collidedObject.collider.layer)
    			-- Если с данным слоем основной объект коллизирует, используем его функцию коллизий или базовую 
  				if collideIndex > -1 and object.isColliding then
  					if object.regiterCollision then
  						object:regiterCollision(object, collideObject, delta)
  					else
  						object:defaultCollisionReaction(object, delta)
  					end
  				end
    			local actionIndex = findIn(self.layers[object.collider.layer].actionLayers, collidedObject.collider.layer)
    			-- Если с данным слоем основной объект взаимодействует, используем его функцию ответочки на взаимодействие
  				if actionIndex > -1 then
  					if object.regiterAction then
                		object:regiterAction(object, collideObject, delta)
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
	MovingProcessor:update( dt )
end

return PhysicsProcessor
