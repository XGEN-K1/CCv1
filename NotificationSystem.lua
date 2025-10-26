-- NotificationSystem.lua
-- Система сповіщень для всіх модулів

local NotificationSystem = {}
local CoreGui = game:GetService("CoreGui")

-- Налаштування
NotificationSystem.Settings = {
    MaxNotifications = 3,
    Duration = 3
}

-- Ініціалізація
function NotificationSystem.Init()
    if NotificationSystem.initialized then return end
    
    -- Створення GUI для сповіщень
    NotificationSystem.notificationGui = Instance.new("ScreenGui")
    NotificationSystem.notificationGui.Name = "CC_Notifications"
    NotificationSystem.notificationGui.Parent = CoreGui
    NotificationSystem.notificationGui.ResetOnSpawn = false

    NotificationSystem.notificationFrame = Instance.new("Frame")
    NotificationSystem.notificationFrame.Name = "NotificationFrame"
    NotificationSystem.notificationFrame.Size = UDim2.new(0, 220, 0, 110)
    NotificationSystem.notificationFrame.Position = UDim2.new(1, -500, 0, -45)
    NotificationSystem.notificationFrame.AnchorPoint = Vector2.new(0, 0)
    NotificationSystem.notificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotificationSystem.notificationFrame.BackgroundTransparency = 1
    NotificationSystem.notificationFrame.BorderSizePixel = 0
    NotificationSystem.notificationFrame.Visible = false
    NotificationSystem.notificationFrame.Parent = NotificationSystem.notificationGui

    Instance.new("UICorner", NotificationSystem.notificationFrame).CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = NotificationSystem.notificationFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = NotificationSystem.notificationFrame
    
    NotificationSystem.initialized = true
    print("✅ NotificationSystem ініціалізовано")
end

-- Функція створення сповіщення
function NotificationSystem.CreateNotificationLabel(text)
    if not NotificationSystem.initialized then return end
    
    if #NotificationSystem.notificationFrame:GetChildren() - 2 >= NotificationSystem.Settings.MaxNotifications then
        NotificationSystem.notificationFrame:GetChildren()[3]:Destroy()
    end
    
    local label = Instance.new("TextLabel")
    label.Name = "NotificationText"
    label.Size = UDim2.new(1, -10, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.Parent = NotificationSystem.notificationFrame
    
    task.delay(NotificationSystem.Settings.Duration, function()
        if label and label.Parent then
            for i = 1, 0, -0.1 do
                if label then
                    label.TextTransparency = 1 - i
                    task.wait(0.05)
                end
            end
            label:Destroy()
            
            if #NotificationSystem.notificationFrame:GetChildren() <= 2 then
                NotificationSystem.notificationFrame.Visible = false
            end
        end
    end)
    
    return label
end

-- Основна функція показу сповіщення
function NotificationSystem.ShowNotification(message)
    if not NotificationSystem.initialized then
        NotificationSystem.Init()
    end
    
    NotificationSystem.notificationFrame.Visible = true
    NotificationSystem.CreateNotificationLabel(message)
end

-- Деструктор
function NotificationSystem.Destroy()
    if NotificationSystem.notificationGui then
        NotificationSystem.notificationGui:Destroy()
    end
    NotificationSystem.initialized = false
end

return NotificationSystem
