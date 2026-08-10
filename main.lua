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
    CoopMain = Window:AddTab("CoopMain", "settings"),
    ["UI Settings"] = Window:AddTab("UI Settings", "menu"),
}

-- I-save ang Window at Tabs sa getgenv para magamit
getgenv().MakiHubWindow = Window
getgenv().MakiHubTabs = Tabs

-- ==================== UI SETTINGS & THEMES ====================
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

-- ==================== HATCH CONFIG ====================
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

-- ==================== BUY FEEDERS & EXPAND ====================
local BuyExpandGroup = Tabs.Main:AddLeftGroupbox("Buy Feeders & Expand", "boxes")

getgenv().UltimateAutoCoop = false
getgenv().BuyGeneratorDelay = 3

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
                            local coopUI = coopsFolder:FindFirstChild("CoopUI")
                            if coopUI then
                                for _, child in ipairs(coopUI:GetChildren()) do
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
                    
                    task.wait(1)
                end
            end)
        end
    end
})

-- ==================== upgrade & smart  ====================
local BuyExpandGroup = Tabs.Main:AddLeftGroupbox("Buy Feeders & Expand", "boxes")

getgenv().UltimateAutoCoop = false
getgenv().BuyGeneratorDelay = 3
getgenv().AutoUpgradeFeederTarget = 20 -- Default target level

-- Dito ang Dropdown para sa Target Level ng Auto Upgrade Feeders
BuyExpandGroup:AddDropdown("AutoUpgradeTargetDropdown", {
    Values = { "10", "15", "20", "25", "30", "40", "50" },
    Default = "20",
    Text = "Feeder Upgrade Target Level",
    Callback = function(Value)
        getgenv().AutoUpgradeFeederTarget = tonumber(Value) or 20
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
                local UpgradeEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeGenerator")

                while getgenv().UltimateAutoCoop do
                    local success, err = pcall(function()
                        local coopLevel = 1
                        local coopsFolder = workspace:FindFirstChild("Coops")
                        if coopsFolder then
                            local coopUI = coopsFolder:FindFirstChild("CoopUI")
                            if coopUI then
                                -- 1. AUTO UPGRADE MUNA HANGGANG SA TARGET LEVEL NA PINILI MO SA UI
                                local targetLevel = getgenv().AutoUpgradeFeederTarget or 20
                                local children = coopUI:GetChildren()
                                
                                for index, child in ipairs(children) do
                                    local currentLevel = child:GetAttribute("Level")
                                    if currentLevel and currentLevel < targetLevel then
                                        pcall(function()
                                            UpgradeEvent:InvokeServer(index)
                                        end)
                                        task.wait(0.05)
                                    end
                                end

                                -- 2. CHECK COOP LEVEL PARA SA BUY & EXPAND LOGIC
                                for _, child in ipairs(coopUI:GetChildren()) do
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
                    task.wait(1)
                end
            end)
        end
    end
})

-- ==================== FARMING CONFIG ====================
local FarmingConfigGroup = Tabs.Main:AddRightGroupbox("Farming Config", "boxes")

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
    Text = "Auto Progression (Tower & Rebirth)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoProgression = Value
        if Value then
            task.spawn(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                
                local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                local RebirthEvent = Remotes:WaitForChild("Rebirth")
                local SurrenderEvent = Remotes:FindFirstChild("TowerSurrender") or Remotes:FindFirstChild("Surrender")
                local TowerStartEvent = Remotes:WaitForChild("TowerStart")

                while getgenv().AutoProgression do
                    pcall(function()
                        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                        if not playerScripts then return end
                        
                        local dataControllerPath = playerScripts:FindFirstChild("Core") and playerScripts.Core.Data:FindFirstChild("DataController")
                        if not dataControllerPath then return end
                        
                        local DataController = require(dataControllerPath)
                        local RebirthBonus = require(ReplicatedStorage.Core.Progression.RebirthBonus)
                        
                        local rebirthData = DataController.rebirth
                        if type(rebirthData) == "function" then rebirthData = rebirthData() end
                        local currentRebirths = (type(rebirthData) == "table" and rebirthData.count) or 0
                        if type(currentRebirths) == "function" then currentRebirths = currentRebirths() end
                        
                        local reqFloor = RebirthBonus.requirementFloor(currentRebirths)
                        
                        local towerBest = DataController.towerBest
                        if type(towerBest) == "function" then towerBest = towerBest() end
                        towerBest = towerBest or 0
                        
                        local where = "corral"
                        local chickenModePath = playerScripts:FindFirstChild("Features") and playerScripts.Features.Chicken:FindFirstChild("ChickenMode")
                        if chickenModePath then
                            local ChickenMode = require(chickenModePath)
                            if ChickenMode.where then where = ChickenMode.where() end
                        end
                        
                        local isInTower = (where == "campaign" or where == "tower")
                        
                        if towerBest < reqFloor and not isInTower then
                            TowerStartEvent:InvokeServer()
                            task.wait(getgenv().TowerDelay or 15)
                        elseif isInTower and towerBest >= reqFloor then
                            if SurrenderEvent then SurrenderEvent:InvokeServer() end
                            task.wait(3)
                        elseif not isInTower and towerBest >= reqFloor then
                            RebirthEvent:InvokeServer()
                            task.wait(5)
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end
})

-- ==================== AUTO CLOSE TOWER CONTINUE ====================
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
    if remotesFolder then
        local continueOffer = remotesFolder:FindFirstChild("TowerContinueOffer")
        local continueDecline = remotesFolder:FindFirstChild("TowerContinueDecline")
        
        if continueOffer and continueDecline then
            continueOffer.OnClientEvent:Connect(function()
                -- Kusang magse-send ng decline kapag naka-on ang Auto Progression mo
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

-- ==================== COOP CONFIG ====================
local CoopConfigGroup = Tabs.CoopMain:AddLeftGroupbox("Coop Config", "boxes")

getgenv().AutoUpgradeFeeder = false
CoopConfigGroup:AddToggle("AutoUpgradeFeederToggle", {
    Text = "Auto Upgrade Feeders (Smart Wait Money)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoUpgradeFeeder = Value
        if Value then
            task.spawn(function()
                local UpgradeEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpgradeGenerator")
                while getgenv().AutoUpgradeFeeder do
                    for feederId = 1, 6 do
                        if not getgenv().AutoUpgradeFeeder then break end
                        pcall(function() UpgradeEvent:InvokeServer(feederId) end)
                        task.wait(0.05)
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
})

getgenv().AutoUpgradeRecycler = false
CoopConfigGroup:AddToggle("AutoUpgradeRecyclerToggle", {
    Text = "Auto Upgrade Recycler (Smart Wait Money)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoUpgradeRecycler = Value
        if Value then
            task.spawn(function()
                local RecyclerEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpgradeRecycler")
                while getgenv().AutoUpgradeRecycler do
                    pcall(function() RecyclerEvent:InvokeServer() end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ==================== LOAD CONFIG INSTANTLY ====================
task.spawn(function()
    local success, err = pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
    
    if success then
        Library:Notify("Successfully loaded autoload config!", 5)
    else
        Library:Notify("Failed to load config: " .. tostring(err), 5)
    end
end)
