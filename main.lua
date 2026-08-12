local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ===================================================
-- MAIN WINDOW CREATION
-- ===================================================
local Window = Fluent:CreateWindow({
    Title = "MAKI HUB",
    SubTitle = "v1.0",
    TabWidth = 150,
    Size = UDim2.fromOffset(990, 650),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.End
})

-- ===================================================
-- MOBILE FLOATING TOGGLE BUTTON (75x75 CIRCLE)
-- ===================================================
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MakiHubMobileToggle"
ToggleGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ToggleGui
ToggleButton.Size = UDim2.fromOffset(75, 75)
ToggleButton.Position = UDim2.new(0, 15, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 136)
ToggleButton.Text = "MAKI"
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Active = true
ToggleButton.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 136)
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local function FixRichText(paragraphObj)
    task.spawn(function()
        task.wait(0.1)
        if paragraphObj and paragraphObj.Frame then
            for _, child in pairs(paragraphObj.Frame:GetDescendants()) do
                if child:IsA("TextLabel") then
                    child.RichText = true
                    child.TextSize = 16
                end
            end
        end
    end)
end

local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "sprout" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local ProgSection = Tabs.Info:AddSection("Progression Status")
local MainProgPara = ProgSection:AddParagraph({
    Title = "FARM OVERVIEW",
    Content = "\n" ..
              "- <b>Current Activity</b>  :  <font color='#00FF88'>[TEST] Waiting for action...</font>\n\n" ..
              "- <b>Current Floor</b>     :  <font color='#FFD700'>Floor 52</font>\n\n" ..
              "- <b>Highest Floor</b>     :  <font color='#FFD700'>Floor 60</font>\n\n" ..
              "- <b>Requirements</b>      :  <font color='#00FF88'>Floor 50 (GOAL REACHED!)</font>\n\n" ..
              "--------------------------------------------------\n\n" ..
              "- <b>Coop Level</b>        :  <font color='#00FF88'>Level 5 (MAX)</font>\n\n" ..
              "- <b>Generator Level</b>   :  <font color='#00FF88'>Level 10 (MAX)</font>\n\n" ..
              "- <b>Feeders Status</b>    :  <font color='#00E5FF'>6 Active Units</font> <font color='#AAAAAA'>(Level Range: 27-30)</font>"
})
FixRichText(MainProgPara)

local SysSection = Tabs.Info:AddSection("Performance Monitor")
local SysPara = SysSection:AddParagraph({
    Title = "Live System Metrics",
    Content = "\n- <b>FPS</b>       :  <font color='#FFD700'>Calculating...</font>\n\n- <b>Ping</b>      :  <font color='#00E5FF'>Calculating...</font>\n\n- <b>Executor</b>  :  Calculating..."
})
FixRichText(SysPara)

local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local lastUpdate = tick()
local frameCount = 0
local currentFPS = 60

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        currentFPS = math.floor(frameCount / (now - lastUpdate))
        frameCount = 0
        lastUpdate = now
        local ping = 0
        pcall(function()
            ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        SysPara:SetDesc(
            "\n- <b>FPS</b>       :  <font color='#FFD700'>" .. tostring(currentFPS) .. " FPS</font>\n\n" ..
            "- <b>Ping</b>      :  <font color='#00E5FF'>" .. tostring(ping) .. " ms</font>\n\n" ..
            "- <b>Executor</b>  :  " .. (identifyexecutor and identifyexecutor() or "Unknown Executor")
        )
    end
end)

local ProgFarmSection = Tabs.Farming:AddSection("🏆 Auto Progression")
local ToggleAutoProgression = ProgFarmSection:AddToggle("AutoProgression", { Title = "Auto Progression", Default = false })

local MainFarmSection = Tabs.Farming:AddSection("🚜 General Farm Toggles")
local ToggleOpenAll = MainFarmSection:AddToggle("AutoOpenAll", { Title = "Auto Open All Eggs", Default = false })
local ToggleCollectEggs = MainFarmSection:AddToggle("AutoCollect", { Title = "Auto Collect Coop Eggs", Default = false })
local ToggleBuyGenExpand = MainFarmSection:AddToggle("BuyGenExpand", { Title = "Buy Generator / Expand", Default = false })
local ToggleAutoUpgrade = MainFarmSection:AddToggle("AutoUpgrade", { Title = "Auto Upgrade Feeders", Default = false })

local ConfigFarmSection = Tabs.Farming:AddSection("⚙️ Farming Configs")
ConfigFarmSection:AddInput("FloorDelay", {
    Title = "Floor Farm Delay (Seconds)",
    Default = "1",
    Placeholder = "e.g. 0.5, 1, 2",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().TowerDelay = tonumber(Value) or 1 end
})
ConfigFarmSection:AddInput("EggDelay", {
    Title = "Egg Collect Delay (Seconds)",
    Default = "5",
    Placeholder = "e.g. 1, 3, 5",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().EggSpawnDelay = tonumber(Value) or 5 end
})
ConfigFarmSection:AddInput("ExpandDelay", {
    Title = "Expand Delay (Seconds)",
    Default = "5",
    Placeholder = "e.g. 2, 5, 10",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().ExpandDelay = tonumber(Value) or 5 end
})
ConfigFarmSection:AddDropdown("TargetUpgradeLevel", {
    Title = "Target Level (Auto Upgrade Feeders)",
    Values = {"10", "15", "20", "25", "27", "30", "35", "40"},
    Default = "27",
    Multi = false,
    Callback = function(Value) getgenv().AutoUpgradeFeederTarget = tonumber(Value) or 27 end
})
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    while true do
        if getgenv().AutoProgression then
            local success, err = pcall(function()
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
            if not success then warn("[Error]:", err) end
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

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MakiHubFluent")
SaveManager:SetFolder("MakiHubFluent/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

local DeleteSection = Tabs.Settings:AddSection("🗑️ Config Management")
DeleteSection:AddButton({
    Title = "Delete Current Config",
    Description = "Permanently deletes the active configuration file.",
    Callback = function()
        pcall(function()
            local folder = "MakiHubFluent/configs/"
            local configName = Options.SaveManager_ConfigList and Options.SaveManager_ConfigList.Value
            if configName and configName ~= "" then
                local fullPath = folder .. configName .. ".json"
                if delfile and isfile and isfile(fullPath) then
                    delfile(fullPath)
                    Fluent:Notify({ Title = "Success", Content = "Na-delete na ang config: " .. configName, Duration = 3 })
                else
                    if delfile then pcall(function() delfile(folder .. configName) end) end
                    Fluent:Notify({ Title = "Success", Content = "Triny burahin ang config.", Duration = 3 })
                end
            else
                Fluent:Notify({ Title = "Error", Content = "Walang napiling config sa dropdown para burahin.", Duration = 3 })
            end
        end)
    end
})

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "MAKI HUB v1.0",
    Content = "Script Loaded Successfully!",
    Duration = 4
})
