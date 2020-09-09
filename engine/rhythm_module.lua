--[[
Default callbacks:
a - bar
b - on-beat
c - off-beat
d - beat
e - syncopated kinda

4/4:
1-2-3-4-
a-------
b---b---
--c---c-
d-d-d-d-
-e-e-e-e

3/4:
1-2-3-
a-----
b-----
--c-c-
d-d-d-
-e-e-e

5/4
1-2-3-4-5-
a---------
------b---
--c-c---c-
d-d-d-d-d-
-e-e-e-e-e

6/8
1-2-3-4-5-6-
a-----------
b-----b-----
--c-c---c-c-
d-d-d-d-d-d-
-e-e-e-e-e-e

You can also add custom callbacks
--]]

local RhythmModule = {
    defaultCallbacks = {
        [4] = {
            bar = { 1 },
            onBeat = { 1, 3 },
            offBeat = { 2, 4 },
            beat = { 1, 2, 3, 4 },
            syncopated = { 1.5, 2.5, 3.5, 4.5 },
        },
        [3] = { 
            bar = { 1 },
            onBeat = { 1 },
            offBeat = { 2, 3 },
            beat = { 1, 2, 3 },
            syncopated = { 1.5, 2.5, 3.5 },
        },
        [5] = {
            bar = { 1 },
            onBeat = { 1, 4 },
            offBeat = { 2, 3, 4 },
            beat = { 1, 2, 3, 4, 5 },
            syncopated = { 1.5, 2.5, 3.5, 4.5, 5.5 },
        },
        [6] = {
            bar = { 1 },
            onBeat = { 1, 4 },
            offBeat = { 2, 3, 5, 6 },
            beat = { 1, 2, 3, 4, 5, 6 },
            syncopated = { 1.5, 2.5, 3.5, 4.5, 5.5, 6.5 },
        }
    },
    previousBeatPosition = 0,
    callbacks = {},
    musicData = nil
}

function RhythmModule:registerRhythmCallback(beatsType, fn)
    table.insert(self.callbacks, { beatsType = beatsType, fn = fn })
end

function RhythmModule:update(dt)
    local track = self.musicData.metadata
    if not track or not self.musicData.source or not self.musicData.source:isPlaying() then
        return
    end
    local trackPos = self.musicData.source:tell()
    local timeSignature = self._getCurrentTimeSignature(track, trackPos)
    if timeSignature <= 0 then
        return
    end
    local syncPoint = self._getLatestSyncPoint(track, trackPos)
    if not syncPoint then
        return
    end
    local barPeriod = syncPoint.timeSignature * 60 / syncPoint.bpm
    local beatPos = 1 + (trackPos - syncPoint.time) % (barPeriod) / (barPeriod / syncPoint.timeSignature)
    --                             (time from bar begining)   /      (beat period)
    self:_sendCallbacks(self.previousBeatPosition, beatPos, timeSignature)
    self.previousBeatPosition = beatPos
end

function RhythmModule:initMusicData(musicData)
    self.musicData = musicData
end

function RhythmModule:_sendCallbacks(from, to, timeSignature)
    if to < from then
        from = from - timeSignature
    end
    if to < from or from < 0 then
        return
    end

    local defaultCallbacks = self.defaultCallbacks[timeSignature]
    for _, callback in ipairs(self.callbacks) do
        local beatsToEmitCallback = type(callback.beatsType) == "table" and callback.beatsType or defaultCallbacks[callback.beatsType]
        if beatsToEmitCallback then
            for i, beat in ipairs(beatsToEmitCallback) do
                if beat > from and beat < to then
                    callback.fn()
                end
            end
        end
    end
end

function RhythmModule._getLatestSyncPoint(track, currentPos)
    if track.syncPoints then
        local closestSyncPoint = nil
        for i, syncPoint in ipairs(track.syncPoints) do
            if syncPoint.time and syncPoint.time < currentPos and (closestSyncPoint and syncPoint.time > closestSyncPoint.time or closestSyncPoint == nil) then
                closestSyncPoint = syncPoint
            end
        end
        if closestSyncPoint then
            return closestSyncPoint
        end
    end
    return nil
end

function RhythmModule._getCurrentTimeSignature(track, currentPos)
    local signature = nil
    if track.syncPoints then
        local closestTime = -1
        for i, syncPoint in ipairs(track.syncPoints) do -- basicly - take last syncPoint that is before currentPos
            if syncPoint.time and syncPoint.timeSignature and
                    syncPoint.time < currentPos and syncPoint.time > closestTime then
                signature = syncPoint.timeSignature
                closestTime = syncPoint.time
            end
        end
        if signature then
            return signature
        end
    end
    if track.timeSignature then
        return track.timeSignature
    end
    return 4 -- most common
end

return RhythmModule