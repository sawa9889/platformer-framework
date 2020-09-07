local musicData = {}

musicData = {
    level1 = {
        fileName = "barroom_ballet",
        loop = true,
        bpm = 115,
        loopPoint = 0,
        volume = 1,
    },
    level2 = {
        fileName = "forest_loop",
        loop = true,
        bpm = 145,
        loopPoint = 9.93,
        volume = 1,
        syncPoints = {
            {
                time = 0,
                timeSignature = 3,
                bpm = 145
            },
        }
    }
}

return musicData
