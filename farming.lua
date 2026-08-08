local Window = getgenv().MakiHubWindow
local Tabs = getgenv().MakiHubTabs

if not Window or not Tabs then
    return
end

-- ==================== MAIN TAB: FARMING CONFIG ====================
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
