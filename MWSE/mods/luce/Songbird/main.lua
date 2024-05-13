local modName = "Songbird"
local version = "v0.02"
local configPath = modName
local config = mwse.loadConfig(configPath, { 
    enabled = true,
    foldersEnabled = { 
        ["Explore"] = true, 
        ["Battle"] = true
    },
    favourites = {}
 })

--  { songName = "Morrowind Title.mp3", songPath = "Data Files/Music/Explore/Morrowind Title.mp3" },
--  { songName = "Gone By Day.mp3", songPath = "Data Files/Music/Explore/Gone By Day.mp3" }
local creditsList = "* abot, Spammer, NullCascade, Merlord, Hrnchamd, kindi, longod, svengineer, OperatorJack: "
  .. "I spent so much time looking at your code trying to figure out how the heck Lua works\n"
  .. "* Herbert for your kind explanations of how the UI code works and getting the hotkey working for me\n"
  .. "* Safebox for help and advice about how lua works\n" 
  .. "* DimNussens for Baandari Dreams which inspired me to make this mod"

local logger = require("logging.logger")
local log = logger.new({ 
    name = modName,
    logLevel = INFO,
    logToConsole = true,
    includeTimestamp = true
})

local function getCurrentTrack() 
    local track = tes3.worldController.audioController.currentMusicFilePath
    if (track == "" or not track) then 
        log:debug("It's nil!")
        return "Not playing yet"
    else
        log:debug("It's not nil! (except it is)") 
        log:debug("%s", track)
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
        log:debug("track: name: %s, dir: %s, path: %s", track.songName, track.songPath, track.songDir)
        table.insert(songTable, track)
    end
    return songTable
end

local function playSong(song)
    tes3.worldController.audioController:changeMusicTrack(song)
end

local function constructListEntry(parent, songName, songPath)
    local block = parent:createSideBySideBlock({})
    block.parent = parent
    mwse.log("Block parent: %s", block.parent)

    local favouriteButton = block:createButton({
        buttonText = "+",
        description = "Add song " .. songName .. " to your favourites list",
        callback = function()
            log:debug("Added " .. songName .. " to favourites list")
            local track = { fileName = songName, filePath = songPath }
            config.favourites[songName] = track
        end
    })
    favouriteButton.parent = block
    mwse.log("%s", favouriteButton.parent)

    local songButton = block:createButton({
        buttonText = "Play " .. songName,
        description = "Details: \n \n" .. songName .. "\n" .. songPath,
        indent = 10,
        callback = function()
            playSong(songPath)
        end
    })
end

local function constructSongList(page, songTable)
    local category = page:createCategory({ label = "Songs" })
    for i, track in ipairs(songTable) do
        log:debug("%s %s, %s", i, track.songName, track.songPath)
        constructListEntry(category, track.songName, track.songPath)
    end
end

-- thank you herbert
local function openSongbirdMenu(menu)
    if menu then
        local mcm = menu:findChild("MenuOptions_MCM_container")
        if mcm then
            mcm:triggerEvent("mouseClick")
            -- return true
        end
        local mcmModList = tes3ui.findMenu("MWSE:ModConfigMenu").children
        for child in table.traverse(mcmModList) do
            if child.text == modName then
                child:triggerEvent("mouseClick")
            end
        end
    end
    return false
end

-- thank you herbert
local function songbirdShortcut()
    -- if we couldn't open the menu
    if not openSongbirdMenu(tes3ui.findMenu("MenuOptions")) then
        -- get the key that opens the options menu, and then press it
        local inputConfig = tes3.getInputBinding(tes3.keybind.menuMode) 
        if inputConfig.device == 1 then -- device == 1 means it's a keyboard key. idk how to make this work on mouse buttons
            tes3.tapKey(inputConfig.code)
            -- as soon as the menu opens, click the mcm button
            event.register("uiActivated", function(e)
                openSongbirdMenu(e.element)
            end, { filter = "MenuOptions", priority=-1, doOnce=true })
        end
    end
end

local function addHeader(page)
    -- Header
    local title = page.sidebar:createInfo({ text = string.upper(modName) .. " " .. version })
    page.sidebar:createInfo({ text = "A mod by Lucevar"})
    page.sidebar:createHyperLink({ text = "Visit on Nexus", url = "https://www.nexusmods.com/morrowind"})
    page.sidebar:createHyperLink({ text = "Visit on Github", url = "https://github.com/Lucevar/songbird" })
    page.sidebar:createInfo({ text = ""})

    -- Current Track
    local currentTrackCategory = page.sidebar:createCategory({ label = "Currently Playing:"})
    currentTrackCategory:createInfo({ text = getCurrentTrack(),
        postCreate = function(self)
            self.elements.info.text = getCurrentTrack()
        end })
end

local function addSettings(page)
    -- Settings
    local settingsCategory = page.sidebar:createCategory({ label = "Settings" })

    -- Settings: Access Hotkey
    settingsCategory:createKeyBinder{ 
        label = "Set hotkey to access Songbird menu", 
        allowCombinations = true, 
        variable = mwse.mcm.createTableVariable{
            id = "accessMenuKey", 
            table = config, 
            restartRequired = false, 
            defaultSetting = { 
                keyCode = tes3.scanCode.m, 
                isShiftDown = false, 
                isAltDown = false, 
                isControlDown = false, 
                isSuperDown = false }
            }
        }

    -- Settings: Logging
    settingsCategory:createDropdown({
        label = "Logging level:",
        options = {
            { label = "TRACE", value = "TRACE"},
            { label = "DEBUG", value = "DEBUG"},
            { label = "INFO", value = "INFO"},
            { label = "WARN", value = "WARN"},
            { label = "ERROR", value = "ERROR"},
            { label = "NONE", value = "NONE"},
        },
        variable = mwse.mcm.createTableVariable{ id = "logLevel", table = config },
        callback = function(self)
            log:setLogLevel(self.variable.value)
        end
    })

    local creditsCategory = page.sidebar:createCategory({ label = "Credits"})
    creditsCategory:createInfo({ text = creditsList })
end

local function constructPage(template, folderName)
    local page = template:createSideBarPage({ label = folderName })
    addHeader(page)
    addSettings(page)
    constructSongList(page, constructSongTableFromFolder(folderName))
end

local function addFavourites(favList)

    for i, track in pairs(config.favourites) do
        local sideBlock = favList:createSideBySideBlock()
        sideBlock.flowDirection = "left_to_right"

        mwse.log("Favourite found: %s", track.fileName)

        local favouriteButton = sideBlock:createButton({
            buttonText = "-",
            description = "Remove song " .. track.fileName .. " from your favourites list",
            callback = function(self)
                mwse.log("Removed " .. track.fileName .. " from favourites list")
                config.favourites[track.fileName] = nil
            end
        })
    
        local songButton = sideBlock:createButton({
            buttonText = "Play " .. track.fileName,
            description = "Details: \n \n" .. track.fileName .. "\n" .. track.filePath,
            indent = 10,
            callback = function()
                playSong(track.filePath)
            end
        })

    end
end

local function constructFavouritesPage(favouritesPage)
    addHeader(favouritesPage)
    addSettings(favouritesPage)
    local favList = favouritesPage:createCategory({ 
        postCreate = function(favList)
            mwse.log("hello")
            mwse.log("%s", favList.widget)
            mwse.log(json.encode(favList.widget))
        end })
    addFavourites(favList)
end

local function registerModConfig()
    -- Initialise template
    local template = mwse.mcm.createTemplate({ name = modName })
    template:saveOnClose(configPath, config)

    local favouritesPage = template:createSideBarPage({ label = "Favourites" })
    constructFavouritesPage(favouritesPage)

    for folderName in pairs(config.foldersEnabled) do
        constructPage(template, folderName)
    end

    -- Finalise
    template:register()
end

local function initialized()
    mwse.log("[" .. modName .. "] initialised")
end

event.register(tes3.event.modConfigReady, registerModConfig)
event.register(tes3.event.keyDown, songbirdShortcut, { filter = config.accessMenuKey.keyCode })
event.register(tes3.event.initialized, initialized)