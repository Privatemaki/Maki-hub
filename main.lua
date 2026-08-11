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
    Main = Window:AddTab("Main", "home"),
    ["UI Settings"] = Window:AddTab("UI Settings", "menu"),
}

getgenv().MakiHubWindow = Window
getgenv().MakiHubTabs = Tabs

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

local HatchGroup = Tabs.Main:AddLeftGroupbox("Hatch Config", "boxes")

getgenv().AutoOpenAll = false
HatchGroup:AddToggle("AutoOpenAllToggle", {
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

getgenv().EggSpawnDelay = 5
HatchGroup:AddInput("EggDelayInput", {
    Text = "Egg Collect Delay (s)",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then
            getgenv().EggSpawnDelay = num
        end
    end
})

getgenv().AutoCollectMyCoopOnly = false
HatchGroup:AddToggle("AutoCollectEggsToggle", {
    Text = "Auto Collect Coop Eggs (Timer)",
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

local BuyExpandGroup = Tabs.Main:AddLeftGroupbox("Buy Feeders & Expand", "boxes")

getgenv().UltimateAutoCoop = false
getgenv().BuyGeneratorDelay = 3
getgenv().AutoUpgradeFeederTarget = 27
getgenv().AutoUpgradeToggleState = false

BuyExpandGroup:AddToggle("AutoUpgradeToggle", {
    Text = "Auto Upgrade",
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

BuyExpandGroup:AddDropdown("AutoUpgradeTargetDropdown", {
    Values = { "10", "15", "20", "25", "27", "30", "40", "50" },
    Default = "27",
    Text = "Feeder Target Level",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            getgenv().AutoUpgradeFeederTarget = num
        end
    end
})

BuyExpandGroup:AddDropdown("BuyGeneratorDelayDropdown", {
    Values = { "0.5s", "1s", "2s", "3s", "5s" },
    Default = "3s",
    Text = "Delay to Buy Generator",
    Callback = function(Value)
        local numStr = Value:gsub("s", "")
        getgenv().BuyGeneratorDelay = tonumber(numStr) or 3
    end
})

BuyExpandGroup:AddToggle("UltimateAutoCoopToggle", {
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

-- ===================================================
-- SMART progression UI CONTROLS FOR MAKI-HUB
-- ===================================================

local StatusLabel = FarmingConfigGroup:AddLabel("Status: Idle")
local FloorLabel = FarmingConfigGroup:AddLabel("Floor Info: 0 / 0")

getgenv().AutoProgression = false
getgenv().TowerDelay = 15

FarmingConfigGroup:AddInput("TowerDelayInput", {
    Text = "Tower Start Delay (Seconds)",
    Default = "15",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            getgenv().TowerDelay = num
        end
    end
})

FarmingConfigGroup:AddToggle("AutoProgressionToggle", {
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
                
                while getgenv().AutoProgression do
                    local success, err = pcall(function()
                        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                        if not playerScripts then return end
                        
                        local DataController = require(playerScripts.Core.Data.DataController)
                        local RebirthBonus = require(ReplicatedStorage.Core.Progression.RebirthBonus)
                        
                        -- Rebirth Count Check
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
                        
                        -- Tower Best Check
                        local towerBest = 0
                        if type(DataController.towerBest) == "function" then
                            local successVal, resVal = pcall(DataController.towerBest)
                            if successVal then
                                towerBest = tonumber(resVal) or 0
                            end
                        elseif type(DataController.towerBest) == "number" then
                            towerBest = DataController.towerBest
                        end
                        
                        -- Green Text Styling
                        if towerBest >= reqFloor then
                            FloorLabel:SetText("<font color=\"#00FF00\">Highest Floor: " .. tostring(towerBest) .. " / Req: " .. tostring(reqFloor) .. "</font>")
                        else
                            FloorLabel:SetText("Highest Floor: " .. tostring(towerBest) .. " / Req: " .. tostring(reqFloor))
                        end
                        
                        -- Where check
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
                        
                        -- FLOW LOGIC
                        if towerBest < reqFloor then
                            if not isInTower then
                                StatusLabel:SetText("<font color=\"#00FF00\">Status: Running Elevator (Floor " .. tostring(towerBest) .. ")</font>")
                                
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
                                
                                StatusLabel:SetText("<font color=\"#00FF00\">Status: Starting Tower Run...</font>")
                                local startRemote = Remotes:FindFirstChild("TowerStart")
                                if startRemote then
                                    pcall(function()
                                        startRemote:InvokeServer()
                                    end)
                                end
                                
                                task.wait(getgenv().TowerDelay or 15)
                            else
                                StatusLabel:SetText("<font color=\"#00FF00\">Status: Playing inside tower...</font>")
                            end
                        else
                            -- RETREAT METHOD
                            StatusLabel:SetText("<font color=\"#00FF00\">Status: Retreating from Tower...</font>")
                            
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
                            
                            -- REBIRTH EXECUTION
                            StatusLabel:SetText("<font color=\"#00FF00\">Status: Executing Rebirth...</font>")
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
                StatusLabel:SetText("Status: Idle")
            end)
        end
    end
})

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

task.spawn(function()
    local success, err = pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end)
