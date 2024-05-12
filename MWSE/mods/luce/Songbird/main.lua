local modName = "Play A Song"
local configPath = modName
local config = mwse.loadConfig(configPath, { enabled = true })

local function getCurrentTrack() 
    local track = tes3.worldController.audioController.currentMusicFilePath
    if (track == "" or not track) then 
        mwse.log("It's nil!")
        return "Not playing yet"
    else
        mwse.log("It's not nil! (except it is)") 
        mwse.log("%s", track)
        return track
    end
end

local function constructSongTableFromFolder(folderName)
    local songTable = {}
    local searchDir = "Data Files/Music/" .. folderName .. "/"
    -- for filePath, dir, fileName in lfs.walkdir(searchDir) do
    for filePath, dir, fileName in lfs.walkdir(searchDir) do
        -- filePath = Data Files/Music/Explore/Morrowind Title.mp3
        -- dir = Data Files/Music/Explore/
        -- fileName = Morrowind Title.mp3
        -- Data Files/Music/Explore/test\test.mp3, Data Files/Music/Explore/test\, test.mp3

        local track = { songName = fileName, songDir = dir, songPath = filePath }
        mwse.log("track: name: %s, dir: %s, path: %s", track.songName, track.songPath, track.songDir)
        table.insert(songTable, track)
    end
    return songTable
end

local function playSong(song)
    tes3.worldController.audioController:changeMusicTrack(song)
end

local function constructListEntry(parent, songName, songPath)
    local button = parent:createButton({
        buttonText = "Play " .. songName,
        description = "Details: \n \n" .. songName .. "\n" .. songPath,
        indent = 10,
        callback = function()
            playSong(songPath)
        end
    })
end

local function constructSongList(explorePage, songTable)
    for i, track in ipairs(songTable) do
        mwse.log("%s %s, %s", i, track.songName, track.songPath)
        constructListEntry(explorePage, track.songName, track.songPath)
    end
end

local function registerModConfig()
    -- Initialise template
    local template = mwse.mcm.createTemplate({ name = modName })
    template:saveOnClose(configPath, config)
    
    -- Create explore page
    local explorePage = template:createSideBarPage({ label = "Explore" })

    -- Current Track
    local currentTrackCategory = explorePage.sidebar:createCategory({ label = "Currently Playing:"})
    currentTrackCategory:createInfo({ text = getCurrentTrack(),
        postCreate = function(self)
            self.elements.info.text = getCurrentTrack()
        end })
    currentTrackCategory:createInfo({ text = ""})
    currentTrackCategory:createInfo({ text = "MORROWIND MAGICAL MUSIC BOX"})
    currentTrackCategory:createInfo({ text = "A mod by Lucevar"})
    currentTrackCategory:createHyperLink({ text = "Visit on Nexus", url = "https://www.nexusmods.com/morrowind"})

    -- List out the available music tracks
    local exploreTable = constructSongTableFromFolder("Explore")
    explorePage:createCategory({ label = "Exploration Songs"})
    constructSongList(explorePage, exploreTable)

    -- Create battle page // todo: extract to method
    local battlePage = template:createSideBarPage({ label = "Battle" })

    -- Current Track
    local currentTrackBattle = battlePage.sidebar:createCategory({ label = "Currently Playing:"})
    currentTrackBattle:createInfo({ text = getCurrentTrack(),
        postCreate = function(self)
            self.elements.info.text = getCurrentTrack()
        end })
    currentTrackBattle:createInfo({ text = ""})

    local battleTable = constructSongTableFromFolder("Battle")
    battlePage:createCategory({ "Battle Songs"})
    constructSongList(battlePage, battleTable)

    -- Finalise
    template:register()
end

local function initialized()
    mwse.log("[" .. modName .. "] initialised")
end

event.register(tes3.event.modConfigReady, registerModConfig)
event.register(tes3.event.initialized, initialized)