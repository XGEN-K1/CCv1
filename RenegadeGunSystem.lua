-- RenegadeGunSystem.lua
-- Нова система Renegade з CC W BIND RenegadeGun - V3.lua

local RenegadeGunSystem = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Налаштування
RenegadeGunSystem.Settings = {
    CursorAim = false,
    SelfShoot = false,
    Radius = 16,
    Enabled = true,
    MarkersEnabled = true
}

-- Змінні
RenegadeGunSystem.Active = false
RenegadeGunSystem.PlayerMarkers = {}
RenegadeGunSystem.Connections = {}
RenegadeGunSystem.Loops = {}

-- Ініціалізація
function RenegadeGunSystem.Init(parentPanel, config)
    RenegadeGunSystem.config = config or {}
    RenegadeGunSystem.LocalPlayer = Players.LocalPlayer
    RenegadeGunSystem.ShootGunEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ShootGun")
    
    -- Створення кнопок
    RenegadeGunSystem.CreateButtons(parentPanel)
    
    -- Налаштування клавіш
    RenegadeGunSystem.SetupKeybinds()
    
    -- Підписка на події гравців
    RenegadeGunSystem.SetupPlayerEvents()
    
    print("✅ RenegadeGunSystem ініціалізовано")
end

-- Створення кнопок GUI
function RenegadeGunSystem.CreateButtons(parentPanel)
    -- Кнопка Cursor Aim
    RenegadeGunSystem.CursorAimButton = Instance.new("TextButton")
    RenegadeGunSystem.CursorAimButton.Size = UDim2.new(0, 80, 0, 30)
    RenegadeGunSystem.CursorAimButton.Position = UDim2.new(0, 5, 0, 210)
    RenegadeGunSystem.CursorAimButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    RenegadeGunSystem.CursorAimButton.BackgroundTransparency = 0.7
    RenegadeGunSystem.CursorAimButton.Text = "Cursor Aim (OFF)"
    RenegadeGunSystem.CursorAimButton.TextColor3 = Color3.new(1, 1, 1)
    RenegadeGunSystem.CursorAimButton.Font = Enum.Font.SourceSansBold
    RenegadeGunSystem.CursorAimButton.TextSize = 14
    RenegadeGunSystem.CursorAimButton.TextScaled = true
    RenegadeGunSystem.CursorAimButton.Parent = parentPanel
    Instance.new("UICorner", RenegadeGunSystem.CursorAimButton).CornerRadius = UDim.new(0, 6)
    
    RenegadeGunSystem.CursorAimButton.MouseButton1Click:Connect(function()
        RenegadeGunSystem.ToggleCursorAim()
    end)
    
    -- Кнопка Self Shoot
    RenegadeGunSystem.SelfShootButton = Instance.new("TextButton")
    RenegadeGunSystem.SelfShootButton.Size = UDim2.new(0, 80, 0, 30)
    RenegadeGunSystem.SelfShootButton.Position = UDim2.new(0, 5, 0, 250)
    RenegadeGunSystem.SelfShootButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    RenegadeGunSystem.SelfShootButton.BackgroundTransparency = 0.7
    RenegadeGunSystem.SelfShootButton.Text = "Self Shoot (OFF)"
    RenegadeGunSystem.SelfShootButton.TextColor3 = Color3.new(1, 1, 1)
    RenegadeGunSystem.SelfShootButton.Font = Enum.Font.SourceSansBold
    RenegadeGunSystem.SelfShootButton.TextSize = 14
    RenegadeGunSystem.SelfShootButton.TextScaled = true
    RenegadeGunSystem.SelfShootButton.Parent = parentPanel
    Instance.new("UICorner", RenegadeGunSystem.SelfShootButton).CornerRadius = UDim.new(0, 6)
    
    RenegadeGunSystem.SelfShootButton.MouseButton1Click:Connect(function()
        RenegadeGunSystem.ToggleSelfShoot()
    end)
end

-- Налаштування клавіш
function RenegadeGunSystem.SetupKeybinds()
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == (RenegadeGunSystem.config.SelfShootKey or Enum.KeyCode.K) then
            RenegadeGunSystem.ToggleSelfShoot()
        elseif input.KeyCode == (RenegadeGunSystem.config.CursorAimKey or Enum.KeyCode.M) then
            RenegadeGunSystem.ToggleCursorAim()
        end
    end)
    
    table.insert(RenegadeGunSystem.Connections, inputConn)
end

-- Підписка на події гравців
function RenegadeGunSystem.SetupPlayerEvents()
    local function onPlayerAdded(player)
        if player == RenegadeGunSystem.LocalPlayer then return end
        
        player.CharacterAdded:Connect(function(character)
            if RenegadeGunSystem.Settings.SelfShoot or RenegadeGunSystem.Settings.CursorAim then
                RenegadeGunSystem.UpdatePlayerMarkers()
            end
        end)
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end
    
    local playerAddedConn = Players.PlayerAdded:Connect(onPlayerAdded)
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        RenegadeGunSystem.RemoveCircle(player)
    end)
    
    table.insert(RenegadeGunSystem.Connections, playerAddedConn)
    table.insert(RenegadeGunSystem.Connections, playerRemovingConn)
end

-- Функції перемикання режимів
function RenegadeGunSystem.ToggleCursorAim()
    RenegadeGunSystem.Settings.CursorAim = not RenegadeGunSystem.Settings.CursorAim
    
    if RenegadeGunSystem.Settings.CursorAim then
        RenegadeGunSystem.Settings.SelfShoot = false -- Вимикаємо інший режим
        RenegadeGunSystem.StartCursorAim()
    else
        RenegadeGunSystem.StopCursorAim()
    end
    
    RenegadeGunSystem.UpdateButtons()
    RenegadeGunSystem.ShowNotification("Cursor Aim: " .. (RenegadeGunSystem.Settings.CursorAim and "ON ✅" or "OFF ❌"))
end

function RenegadeGunSystem.ToggleSelfShoot()
    RenegadeGunSystem.Settings.SelfShoot = not RenegadeGunSystem.Settings.SelfShoot
    
    if RenegadeGunSystem.Settings.SelfShoot then
        RenegadeGunSystem.Settings.CursorAim = false -- Вимикаємо інший режим
        RenegadeGunSystem.StartSelfShoot()
    else
        RenegadeGunSystem.StopSelfShoot()
    end
    
    RenegadeGunSystem.UpdateButtons()
    RenegadeGunSystem.ShowNotification("Self Shoot: " .. (RenegadeGunSystem.Settings.SelfShoot and "ON ✅" or "OFF ❌"))
end

-- Оновлення стану кнопок
function RenegadeGunSystem.UpdateButtons()
    if RenegadeGunSystem.CursorAimButton then
        RenegadeGunSystem.CursorAimButton.Text = "Cursor Aim (" .. (RenegadeGunSystem.Settings.CursorAim and "ON" or "OFF") .. ")"
        RenegadeGunSystem.CursorAimButton.BackgroundColor3 = RenegadeGunSystem.Settings.CursorAim and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(100, 100, 100)
    end
    
    if RenegadeGunSystem.SelfShootButton then
        RenegadeGunSystem.SelfShootButton.Text = "Self Shoot (" .. (RenegadeGunSystem.Settings.SelfShoot and "ON" or "OFF") .. ")"
        RenegadeGunSystem.SelfShootButton.BackgroundColor3 = RenegadeGunSystem.Settings.SelfShoot and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(100, 100, 100)
    end
end

-- Система маркерів
function RenegadeGunSystem.CreateCircle(player)
    if RenegadeGunSystem.PlayerMarkers[player] then return end
    
    local char = player.Character
    if char and char:FindFirstChild("Head") then
        local head = char.Head
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerMarker"
        billboard.Adornee = head
        billboard.Size = UDim2.new(2, 0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.Parent = billboard
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame
        
        RenegadeGunSystem.PlayerMarkers[player] = billboard
    end
end

function RenegadeGunSystem.RemoveCircle(player)
    local marker = RenegadeGunSystem.PlayerMarkers[player]
    if marker then
        marker:Destroy()
        RenegadeGunSystem.PlayerMarkers[player] = nil
    end
end

function RenegadeGunSystem.CleanupAllMarkers()
    for player, marker in pairs(RenegadeGunSystem.PlayerMarkers) do
        if marker then
            marker:Destroy()
        end
    end
    RenegadeGunSystem.PlayerMarkers = {}
end

-- Пошук гравців у радіусі
function RenegadeGunSystem.GetPlayersInRadius()
    local playersInRadius = {}
    local character = RenegadeGunSystem.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return playersInRadius
    end
    
    local rootPart = character.HumanoidRootPart
    local rootPosition = rootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= RenegadeGunSystem.LocalPlayer and player.Character then
            local char = player.Character
            local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - rootPosition).Magnitude
                if distance <= RenegadeGunSystem.Settings.Radius then
                    table.insert(playersInRadius, player)
                end
            end
        end
    end
    
    return playersInRadius
end

-- Оновлення маркерів
function RenegadeGunSystem.UpdatePlayerMarkers()
    if not RenegadeGunSystem.Settings.MarkersEnabled then return end
    
    local playersInRadius = RenegadeGunSystem.GetPlayersInRadius()
    local markedPlayers = {}
    
    -- Додати маркери для гравців в радіусі
    for _, player in pairs(playersInRadius) do
        markedPlayers[player] = true
        RenegadeGunSystem.CreateCircle(player)
    end
    
    -- Видалити маркери для гравців поза радіусом
    for player in pairs(RenegadeGunSystem.PlayerMarkers) do
        if not markedPlayers[player] then
            RenegadeGunSystem.RemoveCircle(player)
        end
    end
end

-- Цикл маркерів
function RenegadeGunSystem.MarkerLoop()
    while RenegadeGunSystem.Settings.SelfShoot or RenegadeGunSystem.Settings.CursorAim do
        RenegadeGunSystem.UpdatePlayerMarkers()
        RunService.Heartbeat:Wait()
    end
    RenegadeGunSystem.CleanupAllMarkers()
end

-- Функції для зброї
function RenegadeGunSystem.GetValidTool(player)
    local char = player.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local mobileCharge = tool:FindFirstChild("MobileCharge")
                if mobileCharge then
                    return tool, "MobileCharge"
                end
                
                local stats = tool:FindFirstChild("Stats")
                if stats and stats:FindFirstChild("ClipSize") then
                    return tool, "ClipSize"
                end
            end
        end
    end
    return nil, nil
end

function RenegadeGunSystem.GetHeadPosition(player)
    local char = player.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            return head.Position
        end
    end
    return nil
end

-- Атака по собі в голову (SelfShoot режим)
function RenegadeGunSystem.AttackSelf(targetPlayer)
    local headPos = RenegadeGunSystem.GetHeadPosition(targetPlayer)
    local tool, toolType = RenegadeGunSystem.GetValidTool(targetPlayer)
    
    if headPos and tool then
        if toolType == "MobileCharge" then
            local mobileCharge = tool:FindFirstChild("MobileCharge")
            if mobileCharge then
                mobileCharge:FireServer(true)
                mobileCharge:FireServer(false)
            end
        elseif toolType == "ClipSize" then
            RenegadeGunSystem.ShootGunEvent:FireServer(headPos, tool)
        end
    end
end

-- Функція для стрільби по курсору
function RenegadeGunSystem.GetCursorPosition()
    local mouse = RenegadeGunSystem.LocalPlayer:GetMouse()
    return mouse.Hit.Position
end

-- Атака по курсору (Cursor режим)
function RenegadeGunSystem.AttackTargetAtCursor(targetPlayer)
    local cursorPos = RenegadeGunSystem.GetCursorPosition()
    local tool, toolType = RenegadeGunSystem.GetValidTool(targetPlayer)
    
    if cursorPos and tool then
        if toolType == "MobileCharge" then
            local mobileCharge = tool:FindFirstChild("MobileCharge")
            if mobileCharge then
                mobileCharge:FireServer(false)
            end
        elseif toolType == "ClipSize" then
            RenegadeGunSystem.ShootGunEvent:FireServer(cursorPos, tool)
        end
    end
end

-- Цикли для стрільби
function RenegadeGunSystem.SelfShootLoop()
    while RenegadeGunSystem.Settings.SelfShoot do
        local playersInRadius = RenegadeGunSystem.GetPlayersInRadius()
        for _, player in pairs(playersInRadius) do
            RenegadeGunSystem.AttackSelf(player)
        end
        RunService.Heartbeat:Wait()
    end
end

function RenegadeGunSystem.CursorShootLoop()
    while RenegadeGunSystem.Settings.CursorAim do
        local playersInRadius = RenegadeGunSystem.GetPlayersInRadius()
        for _, player in pairs(playersInRadius) do
            RenegadeGunSystem.AttackTargetAtCursor(player)
        end
        RunService.Heartbeat:Wait()
    end
end

-- Запуск режимів
function RenegadeGunSystem.StartSelfShoot()
    RenegadeGunSystem.StopAllLoops()
    spawn(RenegadeGunSystem.MarkerLoop)
    spawn(RenegadeGunSystem.SelfShootLoop)
end

function RenegadeGunSystem.StartCursorAim()
    RenegadeGunSystem.StopAllLoops()
    spawn(RenegadeGunSystem.MarkerLoop)
    spawn(RenegadeGunSystem.CursorShootLoop)
end

-- Зупинка режимів
function RenegadeGunSystem.StopSelfShoot()
    RenegadeGunSystem.CleanupAllMarkers()
end

function RenegadeGunSystem.StopCursorAim()
    RenegadeGunSystem.CleanupAllMarkers()
end

function RenegadeGunSystem.StopAllLoops()
    -- Маркери очищаються автоматично при виході з циклу
end

-- Сповіщення
function RenegadeGunSystem.ShowNotification(message)
    if getgenv().CC_Modules and getgenv().CC_Modules.NotificationSystem then
        getgenv().CC_Modules.NotificationSystem.ShowNotification(message)
    else
        warn("NotificationSystem не завантажено: " .. message)
    end
end

-- Деструктор
function RenegadeGunSystem.Destroy()
    RenegadeGunSystem.Settings.SelfShoot = false
    RenegadeGunSystem.Settings.CursorAim = false
    
    RenegadeGunSystem.CleanupAllMarkers()
    RenegadeGunSystem.StopAllLoops()
    
    for _, conn in pairs(RenegegadeGunSystem.Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    
    if RenegadeGunSystem.CursorAimButton then
        RenegadeGunSystem.CursorAimButton:Destroy()
    end
    if RenegadeGunSystem.SelfShootButton then
        RenegadeGunSystem.SelfShootButton:Destroy()
    end
    
    print("✅ RenegadeGunSystem вимкнено")
end

return RenegadeGunSystem
