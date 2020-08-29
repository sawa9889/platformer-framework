require "conf"
require "engine.utils"

Debug = require "engine.debug"
serpent = require "lib.debug.serpent"

StateManager = require "lib.hump.gamestate"

AssetManager = require "engine.asset_manager"

states = {
    game = require "game.states.game"
}

function love.load()
    AssetManager:load("data")
    StateManager.switch(states.game)
end

function love.draw()
    StateManager.draw()
end

function love.update(dt)
    StateManager.update(dt)
end

function love.mousepressed(x, y)
    if StateManager.current().mousepressed then
        StateManager.current():mousepressed(x, y)
    end
end

function love.mousereleased(x, y)
    if StateManager.current().mousereleased then
        StateManager.current():mousereleased(x, y)
    end
end

function love.keypressed(key)
    if StateManager.current().keypressed then
        StateManager.current():keypressed(key)
    end
end
