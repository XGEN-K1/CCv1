-- SpeedSystem.lua
local SpeedSystem = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Налаштування
local SpeedSettings = {
    Enabled = false,
    WalkSpeed = 22,
    Active = false
}

local LocalPlayer = Players.LocalPlayer
local currentConnections = {}
local speedButton = nil

-- Основні функції
function SpeedSystem.Init(parentPanel)
    -- Створюємо UI
    SpeedSystem.CreateUI(parentPanel)
    
    -- Застосовуємо початкові налаштування
    if SpeedSettings.Enabled then
        SpeedSystem.Enable()
    end
    
    return true
end

function SpeedSystem.CreateUI(parentPanel)
    -- Кнопка швидкості
    speedButton = Instance.new("TextButton")
    speedButton.Size = UDim2.new(1, 0, 0, 30)
    speedButton.Position = UDim2.new(0, 0, 0, 0)
    speedButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    speedButton.Text = "🚀 Speed: OFF"
    speedButton.TextColor3 = Color3.new(1, 1, 1)
    speedButton.Font = Enum.Font.SourceSans
    speedButton.TextSize = 14
    speedButton.Parent = parentPanel
    
    speedButton.MouseButton1Click:Connect(function()
        SpeedSystem.Toggle()
    end)
    
    -- Слайдер для налаштування швидкості
    local speedSliderContainer = Instance.new("Frame")
    speedSliderContainer.Size = UDim2.new(1, 0, 0, 40)
    speedSliderContainer.Position = UDim2.new(0, 0, 0, 35)
    speedSliderContainer.BackgroundTransparency = 1
    speedSliderContainer.Parent = parentPanel
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. SpeedSettings.WalkSpeed
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.Font = Enum.Font.SourceSans
    speedLabel.TextSize = 12
    speedLabel.Parent = speedSliderContainer
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 15)
    slider.Position = UDim2.new(0, 0, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.Text = ""
    slider.Parent = speedSliderContainer
    
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    fill.Size = UDim2.new((SpeedSettings.WalkSpeed - 16) / (50 - 16), 0, 1, 0)
    fill.Parent = slider
    
    slider.MouseButton1Down:Connect(function()
        local moveConn
        moveConn = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                local newSpeed = math.floor(16 + (50 - 16) * rel)
                SpeedSettings.WalkSpeed = newSpeed
                speedLabel.Text = "Speed: " .. newSpeed
                
                -- Оновлюємо швидкість якщо система активна
                if SpeedSettings.Active then
                    SpeedSystem.UpdateSpeed()
                end
            end
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
            end
        end)
    end)
end

function SpeedSystem.LockWalkSpeed(humanoid)
    if not humanoid then return end
    
    -- Встановлюємо початкову швидкість
    humanoid.WalkSpeed = SpeedSettings.WalkSpeed
    
    -- Блокуємо зміни WalkSpeed
    local connection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= SpeedSettings.WalkSpeed then
            humanoid.WalkSpeed = SpeedSettings.WalkSpeed
        end
    end)
    
    table.insert(currentConnections, connection)
end

function SpeedSystem.OnCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    SpeedSystem.LockWalkSpeed(humanoid)
end

function SpeedSystem.UpdateSpeed()
    -- Оновлюємо швидкість для поточного персонажа
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = SpeedSettings.WalkSpeed
        end
    end
end

function SpeedSystem.Enable()
    SpeedSettings.Enabled = true
    SpeedSettings.Active = true
    
    -- Очищаємо старі з'єднання
    for _, conn in pairs(currentConnections) do
        conn:Disconnect()
    end
    currentConnections = {}
    
    -- Застосовуємо до поточного персонажа
    if LocalPlayer.Character then
        SpeedSystem.OnCharacterAdded(LocalPlayer.Character)
    end
    
    -- Додаємо обробник для нових персонажів
    local charConnection = LocalPlayer.CharacterAdded:Connect(SpeedSystem.OnCharacterAdded)
    table.insert(currentConnections, charConnection)
    
    -- Оновлюємо UI
    if speedButton then
        speedButton.Text = "🚀 Speed: ON"
        speedButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    end
    
    SpeedSystem.ShowNotification("Speed enabled: " .. SpeedSettings.WalkSpeed)
end

function SpeedSystem.Disable()
    SpeedSettings.Enabled = false
    SpeedSettings.Active = false
    
    -- Відключаємо всі з'єднання
    for _, conn in pairs(currentConnections) do
        conn:Disconnect()
    end
    currentConnections = {}
    
    -- Відновлюємо нормальну швидкість
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 -- Стандартна швидкість в Roblox
        end
    end
    
    -- Оновлюємо UI
    if speedButton then
        speedButton.Text = "🚀 Speed: OFF"
        speedButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    end
    
    SpeedSystem.ShowNotification("Speed disabled")
end

function SpeedSystem.Toggle()
    if SpeedSettings.Enabled then
        SpeedSystem.Disable()
    else
        SpeedSystem.Enable()
    end
end

function SpeedSystem.SetSpeed(newSpeed)
    SpeedSettings.WalkSpeed = math.clamp(newSpeed, 16, 100)
    if SpeedSettings.Active then
        SpeedSystem.UpdateSpeed()
    end
    SpeedSystem.ShowNotification("Speed set to: " .. SpeedSettings.WalkSpeed)
end

function SpeedSystem.ShowNotification(msg)
    if getgenv().NotificationSystem then
        getgenv().NotificationSystem.ShowNotification(msg)
    else
        print("🚀 SPEED: " .. msg)
    end
end

function SpeedSystem.GetSettings()
    return SpeedSettings
end

function SpeedSystem.Destroy()
    SpeedSystem.Disable()
    if speedButton then
        speedButton:Destroy()
        speedButton = nil
    end
    SpeedSystem.ShowNotification("Speed System destroyed")
end

-- Глобальні функції
getgenv().SPEED = {
    Enable = SpeedSystem.Enable,
    Disable = SpeedSystem.Disable,
    Toggle = SpeedSystem.Toggle,
    SetSpeed = SpeedSystem.SetSpeed,
    GetSettings = SpeedSystem.GetSettings
}

return SpeedSystem
