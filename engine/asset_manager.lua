local Peachy = require "lib.peachy.peachy"

local AssetManager = {
    assets = {
        images = {},
        sounds = {}
    },
    extensions = {
        images = {"png", "jpg", "gif"},
        sounds = {"mp3", "ogg", "wav"},
    }
}

function AssetManager:load(path)
    self:recursiveImport(path)
end

function AssetManager:recursiveImport(path)
    local lfs = love.filesystem
    local files = lfs.getDirectoryItems(path)
    for _, file in ipairs(files) do
        local path_to_file = path..'/'..file
        if love.filesystem.getInfo(path_to_file).type == 'file' then
            self:loadFile(path, file)
        elseif love.filesystem.getInfo(path_to_file).type == 'directory' then
            self:recursiveImport(path_to_file)
        end
    end
end

function AssetManager:loadFile(path, file)
    local fileName = string.sub(file, 1, string.find(file, "[.]")-1)
    local fullPath = path..'/'..file
    for fileType, _ in pairs(self.extensions) do
        if self:checkExtension(fullPath, fileType) then
            if self.assets[fileType][fileName] then
                print("Error loading \""..path.."\": file with name \""..fileName.."\" is already loaded.")
            end
            print("Loading file: " .. fileName)
            self.assets[fileType][fileName] = self:loadData(fileType, fullPath, fileName)
        end
    end
end

function AssetManager:loadData(fileType, path, name)
    if fileType == "images" then
        return self:loadImageData(path, name)
    elseif fileType == "sounds" then
        return self:loadSoundData(path, name)
    end
end

function AssetManager:loadImageData(path, name)
    local imageData = {
        image = love.graphics.newImage(path),
        path = path,
        animation = nil,
    }
    imageData.image:setFilter("nearest", "nearest")

    local animationJsonPath = string.sub(path, 1, string.find(path, "[.]")-1) .. ".json"
    if love.filesystem.getInfo(animationJsonPath) then
        imageData.animation = animationJsonPath
    end

    return imageData
end

function AssetManager:loadSoundData(path, name)
    local soundData = {
        sound = love.audio.newSource(path, "static"), -- TODO: if file is big: "streaming"
        path = path,
    }

    return soundData
end

function AssetManager:checkExtension(path, type)
    local extensions = self.extensions[type]
    if not extensions then
        error("No such type of file: " .. type)
    end
    local fileExtension = string.sub(path, string.find(path, "[.]")+1 )
    for _, extension in ipairs(extensions) do
        if extension == fileExtension then
            return true
        end
    end
    return false
end

function AssetManager:getImage(name)
    if not self.assets.images[name] then
        error("No such image: " .. name)
    end
    return self.assets.images[name].image
end

function AssetManager:getAnimation(name)
    local imageData = self.assets.images[name]
    if not imageData or not self.assets.images[name].animation then
        error("Cannot load an animation " .. name)
    end
    return Peachy.new(imageData.animation, imageData.image)
end

function AssetManager:getSound(name)
    if not self.assets.sounds[name] then
        error("No such sound: " .. name)
    end
    return self.assets.sounds[name].sound:clone()
end

return AssetManager