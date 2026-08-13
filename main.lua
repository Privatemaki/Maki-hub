local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "MAKI HUB",
    Footer = "Maki Hub v2.5 | Ultimate Edition",
    Icon = "crown",
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

getgenv().AutoProgression = false
getgenv().TowerDelay = 1
getgenv().ExpandCoop = false
getgenv().ExpandTargetLevel = 2
getgenv().BuyGenerator = false
getgenv().AutoBuyGenTarget = 6
getgenv().UpgradeGenerator = false
getgenv().UpgradeGenTarget = 10
getgenv().UpgradeGeneratorMethod = "Teleport"
getgenv().UpgradeRecycler = false
getgenv().UpgradeRecyclerTarget = 10
getgenv().AutoCollectEgg = false
getgenv().CollectEggMethod = "Teleport"

local InfoLeft = Tabs.Info:AddLeftGroupbox("Progression Status", "info")
local LabelActivity = InfoLeft:AddLabel("Current Activity: Idle")
local LabelCurrFloor = InfoLeft:AddLabel("Current Floor: 0")
local LabelHighestFloor = InfoLeft:AddLabel("Highest Floor: 0")
local LabelReqs = InfoLeft:AddLabel("Requirements: Checking...")
InfoLeft:AddLabel("Coop Level: Synced")
InfoLeft:AddLabel("Generator Level: Synced")
InfoLeft:AddLabel("Feeders Status: Active")

local InfoRight = Tabs.Info:AddRightGroupbox("Performance Monitor", "activity")
local LabelFPS = InfoRight:AddLabel("FPS: Calculating...")
InfoRight:AddLabel("Ping: Calculating...")
InfoRight:AddLabel("Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"))

task.spawn(function()
    local RunService = game:GetService("RunService")
    local StatsService = game:GetService("Stats")
    local lastUpdate = tick()
    local frameCount = 0
    while true do
        frameCount = frameCount + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            local currentFPS = math.floor(frameCount / (now - lastUpdate))
            frameCount = 0
            lastUpdate = now
            LabelFPS:SetText("FPS: " .. tostring(currentFPS))
        end
        RunService.RenderStepped:Wait()
    end
end)

local BoxAutoTower = Tabs.Farming:AddLeftGroupbox("Auto Tower / Rebirth", "sword")
BoxAutoTower:AddToggle("AutoProgressionToggle", {
    Text = "Enable Auto Tower",
    Default = false,
    Callback = function(Value) getgenv().AutoProgression = Value end
})
BoxAutoTower:AddInput("TowerDelayInput", {
    Text = "Tower Delay",
    Default = "1",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().TowerDelay = tonumber(Value) or 1 end
})

local BoxExpandCoop = Tabs.Farming:AddLeftGroupbox("Expand Coop", "maximize-2")
BoxExpandCoop:AddToggle("ExpandCoopToggle", {
    Text = "Enable Expand Coop",
    Default = false,
    Callback = function(Value) getgenv().ExpandCoop = Value end
})
BoxExpandCoop:AddInput("ExpandTargetLevelInput", {
    Text = "Expand Target Level",
    Default = "2",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().ExpandTargetLevel = tonumber(Value) or 2 end
})

local BoxGenerators = Tabs.Farming:AddRightGroupbox("Generator Management", "cpu")
BoxGenerators:AddToggle("BuyGeneratorToggle", {
    Text = "Enable Buy Generator",
    Default = false,
    Callback = function(Value) getgenv().BuyGenerator = Value end
})
BoxGenerators:AddInput("AutoBuyGenTargetInput", {
    Text = "Target Generator Count (1-6)",
    Default = "6",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().AutoBuyGenTarget = tonumber(Value) or 6 end
})

BoxGenerators:AddDivider()

BoxGenerators:AddToggle("UpgradeGeneratorToggle", {
    Text = "Enable Upgrade Generator",
    Default = false,
    Callback = function(Value) getgenv().UpgradeGenerator = Value end
})
BoxGenerators:AddInput("UpgradeGenTargetInput", {
    Text = "Generator Target Level",
    Default = "10",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().UpgradeGenTarget = tonumber(Value) or 10 end
})
BoxGenerators:AddDropdown("UpgradeGeneratorMethodDropdown", {
    Values = { "Teleport", "Walk" },
    Default = "Teleport",
    Text = "Upgrade Method",
    Callback = function(Value) getgenv().UpgradeGeneratorMethod = Value end
})

local BoxRecyclerEggs = Tabs.Farming:AddRightGroupbox("Recycler & Eggs", "refresh-cw")
BoxRecyclerEggs:AddToggle("UpgradeRecyclerToggle", {
    Text = "Enable Upgrade Recycler",
    Default = false,
    Callback = function(Value) getgenv().UpgradeRecycler = Value end
})
BoxRecyclerEggs:AddInput("UpgradeRecyclerTargetInput", {
    Text = "Recycler Target Level",
    Default = "10",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().UpgradeRecyclerTarget = tonumber(Value) or 10 end
})

BoxRecyclerEggs:AddDivider()

BoxRecyclerEggs:AddToggle("AutoCollectEggToggle", {
    Text = "Enable Auto Collect Egg",
    Default = false,
    Callback = function(Value) getgenv().AutoCollectEgg = Value end
})
BoxRecyclerEggs:AddDropdown("CollectEggMethodDropdown", {
    Values = { "Teleport", "Walk" },
    Default = "Teleport",
    Text = "Egg Collect Method",
    Callback = function(Value) getgenv().CollectEggMethod = Value end
})

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
    
    while true do
        if getgenv().AutoProgression and Remotes then
            pcall(function()
                local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                if not playerScripts then return end
                
                local DataController = require(playerScripts.Core.Data.DataController)
                local RebirthBonus = require(ReplicatedStorage.Core.Progression.RebirthBonus)
                
                local currentRebirths = 0
                if DataController.rebirth then
                    local res = DataController.rebirth()
                    if type(res) == "table" then currentRebirths = res.count or 0
                    else currentRebirths = tonumber(res) or 0 end
                end
                
                local reqFloor = RebirthBonus.requirementFloor(currentRebirths)
                local towerBest = 0
                if type(DataController.towerBest) == "function" then
                    local successVal, resVal = pcall(DataController.towerBest)
                    if successVal then towerBest = tonumber(resVal) or 0 end
                elseif type(DataController.towerBest) == "number" then
                    towerBest = DataController.towerBest
                end
                
                LabelReqs:SetText("Requirements: Floor " .. tostring(reqFloor))
                LabelHighestFloor:SetText("Highest Floor: " .. tostring(towerBest))

                local liveFloor = 0
                pcall(function()
                    local currentPlot = LocalPlayer:GetAttribute("Plot")
                    if currentPlot ~= nil then
                        local arenasFolder = workspace:FindFirstChild("Arenas")
                        if arenasFolder ~= nil then
                            local arena = arenasFolder:FindFirstChild("Arena" .. tostring(currentPlot))
                            if arena ~= nil then
                                local f = arena:GetAttribute("TowerFloor")
                                if f then liveFloor = tonumber(f) or 0 end
                            end
                        end
                    end
                end)
                LabelCurrFloor:SetText("Current Floor: " .. tostring(liveFloor))
                
                local where = "corral"
                pcall(function()
                    if playerScripts:FindFirstChild("Features") and playerScripts.Features:FindFirstChild("Chicken") then
                        local chickenMode = playerScripts.Features.Chicken:FindFirstChild("ChickenMode")
                        if chickenMode and chickenMode:FindFirstChild("where") then
                            where = chickenMode.where()
                        end
                    end
                end)
                
                local isInTower = (where == "campaign" or where == "tower")
                
                if (liveFloor > 0 and liveFloor < reqFloor) or (towerBest < reqFloor and not isInTower) then
                    LabelActivity:SetText("Current Activity: Climbing Tower")
                    if not isInTower then
                        local elevatorRemote = Remotes:FindFirstChild("TowerElevator")
                        if elevatorRemote then
                            pcall(function()
                                if elevatorRemote:IsA("RemoteFunction") then elevatorRemote:InvokeServer(towerBest)
                                else elevatorRemote:FireServer(towerBest) end
                            end)
                        end
                        task.wait(0.5)
                        local startRemote = Remotes:FindFirstChild("TowerStart")
                        if startRemote then pcall(function() startRemote:InvokeServer() end) end
                        task.wait(getgenv().TowerDelay or 1)
                    end
                else
                    LabelActivity:SetText("Current Activity: Rebirthing")
                    pcall(function()
                        local retreatRemote = Remotes:FindFirstChild("TowerSurrender") or Remotes:FindFirstChild("Retreat") or Remotes:FindFirstChild("TowerRetreat")
                        if retreatRemote then
                            if retreatRemote:IsA("RemoteFunction") then retreatRemote:InvokeServer()
                            else retreatRemote:FireServer() end
                        end
                    end)
                    task.wait(3)
                    local rebirthRemote = Remotes:FindFirstChild("Rebirth")
                    if rebirthRemote then
                        pcall(function()
                            if rebirthRemote:IsA("RemoteFunction") then rebirthRemote:InvokeServer()
                            else rebirthRemote:FireServer() end
                        end)
                    end
                    task.wait(4)
                end
            end)
        else
            LabelActivity:SetText("Current Activity: Idle")
        end
        task.wait(2)
    end
end)

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
    if remotesFolder then
        local continueOffer = remotesFolder:FindFirstChild("TowerContinueOffer")
        local continueDecline = remotesFolder:FindFirstChild("TowerContinueDecline")
        if continueOffer and continueDecline then
            continueOffer.OnClientEvent:Connect(function()
                if getgenv().AutoProgression then
                    task.wait(0.1)
                    pcall(function() continueDecline:FireServer() end)
                end
            end)
        end
    end
end)

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
    
    while true do
        if remotes then
            pcall(function()
                if getgenv().ExpandCoop then
                    local targetCoopLevel = tonumber(getgenv().ExpandTargetLevel) or 2
                    local currentCoopLevel = 0
                    
                    pcall(function()
                        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                        if playerScripts then
                            local DataController = require(playerScripts.Core.Data.DataController)
                            if DataController then
                                local coopData = nil
                                if type(DataController.coop) == "function" then
                                    coopData = DataController.coop()
                                elseif type(DataController.coop) == "table" then
                                    coopData = DataController.coop
                                elseif DataController.GetCoopData then
                                    coopData = DataController.GetCoopData()
                                end
                                
                                if type(coopData) == "table" then
                                    currentCoopLevel = coopData.level or coopData.tier or coopData.count or 0
                                elseif type(coopData) == "number" then
                                    currentCoopLevel = coopData
                                end
                            end
                        end
                    end)
                    
                    if currentCoopLevel == 0 then
                        pcall(function()
                            local attr = LocalPlayer:GetAttribute("CoopLevel") or LocalPlayer:GetAttribute("CoopSize")
                            if attr then currentCoopLevel = tonumber(attr) or 0 end
                        end)
                    end
                    
                    if currentCoopLevel < targetCoopLevel then
                        local expandRemote = remotes:FindFirstChild("ExpandCoop") or remotes:FindFirstChild("Expand")
                        if expandRemote then
                            if expandRemote:IsA("RemoteFunction") then 
                                expandRemote:InvokeServer() 
                            else 
                                expandRemote:FireServer() 
                            end
                        end
                    end
                end
                
                if getgenv().BuyGenerator then
                    local maxTarget = math.clamp(getgenv().AutoBuyGenTarget or 6, 1, 6)
                    local currentCount = 0
                    
                    pcall(function()
                        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                        if playerScripts then
                            local DataController = require(playerScripts.Core.Data.DataController)
                            if DataController then
                                local genData = nil
                                if type(DataController.generators) == "function" then
                                    genData = DataController.generators()
                                elseif type(DataController.generators) == "table" then
                                    genData = DataController.generators
                                elseif DataController.GetGeneratorData then
                                    genData = DataController.GetGeneratorData()
                                end
                                
                                if type(genData) == "table" then
                                    local c = 0
                                    for _, _ in pairs(genData) do
                                        c = c + 1
                                    end
                                    currentCount = c
                                end
                            end
                        end
                    end)
                    
                    if currentCount == 0 then
                        pcall(function()
                            local currentPlot = LocalPlayer:GetAttribute("Plot")
                            if currentPlot ~= nil then
                                for _, obj in ipairs(workspace:GetDescendants()) do
                                    if obj:IsA("Model") and obj.Name:lower():find("generator") then
                                        if obj.Parent and obj.Parent.Name:lower():find(tostring(currentPlot)) then
                                            currentCount = currentCount + 1
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    
                    if currentCount < maxTarget then
                        local genRemote = remotes:FindFirstChild("BuyGenerator") or remotes:FindFirstChild("GeneratorBuy") or remotes:FindFirstChild("BuyGen")
                        if genRemote then
                            local nextIndex = currentCount + 1
                            if nextIndex <= maxTarget then
                                if genRemote:IsA("RemoteFunction") then 
                                    genRemote:InvokeServer(nextIndex) 
                                else 
                                    genRemote:FireServer(nextIndex) 
                                end
                            end
                        end
                    end
                end
                
                if getgenv().UpgradeGenerator then
                    local upGenRemote = remotes:FindFirstChild("UpgradeGenerator") or remotes:FindFirstChild("GeneratorUpgrade") or remotes:FindFirstChild("UpgradeGen")
                    if upGenRemote then
                        for i = 1, 6 do
                            if not getgenv().UpgradeGenerator then break end
                            pcall(function()
                                if upGenRemote:IsA("RemoteFunction") then 
                                    upGenRemote:InvokeServer(i) 
                                else 
                                    upGenRemote:FireServer(i) 
                                end
                            end)
                            task.wait(0.15)
                        end
                    end
                end
                
                if getgenv().UpgradeRecycler then
                    local upRecRemote = remotes:FindFirstChild("UpgradeRecycler") or remotes:FindFirstChild("RecyclerUpgrade")
                    if upRecRemote then
                        if upRecRemote:IsA("RemoteFunction") then upRecRemote:InvokeServer() else upRecRemote:FireServer() end
                    end
                end
                
                if getgenv().AutoCollectEgg then
                    local eggRemote = remotes:FindFirstChild("CollectEgg") or remotes:FindFirstChild("ClaimEggs") or remotes:FindFirstChild("EggCollect")
                    if eggRemote then
                        if eggRemote:IsA("RemoteFunction") then eggRemote:InvokeServer() else eggRemote:FireServer() end
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

local SettingsLeft = Tabs.Settings:AddLeftGroupbox("Menu & Config Management", "settings")

SettingsLeft:AddButton("Unload", function() Library:Unload() end)
SettingsLeft:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "End", NoUI = true, Text = "Menu keybind" })

SettingsLeft:AddButton("Auto Rejoin", function()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    ts:Teleport(game.PlaceId, p)
end)

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
