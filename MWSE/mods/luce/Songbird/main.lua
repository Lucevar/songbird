local modName = "Songbird"
local version = "v0.02"
local configPath = modName
local config = mwse.loadConfig(configPath, { 
    enabled = true,
    foldersEnabled = { 
        ["Explore"] = true, 
        ["Battle"] = true
    }
 })

local creditsList = "abot, Spammer, NullCascade, Merlord, Hrnchamd, kindi, longod, svengineer: "
  .. "I spent so much time looking at your code trying to figure out how the heck Lua works\n"
  .. "Herbert for your kind explanations of how the UI code works \n" 
  .. "DimNussens for Baandari Dreams which inspired me to make this mod"

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
    local button = parent:createButton({
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

local function openSongbirdMenu()
    -- local mcmModList = tes3ui.findMenu(tes3ui.registerID("MWSE:ModConfigMenu")).children

    -- for child in table.traverse(mcmModList) do
    --     if child.text == "Songbird" then
    --         child:triggerEvent("mouseClick")
    --     end
    -- end

    -- local menu = tes3ui.findMenu(tes3ui.registerID("MWSE:ModConfigMenu"))
    local mcmMenu = tes3ui.registerID("MWSE:ModConfigMenu")
    mwse.log("%s", mcmMenu)

    local optionsMenu = tes3ui.registerID("MenuOptions")
    mwse.log("%s", optionsMenu)

    -- if (tes3ui.findMenu(optionsMenu)) then
    --     tes3ui.leaveMenuMode()
    -- end

    tes3ui.enterMenuMode(tes3ui.findMenu((optionsMenu)))
    -- local menu = tes3ui.findMenu("MWSE:ModConfigMenu")
    -- local found = tes3ui.findMenu(menu)
    -- mwse.log("found %s", found)
    -- mwse.log("menu %s", menu)
    -- if ( menu == nil ) then
    --     mwse.log("Menu nil")
    --     return
    -- end

    -- tes3ui.enterMenuMode("MWSE:ModConfigMenu") -> enters menu mode but blank screen
    -- tes3ui.enterMenuMode(tes3ui.registerID("MWSE:ModConfigMenu")) -> enters menu mode but blank screen
    -- tes3ui.enterMenuMode(menu)
    -- tes3ui.enterMenuMode(tes3ui.findMenu(tes3ui.registerID("MWSE:ModConfigMenu"))) -> right click menu

    -- if (tes3ui.findMenu(tes3ui.registerID("MWSE:ModConfigMenu"))) then
    --     tes3ui.leaveMenuMode()
    -- end

    -- local mcmModList = tes3ui.findMenu(menu).children
    -- mwse.log("%s", mcmModList)

    -- tes3ui.enterMenuMode(tes3ui.findMenu(tes3ui.registerID("MWSE:ModConfigMenu")))
    -- mwse.log("Attempting to enter menu mode %s", menu)
    -- tes3ui.enterMenuMode(menu)
end

local function addHeader(page)
    -- Header
    page.sidebar:createInfo({ text = string.upper(modName) .. " " .. version })
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
        label = "Hotkey to access Songbird menu: ", 
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
                isSuperDown = false}
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

local function registerModConfig()
    -- Initialise template
    local template = mwse.mcm.createTemplate({ name = modName })
    template:saveOnClose(configPath, config)

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
event.register(tes3.event.keyDown, openSongbirdMenu, { filter = config.accessMenuKey.keyCode })
event.register(tes3.event.initialized, initialized)