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

-- Helper Function para i-enable ang RichText
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

-- ===================================================
-- TABS CREATION
-- ===================================================
local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "sprout" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
-- ===================================================
-- TAB 1: PROGRESSION STATUS & PERFORMANCE
-- ===================================================

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
              "- <b>Feeders Status</b>    :  <font color='#00E5FF'>6 Active Units</font>"
})
FixRichText(MainProgPara)

local SysSection = Tabs.Info:AddSection("Performance Monitor")

local SysPara = SysSection:AddParagraph({
    Title = "Live System Metrics",
    Content = "\n- <b>FPS</b>       :  <font color='#FFD700'>Calculating...</font>\n\n- <b>Ping</b>      :  <font color='#00E5FF'>Calculating...</font>\n\n- <b>Executor</b>  :  Calculating..."
})
FixRichText(SysPara)

-- REAL-TIME SYSTEM MONITOR LOOP
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

-- ===================================================
-- TAB 2: FARMING CONTROLS
-- ===================================================

-- SECTION 1: AUTO PROGRESSION
local ProgFarmSection = Tabs.Farming:AddSection("🏆 Auto Progression")

ProgFarmSection:AddToggle("AutoProgression", { 
    Title = "Auto Progression", 
    Default = false,
    Callback = function(Value)
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
                            if type(res) == "table" then
                                currentRebirths = res.count or 0
                            else
                                currentRebirths = tonumber(res) or 0
                            end
                        end
                        
                        local reqFloor = RebirthBonus.requirementFloor(currentRebirths)
                        
                        local towerBest = 0
                        if type(DataController.towerBest) == "function" then
                            local successVal, resVal = pcall(DataController.towerBest)
                            if successVal then
                                towerBest = tonumber(resVal) or 0
                            end
                        elseif type(DataController.towerBest) == "number" then
                            towerBest = DataController.towerBest
                        end
                        
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
                        
                        if towerBest < reqFloor then
                            if not isInTower then
                                local elevatorRemote = Remotes:FindFirstChild("TowerElevator")
                                if elevatorRemote then
                                    pcall(function()
                                        if elevatorRemote:IsA("RemoteFunction") then
                                            elevatorRemote:InvokeServer(towerBest)
                                        else
                                            elevatorRemote:FireServer(towerBest)
                                        end
                                    end)
                                end
                                
                                task.wait(0.5)
                                
                                local startRemote = Remotes:FindFirstChild("TowerStart")
                                if startRemote then
                                    pcall(function()
                                        startRemote:InvokeServer()
                                    end)
                                end
                                
                                task.wait(getgenv().TowerDelay or 15)
                            end
                        else
                            pcall(function()
                                local retreatRemote = Remotes:FindFirstChild("TowerSurrender") 
                                                   or Remotes:FindFirstChild("Retreat") 
                                                   or Remotes:FindFirstChild("TowerRetreat")
                                if retreatRemote then
                                    if retreatRemote:IsA("RemoteFunction") then
                                        retreatRemote:InvokeServer()
                                    else
                                        retreatRemote:FireServer()
                                    end
                                end
                            end)
                            
                            task.wait(3)
                            
                            local rebirthRemote = Remotes:FindFirstChild("Rebirth")
                            if rebirthRemote then
                                pcall(function()
                                    if rebirthRemote:IsA("RemoteFunction") then
                                        rebirthRemote:InvokeServer()
                                    else
                                        rebirthRemote:FireServer()
                                    end
                                end)
                            end
                            
                            task.wait(4)
                        end
                    end)
                    
                    if not success then
                        warn("[Error]:", err)
                    end
                    
                    task.wait(2)
                end
            end)
        end
    end
})

ProgFarmSection:AddInput("FloorDelay", {
    Title = "Floor Farm Delay (Seconds)",
    Default = "1",
    Placeholder = "e.g. 0.5, 1, 2",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            getgenv().TowerDelay = num
        end
    end
})

-- SECTION 2: GENERAL FARM TOGGLES
local MainFarmSection = Tabs.Farming:AddSection("🚜 General Farm Toggles")

getgenv().AutoOpenAll = false
MainFarmSection:AddToggle("AutoOpenAll", { 
    Title = "Auto Open All Eggs", 
    Default = false,
    Callback = function(Value)
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
    end
})

getgenv().AutoCollectMyCoopOnly = false
MainFarmSection:AddToggle("AutoCollect", { 
    Title = "Auto Collect Coop Eggs", 
    Default = false,
    Callback = function(Value)
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
    end
})

getgenv().AutoUpgradeToggleState = false
getgenv().AutoUpgradeFeederTarget = 27
MainFarmSection:AddToggle("AutoUpgradeToggle", { 
    Title = "Auto Buy Feeders & Upgrade", 
    Default = false,
    Callback = function(Value)
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
                                        pcall(function()
                                            UpgradeGeneratorRemote:InvokeServer(index)
                                        end)
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
    end
})

getgenv().UltimateAutoCoop = false
MainFarmSection:AddToggle("AutoCoop", { 
    Title = "Auto Expand", 
    Default = false,
    Callback = function(Value)
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
                                if child.Name == "Feeder" then
                                    currentFeederCount = currentFeederCount + 1
                                end
                            end
                        end

                        if currentFeederCount >= maxAllowed then
                            if coopLevel >= 5 then
                                task.wait(5)
                                return
                            end

                            pcall(function()
                                ExpandEvent:InvokeServer()
                            end)
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
                                    
                                    if rawText:find("K") then
                                        multiplier = 1000
                                        rawText = rawText:gsub("K", "")
                                    elseif rawText:find("M") then
                                        multiplier = 1000000
                                        rawText = rawText:gsub("M", "")
                                    elseif rawText:find("B") then
                                        multiplier = 1000000000
                                        rawText = rawText:gsub("B", "")
                                    end
                                    
                                    playerMoney = (tonumber(rawText) or 0) * multiplier
                                end
                            end
                        end

                        if playerMoney < 1500 then
                            task.wait(3)
                            return
                        end

                        local targetSlot = currentFeederCount + 1
                        pcall(function()
                            BuyEvent:InvokeServer(targetSlot)
                        end)
                        
                        task.wait(getgenv().BuyGeneratorDelay or 3)
                    end)
                    
                    if not success then 
                        task.wait(2) 
                    end
                    
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ===================================================
-- AUTO CLOSE TELEMETRY & OFFERS
-- ===================================================
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
                    pcall(function()
                        continueDecline:FireServer()
                    end)
                end
            end)
        end
    end
end)

-- ===================================================
-- TAB 3: SETTINGS
-- ===================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("MakiHubFluent")
SaveManager:SetFolder("MakiHubFluent/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- AUTO LOAD CONFIG FIX
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "MAKI HUB v1.0",
    Content = "Script Loaded Successfully!",
    Duration = 4
})
