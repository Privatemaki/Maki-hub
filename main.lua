local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "MAKI HUB",
    SubTitle = "v1.0",
    TabWidth = 150,
    Size = UDim2.fromOffset(990, 650),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.End
})

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

-- TAB 1: INFO & PERFORMANCE
local ProgSection = Tabs.Info:AddSection("Progression Status")
local MainProgPara = ProgSection:AddParagraph({
    Title = "FARM OVERVIEW",
    Content = "\n- <b>Status</b>: <font color='#00FF88'>Maki Hub Active (Fluent UI)</font>"
})
FixRichText(MainProgPara)

local SysSection = Tabs.Info:AddSection("Performance Monitor")
local SysPara = SysSection:AddParagraph({
    Title = "Live System Metrics",
    Content = "\n- <b>FPS</b> : Calculating...\n- <b>Ping</b> : Calculating..."
})
FixRichText(SysPara)

local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        local currentFPS = math.floor(frameCount / (now - lastUpdate))
        frameCount = 0
        lastUpdate = now
        local ping = 0
        pcall(function() ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        SysPara:SetDesc("\n- <b>FPS</b> : <font color='#FFD700'>" .. tostring(currentFPS) .. " FPS</font>\n\n- <b>Ping</b> : <font color='#00E5FF'>" .. tostring(ping) .. " ms</font>\n\n- <b>Executor</b> : " .. (identifyexecutor and identifyexecutor() or "Unknown"))
    end
end)

-- TAB 2: SMART FLOW & FARMING
local SmartFlowSection = Tabs.Farming:AddSection("🏆 Smart Flow & Auto Progression")
local StatusParagraph = SmartFlowSection:AddParagraph({
    Title = "Smart Flow Monitor",
    Content = "Status: Idle\nFloor Info: 0 / 0"
})
FixRichText(StatusParagraph)

getgenv().AutoProgression = false
getgenv().TowerDelay = 15

SmartFlowSection:AddToggle("AutoProgressionToggle", { Title = "Enable Progression Flow", Default = false })
Options.AutoProgressionToggle:OnChanged(function(Value)
    getgenv().AutoProgression = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Remotes = ReplicatedStorage:WaitForChild("Remotes")
            
            while getgenv().AutoProgression do
                local success, err = pcall(function()
                    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                    if not playerScripts then return end
                    
                    local DataController = require(playerScripts.Core.Data.DataController)
                    local RebirthBonus = require(ReplicatedStorage.Core.Progression.RebirthBonus)
                    
                    local currentRebirths = 0
                    if DataController.rebirth then
                        local res = DataController.rebirth()
                        currentRebirths = type(res) == "table" and (res.count or 0) or (tonumber(res) or 0)
                    end
                    
                    local reqFloor = RebirthBonus.requirementFloor(currentRebirths)
                    local towerBest = 0
                    if type(DataController.towerBest) == "function" then
                        local sv, rv = pcall(DataController.towerBest)
                        if sv then towerBest = tonumber(rv) or 0 end
                    elseif type(DataController.towerBest) == "number" then
                        towerBest = DataController.towerBest
                    end
                    
                    local floorText = "Highest Floor: " .. tostring(towerBest) .. " / Req: " .. tostring(reqFloor)
                    if towerBest >= reqFloor then
                        floorText = "<font color='#00FF00'>Highest Floor: " .. tostring(towerBest) .. " / Req: " .. tostring(reqFloor) .. "</font>"
                    end
                    
                    local where = "corral"
                    pcall(function()
                        if playerScripts:FindFirstChild("Features") and playerScripts.Features:FindFirstChild("Chicken") then
                            local cm = playerScripts.Features.Chicken:FindFirstChild("ChickenMode")
                            if cm and cm:FindFirstChild("where") then where = cm.where() end
                        end
                    end)
                    
                    local isInTower = (where == "campaign" or where == "tower")
                    
                    if towerBest < reqFloor then
                        if not isInTower then
                            StatusParagraph:SetDesc("Status: Running Elevator (Floor " .. tostring(towerBest) .. ")\n" .. floorText)
                            local er = Remotes:FindFirstChild("TowerElevator")
                            if er then pcall(function() if er:IsA("RemoteFunction") then er:InvokeServer(towerBest) else er:FireServer(towerBest) end end) end
                            task.wait(0.5)
                            StatusParagraph:SetDesc("Status: Starting Tower Run...\n" .. floorText)
                            local sr = Remotes:FindFirstChild("TowerStart")
                            if sr then pcall(function() sr:InvokeServer() end) end
                            task.wait(getgenv().TowerDelay or 15)
                        else
                            StatusParagraph:SetDesc("Status: Playing inside tower...\n" .. floorText)
                        end
                    else
                        StatusParagraph:SetDesc("Status: Retreating from Tower...\n" .. floorText)
                        pcall(function()
                            local rr = Remotes:FindFirstChild("TowerSurrender") or Remotes:FindFirstChild("Retreat") or Remotes:FindFirstChild("TowerRetreat")
                            if rr then if rr:IsA("RemoteFunction") then rr:InvokeServer() else rr:FireServer() end end
                        end)
                        task.wait(3)
                        StatusParagraph:SetDesc("Status: Executing Rebirth...\n" .. floorText)
                        local rbr = Remotes:FindFirstChild("Rebirth")
                        if rbr then pcall(function() if rbr:IsA("RemoteFunction") then rbr:InvokeServer() else rbr:FireServer() end end) end
                        task.wait(4)
                    end
                end)
                if not success then warn("[Error]:", err) end
                task.wait(2)
            end
            StatusParagraph:SetDesc("Status: Idle\nFloor Info: 0 / 0")
        end)
    end
end)

SmartFlowSection:AddInput("TowerDelayInput", {
    Title = "Tower Start Delay (Seconds)",
    Default = "15",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then getgenv().TowerDelay = num end
    end
})
local HatchSection = Tabs.Farming:AddSection("🥚 Hatch Config")

getgenv().AutoOpenAll = false
HatchSection:AddToggle("AutoOpenAllToggle", { Title = "Auto Open All Eggs", Default = false })
Options.AutoOpenAllToggle:OnChanged(function(Value)
    getgenv().AutoOpenAll = Value
    if Value then
        task.spawn(function()
            local HatchEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HatchEgg")
            local eggList = {"barn", "feed", "storm", "crown", "golden", "ordnance", "arena", "fang", "charm", "meme", "bloom", "diner", "haunt", "circuit", "void", "rival", "hotEgg"}
            while getgenv().AutoOpenAll do
                for _, eggName in ipairs(eggList) do
                    if not getgenv().AutoOpenAll then break end
                    pcall(function() HatchEvent:InvokeServer(eggName) end)
                    task.wait(0.1)
                end
                task.wait(0.2)
            end
        end)
    end
end)

getgenv().EggSpawnDelay = 5
HatchSection:AddInput("EggDelayInput", {
    Title = "Egg Collect Delay (s)",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then getgenv().EggSpawnDelay = num end
    end
})

getgenv().AutoCollectMyCoopOnly = false
HatchSection:AddToggle("AutoCollectEggsToggle", { Title = "Auto Collect Coop Eggs (Timer)", Default = false })
Options.AutoCollectEggsToggle:OnChanged(function(Value)
    getgenv().AutoCollectMyCoopOnly = Value
    if Value then
        task.spawn(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            while getgenv().AutoCollectMyCoopOnly do
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local coopsFolder = workspace:FindFirstChild("Coops")
                    local myCoop = nil
                    if coopsFolder then
                        local closestDist = math.huge
                        for _, coop in ipairs(coopsFolder:GetChildren()) do
                            local coopPart = coop:IsA("Model") and coop.PrimaryPart or coop:FindFirstChildWhichIsA("BasePart")
                            if coopPart then
                                local dist = (rootPart.Position - coopPart.Position).Magnitude
                                if dist < closestDist and dist < 40 then 
                                    closestDist = dist
                                    myCoop = coop
                                end
                            end
                        end
                        if myCoop then
                            local nestEggsFolder = workspace:FindFirstChild("NestEggs")
                            local hasEggToCollect = false
                            if nestEggsFolder and #nestEggsFolder:GetChildren() > 0 then
                                for _, egg in ipairs(nestEggsFolder:GetChildren()) do
                                    local eggPart = egg:IsA("Model") and egg.PrimaryPart or (egg:IsA("BasePart") and egg or nil)
                                    local coopCenter = myCoop:IsA("Model") and myCoop.PrimaryPart or myCoop:FindFirstChildWhichIsA("BasePart")
                                    if eggPart and coopCenter and (eggPart.Position - coopCenter.Position).Magnitude <= 20 then
                                        hasEggToCollect = true
                                        break
                                    end
                                end
                            end
                            if hasEggToCollect then
                                task.wait(getgenv().EggSpawnDelay or 5)
                                for _, egg in ipairs(nestEggsFolder:GetChildren()) do
                                    if not getgenv().AutoCollectMyCoopOnly then break end
                                    local eggPart = egg:IsA("Model") and egg.PrimaryPart or (egg:IsA("BasePart") and egg or nil)
                                    local coopCenter = myCoop:IsA("Model") and myCoop.PrimaryPart or myCoop:FindFirstChildWhichIsA("BasePart")
                                    if eggPart and coopCenter and (eggPart.Position - coopCenter.Position).Magnitude <= 20 then
                                        rootPart.CFrame = eggPart.CFrame + Vector3.new(0, 2, 0)
                                        task.wait(0.3)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                else
                    task.wait(1)
                end
            end
        end)
    end
end)

local BuyExpandSection = Tabs.Farming:AddSection("🚜 Buy Feeders & Expand")

getgenv().UltimateAutoCoop = false
getgenv().BuyGeneratorDelay = 3
getgenv().AutoUpgradeFeederTarget = 27
getgenv().AutoUpgradeToggleState = false

BuyExpandSection:AddToggle("AutoUpgradeToggle", { Title = "Auto Upgrade Feeder", Default = false })
Options.AutoUpgradeToggle:OnChanged(function(Value)
    getgenv().AutoUpgradeToggleState = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local UpgradeGeneratorRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeGenerator")

            while getgenv().AutoUpgradeToggleState do
                local coopsFolder = workspace:FindFirstChild("Coops")
                if coopsFolder then
                    local myCoopUI = coopsFolder:FindFirstChild("CoopUI")
                    if myCoopUI then
                        local children = myCoopUI:GetChildren()
                        local index = 1
                        local TARGET_LEVEL = getgenv().AutoUpgradeFeederTarget or 27
                        
                        for _, child in ipairs(children) do
                            if not getgenv().AutoUpgradeToggleState then break end
                            local currentLevel = child:GetAttribute("Level")
                            
                            if currentLevel then
                                if currentLevel < TARGET_LEVEL then
                                    pcall(function() UpgradeGeneratorRemote:InvokeServer(index) end)
                                    task.wait(0.5)
                                    break 
                                end
                                index = index + 1
                            end
                        end
                    end
                end
                task.wait(0.7)
            end
        end)
    end
end)

BuyExpandSection:AddDropdown("AutoUpgradeTargetDropdown", {
    Title = "Feeder Target Level",
    Values = { "10", "15", "20", "25", "27", "30", "40", "50" },
    Default = "27",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then getgenv().AutoUpgradeFeederTarget = num end
    end
})

BuyExpandSection:AddDropdown("BuyGeneratorDelayDropdown", {
    Title = "Delay to Buy Generator",
    Values = { "0.5s", "1s", "2s", "3s", "5s" },
    Default = "3s",
    Callback = function(Value)
        local numStr = Value:gsub("s", "")
        getgenv().BuyGeneratorDelay = tonumber(numStr) or 3
    end
})

BuyExpandSection:AddToggle("UltimateAutoCoopToggle", { Title = "Auto Buy Feeders & Expand", Default = false })
Options.UltimateAutoCoopToggle:OnChanged(function(Value)
    getgenv().UltimateAutoCoop = Value
    if Value then
        task.spawn(function()
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local LocalPlayer = Players.LocalPlayer
            
            local BuyEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyGenerator")
            local ExpandEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ExpandCoop")

            while getgenv().UltimateAutoCoop do
                local success, err = pcall(function()
                    local coopLevel = 1 
                    local coopsFolder = workspace:FindFirstChild("Coops")
                    
                    if coopsFolder then
                        local myCoopUI = coopsFolder:FindFirstChild("CoopUI")
                        if myCoopUI then
                            for _, child in ipairs(myCoopUI:GetChildren()) do
                                local sGui = child:FindFirstChildOfClass("SurfaceGui")
                                if sGui then
                                    for _, desc in ipairs(sGui:GetDescendants()) do
                                        if desc:IsA("TextLabel") then
                                            local txt = desc.Text or ""
                                            if txt:match("Nv%.(%d+)") then
                                                local lvl = tonumber(txt:match("Nv%.(%d+)"))
                                                if lvl and lvl >= 1 and lvl <= 5 then
                                                    coopLevel = lvl
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                                if coopLevel > 1 then break end
                            end
                        end
                    end

                    local maxAllowed = coopLevel + 1
                    if maxAllowed > 6 then maxAllowed = 6 end

                    local currentFeederCount = 0
                    if coopsFolder and coopsFolder:FindFirstChild("CoopUI") then
                        for _, child in ipairs(coopsFolder.CoopUI:GetChildren()) do
                            if child.Name == "Feeder" then currentFeederCount = currentFeederCount + 1 end
                        end
                    end

                    if currentFeederCount >= maxAllowed then
                        if coopLevel >= 5 then task.wait(5) return end
                        pcall(function() ExpandEvent:InvokeServer() end)
                        task.wait(4)
                        return
                    end

                    local playerMoney = 0
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        local hud = playerGui:FindFirstChild("HUD")
                        local moneyFolder = hud and hud:FindFirstChild("Frame") and hud.Frame:FindFirstChild("money")
                        if moneyFolder then
                            local qFolder = moneyFolder:FindFirstChild("q")
                            local numLabel = qFolder and qFolder:FindFirstChild("num")
                            if numLabel and numLabel:IsA("TextLabel") then
                                local rawText = numLabel.Text:upper():gsub(",", "")
                                local multiplier = 1
                                if rawText:find("K") then multiplier = 1000 rawText = rawText:gsub("K", "")
                                elseif rawText:find("M") then multiplier = 1000000 rawText = rawText:gsub("M", "")
                                elseif rawText:find("B") then multiplier = 1000000000 rawText = rawText:gsub("B", "") end
                                playerMoney = (tonumber(rawText) or 0) * multiplier
                            end
                        end
                    end

                    if playerMoney < 1500 then task.wait(3) return end

                    local targetSlot = currentFeederCount + 1
                    pcall(function() BuyEvent:InvokeServer(targetSlot) end)
                    task.wait(getgenv().BuyGeneratorDelay or 3)
                end)
                if not success then task.wait(2) end
                task.wait(0.5)
            end
        end)
    end
end)

-- TAB 3: SETTINGS & AUTO-LOAD CONFIG
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("MakiHubFluent")
SaveManager:SetFolder("MakiHubFluent/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "MAKI HUB v1.0",
    Content = "All Functions & Auto-Load Loaded!",
    Duration = 5
})
