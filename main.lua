-- ===================================================
-- PART 1: WINDOW INITIALIZATION & UI SETUP
-- ===================================================
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
-- ===================================================
-- PART 2: INFO TAB & REAL-TIME LOOP
-- ===================================================
local ProgSection = Tabs.Info:AddSection("Progression Status")

local MainProgPara = ProgSection:AddParagraph({
    Title = "FARM OVERVIEW",
    Content = "\n" ..
              "- <b>Current Activity</b>  :  <font color='#00FF88'>Initializing...</font>\n\n" ..
              "- <b>Current Floor</b>     :  <font color='#FFD700'>0</font>\n\n" ..
              "- <b>Highest Floor</b>     :  <font color='#FFD700'>0</font>\n\n" ..
              "- <b>Requirements</b>      :  <font color='#FFD700'>Floor 0</font>\n\n" ..
              "--------------------------------------------------\n\n" ..
              "- <b>Coop Level</b>        :  <font color='#00FF88'>Level 1</font>\n\n" ..
              "- <b>Generator Level</b>   :  <font color='#00FF88'>Level 1</font>\n\n" ..
              "- <b>Feeders Status</b>    :  <font color='#00E5FF'>0 Active Units</font>"
})
FixRichText(MainProgPara)

local SysSection = Tabs.Info:AddSection("Performance Monitor")
local SysPara = SysSection:AddParagraph({
    Title = "Live System Metrics",
    Content = "\n- <b>FPS</b>       :  <font color='#FFD700'>Calculating...</font>\n\n- <b>Ping</b>      :  <font color='#00E5FF'>Calculating...</font>\n\n- <b>Executor</b>  :  Calculating..."
})
FixRichText(SysPara)

task.spawn(function()
    local RunService = game:GetService("RunService")
    local StatsService = game:GetService("Stats")
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

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
            
            local currentAct = getgenv().CurrentActivityText or "<font color='#FF4444'>Idle / Stopped</font>"
            local currFloor = "0"
            local highFloor = "0"
            local reqFloorVal = "0"
            local coopLvl = "1"
            local genLvl = "1"
            local activeFeeders = 0
            local minFeederLvl, maxFeederLvl = 99, 0

            pcall(function()
                local currentPlot = LocalPlayer:GetAttribute("Plot")
                if currentPlot ~= nil then
                    local arenasFolder = workspace:FindFirstChild("Arenas")
                    if arenasFolder ~= nil then
                        local arena = arenasFolder:FindFirstChild("Arena" .. tostring(currentPlot))
                        if arena ~= nil then
                            local liveFloor = arena:GetAttribute("TowerFloor")
                            if liveFloor ~= nil and tonumber(liveFloor) and tonumber(liveFloor) > 0 then
                                currFloor = tostring(liveFloor)
                            end
                        end
                    end
                end

                if currFloor == "0" then
                    pcall(function()
                        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                        if playerScripts ~= nil then
                            local DataController = require(playerScripts.Core.Data.DataController)
                            if type(DataController.floor) == "function" then
                                local f = DataController.floor()
                                if f and f > 0 then currFloor = tostring(f) end
                            elseif type(DataController.floor) == "number" and DataController.floor > 0 then
                                currFloor = tostring(DataController.floor)
                            end
                        end
                    end)
                end

                local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                if playerScripts then
                    local DataController = require(playerScripts.Core.Data.DataController)
                    local RebirthBonus = require(ReplicatedStorage.Core.Progression.RebirthBonus)
                    local currentRebirths = 0
                    if DataController.rebirth then
                        local res = DataController.rebirth()
                        currentRebirths = type(res) == "table" and (res.count or 0) or (tonumber(res) or 0)
                    end
                    reqFloorVal = tostring(RebirthBonus.requirementFloor(currentRebirths))
                    
                    if type(DataController.towerBest) == "function" then
                        highFloor = tostring(DataController.towerBest() or 0)
                    elseif type(DataController.towerBest) == "number" then
                        highFloor = tostring(DataController.towerBest)
                    end
                end

                local coopsFolder = workspace:FindFirstChild("Coops")
                if coopsFolder then
                    local myCoopUI = coopsFolder:FindFirstChild("CoopUI")
                    if myCoopUI then
                        for _, child in ipairs(myCoopUI:GetChildren()) do
                            if child.Name == "Feeder" then
                                activeFeeders = activeFeeders + 1
                                local lvl = child:GetAttribute("Level") or 1
                                if lvl < minFeederLvl then minFeederLvl = lvl end
                                if lvl > maxFeederLvl then maxFeederLvl = lvl end
                            end
                            local sGui = child:FindFirstChildOfClass("SurfaceGui")
                            if sGui then
                                for _, desc in ipairs(sGui:GetDescendants()) do
                                    if desc:IsA("TextLabel") and desc.Text:match("Nv%.(%d+)") then
                                        coopLvl = desc.Text:match("Nv%.(%d+)")
                                    end
                                end
                            end
                        end
                    end
                end
                if minFeederLvl > maxFeederLvl then minFeederLvl = 0 end
            end)

            local feederText = activeFeeders > 0 and string.format("%d Active Units (Level Range: %d-%d)", activeFeeders, minFeederLvl, maxFeederLvl) or "0 Active Units"

            MainProgPara:SetDesc(
                "\n" ..
                "- <b>Current Activity</b>  :  " .. currentAct .. "\n\n" ..
                "- <b>Current Floor</b>     :  <font color='#FFD700'>Floor " .. currFloor .."</font>\n\n" ..
                "- <b>Highest Floor</b>     :  <font color='#FFD700'>Floor " .. highFloor .. "</font>\n\n" ..
                "- <b>Requirements</b>      :  <font color='#00FF88'>Floor " .. reqFloorVal .. "</font>\n\n" ..
                "--------------------------------------------------\n\n" ..
                "- <b>Coop Level</b>        :  <font color='#00FF88'>Level " .. coopLvl .. "</font>\n\n" ..
                "- <b>Generator Level</b>   :  <font color='#00FF88'>Level " .. genLvl .. "</font>\n\n" ..
                "- <b>Feeders Status</b>    :  <font color='#00E5FF'>" .. feederText .. "</font>"
            )

            SysPara:SetDesc(
                "\n- <b>FPS</b>       :  <font color='#FFD700'>" .. tostring(currentFPS) .. " FPS</font>\n\n" ..
                "- <b>Ping</b>      :  <font color='#00E5FF'>" .. tostring(ping) .. " ms</font>\n\n" ..
                "- <b>Executor</b>  :  " .. (identifyexecutor and identifyexecutor() or "Unknown Executor")
            )
        end
    end)
end)
-- ===================================================
-- PART 3: GENERAL FARM TOGGLES (EGGS & COOP)
-- ===================================================
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

getgenv().UltimateAutoCoop = false
MainFarmSection:AddToggle("AutoCoop", { 
    Title = "Auto Expand Coop", 
    Default = false,
    Callback = function(Value)
        getgenv().UltimateAutoCoop = Value
        if Value then
            task.spawn(function()
                local Players = game:GetService("Players")
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

                        if coopLevel >= 5 then
                            task.wait(5)
                            return
                        end

                        pcall(function() ExpandEvent:InvokeServer() end)
                        task.wait(4)
                    end)
                    if not success then task.wait(2) end
                    task.wait(1)
                end
            end)
        end
    end
})
-- ===================================================
-- PART 4: FEEDERS UPGRADE & AUTO PROGRESSION SECTION
-- ===================================================
getgenv().AutoUpgradeToggleState = false
MainFarmSection:AddToggle("AutoUpgradeToggle", { 
    Title = "Auto Buy Feeders & Upgrade", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoUpgradeToggleState = Value
        if Value then
            task.spawn(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local BuyEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyGenerator")
                local UpgradeGeneratorRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeGenerator")
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer

                while getgenv().AutoUpgradeToggleState do
                    local coopsFolder = workspace:FindFirstChild("Coops")
                    local currentFeederCount = 0
                    local coopLevel = 1

                    if coopsFolder then
                        local myCoopUI = coopsFolder:FindFirstChild("CoopUI")
                        if myCoopUI then
                            for _, child in ipairs(myCoopUI:GetChildren()) do
                                if child.Name == "Feeder" then
                                    currentFeederCount = currentFeederCount + 1
                                end
                                local sGui = child:FindFirstChildOfClass("SurfaceGui")
                                if sGui then
                                    for _, desc in ipairs(sGui:GetDescendants()) do
                                        if desc:IsA("TextLabel") and desc.Text:match("Nv%.(%d+)") then
                                            coopLevel = tonumber(desc.Text:match("Nv%.(%d+)")) or 1
                                        end
                                    end
                                end
                            end

                            local maxAllowed = coopLevel + 1
                            if maxAllowed > 6 then maxAllowed = 6 end

                            if currentFeederCount < maxAllowed then
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

                                if playerMoney >= 1500 then
                                    local targetSlot = currentFeederCount + 1
                                    pcall(function() BuyEvent:InvokeServer(targetSlot) end)
                                    task.wait(2)
                                end
                            end

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
    end
})

local AutoProgSection = Tabs.Farming:AddSection("Auto Progression & Farming")

AutoProgSection:AddToggle("AutoProgressionToggle", {
    Title = "Auto Progression (Tower/Rebirth)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoProgression = Value
        if Value then
            getgenv().CurrentActivityText = "<font color='#00FF88'>Auto Progression Active...</font>"
        else
            getgenv().CurrentActivityText = "<font color='#FF4444'>Idle / Stopped</font>"
        end
    end
})
-- ===================================================
-- PART 5: FIXED AUTO PROGRESSION & DYNAMIC REMOTE FINDER
-- ===================================================
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Helper function para hanapin ang remote kahit saan sa ReplicatedStorage
    fnct_findRemote = function(name)
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name:lower() == name:lower() then
                return obj
            end
        end
        return nil
    end

    while task.wait(1) do
        if getgenv().AutoProgression then
            pcall(function()
                local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                if playerScripts then
                    local DataController = require(playerScripts.Core.Data.DataController)
                    local RebirthBonus = require(ReplicatedStorage.Core.Progression.RebirthBonus)
                    
                    local currentRebirths = 0
                    if DataController.rebirth then
                        local res = DataController.rebirth()
                        currentRebirths = type(res) == "table" and (res.count or 0) or (tonumber(res) or 0)
                    end
                    
                    local reqFloor = tonumber(RebirthBonus.requirementFloor(currentRebirths)) or 0
                    local towerBestVal = 0
                    if type(DataController.towerBest) == "function" then
                        towerBestVal = tonumber(DataController.towerBest() or 0)
                    elseif type(DataController.towerBest) == "number" then
                        towerBestVal = DataController.towerBest
                    end

                    if towerBestVal >= reqFloor then
                        getgenv().CurrentActivityText = "<font color='#FFD700'>Goal Reached! Retreating & Rebirthing...</font>"
                        
                        -- Dynamic remote search and trigger
                        local retreatRemote = fnct_findRemote("TowerSurrender") or fnct_findRemote("Surrender") or fnct_findRemote("LeaveTower") or fnct_findRemote("QuitTower")
                        if retreatRemote then
                            pcall(function() retreatRemote:FireServer() end)
                        end
                        
                        local rebirthRemote = fnct_findRemote("Rebirth") or fnct_findRemote("RequestRebirth") or fnct_findRemote("DoRebirth")
                        if rebirthRemote then
                            pcall(function() rebirthRemote:FireServer() end)
                        end
                        
                        task.wait(3)
                    else
                        getgenv().CurrentActivityText = "<font color='#00FF88'>Auto Progression Active (Climbing)...</font>"
                    end
                end
            end)
        end
    end
end)

local ConfigFarmSection = Tabs.Farming:AddSection("⚙️ Farming Config")

ConfigFarmSection:AddInput("FloorDelay", {
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

ConfigFarmSection:AddInput("EggDelay", {
    Title = "Egg Collect Delay (Seconds)",
    Default = "5",
    Placeholder = "e.g. 1, 3, 5",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then
            getgenv().EggSpawnDelay = num
        end
    end
})

ConfigFarmSection:AddDropdown("TargetUpgradeLevel", {
    Title = "Target Level (Auto Upgrade Generator)",
    Values = {"10", "15", "20", "25", "27", "30", "35", "40"},
    Default = "27",
    Multi = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            getgenv().AutoUpgradeFeederTarget = num
        end
    end
})       
-- ===================================================
-- PART 6: TELEMETRY, SETTINGS, & SAVE MANAGER
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

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "MAKI HUB v1.0",
    Content = "Script Updated Successfully!",
    Duration = 4
})
