local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "𝙼𝙰𝙺𝙸 𝙷𝚄𝙱",
    Footer = "Maki Hub | TV Screen Edition",
    Icon = 6023426915,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- TAB ORDER: INFO -> FARMING -> SETTINGS
local Tabs = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "sprout"),
    ["UI Settings"] = Window:AddTab("Settings", "settings"),
}

getgenv().MakiHubWindow = Window
getgenv().MakiHubTabs = Tabs

-- UI Settings Group
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

-- ===================================================
-- 1ST TAB: INFO (TV SCREEN DASHBOARD)
-- ===================================================
local LiveProgressionGroup = Tabs.Info:AddLeftGroupbox("📺 LIVE PROGRESSION MONITOR", "activity")
local HubInfoGroup = Tabs.Info:AddLeftGroupbox("ℹ️ HUB & PLAYER INFO", "user")

LiveProgressionGroup:AddLabel("<font color=\"#00FF88\"><b>==================== MAIN STATUS ====================</b></font>")
local StatusLabel = LiveProgressionGroup:AddLabel("<font color=\"#FFFFFF\">Current Activity : </font><font color=\"#AAAAAA\">Idle</font>")
local FloorLabel = LiveProgressionGroup:AddLabel("<font color=\"#FFFFFF\">Floor Requirement : </font><font color=\"#FF9900\">Highest: 0 / Required: 0</font>")

LiveProgressionGroup:AddDivider()
LiveProgressionGroup:AddLabel("<font color=\"#00E5FF\"><b>==================== FARM STATUS ====================</b></font>")
local CoopStatusLabel = LiveProgressionGroup:AddLabel("<font color=\"#FFFFFF\">Coop Level : </font><font color=\"#00FF00\">Detecting...</font>")
local FeederStatusLabel = LiveProgressionGroup:AddLabel("<font color=\"#FFFFFF\">Feeder Stats : </font><font color=\"#00E5FF\">Detecting...</font>")

LiveProgressionGroup:AddDivider()
LiveProgressionGroup:AddLabel("<font color=\"#FFCC00\"><b>================== AUTOMATION FLOW ==================</b></font>")
LiveProgressionGroup:AddLabel("<font color=\"#AAAAAA\">[✓] Auto Tower Progression & Auto Screen Clicker</font>")
LiveProgressionGroup:AddLabel("<font color=\"#AAAAAA\">[✓] Auto Rebirth Screen Bypass Enabled</font>")

HubInfoGroup:AddLabel("Script Name : <font color=\"#FFCC00\"><b>MAKI HUB</b></font>  |  Version : <font color=\"#00FF00\">v4.0 Fixed Rebirth</font>")
HubInfoGroup:AddLabel("Status      : <font color=\"#00FF00\">Undetected / Active</font>")
HubInfoGroup:AddLabel("Player Name : <font color=\"#FFFFFF\">" .. game:GetService("Players").LocalPlayer.DisplayName .. "</font>")

-- ===================================================
-- 2ND TAB: FARMING - LEFT COLUMN (MAIN TOGGLES)
-- ===================================================
local MainControlsGroup = Tabs.Farming:AddLeftGroupbox("🟢 MAIN TOGGLES", "sliders")

getgenv().AutoOpenAll = false
getgenv().AutoCollectMyCoopOnly = false
getgenv().UltimateAutoCoop = false
getgenv().AutoUpgradeToggleState = false
getgenv().AutoProgression = false

MainControlsGroup:AddToggle("AutoOpenAllToggle", {
    Text = "Auto Open All Eggs",
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

MainControlsGroup:AddToggle("AutoCollectEggsToggle", {
    Text = "Auto Collect Coop Eggs",
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
MainControlsGroup:AddToggle("UltimateAutoCoopToggle", {
    Text = "Auto Buy Feeders & Expand",
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

MainControlsGroup:AddToggle("AutoUpgradeToggle", {
    Text = "Auto Upgrade Feeders",
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

-- ===================================================
-- 2ND TAB: FARMING - RIGHT COLUMN (ISANG BUONG CONFIG BOX)
-- ===================================================
local AllConfigsGroup = Tabs.Farming:AddRightGroupbox("⚙️ ALL CONFIGURATIONS", "settings")

getgenv().EggSpawnDelay = 5
getgenv().BuyGeneratorDelay = 3
getgenv().AutoUpgradeFeederTarget = 27
getgenv().TowerDelay = 15

AllConfigsGroup:AddLabel("<font color=\"#00FF88\"><b>--- Hatch Settings ---</b></font>")
AllConfigsGroup:AddInput("EggDelayInput", {
    Text = "Egg Collect Delay (s)",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then getgenv().EggSpawnDelay = num end
    end
})

AllConfigsGroup:AddDivider()
AllConfigsGroup:AddLabel("<font color=\"#00E5FF\"><b>--- Feeder Settings ---</b></font>")
AllConfigsGroup:AddDropdown("AutoUpgradeTargetDropdown", {
    Values = { "10", "15", "20", "25", "27", "30", "40", "50" },
    Default = "27",
    Text = "Feeder Target Level",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then getgenv().AutoUpgradeFeederTarget = num end
    end
})

AllConfigsGroup:AddDropdown("BuyGeneratorDelayDropdown", {
    Values = { "0.5s", "1s", "2s", "3s", "5s" },
    Default = "3s",
    Text = "Buy Generator Delay",
    Callback = function(Value)
        local numStr = Value:gsub("s", "")
        getgenv().BuyGeneratorDelay = tonumber(numStr) or 3
    end
})

AllConfigsGroup:AddDivider()
AllConfigsGroup:AddLabel("<font color=\"#FF9900\"><b>--- Tower Settings ---</b></font>")
AllConfigsGroup:AddInput("TowerDelayInput", {
    Text = "Tower Start Delay (s)",
    Default = "15",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then getgenv().TowerDelay = num end
    end
})
-- ===================================================
-- LIVE MONITORING LOOP FOR COOP & FEEDERS
-- ===================================================
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local coopsFolder = workspace:FindFirstChild("Coops")
            local coopLevel = 1
            local feederCount = 0
            local lowestFeederLvl = math.huge
            local highestFeederLvl = 0

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
                                        if lvl then
                                            coopLevel = lvl
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        if child.Name == "Feeder" or child:GetAttribute("Level") then
                            feederCount = feederCount + 1
                            local fLvl = child:GetAttribute("Level") or 1
                            if fLvl < lowestFeederLvl then lowestFeederLvl = fLvl end
                            if fLvl > highestFeederLvl then highestFeederLvl = fLvl end
                        end
                    end
                end
            end

            CoopStatusLabel:SetText("<font color=\"#FFFFFF\">Coop Level : </font><font color=\"#00FF88\">Level " .. tostring(coopLevel) .. "</font>")
            
            if feederCount > 0 then
                if lowestFeederLvl == math.huge then lowestFeederLvl = 1 end
                FeederStatusLabel:SetText("<font color=\"#FFFFFF\">Feeder Stats : </font><font color=\"#00E5FF\">" .. tostring(feederCount) .. " Active (Lowest: Lvl " .. tostring(lowestFeederLvl) .. " | Highest: Lvl " .. tostring(highestFeederLvl) .. ")</font>")
            else
                FeederStatusLabel:SetText("<font color=\"#FFFFFF\">Feeder Stats : </font><font color=\"#FF9900\">0 Feeders Built</font>")
            end
        end)
    end
end)

-- ===================================================
-- AUTO REBIRTH SCREEN BYPASS / CLICKER (FIXES STUCK POPUP)
-- ===================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local GuiService = game:GetService("GuiService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    while task.wait(0.5) do
        if getgenv().AutoProgression then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    -- Scan for Rebirth UI / Back to coop buttons
                    for _, gui in ipairs(playerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Enabled then
                            for _, btn in ipairs(gui:GetDescendants()) do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    local txt = (btn:IsA("TextButton") and btn.Text or ""):lower()
                                    local name = btn.Name:lower()
                                    
                                    if txt:find("back to your coop") or txt:find("rebirth") or name:find("rebirth") or name:find("backtocoop") then
                                        -- Auto Click Rebirth/Back Button
                                        local pos = btn.AbsolutePosition
                                        local size = btn.AbsoluteSize
                                        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 36, 0, true, game, 1)
                                        task.wait(0.05)
                                        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 36, 0, false, game, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ===================================================
-- FAST & ACCURATE PROGRESSION LOOP (REALTIME SCREEN FLOOR DETECTION)
-- ===================================================
MainControlsGroup:AddToggle("AutoProgressionToggle", {
    Text = "Enable Progression Flow",
    Default = false,
    Callback = function(Value)
        getgenv().AutoProgression = Value
        if Value then
            task.spawn(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                
                local lastStart = 0

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
                        
                        local reqFloor = RebirthBonus.requirementFloor(currentRebirths) or 0
                        
                        -- REALTIME SCREEN SCAN FOR CURRENT TOWER FLOOR (Fixes DataController Lag)
                        local currentRealFloor = 0
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui then
                            for _, gui in ipairs(playerGui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled then
                                    for _, label in ipairs(gui:GetDescendants()) do
                                        if label:IsA("TextLabel") and label.Text then
                                            local f, r = label.Text:match("(%d+)%s*/%s*(%d+)")
                                            if f and r then
                                                currentRealFloor = tonumber(f) or 0
                                                if tonumber(r) then reqFloor = tonumber(r) end
                                                break
                                            end
                                        end
                                    end
                                end
                                if currentRealFloor > 0 then break end
                            end
                        end

                        if currentRealFloor == 0 then
                            if type(DataController.towerBest) == "function" then
                                local successVal, resVal = pcall(DataController.towerBest)
                                if successVal then currentRealFloor = tonumber(resVal) or 0 end
                            elseif type(DataController.towerBest) == "number" then
                                currentRealFloor = DataController.towerBest
                            end
                        end
                        
                        -- Update UI Status
                        if currentRealFloor >= reqFloor and reqFloor > 0 then
                            FloorLabel:SetText("<font color=\"#FFFFFF\">Floor Requirement : </font><font color=\"#00FF00\">Highest: " .. tostring(currentRealFloor) .. " / Required: " .. tostring(reqFloor) .. " (GOAL REACHED!)</font>")
                        else
                            FloorLabel:SetText("<font color=\"#FFFFFF\">Floor Requirement : </font><font color=\"#FF9900\">Highest: " .. tostring(currentRealFloor) .. " / Required: " .. tostring(reqFloor) .. "</font>")
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
                        
                        -- REALTIME GOAL CHECK
                        if currentRealFloor >= reqFloor and reqFloor > 0 then
                            StatusLabel:SetText("<font color=\"#FFFFFF\">Current Activity : </font><font color=\"#FF3366\">Floor " .. tostring(currentRealFloor) .. " Reached! Auto Retracting & Rebirthing...</font>")
                            
                            -- Fire all Surrender / Rebirth Remotes
                            for _, rName in ipairs({"TowerSurrender", "Retreat", "TowerRetreat", "SurrenderTower", "Rebirth"}) do
                                local r = Remotes:FindFirstChild(rName)
                                if r then
                                    pcall(function()
                                        if r:IsA("RemoteFunction") then r:InvokeServer() else r:FireServer() end
                                    end)
                                end
                            end
                            
                            task.wait(1)
                        else
                            -- STILL NEED FLOORS
                            if not isInTower then
                                local currentTime = tick()
                                local delayTime = getgenv().TowerDelay or 15
                                
                                if (currentTime - lastStart) >= delayTime then
                                    StatusLabel:SetText("<font color=\"#FFFFFF\">Current Activity : </font><font color=\"#00E5FF\">Running Elevator to Floor " .. tostring(currentRealFloor) .. "...</font>")
                                    
                                    local elevatorRemote = Remotes:FindFirstChild("TowerElevator")
                                    if elevatorRemote then
                                        pcall(function()
                                            if elevatorRemote:IsA("RemoteFunction") then
                                                elevatorRemote:InvokeServer(currentRealFloor)
                                            else
                                                elevatorRemote:FireServer(currentRealFloor)
                                            end
                                        end)
                                    end
                                    
                                    task.wait(0.5)
                                    StatusLabel:SetText("<font color=\"#FFFFFF\">Current Activity : </font><font color=\"#00FF00\">Starting Tower Run...</font>")
                                    local startRemote = Remotes:FindFirstChild("TowerStart")
                                    if startRemote then
                                        pcall(function() startRemote:InvokeServer() end)
                                    end
                                    
                                    lastStart = tick()
                                else
                                    local remaining = math.ceil(delayTime - (currentTime - lastStart))
                                    StatusLabel:SetText("<font color=\"#FFFFFF\">Current Activity : </font><font color=\"#00E5FF\">Waiting Elevator Cooldown (" .. tostring(remaining) .. "s)...</font>")
                                end
                            else
                                StatusLabel:SetText("<font color=\"#FFFFFF\">Current Activity : </font><font color=\"#00FF00\">Playing inside Tower (Floor " .. tostring(currentRealFloor) .. ")...</font>")
                            end
                        end
                    end)
                    
                    if not success then warn("[Progression Loop Error]:", err) end
                    task.wait(0.5)
                end
                StatusLabel:SetText("<font color=\"#FFFFFF\">Current Activity : </font><font color=\"#AAAAAA\">Idle</font>")
            end)
        end
    end
})

-- AUTO CLOSE TELEMETRY & OFFERS
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

-- SAVE MANAGER LOAD
task.spawn(function()
    local success, err = pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end)
