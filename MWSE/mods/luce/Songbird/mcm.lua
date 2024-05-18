local this = {}

local page = {}
local mainHeaderBlock = {}
local battlePage = {}
local explorePage = {}
local labelBlock = {}
local optionsPage = {}
local currentTrack = {}
local creditsList = "* Spammer, NullCascade, Merlord, Hrnchamd, abot, kindi, longod, svengineer, OperatorJack: "
  .. "I spent so much time looking at your code trying to figure out how the heck Lua works\n"
  .. "* Herbert for your encouragement and kind explanations of how the UI code works and getting the hotkey working for me\n"
  .. "* Safebox for help and advice about how lua works and for listening to a heck of a lot of frustrated ranting\n" 
  .. "* DimNussens for Baandari Dreams which inspired me to make this mod"

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

-- musicSelectTrack

local function createHeader()
    -- Header
    if(mainHeaderBlock.children ~= nil) then
        -- if (currentTrack ~= nil) then
        --     if (currentTrack.text ~= nil) then
        --         currentTrack.text = nil
        --     end
        -- end
        mainHeaderBlock:destroyChildren()
        -- currentTrack.text = getCurrentTrack()
        mainHeaderBlock:getTopLevelMenu():updateLayout()
    end
    local title = mainHeaderBlock:createLabel({ text = "SONGBIRD \n" })
    local currentSongLabel = mainHeaderBlock:createLabel({ text = "Currently Playing: "})
    currentSongLabel.color = tes3ui.getPalette(tes3.palette.headerColor)
    currentTrack = mainHeaderBlock:createLabel({ text = getCurrentTrack() })
    currentTrack.text = tostring(getCurrentTrack())
    currentTrack:getTopLevelMenu():updateLayout()
    currentTrack:getTopLevelMenu():updateLayout()
end

local function addSettings()
    -- Settings
    local settingsCategory = optionsPage:createLabel({ text = "Settings" })
    settingsCategory.color = tes3ui.getPalette(tes3.palette.headerColor)

    local hotkeyLabel = optionsPage:createLabel({ text = "Set a hotkey to open the Songbird menu. Default is m (for 'music'). "})
    local key = tostring(this.config.accessMenuKey["keyCode"])
    local hotkeyButton = optionsPage:createButton({ text = key })

    local settingsHeader = optionsPage:createBlock()
    settingsHeader.widthProportional = 1
    settingsHeader.heightProportional = 0.5
    settingsHeader.childAlignX = 0.5
    settingsHeader.flowDirection = "top_to_bottom"

    local creditsTitle = settingsHeader:createLabel({ text = "Credits" })
    creditsTitle.color = tes3ui.getPalette(tes3.palette.headerColor)

    settingsHeader:createLabel({ text = "A mod by Lucevar \n"})
    settingsHeader:createHyperlink({ text = "Visit on Nexus", url = "https://www.nexusmods.com/morrowind"})
    settingsHeader:createHyperlink({ text = "Visit on Github", url = "https://github.com/Lucevar/songbird" })

    local credits = optionsPage:createLabel({ text = creditsList })
    credits.wrapText = true
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

local function constructBattleFavourites(favouritesPane)
    for _, track in pairs(this.config.battleFavourites) do
        local row = favouritesPane:createBlock({})
        row.flowDirection = "left_to_right"
        row.borderBottom = 5
        row.autoHeight = true
        row.autoWidth = true
        -- row.childAlignY = 0.5

        local removeFaveButton = row:createButton({ text = "-" })
        removeFaveButton.paddingAllSides = 2
        removeFaveButton:register("mouseClick", function(e)
            this.config.battleFavourites[track.fileName] = nil
            favouritesPane:destroyChildren()
            constructBattleFavourites(favouritesPane)
            favouritesPane:getTopLevelMenu():updateLayout()
        end)

        local songButton = row:createButton({ text = track.fileName })
        songButton:register("mouseClick", function(e)
            playSong(track.filePath)
            local timer = timer.start({ 
                        type = timer.real, 
                        duration = 1.5,
                        callback = function()
                            createHeader()
            end})
        end)
    end
end

local function constructExploreFavourites(favouritesPane)
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
            favouritesPane:destroyChildren()
            constructExploreFavourites(favouritesPane)
            favouritesPane:getTopLevelMenu():updateLayout()
        end)

        local songButton = row:createButton({ text = track.fileName })
        songButton:register("mouseClick", function(e)
            playSong(track.filePath)
            local timer = timer.start({ 
                        type = timer.real, 
                        duration = 1.5,
                        callback = function()
                            createHeader()
            end})
        end)
    end
end

local function createBattlePage()
    battlePage = page:createBlock()
    battlePage.widthProportional = 1
    battlePage.heightProportional = 2.5
    battlePage.flowDirection = "top_to_bottom"

    local labelBlock = battlePage:createBlock()
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

    local battlePanes = battlePage:createBlock()
    battlePanes.widthProportional = 1
    battlePanes.heightProportional = 2.4
    battlePanes.flowDirection = "left_to_right"

    local favouritesPane = battlePanes:createVerticalScrollPane()
    favouritesPane.widthProportional = 1
    favouritesPane.heightProportional = 1
    favouritesPane.paddingAllSides = 12
    favouritesPane = favouritesPane:getContentElement()

    constructBattleFavourites(favouritesPane)

    local battlePane = battlePanes:createVerticalScrollPane()
    battlePane.widthProportional = 1
    battlePane.heightProportional = 1
    battlePane.paddingAllSides = 8
    battlePane = battlePane:getContentElement()

    for _, track in pairs(getSongTable("Battle")) do
        local row = battlePane:createBlock({})
        row.flowDirection = "left_to_right"
        row.borderBottom = 1
        row.autoHeight = true
        row.autoWidth = true
        local addFaveButton = row:createButton({ text = "+" })
        addFaveButton.paddingAllSides = 1
        addFaveButton.maxWidth = 25
        addFaveButton:register("mouseClick", function(e)
            this.config.battleFavourites[track.fileName] = track
            favouritesPane:destroyChildren()
            constructBattleFavourites(favouritesPane)
            favouritesPane:getTopLevelMenu():updateLayout()
        end)

        local songButton = row:createButton({ text = track.fileName })
        songButton:register("mouseClick", function(e)
            playSong(track.filePath)
            local timer = timer.start({ 
                        type = timer.real, 
                        duration = 1.5,
                        callback = function()
                            createHeader()
            end })
        end)
    end
end

local function createExplorePage()
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

    constructExploreFavourites(favouritesPane)

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
            constructExploreFavourites(favouritesPane)
            favouritesPane:getTopLevelMenu():updateLayout()
        end)

        local songButton = row:createButton({ text = track.fileName })
        songButton:register("mouseClick", function(e)
            playSong(track.filePath)
            local timer = timer.start({ 
                        type = timer.real, 
                        duration = 1.5,
                        callback = function()
                            createHeader()
            end })
        end)
    end

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
            explorePage.visible = false
            return
        end
        if (explorePage.visible == false) then
            for _, pageChild in pairs(explorePage.children) do
                pageChild.visible = true
            end
            explorePage.visible = true
            optionsPage.visible = false
            battlePage.visible = false
            return
        end
    end)

    local battleButton = optionsBlock:createButton()
    battleButton.text = "Battle"
    battleButton:register("mouseClick", function(e)
        if(battlePage.visible == true) then
            for _, pageChild in pairs(battlePage.children) do
                pageChild.visible = false
            end
            battlePage.visible = false
            return
        end
        if (battlePage.visible == false) then
            for _, pageChild in pairs(battlePage.children) do
                pageChild.visible = true
            end
            battlePage.visible = true
            optionsPage.visible = false
            explorePage.visible = false
            return
        end
    end)

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
            battlePage.visible = false
            explorePage.visible = false
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
    
    createExplorePage()
    createBattlePage()
    createOptionsPage()
    explorePage.visible = true
    battlePage.visible = false
    optionsPage.visible = false
end

function this.onClose(_)
    mwse.saveConfig("Songbird", this.config)
end

return this