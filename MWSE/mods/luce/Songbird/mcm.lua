local this = {}

local page = {}
local mainHeaderBlock = {}
local battlePanes = {}
local explorePage = {}
local labelBlock = {}
local optionsPage = {}

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

local function createCurrentTrackBlock()

end

-- musicSelectTrack

local function createHeader()
    -- Header
    -- local title = mainHeaderBlock:createInfo({ text = string.upper(modName) .. " " .. version })
    local currentTrack = nil
    if(mainHeaderBlock.children ~= nil) then
        mainHeaderBlock:destroyChildren()
    end
    local title = mainHeaderBlock:createLabel({ text = "SONGBIRD \n" })
    local currentSongLabel = mainHeaderBlock:createLabel({ text = "Currently Playing: "})
    currentSongLabel.color = tes3ui.getPalette(tes3.palette.headerColor)
    currentTrack = mainHeaderBlock:createLabel({ text = getCurrentTrack() })
    mwse.log(currentTrack.text)
    currentTrack.text = tostring(getCurrentTrack())
    mwse.log(currentTrack.text)
    currentTrack:getTopLevelMenu():updateLayout()
    mwse.log(currentTrack.text)
    -- mainHeaderBlock:createLabel({ text = "A mod by Lucevar \n"})
    -- mainHeaderBlock:createHyperlink({ text = "Visit on Nexus", url = "https://www.nexusmods.com/morrowind"})
    -- mainHeaderBlock:createHyperlink({ text = "Visit on Github", url = "https://github.com/Lucevar/songbird" })
    -- mainHeaderBlock:createInfo({ text = ""})

    -- -- Current Track
    -- local currentTrackCategory = mainHeaderBlock:createCategory({ label = "Currently Playing:"})
    -- currentTrackCategory:createInfo({ text = getCurrentTrack(),
    --     postCreate = function(self)
    --         self.elements.info.text = getCurrentTrack()
    --     end })
end

local function addSettings()
    -- Settings
    local settingsHeader = optionsPage:createBlock()
    settingsHeader.widthProportional = 1
    settingsHeader.widthProportional = 0.3
    settingsHeader.childAlignX = 0.5

    local title = settingsHeader:createLabel({ text = "SONGBIRD" })
    settingsHeader:createLabel({ text = "A mod by Lucevar \n"})
    settingsHeader:createHyperlink({ text = "Visit on Nexus", url = "https://www.nexusmods.com/morrowind"})
    settingsHeader:createHyperlink({ text = "Visit on Github", url = "https://github.com/Lucevar/songbird" })

    local settingsCategory = optionsPage:createLabel({ text = "Settings" })
    settingsCategory.color = tes3ui.getPalette(tes3.palette.headerColor)

    local hotkeyLabel = optionsPage:createLabel({ text = "Set a hotkey to open the Songbird menu: "})
    local hotkeyButton = optionsPage:createButton({ text = this.config.accessMenuKey })
    -- Settings: Access Hotkey
    -- settingsCategory:createKeyBinder{ 
    --     label = "Set hotkey to access Songbird menu", 
    --     allowCombinations = true, 
    --     variable = mwse.mcm.createTableVariable{
    --         id = "accessMenuKey", 
    --         table = config, 
    --         restartRequired = false, 
    --         defaultSetting = { 
    --             keyCode = tes3.scanCode.m, 
    --             isShiftDown = false, 
    --             isAltDown = false, 
    --             isControlDown = false, 
    --             isSuperDown = false }
    --         }
    --     }

    -- local creditsCategory = page.sidebar:createCategory({ label = "Credits"})
    -- creditsCategory:createInfo({ text = creditsList })
end

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
        songButton:register("mouseClick", function(e)
            playSong(track.filePath)
        end)
        songButton:registerAfter("mouseClick", function(e)
            local timer = timer.start({ 
                type = timer.real, 
                duration = 0.5,
                callback = createHeader })
        end)
    end
end

local function createExplorePanes()
    mwse.log("creating explore panes")

    explorePage = page:createBlock()
    explorePage.widthProportional = 1
    explorePage.heightProportional = 2.5
    explorePage.flowDirection = "top_to_bottom"

    local labelBlock = explorePage:createBlock()
    labelBlock.widthProportional = 1
    labelBlock.heightProportional = 0.1
    labelBlock.flowDirection = "left_to_right"
    local leftLabel = labelBlock:createBlock()
    leftLabel.widthProportional = 1
    leftLabel.heightProportional = 1
    leftLabel.childAlignX = 0.5
    local favouritesLabel = leftLabel:createLabel({ text = "Favourites" })
    favouritesLabel.paddingAllSides = 2
    favouritesLabel.color = tes3ui.getPalette(tes3.palette.headerColor)
    local rightLabel = labelBlock:createBlock()
    rightLabel.widthProportional = 1
    rightLabel.heightProportional = 1
    rightLabel.childAlignX = 0.5
    local songsLabel = rightLabel:createLabel({ text = "Songs" })
    songsLabel.paddingAllSides = 2
    songsLabel.color = tes3ui.getPalette(tes3.palette.headerColor)

    local explorePanes = explorePage:createBlock()
    explorePanes.widthProportional = 1
    explorePanes.heightProportional = 2.4
    explorePanes.flowDirection = "left_to_right"

    local favouritesPane = explorePanes:createVerticalScrollPane()
    favouritesPane.widthProportional = 1
    favouritesPane.heightProportional = 1
    favouritesPane.paddingAllSides = 12
    favouritesPane = favouritesPane:getContentElement()

    constructFavourites(favouritesPane)

    local explorePane = explorePanes:createVerticalScrollPane()
    explorePane.widthProportional = 1
    explorePane.heightProportional = 1
    explorePane.paddingAllSides = 8
    explorePane = explorePane:getContentElement()

    for _, track in pairs(getSongTable("Explore")) do
        local row = explorePane:createBlock({})
        row.flowDirection = "left_to_right"
        row.borderBottom = 1
        row.autoHeight = true
        row.autoWidth = true
        local addFaveButton = row:createButton({ text = "+" })
        addFaveButton.paddingAllSides = 1
        addFaveButton.maxWidth = 25
        addFaveButton:register("mouseClick", function(e)
            this.config.exploreFavourites[track.fileName] = track
            favouritesPane:destroyChildren()
            constructFavourites(favouritesPane)
            favouritesPane:getTopLevelMenu():updateLayout()
        end)

        local songButton = row:createButton({ text = track.fileName })
        songButton:register("mouseClick", function(e)
            mwse.log("mouseclick")
            playSong(track.filePath)
        end)
        songButton:registerAfter("mouseClick", function(e)
            mwse.log("Starting timer")
            local timer = timer.start({ 
                type = timer.real, 
                duration = 1,
                callback = createHeader()})
        end)
    end

    mwse.log(explorePanes.visible)
    explorePanes:getTopLevelMenu():updateLayout()
    return explorePanes
end

-- page with the mod-level options
local function createOptionsPage()
    optionsPage = page:createBlock()
    optionsPage.widthProportional = 1
    optionsPage.heightProportional = 3.1
    optionsPage.flowDirection = "top_to_bottom"

    addSettings()
end

    -- the block with the explore / battle / options buttons
local function createOptionsBlock(optionsBlock)
    local exploreButton = optionsBlock:createButton()
    exploreButton.text = "Explore"
    exploreButton:register("mouseClick", function(e)
        if(explorePage.visible == true) then
            for _, pageChild in pairs(explorePage.children) do
                pageChild.visible = false
            end
            -- for _, labelChild in pairs(labelBlock.children) do
            --     labelChild.visible = false
            -- end
            explorePage.visible = false
            -- labelBlock:getTopLevelMenu():updateLayout()
            -- explorePanes:getTopLevelMenu():updateLayout()
            return
        end
        if (explorePage.visible == false) then
            for _, pageChild in pairs(explorePage.children) do
                pageChild.visible = true
            end
            -- for _, labelChild in pairs(labelBlock.children) do
            --     labelChild.visible = true
            -- end
            explorePage.visible = true
            optionsPage.visible = false
            -- labelBlock:getTopLevelMenu():updateLayout()
            -- explorePanes:getTopLevelMenu():updateLayout()
            return
        end
    end)

    local battleButton = optionsBlock:createButton()
    battleButton.text = "Battle"

    local optionsButton = optionsBlock:createButton()
    optionsButton.text = "Options"
    optionsButton:register("mouseClick", function(e)
        if(optionsPage.visible == true) then
            for _, optionChild in pairs(optionsPage.children) do
                optionChild.visible = false
            end
            optionsPage.visible = false
            return
        end
        if(optionsPage.visible == false) then
            explorePage.visible = false
            for _, optionChild in pairs(optionsPage.children) do
                optionChild.visible = true
            end
            optionsPage.visible = true
        end
    end)
end

function this.onCreate(parent)
    page = parent:createThinBorder({})
    page.flowDirection = "top_to_bottom"
    page.heightProportional = 1.0
    page.widthProportional = 1.0
    page.paddingAllSides = 12
    page.wrapText = true
    -- header
    mainHeaderBlock = page:createBlock()
    mainHeaderBlock.widthProportional = 1
    mainHeaderBlock.heightProportional = 0.4
    mainHeaderBlock.flowDirection = "top_to_bottom"
    mainHeaderBlock.childAlignX = 0.5
    mainHeaderBlock.paddingAllSides = 2

    createHeader()

    local optionsBlock = page:createBlock()
    optionsBlock.widthProportional = 1
    optionsBlock.heightProportional = 0.20
    optionsBlock.flowDirection = "left_to_right"
    optionsBlock.childAlignX = 0.5
    optionsBlock.paddingAllSides = 2
    createOptionsBlock(optionsBlock)
    
    createExplorePanes()
    createOptionsPage()
    explorePage.visible = true
    optionsPage.visible = false
end

function this.onClose(_)
    mwse.saveConfig("Songbird", this.config)
end

return this