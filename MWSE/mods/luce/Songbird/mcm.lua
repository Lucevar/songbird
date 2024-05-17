local this = {}

local function playSong(song)
    tes3.worldController.audioController:changeMusicTrack(song)
end

local function getCurrentTrack() 
    local track = tes3.worldController.audioController.currentMusicFilePath
    if (track == "" or not track) then 
        return "Not playing yet"
    else
        return track
    end
end

-- local function constructExploreFavourites(pane)
--     -- mwse.log(json.encode(pane:getContentElement().children))

--     if (pane.children) then
--         pane:destroyChildren()
--     end

--     for _, track in pairs(this.config.exploreFavourites) do
--         local block = pane:createBlock({ label = "Block"})
--         block.flowDirection = "left_to_right"
--         block.layoutWidthFraction = 1.0
--         block.layoutHeightFraction = 1.0

--         local removeButton = block:createButton({ text = "-"})
--         removeButton.widthProportional = 0.1
--         removeButton:register("mouseClick", function(e)
--             this.config.favourites[track.fileName] = nil
--             mwse.log(json.encode(this.config.exploreFavourites))
--             constructFavourites(pane)
--         end)

--         local songButton = block:createButton({
--             text = track.fileName
--         })
--         songButton:register("mouseClick", function(e)
--             playSong(track.filePath)
--         end)
--         songButton.widthProportional = 1.0
--     end
-- end

-- -- thank you herbert
-- local function openSongbirdMenu(menu)
--     if menu then
--         local mcm = menu:findChild("MenuOptions_MCM_container")
--         if mcm then
--             mcm:triggerEvent("mouseClick")
--             -- return true
--         end
--         local mcmModList = tes3ui.findMenu("MWSE:ModConfigMenu").children
--         for child in table.traverse(mcmModList) do
--             if child.text == modName then
--                 child:triggerEvent("mouseClick")
--             end
--         end
--     end
--     return false
-- end

-- -- thank you herbert
-- local function songbirdShortcut()
--     -- if we couldn't open the menu
--     if not openSongbirdMenu(tes3ui.findMenu("MenuOptions")) then
--         -- get the key that opens the options menu, and then press it
--         local inputConfig = tes3.getInputBinding(tes3.keybind.menuMode) 
--         if inputConfig.device == 1 then -- device == 1 means it's a keyboard key. idk how to make this work on mouse buttons
--             tes3.tapKey(inputConfig.code)
--             -- as soon as the menu opens, click the mcm button
--             event.register("uiActivated", function(e)
--                 openSongbirdMenu(e.element)
--             end, { filter = "MenuOptions", priority=-1, doOnce=true })
--         end
--     end
-- end

local function createHeader(mainHeaderBlock)
    -- Header
    -- local title = mainHeaderBlock:createInfo({ text = string.upper(modName) .. " " .. version })
    local title = mainHeaderBlock:createLabel({ text = "SONGBIRD" })
    mainHeaderBlock:createLabel({ text = "A mod by Lucevar \n"})
    mainHeaderBlock:createHyperlink({ text = "Visit on Nexus", url = "https://www.nexusmods.com/morrowind"})
    mainHeaderBlock:createHyperlink({ text = "Visit on Github", url = "https://github.com/Lucevar/songbird" })
    -- mainHeaderBlock:createInfo({ text = ""})

    -- -- Current Track
    -- local currentTrackCategory = mainHeaderBlock:createCategory({ label = "Currently Playing:"})
    -- currentTrackCategory:createInfo({ text = getCurrentTrack(),
    --     postCreate = function(self)
    --         self.elements.info.text = getCurrentTrack()
    --     end })
end

-- local function addSettings(page)
--     -- Settings
--     local settingsCategory = page.sidebar:createCategory({ label = "Settings" })

--     -- Settings: Access Hotkey
--     settingsCategory:createKeyBinder{ 
--         label = "Set hotkey to access Songbird menu", 
--         allowCombinations = true, 
--         variable = mwse.mcm.createTableVariable{
--             id = "accessMenuKey", 
--             table = config, 
--             restartRequired = false, 
--             defaultSetting = { 
--                 keyCode = tes3.scanCode.m, 
--                 isShiftDown = false, 
--                 isAltDown = false, 
--                 isControlDown = false, 
--                 isSuperDown = false }
--             }
--         }

--     local creditsCategory = page.sidebar:createCategory({ label = "Credits"})
--     creditsCategory:createInfo({ text = creditsList })
-- end

local function getSongTable(folderName)
    local songTable = {}
    local searchDir = "Data Files/Music/" .. folderName .. "/"
    -- for filePath, dir, fileName in lfs.walkdir(searchDir) do
    for filePath, dir, fileName in lfs.walkdir(searchDir) do
        -- filePath = Data Files/Music/Explore/Morrowind Title.mp3
        -- dir = Data Files/Music/Explore/
        -- fileName = Morrowind Title.mp3
        -- Data Files/Music/Explore/test\test.mp3, Data Files/Music/Explore/test\, test.mp3

        local track = { fileName = fileName, dir = dir, filePath = filePath }
        -- mwse.log("track: name: %s, dir: %s, path: %s", track.fileName, track.filePath, track.dir)
        table.insert(songTable, track)
    end
    return songTable
end

-- local function constructSongList(pane, songTable)
--     mwse.log("Constructing song list")
--     for _, track in pairs(songTable) do
--         local block = pane:createBlock({ })
--         block.flowDirection = "left_to_right"
--         block.layoutWidthFraction = 1.0
--         -- block.layoutHeightFraction = 1.0
--         -- block.autoWidth = true
--         block.autoHeight = true

--         local addButton = block:createButton({ text = "+"})
--         addButton.widthProportional = 0.1
--         addButton.paddingAllSides = 6
--         addButton:register("mouseClick", function(e)
--             this.config.favourites[track.fileName] = track
--             mwse.log(json.encode(this.config.favourites))
--             constructFavourites(pane)
--             pane:getTopLevelMenu():updateLayout()
--         end)

--         local songButton = block:createButton({
--             text = track.fileName
--         })
--         -- songButton.wrapText = true
--         songButton:register("mouseClick", function(e)
--             playSong(track.filePath)
--         end)
--         songButton.widthProportional = 1.0
--     end
-- end

-- local function addOtherLists(pane)
--     for folderName in pairs(this.config.foldersEnabled) do
--         constructSongList(pane, getSongTable(folderName))
--     end
-- end

local function createOptionsBlock(optionsBlock)
    local exploreButton = optionsBlock:createButton()
    exploreButton.text = "Explore"

    local battleButton = optionsBlock:createButton()
    battleButton.text = "Battle"

    local optionsButton = optionsBlock:createButton()
    optionsButton.text = "Options"
end

local function constructFavourites(favouritesPane)
    for _, track in pairs(this.config.exploreFavourites) do
        local row = favouritesPane:createBlock({})
        row.flowDirection = "left_to_right"
        row.borderBottom = 5
        row.autoHeight = true
        row.autoWidth = true
        -- row.childAlignY = 0.5

        local removeFaveButton = row:createButton({ text = "-" })
        removeFaveButton.paddingAllSides = 2
        removeFaveButton:register("mouseClick", function(e)
            this.config.exploreFavourites[track.fileName] = nil
            mwse.log(json.encode(this.config.exploreFavourites))
            favouritesPane:destroyChildren()
            constructFavourites(favouritesPane)
            favouritesPane:getTopLevelMenu():updateLayout()
        end)

        local songButton = row:createButton({ text = track.fileName })
        -- songButton.wrapText = true
        -- songButton.autoWidth = true
        songButton:register("mouseClick", function(e)
            playSong(track.filePath)
        end)
    end
end

function this.onCreate(parent)
    -- local pane = baseContainer:createVerticalScrollPane({ id = "pane" })
    -- pane:createButton({ text = "Blah"})
    -- local favouritesList = constructFavourites(pane)
    -- -- addOtherLists(pane)

    local page = parent:createThinBorder({})
    page.flowDirection = "top_to_bottom"
    page.heightProportional = 1.0
    page.widthProportional = 1.0
    page.paddingAllSides = 12
    page.wrapText = true
    -- header
    local mainHeaderBlock = page:createBlock()
    mainHeaderBlock.widthProportional = 1
    mainHeaderBlock.heightProportional = 0.7
    mainHeaderBlock.flowDirection = "top_to_bottom"
    mainHeaderBlock.childAlignX = 0.5
    mainHeaderBlock.paddingAllSides = 4

    createHeader(mainHeaderBlock)

    local optionsBlock = page:createBlock()
    optionsBlock.widthProportional = 1
    optionsBlock.heightProportional = 0.20
    optionsBlock.flowDirection = "left_to_right"
    optionsBlock.childAlignX = 0.5
    optionsBlock.paddingAllSides = 2
    createOptionsBlock(optionsBlock)

    local labelBlock = page:createBlock()
    labelBlock.widthProportional = 1
    labelBlock.heightProportional = 0.1
    labelBlock.flowDirection = "left_to_right"
    local leftLabel = labelBlock:createBlock()
    leftLabel.widthProportional = 1
    leftLabel.heightProportional = 1
    leftLabel.childAlignX = 0.5
    local favouritesLabel = leftLabel:createLabel({ text = "Favourites" })
    favouritesLabel.paddingAllSides = 2
    local rightLabel = labelBlock:createBlock()
    rightLabel.widthProportional = 1
    rightLabel.heightProportional = 1
    rightLabel.childAlignX = 0.5
    local exploreLabel = rightLabel:createLabel({ text = "Songs" })
    exploreLabel.paddingAllSides = 2
    
    local panes = page:createBlock()
    panes.widthProportional = 1
    panes.heightProportional = 2.7
    panes.flowDirection = "left_to_right"

    local favouritesPane = panes:createVerticalScrollPane()
    favouritesPane.widthProportional = 1
    favouritesPane.heightProportional = 1
    favouritesPane.paddingAllSides = 12
    favouritesPane = favouritesPane:getContentElement()

    constructFavourites(favouritesPane)

    local explorePane = panes:createVerticalScrollPane()
    explorePane.widthProportional = 1
    explorePane.heightProportional = 1
    explorePane.paddingAllSides = 12
    explorePane = explorePane:getContentElement()

    -- local headerBlock = explorePane:createBlock()
    -- headerBlock.widthProportional = 1
    -- headerBlock.heightProportional = 1
    -- local headerLabel = headerBlock:createLabel()
    -- headerLabel.text = "Explore Songs"

    for _, track in pairs(getSongTable("Explore")) do
        local row = explorePane:createBlock({})
        row.flowDirection = "left_to_right"
        row.borderBottom = 1
        row.autoHeight = true
        row.autoWidth = true
        -- row.widthProportional = 1
        -- row.heightProportional = 1
        -- row.childAlignY = 0.5
        local addFaveButton = row:createButton({ text = "+" })
        addFaveButton.paddingAllSides = 2
        addFaveButton.maxWidth = 25
        addFaveButton:register("mouseClick", function(e)
            this.config.exploreFavourites[track.fileName] = track
            mwse.log(json.encode(this.config.exploreFavourites))
            favouritesPane:destroyChildren()
            constructFavourites(favouritesPane)
            favouritesPane:getTopLevelMenu():updateLayout()
        end)

        local songButton = row:createButton({ text = track.fileName })
        -- songButton.wrapText = true
        -- songButton.autoWidth = true
        songButton:register("mouseClick", function(e)
            playSong(track.filePath)
        end)
    end

end

-- event.register(tes3.event.modConfigReady, onModConfigReady)

function this.onClose(_)
    mwse.saveConfig("Songbird", this.config)
end

return this