if not AssetManager then
    error("AssetManager is required for MusicPlayer")
end

-- require("engine.rhythm_module") -- TODO: module for rhythm synchronization

local MusicPlayer = {
    currentTrack = {
        name = nil,
        source = nil,
        metadata = nil
    },
    globalMusicVolume = 1,
}

function MusicPlayer:loadData(musicData)
    self.musicData = musicData
end

function MusicPlayer:play(track)
    if self.currentTrack.name == track and self.currentTrack.source then
        if not self.currentTrack.source:isPlaying() then
            self:_playCurrentSource()
        end
        return -- trying to switch to track that is already playing - do nothing
    end
    if self.currentTrack.source then
        self.currentTrack.source:stop()
    end
    local trackData = self.musicData[track]
    self.currentTrack.name = track
    self.currentTrack.metadata = trackData
    self.currentTrack.source = AssetManager:getSound(trackData.fileName)
    self:_playCurrentSource()
end

function MusicPlayer:setGlobalVolume(volume)
    self.globalMusicVolume = math.clamp(0, volume, 1)
    self:_setVolume()
end

function MusicPlayer:update(dt)
    -- TODO: check music looped to go to the looping point
    -- TODO: rhythm module stuff
end

function MusicPlayer:_setVolume()
    if self.currentTrack.source then
        local volume = self.globalMusicVolume
        if self.currentTrack.metadata.volume then
            volume = volume * self.currentTrack.metadata.volume
        end
        self.currentTrack.source:setVolume(volume)
    end
end

function MusicPlayer:_playCurrentSource()
    if self.currentTrack.metadata.loop == nil or self.currentTrack.metadata.loop == true then
        self.currentTrack.source:setLooping(true)
    end
    self:_setVolume()
    self.currentTrack.source:play()
end

return MusicPlayer
