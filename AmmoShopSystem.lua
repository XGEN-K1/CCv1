-- AmmoShopSystem.lua
-- Система магазинів амуніції

local AmmoShopSystem = {}
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Налаштування
AmmoShopSystem.Settings = {
    FilterActive = true
}

-- Змінні
AmmoShopSystem.FoundEntries = {}
AmmoShopSystem.Buttons = {}
AmmoShopSystem.UIElements = {}
AmmoShopSystem.LocalPlayer = Players.LocalPlayer

-- Ініціалізація
function AmmoShopSystem.Init(parentPanel, filterButton)
    AmmoShopSystem.parentPanel = parentPanel
    AmmoShopSystem.filterButton = filterButton
    
    -- Збір магазинів амуніції
    AmmoShopSystem.CollectAmmoShops()
    
    -- Створення UI елементів
    AmmoShopSystem.CreateUIElements()
    
    -- Налаштування підписок
    AmmoShopSystem.SetupConnections()
    
    print("✅ AmmoShopSystem ініціалізовано")
end

-- Збір магазинів амуніції
function AmmoShopSystem.CollectAmmoShops()
    local gunAmmoShops = Workspace:WaitForChild("Shops"):GetChildren()
    AmmoShopSystem.FoundEntries = {}

    for _, shop in ipairs(gunAmmoShops) do
        if shop:IsA("Model") and shop.Name == "GunAmmo" then
            local boolValue = nil
            local clickDetector = nil

            for _, obj in ipairs(shop:GetDescendants()) do
                if obj:IsA("BoolValue") and not AmmoShopSystem.FoundEntries[obj.Name] then
                    boolValue = obj
                end
                if obj:IsA("ClickDetector") and obj.Parent and obj.Parent.Name == "Head" then
                    clickDetector = obj
                end
            end

            if boolValue and clickDetector then
                AmmoShopSystem.FoundEntries[boolValue.Name] = clickDetector
            end
        end
    end
end

-- Створення UI елементів
function AmmoShopSystem.CreateUIElements()
    -- Поле пошуку
    AmmoShopSystem.UIElements.SearchBox = Instance.new("TextBox")
    AmmoShopSystem.UIElements.SearchBox.Size = UDim2.new(0, 260, 0, 30)
    AmmoShopSystem.UIElements.SearchBox.Position = UDim2.new(0, 5, 0, 50)
    AmmoShopSystem.UIElements.SearchBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    AmmoShopSystem.UIElements.SearchBox.PlaceholderText = "Search Ammo..."
    AmmoShopSystem.UIElements.SearchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    AmmoShopSystem.UIElements.SearchBox.BackgroundTransparency = 0.7
    AmmoShopSystem.UIElements.SearchBox.TextColor3 = Color3.new(1, 1, 1)
    AmmoShopSystem.UIElements.SearchBox.Font = Enum.Font.SourceSans
    AmmoShopSystem.UIElements.SearchBox.TextSize = 18
    AmmoShopSystem.UIElements.SearchBox.ClearTextOnFocus = false
    AmmoShopSystem.UIElements.SearchBox.Text = ""
    AmmoShopSystem.UIElements.SearchBox.TextTruncate = Enum.TextTruncate.AtEnd
    AmmoShopSystem.UIElements.SearchBox.Parent = AmmoShopSystem.parentPanel
    Instance.new("UICorner", AmmoShopSystem.UIElements.SearchBox).CornerRadius = UDim.new(0, 6)

    -- Список
    AmmoShopSystem.UIElements.Scroll = Instance.new("ScrollingFrame")
    AmmoShopSystem.UIElements.Scroll.Size = UDim2.new(0, 260, 0, 275)
    AmmoShopSystem.UIElements.Scroll.Position = UDim2.new(0, 5, 0, 90)
    AmmoShopSystem.UIElements.Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    AmmoShopSystem.UIElements.Scroll.ScrollBarThickness = 8
    AmmoShopSystem.UIElements.Scroll.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    AmmoShopSystem.UIElements.Scroll.BackgroundTransparency = 0.9
    AmmoShopSystem.UIElements.Scroll.BorderSizePixel = 0
    AmmoShopSystem.UIElements.Scroll.Parent = AmmoShopSystem.parentPanel
    Instance.new("UICorner", AmmoShopSystem.UIElements.Scroll).CornerRadius = UDim.new(0, 6)

    -- Layout для списку
    AmmoShopSystem.UIElements.UIList = Instance.new("UIListLayout")
    AmmoShopSystem.UIElements.UIList.Parent = AmmoShopSystem.UIElements.Scroll
    AmmoShopSystem.UIElements.UIList.SortOrder = Enum.SortOrder.LayoutOrder
    AmmoShopSystem.UIElements.UIList.Padding = UDim.new(0, 4)

    -- Створення кнопок для кожного магазину
    AmmoShopSystem.CreateShopButtons()
end

-- Створення кнопок магазинів
function AmmoShopSystem.CreateShopButtons()
    AmmoShopSystem.Buttons = {}

    for name, detector in pairs(AmmoShopSystem.FoundEntries) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 260, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        button.BackgroundTransparency = 0.7
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 18
        button.Text = name
        button.Name = name
        button.TextTruncate = Enum.TextTruncate.AtEnd
        button.Parent = AmmoShopSystem.UIElements.Scroll
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

        button.MouseButton1Click:Connect(function()
            if detector and detector.Parent then
                fireclickdetector(detector)
                AmmoShopSystem.ShowNotification("Purchased: " .. name)
            end
        end)

        AmmoShopSystem.Buttons[name] = button
    end

    -- Оновлення розміру канвасу
    AmmoShopSystem.UpdateCanvas()
end

-- Налаштування підписок
function AmmoShopSystem.SetupConnections()
    -- Кнопка фільтра
    if AmmoShopSystem.filterButton then
        AmmoShopSystem.filterButton.MouseButton1Click:Connect(function()
            AmmoShopSystem.Settings.FilterActive = not AmmoShopSystem.Settings.FilterActive
            AmmoShopSystem.filterButton.BackgroundColor3 = AmmoShopSystem.Settings.FilterActive and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
            AmmoShopSystem.UpdateVisibility()
        end)
    end

    -- Пошук
    AmmoShopSystem.UIElements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        AmmoShopSystem.UpdateVisibility()
    end)

    -- Зміни інвентаря
    AmmoShopSystem.LocalPlayer.Backpack.ChildAdded:Connect(function()
        AmmoShopSystem.UpdateVisibility()
    end)
    
    AmmoShopSystem.LocalPlayer.Backpack.ChildRemoved:Connect(function()
        AmmoShopSystem.UpdateVisibility()
    end)

    -- Підписка на зміни персонажа
    AmmoShopSystem.HookCharacter()
    AmmoShopSystem.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        AmmoShopSystem.HookCharacter()
        AmmoShopSystem.UpdateVisibility()
    end)
end

-- Підписка на зміни персонажа
function AmmoShopSystem.HookCharacter()
    local char = Workspace:FindFirstChild(AmmoShopSystem.LocalPlayer.Name)
    if char then
        char.ChildAdded:Connect(function()
            AmmoShopSystem.UpdateVisibility()
        end)
        char.ChildRemoved:Connect(function()
            AmmoShopSystem.UpdateVisibility()
        end)
    end
end

-- Функції для фільтрації
function AmmoShopSystem.PlayerHasTool(toolName)
    for _, container in ipairs({AmmoShopSystem.LocalPlayer.Backpack, Workspace:FindFirstChild(AmmoShopSystem.LocalPlayer.Name)}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and item.Name == toolName then
                    return true
                end
            end
        end
    end
    return false
end

function AmmoShopSystem.UpdateVisibility()
    local query = AmmoShopSystem.UIElements.SearchBox.Text:lower()
    for name, button in pairs(AmmoShopSystem.Buttons) do
        local visible = true
        if AmmoShopSystem.Settings.FilterActive and not AmmoShopSystem.PlayerHasTool(name) then
            visible = false
        end
        if query ~= "" and not name:lower():find(query, 1, true) then
            visible = false
        end
        button.Visible = visible
    end
    AmmoShopSystem.UpdateCanvas()
end

function AmmoShopSystem.UpdateCanvas()
    task.defer(function()
        if AmmoShopSystem.UIElements.Scroll and AmmoShopSystem.UIElements.UIList then
            AmmoShopSystem.UIElements.Scroll.CanvasSize = UDim2.new(0, 0, 0, AmmoShopSystem.UIElements.UIList.AbsoluteContentSize.Y + 10)
        end
    end)
end

-- Сповіщення
function AmmoShopSystem.ShowNotification(message)
    if getgenv().CC_Modules and getgenv().CC_Modules.NotificationSystem then
        getgenv().CC_Modules.NotificationSystem.ShowNotification(message)
    else
        warn("NotificationSystem не завантажено: " .. message)
    end
end

-- Деструктор
function AmmoShopSystem.Destroy()
    for _, button in pairs(AmmoShopSystem.Buttons) do
        if button then
            button:Destroy()
        end
    end
    
    for _, element in pairs(AmmoShopSystem.UIElements) do
        if element then
            element:Destroy()
        end
    end
    
    AmmoShopSystem.Buttons = {}
    AmmoShopSystem.UIElements = {}
    AmmoShopSystem.FoundEntries = {}
    
    print("✅ AmmoShopSystem вимкнено")
end

return AmmoShopSystem
