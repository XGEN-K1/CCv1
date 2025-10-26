-- AimSystem.lua
local AimSystem = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Локальні змінні
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local CC = Workspace.CurrentCamera

-- Налаштування
local AimBotSettings = {
    Enabled = true,
    BindsEnabled = true,
    AimKey = "t",
    DeselectKey = "j",
    ShootKey = "v",
    UseVKey = true,
    TriggerKey = "h",
    SwitchTargetKey = "b",
    FOV = 500,
    interval = 0,
    LeadFactor = 0.6,
    BulletSpread = 0,
    ShowBeam = true,
    BeamMode = "Prediction",
    horiscoof = 0.5
}

local Plr = nil
local enabled = false
local shooting = false
local triggerMode = false
local keyConnections = {}
local lineBeam, fromAttachment, toAttachment

-- Функції модуля
function AimSystem.Init(parentPanel, customSettings)
    if customSettings then
        for k, v in pairs(customSettings) do
            AimBotSettings[k] = v
        end
    end
    
    -- Створюємо UI
    AimSystem.CreateUI(parentPanel)
    
    -- Налаштовуємо keybinds
    AimSystem.SetupKeybinds()
    
    -- Завантажуємо налаштування
    AimSystem.LoadSettings()
    
    return true
end

function AimSystem.CreateUI(parentPanel)
    -- Заголовок AIM
    local aimLabel = Instance.new("TextLabel")
    aimLabel.Size = UDim2.new(1, 0, 0, 25)
    aimLabel.BackgroundTransparency = 1
    aimLabel.Text = "🎯 AIM System"
    aimLabel.TextColor3 = Color3.new(1, 1, 1)
    aimLabel.Font = Enum.Font.SourceSansBold
    aimLabel.TextSize = 16
    aimLabel.TextXAlignment = Enum.TextXAlignment.Center
    aimLabel.Parent = parentPanel

    -- Кнопка включення/виключення
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 30)
    toggleBtn.Position = UDim2.new(0, 0, 0, 30)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    toggleBtn.Text = "AIM: ON"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.SourceSans
    toggleBtn.TextSize = 14
    toggleBtn.Parent = parentPanel
    
    toggleBtn.MouseButton1Click:Connect(function()
        AimSystem.Toggle()
        toggleBtn.Text = "AIM: " .. (AimBotSettings.Enabled and "ON" or "OFF")
        toggleBtn.BackgroundColor3 = AimBotSettings.Enabled and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
    end)

    -- Кнопка автозахвату цілі
    local targetBtn = Instance.new("TextButton")
    targetBtn.Size = UDim2.new(1, 0, 0, 30)
    targetBtn.Position = UDim2.new(0, 0, 0, 65)
    targetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
    targetBtn.Text = "Auto Target"
    targetBtn.TextColor3 = Color3.new(1, 1, 1)
    targetBtn.Font = Enum.Font.SourceSans
    targetBtn.TextSize = 14
    targetBtn.Parent = parentPanel
    
    targetBtn.MouseButton1Click:Connect(function()
        AimSystem.AutoTargetClosest()
    end)

    -- Кнопка очищення цілі
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(1, 0, 0, 30)
    clearBtn.Position = UDim2.new(0, 0, 0, 100)
    clearBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
    clearBtn.Text = "Clear Target"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.SourceSans
    clearBtn.TextSize = 14
    clearBtn.Parent = parentPanel
    
    clearBtn.MouseButton1Click:Connect(function()
        AimSystem.ClearTarget()
    end)
end

function AimSystem.SetupKeybinds()
    -- Очищаємо старі з'єднання
    for _, conn in pairs(keyConnections) do
        conn:Disconnect()
    end
    keyConnections = {}

    -- Додаємо нові keybinds
    keyConnections.keyDown = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not AimBotSettings.Enabled or not AimBotSettings.BindsEnabled then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name:lower()
            
            if key == AimBotSettings.AimKey then
                AimSystem.AutoTargetClosest()
            elseif key == AimBotSettings.DeselectKey then
                AimSystem.ClearTarget()
            elseif key == AimBotSettings.ShootKey and not shooting and AimBotSettings.UseVKey then
                AimSystem.StartShooting()
            elseif key == AimBotSettings.TriggerKey then
                triggerMode = not triggerMode
                AimSystem.ShowNotification("Trigger: " .. tostring(triggerMode))
            end
        end
    end)
end

function AimSystem.AutoTargetClosest()
    local closest, shortest = nil, AimBotSettings.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos = CC:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
            if dist < shortest then 
                closest = v
                shortest = dist 
            end
        end
    end
    
    if closest then 
        Plr = closest
        enabled = true
        AimSystem.ShowNotification("Target: " .. Plr.Name)
        return true
    else
        AimSystem.ShowNotification("No targets found")
        return false
    end
end

function AimSystem.ClearTarget()
    Plr = nil
    enabled = false
    AimSystem.CleanupBeam()
    AimSystem.ShowNotification("Target cleared")
end

function AimSystem.StartShooting()
    shooting = true
    spawn(function()
        while shooting and AimBotSettings.Enabled do
            if enabled and Plr then 
                AimSystem.ShootAtTarget()
            else
                AimSystem.ShootAtCursor()
            end
            task.wait(AimBotSettings.interval)
        end
    end)
end

function AimSystem.StopShooting()
    shooting = false
end

function AimSystem.ShootAtTarget()
    if not Plr or not Plr.Character then return end
    
    local targetPos = Plr.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
    local tool = Workspace[LocalPlayer.Name]:FindFirstChildOfClass("Tool")
    if tool then 
        ReplicatedStorage.RemoteEvents.ShootGun:FireServer(targetPos, tool) 
    end
end

function AimSystem.ShootAtCursor()
    local ray = CC:ScreenPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    local targetPos = res and res.Position or ray.Origin + ray.Direction * 1000
    
    local tool = Workspace[LocalPlayer.Name]:FindFirstChildOfClass("Tool")
    if tool then 
        ReplicatedStorage.RemoteEvents.ShootGun:FireServer(targetPos, tool) 
    end
end

function AimSystem.CleanupBeam()
    if lineBeam then lineBeam:Destroy(); lineBeam = nil end
    if fromAttachment then fromAttachment:Destroy(); fromAttachment = nil end
    if toAttachment then toAttachment.Parent:Destroy(); toAttachment = nil end
end

function AimSystem.ShowNotification(msg)
    if getgenv().NotificationSystem then
        getgenv().NotificationSystem.ShowNotification(msg)
    else
        print("🎯 AIM: " .. msg)
    end
end

-- API функції
function AimSystem.Enable()
    AimBotSettings.Enabled = true
    AimSystem.ShowNotification("AIM Enabled")
end

function AimSystem.Disable()
    AimBotSettings.Enabled = false
    enabled = false
    AimSystem.ShowNotification("AIM Disabled")
end

function AimSystem.Toggle()
    AimBotSettings.Enabled = not AimBotSettings.Enabled
    AimSystem.ShowNotification("AIM " .. (AimBotSettings.Enabled and "Enabled" or "Disabled"))
end

function AimSystem.SetTarget(player)
    if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
        Plr = player
        enabled = true
        AimSystem.ShowNotification("Target set: " .. player.Name)
        return true
    else
        AimSystem.ShowNotification("Invalid target")
        return false
    end
end

function AimSystem.GetCurrentTarget()
    return Plr
end

function AimSystem.GetSettings()
    return AimBotSettings
end

function AimSystem.SaveSettings()
    if writefile then
        local json = HttpService:JSONEncode(AimBotSettings)
        writefile("aim_settings.txt", json)
        AimSystem.ShowNotification("Settings saved")
    end
end

function AimSystem.LoadSettings()
    if readfile and isfile and isfile("aim_settings.txt") then
        local success, result = pcall(function()
            local json = readfile("aim_settings.txt")
            return HttpService:JSONDecode(json)
        end)
        
        if success and result then
            for k, v in pairs(result) do
                if AimBotSettings[k] ~= nil then
                    AimBotSettings[k] = v
                end
            end
            AimSystem.ShowNotification("Settings loaded")
        end
    end
end

function AimSystem.Destroy()
    -- Очищення ресурсів
    for _, conn in pairs(keyConnections) do
        conn:Disconnect()
    end
    AimSystem.CleanupBeam()
    Plr = nil
    enabled = false
    shooting = false
    AimSystem.ShowNotification("AIM System destroyed")
end

-- Експортуємо глобальні функції
getgenv().AIM = {
    Enable = AimSystem.Enable,
    Disable = AimSystem.Disable,
    Toggle = AimSystem.Toggle,
    SetTarget = AimSystem.SetTarget,
    ClearTarget = AimSystem.ClearTarget,
    GetCurrentTarget = AimSystem.GetCurrentTarget,
    AutoTargetClosest = AimSystem.AutoTargetClosest
}

return AimSystem
