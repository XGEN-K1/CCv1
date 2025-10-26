-- StompSystem.lua
-- Система стомпу з основного скрипту

local StompSystem = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Налаштування
StompSystem.Settings = {
    Enabled = true,
    BindEnabled = true,
    StompKey = Enum.KeyCode.Y
}

-- Змінні
StompSystem.Active = false
StompSystem.StompLoop = nil
StompSystem.Connections = {}

-- Ініціалізація
function StompSystem.Init(parentPanel, config)
    StompSystem.config = config or {}
    StompSystem.StompEvent = config.StompEvent
    
    -- Створення кнопок
    StompSystem.CreateButtons(parentPanel)
    
    -- Налаштування клавіш
    StompSystem.SetupKeybinds()
    
    print("✅ StompSystem ініціалізовано")
end

-- Створення кнопок GUI
function StompSystem.CreateButtons(parentPanel)
    -- Кнопка Stomp
    StompSystem.StompButton = Instance.new("TextButton")
    StompSystem.StompButton.Size = UDim2.new(0, 80, 0, 30)
    StompSystem.StompButton.Position = UDim2.new(0, 5, 0, 210)
    StompSystem.StompButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    StompSystem.StompButton.BackgroundTransparency = 0.7
    StompSystem.StompButton.Text = "Stomp (OFF)"
    StompSystem.StompButton.TextColor3 = Color3.new(1, 1, 1)
    StompSystem.StompButton.Font = Enum.Font.SourceSansBold
    StompSystem.StompButton.TextSize = 18
    StompSystem.StompButton.TextScaled = true
    StompSystem.StompButton.Parent = parentPanel
    Instance.new("UICorner", StompSystem.StompButton).CornerRadius = UDim.new(0, 6)
    
    StompSystem.StompButton.MouseButton1Click:Connect(function()
        StompSystem.ToggleStomp()
        StompSystem.UpdateButtons()
    end)
    
    -- Кнопка StompBind
    StompSystem.StompBindButton = Instance.new("TextButton")
    StompSystem.StompBindButton.Size = UDim2.new(0, 80, 0, 30)
    StompSystem.StompBindButton.Position = UDim2.new(0, 5, 0, 250)
    StompSystem.StompBindButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    StompSystem.StompBindButton.BackgroundTransparency = 0.7
    StompSystem.StompBindButton.Text = "StompBindY (ON)"
    StompSystem.StompBindButton.TextColor3 = Color3.new(1, 1, 1)
    StompSystem.StompBindButton.Font = Enum.Font.SourceSansBold
    StompSystem.StompBindButton.TextSize = 18
    StompSystem.StompBindButton.TextScaled = true
    StompSystem.StompBindButton.Parent = parentPanel
    Instance.new("UICorner", StompSystem.StompBindButton).CornerRadius = UDim.new(0, 6)
    
    StompSystem.StompBindButton.MouseButton1Click:Connect(function()
        StompSystem.Settings.BindEnabled = not StompSystem.Settings.BindEnabled
        StompSystem.UpdateButtons()
        StompSystem.ShowNotification("Stomp Binds: " .. (StompSystem.Settings.BindEnabled and "Enabled" or "Disabled"))
    end)
end

-- Налаштування клавіш
function StompSystem.SetupKeybinds()
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not StompSystem.Settings.BindEnabled then return end
        
        if input.KeyCode == (StompSystem.config.ToggleKey or Enum.KeyCode.Y) then
            StompSystem.ToggleStomp()
            StompSystem.UpdateButtons()
        end
    end)
    
    table.insert(StompSystem.Connections, inputConn)
end

-- Основна функція стомпу
function StompSystem.ToggleStomp()
    if not StompSystem.Settings.Enabled then return end
    
    StompSystem.Active = not StompSystem.Active
    
    if StompSystem.Active then
        StompSystem.StartStomp()
    else
        StompSystem.StopStomp()
    end
    
    StompSystem.ShowNotification("Stomp: " .. (StompSystem.Active and "On ✅" or "Off ❌"))
end

function StompSystem.StartStomp()
    StompSystem.StompLoop = RunService.Heartbeat:Connect(function()
        if StompSystem.Active and StompSystem.Settings.Enabled then
            StompSystem.StompEvent:FireServer()
            task.wait(0.1)
        else
            if StompSystem.StompLoop then
                StompSystem.StompLoop:Disconnect()
            end
        end
    end)
end

function StompSystem.StopStomp()
    if StompSystem.StompLoop then
        StompSystem.StompLoop:Disconnect()
        StompSystem.StompLoop = nil
    end
end

-- Оновлення стану кнопок
function StompSystem.UpdateButtons()
    if StompSystem.StompButton then
        StompSystem.StompButton.Text = "Stomp (" .. (StompSystem.Active and "ON" or "OFF") .. ")"
        StompSystem.StompButton.BackgroundColor3 = StompSystem.Active and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(100, 100, 100)
    end
    
    if StompSystem.StompBindButton then
        StompSystem.StompBindButton.Text = "StompBindY (" .. (StompSystem.Settings.BindEnabled and "ON" or "OFF") .. ")"
        StompSystem.StompBindButton.BackgroundColor3 = StompSystem.Settings.BindEnabled and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(100, 100, 100)
    end
end

-- Сповіщення
function StompSystem.ShowNotification(message)
    if getgenv().CC_Modules and getgenv().CC_Modules.NotificationSystem then
        getgenv().CC_Modules.NotificationSystem.ShowNotification(message)
    else
        warn("NotificationSystem не завантажено: " .. message)
    end
end

-- Деструктор
function StompSystem.Destroy()
    StompSystem.Active = false
    StompSystem.StopStomp()
    
    for _, conn in pairs(StompSystem.Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    
    if StompSystem.StompButton then
        StompSystem.StompButton:Destroy()
    end
    if StompSystem.StompBindButton then
        StompSystem.StompBindButton:Destroy()
    end
    
    print("✅ StompSystem вимкнено")
end

return StompSystem
