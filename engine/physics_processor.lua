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

function PhysicsProcessor:addLayer( newLayer )
    for ind, layer in pairs(self.layers) do
        table.insert( layer.collidedLayers, newLayer.name )
    end
    table.insert( self.layers, newLayer )
end

function PhysicsProcessor:registerLayer( layerName, gravity )
	-- Добавляет в обработчика всех колизий новый слой, с указанной гравитацией и двумя пустыми списками - CollidedLayers, ActionLayers
	local newLayer = {	
					    name = layerName,
					    gravityEnabled = gravity
					    collidedLayers = {},
					    actionLayers = {},
					 }
    for ind, layer in pairs(self.layers) do
        table.insert( newLayer.collidedLayers, layer.name )
    end			 
	self:addLayer(newLayer)
end

function PhysicsProcessor:addCollidedLayers( layerName, collidedLayersNames )
	-- Добавить для слоя слои от которых он отталкивается
    for _, name in pairs(collidedLayersNames) do
    	local index = findIn(self.layers, name)
        if index == -1 then
        	-- Удалить слой из списка
        end
    end
    for _, name in pairs(collidedLayersNames) do
        table.insert( self.layers[layerName].collidedLayers, name )
    end
end

function PhysicsProcessor:addActionLayers( layerName, actionLayersNames )
	-- Добавить для слоя слои с которыми он взаимодействует
    for _, name in pairs(actionLayersNames) do
    	local index = findIn(self.layers, name)
        if index == -1 then
        	-- Удалить слой из списка
        end
    end
    for _, name in pairs(actionLayersNames) do
        table.insert( self.layers[layerName].actionLayers, name )
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

function PhysicsProcessor:CalculateCollisions()
	-- Найти объект с линкованными коллайдерами и пройтись по всем разом, рассчитывая с единым дельта вектором для всех
    for ind, object in pairs(self.objects) do
        local collisions = self.HC:collisions(object.collider)
        for shape, delta in pairs(collisions) do
        	local collidedObject
            for ind, secondObject in pairs(self.objects) do
                collidedObject = secondObject.collider == shape and secondObject or collideObject
            end
            if collidedObject then  
    			local collideIndex = findIn(self.layers[object.collider.layer].collidedLayers, collidedObject.collider.layer)
  				if collideIndex > -1 and object.isColliding then
  					if object.regiterCollision then
  						object:regiterCollision(object, collideObject, delta)
  					else
  						object:defaultCollisionReaction(object, delta)
  					end
  				end
    			local actionIndex = findIn(self.layers[object.collider.layer].actionLayers, collidedObject.collider.layer)
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
	self:CalculateCollisions()
	MovingProcessor:update( dt )
end

return PhysicsProcessor
