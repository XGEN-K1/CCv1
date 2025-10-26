-- PlayerSystem.lua
-- Система роботи з гравцями (граб, чардж, дроп грошей)

local PlayerSystem = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Налаштування
PlayerSystem.Settings = {
    TargetPlayer = nil,
    IsCharging = false
}

-- Змінні
PlayerSystem.Buttons = {}
PlayerSystem.UIElements = {}
PlayerSystem.Connections = {}
PlayerSystem.LocalPlayer = Players.LocalPlayer

-- Ініціалізація
function PlayerSystem.Init(parentPanel)
    PlayerSystem.parentPanel = parentPanel
    
    -- Створення UI елементів
    PlayerSystem.CreateUIElements()
    
    -- Налаштування підписок
    PlayerSystem.SetupConnections()
    
    print("✅ PlayerSystem ініціалізовано")
end

-- Створення UI елементів
function PlayerSystem.CreateUIElements()
    -- Поле введення цілі
    PlayerSystem.UIElements.TargetInput = Instance.new("TextBox")
    PlayerSystem.UIElements.TargetInput.Size = UDim2.new(0, 80, 0, 30)
    PlayerSystem.UIElements.TargetInput.Position = UDim2.new(0, 5, 0, 50)
    PlayerSystem.UIElements.TargetInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    PlayerSystem.UIElements.TargetInput.PlaceholderText = "Enter username"
    PlayerSystem.UIElements.TargetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    PlayerSystem.UIElements.TargetInput.BackgroundTransparency = 0.7
    PlayerSystem.UIElements.TargetInput.TextColor3 = Color3.new(1, 1, 1)
    PlayerSystem.UIElements.TargetInput.Font = Enum.Font.SourceSans
    PlayerSystem.UIElements.TargetInput.TextSize = 18
    PlayerSystem.UIElements.TargetInput.ClearTextOnFocus = true
    PlayerSystem.UIElements.TargetInput.Text = ""
    PlayerSystem.UIElements.TargetInput.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerSystem.UIElements.TargetInput.Parent = PlayerSystem.parentPanel
    Instance.new("UICorner", PlayerSystem.UIElements.TargetInput).CornerRadius = UDim.new(0, 6)

    -- Підказка автодоповнення
    PlayerSystem.UIElements.AutoCompleteLabel = Instance.new("TextLabel")
    PlayerSystem.UIElements.AutoCompleteLabel.Size = UDim2.new(0, 80, 0, 20)
    PlayerSystem.UIElements.AutoCompleteLabel.Position = UDim2.new(0, 5, 0, 85)
    PlayerSystem.UIElements.AutoCompleteLabel.BackgroundTransparency = 1
    PlayerSystem.UIElements.AutoCompleteLabel.Text = ""
    PlayerSystem.UIElements.AutoCompleteLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PlayerSystem.UIElements.AutoCompleteLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerSystem.UIElements.AutoCompleteLabel.Font = Enum.Font.SourceSansItalic
    PlayerSystem.UIElements.AutoCompleteLabel.TextSize = 14
    PlayerSystem.UIElements.AutoCompleteLabel.Parent = PlayerSystem.parentPanel

    -- Поле введення суми
    PlayerSystem.UIElements.AmountInput = Instance.new("TextBox")
    PlayerSystem.UIElements.AmountInput.Size = UDim2.new(0, 80, 0, 30)
    PlayerSystem.UIElements.AmountInput.Position = UDim2.new(0, 5, 0, 110)
    PlayerSystem.UIElements.AmountInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    PlayerSystem.UIElements.AmountInput.PlaceholderText = "Amount"
    PlayerSystem.UIElements.AmountInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    PlayerSystem.UIElements.AmountInput.BackgroundTransparency = 0.7
    PlayerSystem.UIElements.AmountInput.TextColor3 = Color3.new(1, 1, 1)
    PlayerSystem.UIElements.AmountInput.Font = Enum.Font.SourceSans
    PlayerSystem.UIElements.AmountInput.TextSize = 18
    PlayerSystem.UIElements.AmountInput.ClearTextOnFocus = true
    PlayerSystem.UIElements.AmountInput.Text = ""
    PlayerSystem.UIElements.AmountInput.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerSystem.UIElements.AmountInput.Parent = PlayerSystem.parentPanel
    Instance.new("UICorner", PlayerSystem.UIElements.AmountInput).CornerRadius = UDim.new(0, 6)

    -- Кнопка Charge
    PlayerSystem.Buttons.Charge = Instance.new("TextButton")
    PlayerSystem.Buttons.Charge.Size = UDim2.new(0, 80, 0, 30)
    PlayerSystem.Buttons.Charge.Position = UDim2.new(0, 5, 0, 185)
    PlayerSystem.Buttons.Charge.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    PlayerSystem.Buttons.Charge.BackgroundTransparency = 0.7
    PlayerSystem.Buttons.Charge.Text = "Charge"
    PlayerSystem.Buttons.Charge.TextColor3 = Color3.new(1, 1, 1)
    PlayerSystem.Buttons.Charge.Font = Enum.Font.SourceSansBold
    PlayerSystem.Buttons.Charge.TextSize = 18
    PlayerSystem.Buttons.Charge.Parent = PlayerSystem.parentPanel
    Instance.new("UICorner", PlayerSystem.Buttons.Charge).CornerRadius = UDim.new(0, 6)

    -- Кнопка Drop Money
    PlayerSystem.Buttons.Drop = Instance.new("TextButton")
    PlayerSystem.Buttons.Drop.Size = UDim2.new(0, 80, 0, 30)
    PlayerSystem.Buttons.Drop.Position = UDim2.new(0, 5, 0, 225)
    PlayerSystem.Buttons.Drop.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    PlayerSystem.Buttons.Drop.BackgroundTransparency = 0.7
    PlayerSystem.Buttons.Drop.Text = "Drop Money"
    PlayerSystem.Buttons.Drop.TextColor3 = Color3.new(1, 1, 1)
    PlayerSystem.Buttons.Drop.Font = Enum.Font.SourceSansBold
    PlayerSystem.Buttons.Drop.TextSize = 18
    PlayerSystem.Buttons.Drop.TextScaled = true
    PlayerSystem.Buttons.Drop.Parent = PlayerSystem.parentPanel
    Instance.new("UICorner", PlayerSystem.Buttons.Drop).CornerRadius = UDim.new(0, 6)

    -- Статус
    PlayerSystem.UIElements.StatusLabel = Instance.new("TextLabel")
    PlayerSystem.UIElements.StatusLabel.Size = UDim2.new(0, 80, 0, 40)
    PlayerSystem.UIElements.StatusLabel.Position = UDim2.new(0, 5, 0, 265)
    PlayerSystem.UIElements.StatusLabel.BackgroundTransparency = 1
    PlayerSystem.UIElements.StatusLabel.Text = "Status: Ready"
    PlayerSystem.UIElements.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PlayerSystem.UIElements.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerSystem.UIElements.StatusLabel.Font = Enum.Font.SourceSans
    PlayerSystem.UIElements.StatusLabel.TextSize = 14
    PlayerSystem.UIElements.StatusLabel.TextWrapped = true
    PlayerSystem.UIElements.StatusLabel.Parent = PlayerSystem.parentPanel
end

-- Налаштування підписок
function PlayerSystem.SetupConnections()
    -- Обробник втрати фокусу для цілі
    PlayerSystem.UIElements.TargetInput.FocusLost:Connect(function()
        local input = PlayerSystem.UIElements.TargetInput.Text
        if input == "" then
            PlayerSystem.Settings.TargetPlayer = nil
            PlayerSystem.UIElements.AutoCompleteLabel.Text = ""
            return
        end
        
        local player = PlayerSystem.FindPlayer(input)
        if player then
            PlayerSystem.UIElements.TargetInput.Text = player.Name
            PlayerSystem.Settings.TargetPlayer = player
            PlayerSystem.UIElements.AutoCompleteLabel.Text = "Target: "..player.DisplayName.." (@"..player.Name..")"
            PlayerSystem.UpdateStatus("Target set ("..(player == PlayerSystem.LocalPlayer and "SELF" or player.Name)..")")
        else
            PlayerSystem.Settings.TargetPlayer = nil
            PlayerSystem.UIElements.AutoCompleteLabel.Text = "Player not found"
            PlayerSystem.UpdateStatus("Invalid target")
        end
    end)

    -- Обробник зміни тексту для підказки
    PlayerSystem.UIElements.TargetInput:GetPropertyChangedSignal("Text"):Connect(function()
        local input = PlayerSystem.UIElements.TargetInput.Text
        if input == "" then
            PlayerSystem.UIElements.AutoCompleteLabel.Text = ""
            return
        end
        
        local player = PlayerSystem.FindPlayer(input)
        if player then
            PlayerSystem.UIElements.AutoCompleteLabel.Text = "Suggested: "..player.DisplayName.." (@"..player.Name..")"
        else
            PlayerSystem.UIElements.AutoCompleteLabel.Text = "No match found"
        end
    end)

    -- Кнопка Charge
    PlayerSystem.Buttons.Charge.MouseButton1Down:Connect(function()
        PlayerSystem.StartCharge()
    end)
    
    PlayerSystem.Buttons.Charge.MouseButton1Up:Connect(function()
        PlayerSystem.StopCharge()
    end)

    -- Кнопка Drop Money
    PlayerSystem.Buttons.Drop.MouseButton1Click:Connect(function()
        PlayerSystem.DropMoney()
    end)

    -- Обробник виходу гравця
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(leavingPlayer)
        if PlayerSystem.Settings.TargetPlayer and PlayerSystem.Settings.TargetPlayer == leavingPlayer then
            PlayerSystem.Settings.TargetPlayer = nil
            PlayerSystem.UIElements.TargetInput.Text = ""
            PlayerSystem.UIElements.AutoCompleteLabel.Text = ""
            PlayerSystem.UpdateStatus("Target left the game")
        end
    end)
    
    table.insert(PlayerSystem.Connections, playerRemovingConn)
end

-- Функції для роботи з гравцями
function PlayerSystem.FindPlayer(input)
    input = string.lower(input)
    if input == "" then return nil end
    
    if input == "me" or input == "self" then
        return PlayerSystem.LocalPlayer
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == input or string.lower(player.DisplayName) == input then
            return player
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name):sub(1, #input) == input or 
           string.lower(player.DisplayName):sub(1, #input) == input then
            return player
        end
    end
    
    return nil
end

-- Функції заряду
function PlayerSystem.ActivateCharge(player, state)
    if not player then return false end
    
    local character = player.Character
    if not character then return false end
    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("MobileCharge") then
            local mobileCharge = tool:FindFirstChild("MobileCharge")
            if mobileCharge then
                mobileCharge:FireServer(state)
                return true
            end
        end
    end
    
    return false
end

function PlayerSystem.StartCharge()
    if not PlayerSystem.Settings.TargetPlayer then
        PlayerSystem.UpdateStatus("No target selected")
        return
    end
    
    PlayerSystem.Settings.IsCharging = true
    PlayerSystem.Buttons.Charge.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    PlayerSystem.UpdateStatus("Charging "..(PlayerSystem.Settings.TargetPlayer == PlayerSystem.LocalPlayer and "SELF" or PlayerSystem.Settings.TargetPlayer.Name))
    
    -- Анімація натискання
    local tween = TweenService:Create(
        PlayerSystem.Buttons.Charge,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 75, 0, 25), Position = UDim2.new(0, 7, 0, 187)}
    )
    tween:Play()
    
    -- Активуємо заряд
    local success = PlayerSystem.ActivateCharge(PlayerSystem.Settings.TargetPlayer, true)
    if not success then
        PlayerSystem.UpdateStatus("No MobileCharge found")
        PlayerSystem.Settings.IsCharging = false
        PlayerSystem.Buttons.Charge.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end

function PlayerSystem.StopCharge()
    if not PlayerSystem.Settings.IsCharging then return end
    
    PlayerSystem.Settings.IsCharging = false
    PlayerSystem.Buttons.Charge.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    PlayerSystem.UpdateStatus("Ready")
    
    -- Анімація відпускання
    local tween = TweenService:Create(
        PlayerSystem.Buttons.Charge,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(0, 5, 0, 185)}
    )
    tween:Play()
    
    -- Деактивуємо заряд
    PlayerSystem.ActivateCharge(PlayerSystem.Settings.TargetPlayer, false)
end

-- Функції для гаманця
function PlayerSystem.FindWalletEvent(player)
    if not player then return nil end
    
    -- Шукаємо в Character
    local character = player.Character
    if character then
        local wallet = character:FindFirstChild("Wallet")
        if wallet then
            local dropEvent = wallet:FindFirstChild("DropEvent")
            if dropEvent then
                return dropEvent
            end
        end
    end
    
    -- Шукаємо в Backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local wallet = backpack:FindFirstChild("Wallet")
        if wallet then
            local dropEvent = wallet:FindFirstChild("DropEvent")
            if dropEvent then
                return dropEvent
            end
        end
    end
    
    return nil
end

function PlayerSystem.DropMoney()
    if not PlayerSystem.Settings.TargetPlayer then
        PlayerSystem.UpdateStatus("No target selected")
        return
    end
    
    local amount = tonumber(PlayerSystem.UIElements.AmountInput.Text)
    if not amount or amount <= 0 then
        PlayerSystem.UpdateStatus("Invalid amount")
        return
    end
    
    if amount > 20000 then
        PlayerSystem.UpdateStatus("Max amount is $20,000")
        return
    end

    -- Шукаємо DropEvent
    local dropEvent = PlayerSystem.FindWalletEvent(PlayerSystem.Settings.TargetPlayer)
    
    if not dropEvent then
        PlayerSystem.UpdateStatus("Wallet not found on target")
        return
    end

    -- Анімація натискання
    local tween = TweenService:Create(
        PlayerSystem.Buttons.Drop,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 75, 0, 25), Position = UDim2.new(0, 7, 0, 227)}
    )
    tween:Play()
    
    -- Відправляємо подію
    dropEvent:FireServer(tostring(amount))
    
    PlayerSystem.UpdateStatus("Dropped $"..amount.." to "..PlayerSystem.Settings.TargetPlayer.Name)
    PlayerSystem.ShowNotification("Dropped $"..amount.." to "..PlayerSystem.Settings.TargetPlayer.Name)
    
    -- Повертаємо кнопку
    task.wait(0.1)
    tween = TweenService:Create(
        PlayerSystem.Buttons.Drop,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(0, 5, 0, 225)}
    )
    tween:Play()
end

-- Допоміжні функції
function PlayerSystem.UpdateStatus(message)
    if PlayerSystem.UIElements.StatusLabel then
        PlayerSystem.UIElements.StatusLabel.Text = "Status: " .. message
    end
end

function PlayerSystem.ShowNotification(message)
    if getgenv().CC_Modules and getgenv().CC_Modules.NotificationSystem then
        getgenv().CC_Modules.NotificationSystem.ShowNotification(message)
    else
        warn("NotificationSystem не завантажено: " .. message)
    end
end

-- Деструктор
function PlayerSystem.Destroy()
    PlayerSystem.Settings.IsCharging = false
    PlayerSystem.Settings.TargetPlayer = nil
    
    for _, conn in pairs(PlayerSystem.Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    
    for _, button in pairs(PlayerSystem.Buttons) do
        if button then
            button:Destroy()
        end
    end
    
    for _, element in pairs(PlayerSystem.UIElements) do
        if element then
            element:Destroy()
        end
    end
    
    print("✅ PlayerSystem вимкнено")
end

return PlayerSystem
