local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "𝙼𝙰𝙺𝙸 𝙷𝚄𝙱",
    Footer = "Obsidian UI",
    Icon = "shield",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "home"),
    CoopMain = Window:AddTab("CoopMain", "settings"),
    ["UI Settings"] = Window:AddTab("UI Settings", "menu"),
}

-- I-save ang Window at Tabs sa getgenv para magamit ng ibang modules
getgenv().MakiHubWindow = Window
getgenv().MakiHubTabs = Tabs

-- UI Settings & Themes
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "boxes")
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "End", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Auto Rejoin", function()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    ts:Teleport(game.PlaceId, p)
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("MakiHubConfigs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- ==================== LOAD MODULE FILES MUNA ====================
local moduleRepo = "https://raw.githubusercontent.com/Privatemaki/Maki-hub/refs/heads/main/"

pcall(function() loadstring(game:HttpGet(moduleRepo .. "hatch.lua"))() end)
pcall(function() loadstring(game:HttpGet(moduleRepo .. "generator.expand"))() end)
pcall(function() loadstring(game:HttpGet(moduleRepo .. "farming.lua"))() end)

-- ==================== SAKA IA-APPLY ANG CONFIG ====================
SaveManager:LoadAutoloadConfig()

Library:Notify("Welcome! Tagumpay na na-load ang MakiHub.", 5)
