local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "𝙼𝙰𝙺𝙸 𝙷𝚄𝙱",
    Footer = "Obsidian UI",
    Icon = 6023426915,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "sprout"),
    Settings = Window:AddTab("Settings", "settings"),
}

getgenv().MakiHubWindow = Window
getgenv().MakiHubTabs = Tabs

-- ===================================================
-- TAB 1: INFO
-- ===================================================
local InfoLeft = Tabs.Info:AddLeftGroupbox("Progression Status", "boxes")
InfoLeft:AddLabel("Current Activity: Idle")
InfoLeft:AddLabel("Current Floor: 0")
InfoLeft:AddLabel("Highest Floor: 0")
InfoLeft:AddLabel("Requirements: Checking...")
InfoLeft:AddLabel("Coop Level: Synced")
InfoLeft:AddLabel("Generator Level: Synced")
InfoLeft:AddLabel("Feeders Status: Active")

local InfoRight = Tabs.Info:AddRightGroupbox("Performance Monitor", "boxes")
InfoRight:AddLabel("FPS: Calculating...")
InfoRight:AddLabel("Ping: Calculating...")
InfoRight:AddLabel("Executor: Unknown")

-- ===================================================
-- TAB 2: FARMING (LEFT: TOGGLES | RIGHT: CONFIGS)
-- ===================================================
local FarmingLeft = Tabs.Farming:AddLeftGroupbox("Auto Farming Toggles", "boxes")

FarmingLeft:AddToggle("AutoProgressionToggle", {
    Text = "Auto Tower / Rebirth",
    Default = false,
    Callback = function(Value) getgenv().AutoProgression = Value end
})

FarmingLeft:AddToggle("ExpandCoopToggle", {
    Text = "Expand Coop",
    Default = false,
    Callback = function(Value) getgenv().ExpandCoop = Value end
})

FarmingLeft:AddToggle("BuyGeneratorToggle", {
    Text = "Buy Generator",
    Default = false,
    Callback = function(Value) getgenv().BuyGenerator = Value end
})

FarmingLeft:AddToggle("UpgradeGeneratorToggle", {
    Text = "Upgrade Generator",
    Default = false,
    Callback = function(Value) getgenv().UpgradeGenerator = Value end
})

FarmingLeft:AddToggle("UpgradeRecyclerToggle", {
    Text = "Upgrade Recycler",
    Default = false,
    Callback = function(Value) getgenv().UpgradeRecycler = Value end
})

FarmingLeft:AddToggle("AutoCollectEggToggle", {
    Text = "Auto Collect Egg",
    Default = false,
    Callback = function(Value) getgenv().AutoCollectEgg = Value end
})

local FarmingRight = Tabs.Farming:AddRightGroupbox("Farming Configurations", "boxes")

FarmingRight:AddInput("TowerDelayInput", {
    Text = "Auto Tower Delay",
    Default = "1",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().TowerDelay = tonumber(Value) or 1 end
})

FarmingRight:AddInput("ExpandTargetLevelInput", {
    Text = "Expand Target Level",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().ExpandTargetLevel = tonumber(Value) or 5 end
})

FarmingRight:AddInput("AutoBuyGenInput", {
    Text = "Auto Buy Generator",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().AutoBuyGenInput = Value end
})

FarmingRight:AddDropdown("UpgradeGenTargetDropdown", {
    Values = { "5", "10", "15", "20", "25", "30" },
    Default = "10",
    Text = "Upgrade Generator Target Level",
    Callback = function(Value) getgenv().UpgradeGenTarget = tonumber(Value) or 10 end
})

FarmingRight:AddDropdown("WalkMethodDropdown", {
    Values = { "Walk", "Teleport" },
    Default = "Walk",
    Text = "Walk Method",
    Callback = function(Value) getgenv().WalkMethod = Value end
})

FarmingRight:AddDropdown("AutoMethodDropdown", {
    Values = { "Click", "Auto" },
    Default = "Auto",
    Text = "Auto Method",
    Callback = function(Value) getgenv().AutoMethod = Value end
})

FarmingRight:AddDropdown("UpgradeRecyclerTargetDropdown", {
    Values = { "5", "10", "15", "20", "25", "30" },
    Default = "10",
    Text = "Upgrade Recycler Target Level",
    Callback = function(Value) getgenv().UpgradeRecyclerTarget = tonumber(Value) or 10 end
})

FarmingRight:AddDropdown("CollectEggMethodDropdown", {
    Values = { "Teleport", "Walk" },
    Default = "Teleport",
    Text = "Auto Collect Egg Method",
    Callback = function(Value) getgenv().CollectEggMethod = Value end
})

-- ===================================================
-- TAB 3: SETTINGS
-- ===================================================
local SettingsLeft = Tabs.Settings:AddLeftGroupbox("Menu & Config Management", "boxes")

SettingsLeft:AddButton("Unload", function() Library:Unload() end)
SettingsLeft:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "End", NoUI = true, Text = "Menu keybind" })

SettingsLeft:AddButton("Auto Rejoin", function()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    ts:Teleport(game.PlaceId, p)
end)

-- ===================================================
-- MANAGERS SETUP
-- ===================================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("MakiHubConfigs")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

task.spawn(function()
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end)
