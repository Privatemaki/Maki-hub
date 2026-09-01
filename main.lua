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
    Misc = Window:AddTab("Misc", "flask"), -- Dito ilalagay ang Auto Fuse at Auto Walk
    Settings = Window:AddTab("Settings", "settings"),
}

getgenv().MakiHubWindow = Window
getgenv().MakiHubTabs = Tabs

-- ===================================================
-- GLOBAL VARIABLES
-- ===================================================
getgenv().AutoProgression = false
getgenv().TowerDelay = 1
getgenv().EnableRetreatAtFloor = false
getgenv().TargetRetreatFloor = 5

getgenv().ExpandCoop = false
getgenv().ExpandTargetLevel = 2
getgenv().BuyGenerator = false
getgenv().AutoBuyGenTarget = 2
getgenv().UpgradeGenerator = false
getgenv().UpgradeGenTarget = 10
getgenv().UpgradeGeneratorMethod = "Teleport"
getgenv().UpgradeRecycler = false
getgenv().UpgradeRecyclerTarget = 10
getgenv().AutoCollectEgg = false
getgenv().CollectEggMethod = "Teleport"

-- Auto Fuse & Auto Walk Variables
_G.AutoFuseEnabled = false
_G.SlotA = ""
_G.SlotB = ""
_G.IgnoreFavorite = true
_G.TargetRarity = "All"
_G.StopDistance = 3

-- ===================================================
-- TAB 1: INFO
-- ===================================================
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

-- FPS Counter Loop
task.spawn(function()
    local RunService = game:GetService("RunService")
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

-- ===================================================
-- TAB 2: FARMING
-- ===================================================
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

local BoxRetreat = Tabs.Farming:AddLeftGroupbox("Tower Retreat Settings", "rotate-ccw")
BoxRetreat:AddToggle("EnableRetreatAtFloorToggle", {
    Text = "Enable Retreat at Floor",
    Default = false,
    Callback = function(Value) getgenv().EnableRetreatAtFloor = Value end
})
BoxRetreat:AddInput("TargetRetreatFloorInput", {
    Text = "Target Retreat Floor",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().TargetRetreatFloor = tonumber(Value) or 5 end
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
    Default = "2",
    Numeric = true,
    Finished = true,
    Callback = function(Value) getgenv().AutoBuyGenTarget = tonumber(Value) or 2 end
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

-- ===================================================
-- TAB 3: MISC (AUTO FUSE & AUTO WALK)
-- ===================================================
local FuseGroup = Tabs.Misc:AddLeftGroupbox("🔍 Pet Fusion Settings", "flask")
local WalkGroup = Tabs.Misc:AddRightGroupbox("🚶 Feeder Auto Walk", "navigation")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function formatPetName(str)
    if not str then return "Unknown Pet" end
    local formatted = string.gsub(str, "_", " ")
    formatted = string.gsub(formatted, "^%l", string.upper)
    formatted = string.gsub(formatted, " %l", function(s) return " " .. string.upper(s:sub(2)) end)
    return formatted
end

local function formatTypeId(name)
    return string.lower(string.gsub(name, "%s+", "_"))
end

local function getPetRarityString(v)
    local rawRarity = v.rarity or v.Tier or v.Rarity or v.rarityName or "Common"
    if type(rawRarity) == "number" then
        local rarityMap = { [1] = "common", [2] = "uncommon", [3] = "rare", [4] = "epic", [5] = "legendary" }
        rawRarity = rarityMap[rawRarity] or "common"
    end
    return tostring(rawRarity):lower()
end

local function isValidPet(v)
    if type(v) ~= "table" or not rawget(v, "id") or not rawget(v, "typeId") then 
        return false 
    end
    
    if _G.IgnoreFavorite and v.isFavorite then
        return false
    end
    
    if _G.TargetRarity ~= "all" and _G.TargetRarity ~= "All" then
        local petRarity = getPetRarityString(v)
        if petRarity ~= string.lower(_G.TargetRarity) then
            return false
        end
    end
    
    return true
end

local function getAvailableChickens()
    local petsTable = {}
    local addedPets = {}
    
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if isValidPet(v) then
                local petName = formatPetName(v.typeId)
                if not addedPets[petName] then
                    addedPets[petName] = true
                    table.insert(petsTable, petName)
                end
            end
        end
    end)
    
    if #petsTable > 0 then
        return petsTable
    end
    return {"Zombie Chick", "Wrapped Hen", "Creepy Clown", "Bone Rooster", "Jack Rooster"}
end

local function findChickenId(targetName, excludeId)
    local targetType = formatTypeId(targetName)
    local foundId = nil
    
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if isValidPet(v) and v.id ~= excludeId then
                if string.lower(tostring(v.typeId)) == targetType then
                    local petRarity = getPetRarityString(v)
                    local selectedRarity = string.lower(_G.TargetRarity)
                    
                    if selectedRarity == "all" or petRarity == selectedRarity then
                        foundId = v.id
                        break
                    end
                end
            end
        end
    end)
    
    return foundId
end

-- Auto Fuse UI Controls inside Misc Tab
FuseGroup:AddToggle("AutoFuseKey", {
    Text = "⚡ Auto Fuse",
    Default = false,
    Callback = function(Value)
        _G.AutoFuseEnabled = Value
        if Value then
            task.spawn(function()
                local FuseRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FuseChickens")
                while _G.AutoFuseEnabled do
                    pcall(function()
                        if _G.SlotA ~= "" and _G.SlotB ~= "" then
                            local idA = findChickenId(_G.SlotA, nil)
                            local idB = findChickenId(_G.SlotB, idA)
                            
                            if idA and idB then
                                task.spawn(function()
                                    FuseRemote:InvokeServer(idA, idB, {}, nil, "a")
                                end)
                            end
                        end
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

FuseGroup:AddToggle("IgnoreFavKey", {
    Text = "🔒 Ignore Favorite Chicken",
    Default = true,
    Callback = function(Value)
        _G.IgnoreFavorite = Value
    end
})

FuseGroup:AddDropdown("RarityDropdown", {
    Values = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary"},
    Default = 1,
    Text = "📊 Rarity Filter",
    Callback = function(Value) 
        _G.TargetRarity = Value 
    end
})

local initialPets = getAvailableChickens()
_G.SlotA = initialPets[1] or ""
_G.SlotB = initialPets[1] or ""

local SlotADrop = FuseGroup:AddDropdown("SlotADropdown", {
    Values = initialPets,
    Default = 1,
    Text = "Pet Slot A",
    Searchable = true,
    Callback = function(Value) _G.SlotA = Value end
})

local SlotBDrop = FuseGroup:AddDropdown("SlotBDropdown", {
    Values = initialPets,
    Default = 1,
    Text = "Pet Slot B",
    Searchable = true,
    Callback = function(Value) _G.SlotB = Value end
})

FuseGroup:AddButton("🔄 Refresh Inventory", function()
    pcall(function()
        local updatedList = getAvailableChickens()
        SlotADrop:SetValues(updatedList)
        SlotBDrop:SetValues(updatedList)
        Library:Notify({ Title = "Inventory Refreshed", Content = "Na-update na ang mga listahan ng manok!", Duration = 2 })
    end)
end)

-- Auto Walk Feeder UI & Direct Execution Logic
WalkGroup:AddInput("StopDistanceInput", {
    Default = "3",
    Numeric = true,
    Finished = true,
    Text = "🎯 Stop Distance",
    Tooltip = "Gaano ka-dikit sa feeder bago tumigil",
    Callback = function(Value)
        _G.StopDistance = tonumber(Value) or 3
    end
})

task.spawn(function()
    while true do
        pcall(function()
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if humanoidRootPart and humanoid then
                local coops = workspace:FindFirstChild("Coops")
                local coopUI = coops and coops:FindFirstChild("CoopUI")
                local feeder = coopUI and coopUI:FindFirstChild("Feeder")
                
                if feeder then
                    local targetPos = nil
                    
                    if feeder:IsA("BasePart") then
                        targetPos = feeder.Position
                    elseif feeder:IsA("Model") then
                        if feeder.PrimaryPart then
                            targetPos = feeder.PrimaryPart.Position
                        else
                            local firstPart = feeder:FindFirstChildWhichIsA("BasePart", true)
                            if firstPart then
                                targetPos = firstPart.Position
                            end
                        end
                    end
                    
                    if targetPos then
                        local distance = (humanoidRootPart.Position - targetPos).Magnitude
                        
                        if distance > _G.StopDistance then
                            humanoid:MoveTo(targetPos)
                        else
                            humanoid:MoveTo(humanoidRootPart.Position)
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- ===================================================
-- AUTOMATION LOGIC LOOPS (TOWER & GENERATOR)
-- ===================================================

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

    local lastRetreatedRebirth = -1

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
                
                local isInTower = (where == "campaign" or where == "tower" or liveFloor > 0)
                
                if towerBest >= reqFloor and not isInTower then
                    LabelActivity:SetText("Current Activity: Rebirthing")
                    local rebirthRemote = Remotes:FindFirstChild("Rebirth")
                    if rebirthRemote then
                        pcall(function()
                            if rebirthRemote:IsA("RemoteFunction") then rebirthRemote:InvokeServer()
                            else rebirthRemote:FireServer() end
                        end)
                    end
                    task.wait(4)
                    return
                end

                if towerBest >= reqFloor and isInTower then
                    LabelActivity:SetText("Current Activity: Rebirth Ready - Retreating")
                    pcall(function()
                        local retreatRemote = Remotes:FindFirstChild("TowerSurrender") or Remotes:FindFirstChild("Retreat") or Remotes:FindFirstChild("TowerRetreat")
                        if retreatRemote then
                            if retreatRemote:IsA("RemoteFunction") then retreatRemote:InvokeServer()
                            else retreatRemote:FireServer() end
                        end
                    end)
                    task.wait(3)
                    return
                end

                local targetRetreat = tonumber(getgenv().TargetRetreatFloor) or 5
                if isInTower and getgenv().EnableRetreatAtFloor and liveFloor >= targetRetreat and lastRetreatedRebirth ~= currentRebirths then
                    LabelActivity:SetText("Current Activity: Strict Retreat at Floor " .. tostring(liveFloor))
                    lastRetreatedRebirth = currentRebirths

                    pcall(function()
                        local retreatRemote = Remotes:FindFirstChild("TowerSurrender") or Remotes:FindFirstChild("Retreat") or Remotes:FindFirstChild("TowerRetreat")
                        if retreatRemote then
                            if retreatRemote:IsA("RemoteFunction") then retreatRemote:InvokeServer()
                            else retreatRemote:FireServer() end
                        end
                    end)
                    task.wait(3)
                    return
                end

                if isInTower then
                    LabelActivity:SetText("Current Activity: Climbing Tower: Floor " .. tostring(liveFloor))
                else
                    local delayTime = tonumber(getgenv().TowerDelay) or 1
                    for i = delayTime, 1, -1 do
                        if not getgenv().AutoProgression then break end
                        LabelActivity:SetText("Current Activity: Tower Delay (" .. i .. "s)")
                        task.wait(1)
                    end
                    
                    if not getgenv().AutoProgression then return end

                    LabelActivity:SetText("Current Activity: Entering Tower")
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
                    task.wait(1.5)
                end
            end)
        else
            LabelActivity:SetText("Current Activity: Idle")
        end
        task.wait(1)
    end
end)

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
    
    local DataServiceClient = nil
    local CoopViewModule = nil
    pcall(function()
        DataServiceClient = require(ReplicatedStorage.Packages.DataService).client
        CoopViewModule = require(ReplicatedStorage.Features.Coop.CoopView)
    end)
    
    while true do
        if remotes then
            pcall(function()
                local coopData = nil
                if DataServiceClient then
                    pcall(function()
                        coopData = DataServiceClient:get({ "coop" })
                    end)
                end
                
                if getgenv().ExpandCoop and coopData then
                    local targetLevel = tonumber(getgenv().ExpandTargetLevel) or 2
                    local currentSlots = tonumber(coopData.slots) or 0
                    local canActuallyExpand = true
                    
                    if CoopViewModule and CoopViewModule.canExpand and currentSlots > 0 then
                        pcall(function()
                            canActuallyExpand = CoopViewModule.canExpand(currentSlots)
                        end)
                    end
                    
                    if currentSlots > 0 and currentSlots < targetLevel and canActuallyExpand then
                        local expandRemote = remotes:FindFirstChild("ExpandCoop") or remotes:FindFirstChild("Expand")
                        if expandRemote then
                            if expandRemote:IsA("RemoteFunction") then expandRemote:InvokeServer() else expandRemote:FireServer() end
                        end
                    end
                end
                
                if getgenv().BuyGenerator and coopData then
                    local maxTarget = math.clamp(getgenv().AutoBuyGenTarget or 2, 1, 6)
                    local currentGenCount = 0
                    
                    if coopData.generators then
                        if type(coopData.generators) == "table" then
                            for _, _ in pairs(coopData.generators) do
                                currentGenCount = currentGenCount + 1
                            end
                        end
                    end
                    
                    local canBuyViaModule = true
                    local slotsCount = tonumber(coopData.slots) or 1
                    if CoopViewModule and CoopViewModule.canBuyGenerator then
                        pcall(function()
                            canBuyViaModule = CoopViewModule.canBuyGenerator(slotsCount, currentGenCount)
                        end)
                    end
                    
                    if currentGenCount < maxTarget and canBuyViaModule then
                        local genRemote = remotes:FindFirstChild("BuyGenerator") or remotes:FindFirstChild("GeneratorBuy") or remotes:FindFirstChild("BuyGen")
                        if genRemote then
                            local nextSlot = currentGenCount + 1
                            if nextSlot <= maxTarget then
                                if genRemote:IsA("RemoteFunction") then genRemote:InvokeServer(nextSlot) else genRemote:FireServer(nextSlot) end
                            end
                        end
                    end
                end
                
                if getgenv().UpgradeGenerator and coopData and coopData.generators then
                    local upGenRemote = remotes:FindFirstChild("UpgradeGenerator") or remotes:FindFirstChild("GeneratorUpgrade") or remotes:FindFirstChild("UpgradeGen")
                    local upgradeTarget = tonumber(getgenv().UpgradeGenTarget) or 10
                    
                    if upGenRemote then
                        for _, genInfo in pairs(coopData.generators) do
                            if not getgenv().UpgradeGenerator then break end
                            local slotIdx = tonumber(genInfo.slot)
                            local genLevel = tonumber(genInfo.level) or 0
                            
                            if slotIdx and genLevel < upgradeTarget then
                                task.spawn(function()
                                    pcall(function()
                                        if upGenRemote:IsA("RemoteFunction") then upGenRemote:InvokeServer(slotIdx) else upGenRemote:FireServer(slotIdx) end
                                    end)
                                end)
                            end
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
        task.wait(0.2)
    end
end)

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    if not remotes then return end

    local continueOfferEvent = remotes:WaitForChild("TowerContinueOffer", 10)
    local declineEvent = remotes:WaitForChild("TowerContinueDecline", 10)

    if continueOfferEvent and declineEvent then
        continueOfferEvent.OnClientEvent:Connect(function()
            task.wait(0.05)
            declineEvent:FireServer()
        end)
    end
end)

-- ===================================================
-- ULTIMATE FAST AUTO RECONNECT (v4)
-- ===================================================
getgenv().AutoReconnect = true

task.spawn(function()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")

    -- 1. Agresibong panggagaling sa GuiService error handler o CoreGui popup
    task.spawn(function()
        while true do
            if getgenv().AutoReconnect then
                pcall(function()
                    -- Hanapin agad kung may lumitaw na error prompt sa CoreGui
                    for _, child in ipairs(CoreGui:GetDescendants()) do
                        if child:IsA("TextLabel") then
                            local t = child.Text or ""
                            if t:find("769") or t:find("277") or t:find("Disconnected") or t:find("Reconnect") then
                                task.wait(0.5)
                                TeleportService:Teleport(game.PlaceId, LocalPlayer)
                            end
                        end
                    end
                end)
            end
            task.wait(0.5) -- Mas mabilis na check (kada kalahating segundo)
        end
    end)

    -- 2. Fallback kung sakaling mawala sa Player list ang LocalPlayer
    while true do
        if getgenv().AutoReconnect then
            pcall(function()
                if not LocalPlayer:IsDescendantOf(Players) then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end)
        end
        task.wait(2)
    end
end)

-- ===================================================
-- SETTINGS TAB
-- ===================================================
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
