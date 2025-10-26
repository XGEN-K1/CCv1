-- UtilitySystem.lua
-- Система утиліт (VR, Ghost, Gate, Boombox, Grab, AimSettings)

local UtilitySystem = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Налаштування
UtilitySystem.Settings = {
    VRActive = false,
    BoomboxToggle = false
}

-- Змінні
UtilitySystem.Buttons = {}
UtilitySystem.LocalPlayer = Players.LocalPlayer

-- Ініціалізація
function UtilitySystem.Init(config)
    UtilitySystem.config = config or {}
    
    -- Створення кнопок
    UtilitySystem.CreateButtons()
    
    print("✅ UtilitySystem ініціалізовано")
end

-- Створення кнопок GUI
function UtilitySystem.CreateButtons()
    -- Кнопка VR
    if UtilitySystem.config.VRButtonParent then
        UtilitySystem.Buttons.VR = Instance.new("TextButton")
        UtilitySystem.Buttons.VR.Size = UDim2.new(0, 80, 0, 30)
        UtilitySystem.Buttons.VR.Position = UDim2.new(0, 5, 0, 50)
        UtilitySystem.Buttons.VR.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        UtilitySystem.Buttons.VR.BackgroundTransparency = 0.7
        UtilitySystem.Buttons.VR.Text = "VR"
        UtilitySystem.Buttons.VR.TextColor3 = Color3.new(1, 1, 1)
        UtilitySystem.Buttons.VR.Font = Enum.Font.SourceSansBold
        UtilitySystem.Buttons.VR.TextSize = 18
        UtilitySystem.Buttons.VR.Parent = UtilitySystem.config.VRButtonParent
        Instance.new("UICorner", UtilitySystem.Buttons.VR).CornerRadius = UDim.new(0, 6)
        
        UtilitySystem.Buttons.VR.MouseButton1Click:Connect(function()
            UtilitySystem.ToggleVR()
        end)
    end
    
    -- Кнопка Ghost
    if UtilitySystem.config.GhostButtonParent then
        UtilitySystem.Buttons.Ghost = Instance.new("TextButton")
        UtilitySystem.Buttons.Ghost.Size = UDim2.new(0, 80, 0, 30)
        UtilitySystem.Buttons.Ghost.Position = UDim2.new(0, 5, 0, 290)
        UtilitySystem.Buttons.Ghost.BackgroundColor3 = Color3.fromRGB(120, 40, 120)
        UtilitySystem.Buttons.Ghost.BackgroundTransparency = 0.7
        UtilitySystem.Buttons.Ghost.Text = "Ghost"
        UtilitySystem.Buttons.Ghost.TextColor3 = Color3.new(1, 1, 1)
        UtilitySystem.Buttons.Ghost.Font = Enum.Font.SourceSansBold
        UtilitySystem.Buttons.Ghost.TextSize = 18
        UtilitySystem.Buttons.Ghost.Parent = UtilitySystem.config.GhostButtonParent
        Instance.new("UICorner", UtilitySystem.Buttons.Ghost).CornerRadius = UDim.new(0, 6)
        
        UtilitySystem.Buttons.Ghost.MouseButton1Click:Connect(function()
            UtilitySystem.ActivateGhost()
        end)
    end
    
    -- Кнопка Gate
    if UtilitySystem.config.GateButtonParent then
        UtilitySystem.Buttons.Gate = Instance.new("TextButton")
        UtilitySystem.Buttons.Gate.Size = UDim2.new(0, 80, 0, 30)
        UtilitySystem.Buttons.Gate.Position = UDim2.new(0, 5, 0, 290)
        UtilitySystem.Buttons.Gate.BackgroundColor3 = Color3.fromRGB(120, 40, 120)
        UtilitySystem.Buttons.Gate.BackgroundTransparency = 0.7
        UtilitySystem.Buttons.Gate.Text = "Gate"
        UtilitySystem.Buttons.Gate.TextColor3 = Color3.new(1, 1, 1)
        UtilitySystem.Buttons.Gate.Font = Enum.Font.SourceSansBold
        UtilitySystem.Buttons.Gate.TextSize = 18
        UtilitySystem.Buttons.Gate.Parent = UtilitySystem.config.GateButtonParent
        Instance.new("UICorner", UtilitySystem.Buttons.Gate).CornerRadius = UDim.new(0, 6)
        
        UtilitySystem.Buttons.Gate.MouseButton1Click:Connect(function()
            UtilitySystem.ActivateGate()
        end)
    end
    
    -- Кнопка Grab
    if UtilitySystem.config.GrabButtonParent then
        UtilitySystem.Buttons.Grab = Instance.new("TextButton")
        UtilitySystem.Buttons.Grab.Size = UDim2.new(0, 80, 0, 30)
        UtilitySystem.Buttons.Grab.Position = UDim2.new(0, 5, 0, 330)
        UtilitySystem.Buttons.Grab.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
        UtilitySystem.Buttons.Grab.BackgroundTransparency = 0.7
        UtilitySystem.Buttons.Grab.Text = "Grab"
        UtilitySystem.Buttons.Grab.TextColor3 = Color3.new(1, 1, 1)
        UtilitySystem.Buttons.Grab.Font = Enum.Font.SourceSansBold
        UtilitySystem.Buttons.Grab.TextSize = 18
        UtilitySystem.Buttons.Grab.Parent = UtilitySystem.config.GrabButtonParent
        Instance.new("UICorner", UtilitySystem.Buttons.Grab).CornerRadius = UDim.new(0, 6)
        
        UtilitySystem.Buttons.Grab.MouseButton1Click:Connect(function()
            UtilitySystem.GrabNearestPlayer()
        end)
    end
    
    -- Кнопка AimSettings
    if UtilitySystem.config.AimSettingsParent then
        UtilitySystem.Buttons.AimSettings = Instance.new("TextButton")
        UtilitySystem.Buttons.AimSettings.Size = UDim2.new(0, 80, 0, 30)
        UtilitySystem.Buttons.AimSettings.Position = UDim2.new(0, 5, 0, 50)
        UtilitySystem.Buttons.AimSettings.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        UtilitySystem.Buttons.AimSettings.BackgroundTransparency = 0.7
        UtilitySystem.Buttons.AimSettings.Text = "AimSettings"
        UtilitySystem.Buttons.AimSettings.TextColor3 = Color3.new(1, 1, 1)
        UtilitySystem.Buttons.AimSettings.Font = Enum.Font.SourceSansBold
        UtilitySystem.Buttons.AimSettings.TextSize = 18
        UtilitySystem.Buttons.AimSettings.TextScaled = true
        UtilitySystem.Buttons.AimSettings.Parent = UtilitySystem.config.AimSettingsParent
        Instance.new("UICorner", UtilitySystem.Buttons.AimSettings).CornerRadius = UDim.new(0, 6)
        
        UtilitySystem.Buttons.AimSettings.MouseButton1Click:Connect(function()
            UtilitySystem.ToggleAimGUI()
        end)
        
        -- Оновлення стану кнопки AimSettings
        UtilitySystem.UpdateAimSettingsButton()
    end
    
    -- Кнопка Boombox
    if UtilitySystem.config.BoomboxParent then
        UtilitySystem.Buttons.Boombox = Instance.new("TextButton")
        UtilitySystem.Buttons.Boombox.Size = UDim2.new(0, 80, 0, 30)
        UtilitySystem.Buttons.Boombox.Position = UDim2.new(0, 5, 0, 80)
        UtilitySystem.Buttons.Boombox.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        UtilitySystem.Buttons.Boombox.BackgroundTransparency = 0.7
        UtilitySystem.Buttons.Boombox.Text = "BoomBox"
        UtilitySystem.Buttons.Boombox.TextColor3 = Color3.new(1, 1, 1)
        UtilitySystem.Buttons.Boombox.Font = Enum.Font.SourceSansBold
        UtilitySystem.Buttons.Boombox.TextSize = 18
        UtilitySystem.Buttons.Boombox.TextScaled = true
        UtilitySystem.Buttons.Boombox.Parent = UtilitySystem.config.BoomboxParent
        Instance.new("UICorner", UtilitySystem.Buttons.Boombox).CornerRadius = UDim.new(0, 6)
        
        UtilitySystem.Buttons.Boombox.MouseButton1Click:Connect(function()
            UtilitySystem.ToggleBoombox()
        end)
    end
end

-- Функції утиліт
function UtilitySystem.ToggleVR()
    UtilitySystem.Settings.VRActive = not UtilitySystem.Settings.VRActive
    if UtilitySystem.Settings.VRActive then
        ReplicatedStorage:WaitForChild("RemoteEvents").VR:FireServer(true)
        UtilitySystem.Buttons.VR.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        UtilitySystem.ShowNotification("VR: Activated")
    else
        ReplicatedStorage:WaitForChild("RemoteEvents").VR:FireServer(false)
        UtilitySystem.Buttons.VR.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        UtilitySystem.ShowNotification("VR: Deactivated")
    end
end

function UtilitySystem.ActivateGhost()
    ReplicatedStorage:WaitForChild("RemoteEvents").Ghost:FireServer(true)
    UtilitySystem.ShowNotification("Ghost Mode: Activated")
end

function UtilitySystem.ActivateGate()
    local KeyPad = game.Workspace.LabGate.KeyPad
    local LabKeyPad = ReplicatedStorage:WaitForChild("RemoteEvents").LabKeyPad
    local LabClear = ReplicatedStorage:WaitForChild("RemoteEvents").LabClear
    local LabEnter = ReplicatedStorage:WaitForChild("RemoteEvents").LabEnter

    LabClear:FireServer()
    LabKeyPad:FireServer(workspace.LabGate.KeyPad.SurfaceGui.NumberPad["1"].Name)
    LabKeyPad:FireServer(workspace.LabGate.KeyPad.SurfaceGui.NumberPad["3"].Name)
    LabKeyPad:FireServer(workspace.LabGate.KeyPad.SurfaceGui.NumberPad["3"].Name)
    LabKeyPad:FireServer(workspace.LabGate.KeyPad.SurfaceGui.NumberPad["7"].Name)
    LabEnter:FireServer()
    
    UtilitySystem.ShowNotification("Gate: Triggered")
end

function UtilitySystem.GrabNearestPlayer()
    local nearest = UtilitySystem.GetClosestPlayer()
    if nearest and nearest.Character and nearest.Character:FindFirstChild("RightUpperLeg") then
        local args = {true, nearest.Character.RightUpperLeg}
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("Grab"):InvokeServer(unpack(args))
        UtilitySystem.ShowNotification("Grab: ".. tostring(nearest))
    else
        UtilitySystem.ShowNotification("Grab: No player found")
    end
end

function UtilitySystem.GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myChar = UtilitySystem.LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= UtilitySystem.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortestDistance then
                closestPlayer = player
                shortestDistance = dist
            end
        end
    end
    return closestPlayer
end

function UtilitySystem.ToggleAimGUI()
    if getgenv().ToggleAimGUI then
        getgenv().ToggleAimGUI(not getgenv().IsAimGUIVisible or false)
        UtilitySystem.ShowNotification("Aim GUI: Toggled")
    else
        UtilitySystem.ShowNotification("Aim GUI functions not loaded")
    end
end

function UtilitySystem.UpdateAimSettingsButton()
    if UtilitySystem.Buttons.AimSettings then
        if getgenv().ToggleAimGUI then
            UtilitySystem.Buttons.AimSettings.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        else
            UtilitySystem.Buttons.AimSettings.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
end

function UtilitySystem.ToggleBoombox()
    local amountInput = UtilitySystem.GetAmountInput()
    local id = amountInput and tonumber(amountInput.Text)
    
    if id then
        UtilitySystem.Settings.BoomboxToggle = not UtilitySystem.Settings.BoomboxToggle
        local musicEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Music")
        musicEvent:FireServer(id, UtilitySystem.Settings.BoomboxToggle)
        
        UtilitySystem.Buttons.Boombox.BackgroundColor3 = UtilitySystem.Settings.BoomboxToggle and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        UtilitySystem.ShowNotification("Boombox: ".. tostring(UtilitySystem.Settings.BoomboxToggle))
    else
        UtilitySystem.ShowNotification("Boombox: Enter sound ID in amount field")
    end
end

function UtilitySystem.GetAmountInput()
    -- Спроба знайти AmountInput з PlayerSystem
    if getgenv().CC_Modules and getgenv().CC_Modules.PlayerSystem then
        local playerSystem = getgenv().CC_Modules.PlayerSystem
        if playerSystem.UIElements and playerSystem.UIElements.AmountInput then
            return playerSystem.UIElements.AmountInput
        end
    end
    return nil
end

-- Сповіщення
function UtilitySystem.ShowNotification(message)
    if getgenv().CC_Modules and getgenv().CC_Modules.NotificationSystem then
        getgenv().CC_Modules.NotificationSystem.ShowNotification(message)
    else
        warn("NotificationSystem не завантажено: " .. message)
    end
end

-- Деструктор
function UtilitySystem.Destroy()
    for _, button in pairs(UtilitySystem.Buttons) do
        if button then
            button:Destroy()
        end
    end
    UtilitySystem.Buttons = {}
    
    print("✅ UtilitySystem вимкнено")
end

return UtilitySystem
