-- local logger = require("logging.logger")
-- local log = logger.new({ 
--     name = modName,
--     logLevel = INFO,
--     logToConsole = true,
--     includeTimestamp = true
-- })

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

--     -- Settings: Logging
--     settingsCategory:createDropdown({
--         label = "Logging level:",
--         options = {
--             { label = "TRACE", value = "TRACE"},
--             { label = "DEBUG", value = "DEBUG"},
--             { label = "INFO", value = "INFO"},
--             { label = "WARN", value = "WARN"},
--             { label = "ERROR", value = "ERROR"},
--             { label = "NONE", value = "NONE"},
--         },
--         variable = mwse.mcm.createTableVariable{ id = "logLevel", table = config },
--         callback = function(self)
--             log:setLogLevel(self.variable.value)
--         end
--     })

-- end

local modName = "Songbird"
local version = "v0.05"

local config = mwse.loadConfig(modName, { 
    enabled = true,
    accessMenuKey = {
        keyCode = 83, 
        isShiftDown = false, 
        isAltDown = false, 
        isControlDown = false, 
        isSuperDown = false
    },
    exploreFavourites = {},
    battleFavourites = {}
 })

local mcm = require("luce.songbird.mcm")
mcm.config = config

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
    mwse.log("detected key")
    -- if we couldn't open the menu
    if tes3.onMainMenu() then
        return
    end
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

local function registerModConfig()
	mwse.registerModConfig(modName, mcm)
end
event.register(tes3.event.modConfigReady, registerModConfig)

event.register(tes3.event.keyDown, songbirdShortcut, { filter = config.accessMenuKey.keyCode })

local function onInitialized()
    mwse.log("[" .. modName .. " " .. version .. "] initialised")
end
event.register(tes3.event.initialized, onInitialized)