-- CombatSystem.lua
-- Система бойових функцій (спам атаки з чорними/білими списками)

local CombatSystem = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Налаштування
CombatSystem.Settings = {
    SpamActive = false,
    SpamBindEnabled = false,
    SpamKey = Enum.KeyCode.P
}

-- Списки
CombatSystem.PLAYER_BLACKLIST = {
    "IslamKesh", "Rasul_975", "22k12m71e", "Ramzes10030",
    "chaudidan1102", "8B39QF", "Ddushhsjeh2", "ELYSIUM_z1", "malinowy242",
    "chillsy_star", "FakeArg", "EDITlNG", "TakeoHonorable", "PickIeJar",
    "FlowFlawz", "R4ts3y", "erickygamer534", "GhostlyCraftz"
}

CombatSystem.PLAYER_WHITELIST = {
    "kenya2202", "XMarDelloX", "reizzaim", "matvey574810398", "jeffsk23",
    "Sanek17622", "Tusovshikk", "CrOw_KaR2", "qweasdytrhgf", "asproPUBG",
    "NoOBRoblox1052", "Gumanou6377", "J28jason", "Zjgckgx", "Larancibel",
    "ARSLAN_LOX23", "Grider_MinYT", "RatoRat44", "Cocolie_Coco",
    "DestructionInAction", "TurkunGucu681", "GSEGE17", "satoru1748",
    "llNOSUKKE", "zorro5771", "digalcazar14", "aleks52953", "Amir60531",
    "lvanTeplyakov"
}

CombatSystem.TEAM_BLACKLIST = { "Muscle Matrix" }
CombatSystem.TEAM_WHITELIST = {
    "(CC) The GreaT Armed", "paiN ね", "[CC] Borno to kill", "OuiOuiBaguette:|",
    "[CC] DARKNESS", "S_P_A_R_T_A", "[CC] Kanaplya", "E L l T E",
    "[CC] Russia imperial", "[CC] Immortal Dynasty"
}

-- Змінні
CombatSystem.Connections = {}
CombatSystem.Loops = {}
CombatSystem.LocalPlayer = Players.LocalPlayer

-- Ініціалізація
function CombatSystem.Init(parentPanel, config)
    CombatSystem.config = config or {}
    
    -- Створення кнопок
    CombatSystem.CreateButtons(parentPanel)
    
    -- Налаштування клавіш
    CombatSystem.SetupKeybinds()
    
    -- Ініціалізація системи
    CombatSystem.InitCombatSystem()
    
    print("✅ CombatSystem ініціалізовано")
end

-- Створення кнопок GUI
function CombatSystem.CreateButtons(parentPanel)
    -- Кнопка Spam
    CombatSystem.SpamButton = Instance.new("TextButton")
    CombatSystem.SpamButton.Size = UDim2.new(0, 80, 0, 30)
    CombatSystem.SpamButton.Position = UDim2.new(0, 5, 0, 130)
    CombatSystem.SpamButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    CombatSystem.SpamButton.BackgroundTransparency = 0.7
    CombatSystem.SpamButton.Text = "Spam (OFF)"
    CombatSystem.SpamButton.TextColor3 = Color3.new(1, 1, 1)
    CombatSystem.SpamButton.Font = Enum.Font.SourceSansBold
    CombatSystem.SpamButton.TextSize = 18
    CombatSystem.SpamButton.TextScaled = true
    CombatSystem.SpamButton.Parent = parentPanel
    Instance.new("UICorner", CombatSystem.SpamButton).CornerRadius = UDim.new(0, 6)
    
    CombatSystem.SpamButton.MouseButton1Click:Connect(function()
        CombatSystem.ToggleSpam()
    end)
    
    -- Кнопка SpamBind
    CombatSystem.SpamBindButton = Instance.new("TextButton")
    CombatSystem.SpamBindButton.Size = UDim2.new(0, 80, 0, 30)
    CombatSystem.SpamBindButton.Position = UDim2.new(0, 5, 0, 170)
    CombatSystem.SpamBindButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    CombatSystem.SpamBindButton.BackgroundTransparency = 0.7
    CombatSystem.SpamBindButton.Text = "SpamBindP (OFF)"
    CombatSystem.SpamBindButton.TextColor3 = Color3.new(1, 1, 1)
    CombatSystem.SpamBindButton.Font = Enum.Font.SourceSansBold
    CombatSystem.SpamBindButton.TextSize = 18
    CombatSystem.SpamBindButton.TextScaled = true
    CombatSystem.SpamBindButton.Parent = parentPanel
    Instance.new("UICorner", CombatSystem.SpamBindButton).CornerRadius = UDim.new(0, 6)
    
    CombatSystem.SpamBindButton.MouseButton1Click:Connect(function()
        CombatSystem.Settings.SpamBindEnabled = not CombatSystem.Settings.SpamBindEnabled
        CombatSystem.UpdateButtons()
        CombatSystem.ShowNotification("Spam Binds: " .. (CombatSystem.Settings.SpamBindEnabled and "Enabled" or "Disabled"))
    end)
end

-- Налаштування клавіш
function CombatSystem.SetupKeybinds()
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not CombatSystem.Settings.SpamBindEnabled then return end
        
        if input.KeyCode == (CombatSystem.config.ActivateKey or Enum.KeyCode.P) then
            CombatSystem.ToggleSpam()
        end
    end)
    
    table.insert(CombatSystem.Connections, inputConn)
end

-- Функції для списків
function CombatSystem.IsInList(value, list)
    if not value then return false end
    local valueLower = tostring(value):lower()
    for _, item in ipairs(list) do
        if tostring(item):lower() == valueLower then
            return true
        end
    end
    return false
end

function CombatSystem.ShouldAttack(player)
    if CombatSystem.IsInList(player.Name, CombatSystem.PLAYER_WHITELIST) then
        return true
    end
    if CombatSystem.IsInList(player.Name, CombatSystem.PLAYER_BLACKLIST) then
        return false
    end

    local teamName = player.Team and player.Team.Name or nil

    if teamName and CombatSystem.IsInList(teamName, CombatSystem.TEAM_WHITELIST) then
        return true
    end
    if teamName and CombatSystem.IsInList(teamName, CombatSystem.TEAM_BLACKLIST) then
        return false
    end

    return CombatSystem.Settings.SpamActive
end

-- Бойові функції
function CombatSystem.AttackPlayer(player)
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("MobileCharge") then
            local charge = tool.MobileCharge
            pcall(function()
                charge:FireServer(true)
                charge:FireServer(false)
            end)
        end
    end
end

function CombatSystem.AttackLoop()
    while true do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= CombatSystem.LocalPlayer and CombatSystem.ShouldAttack(p) then
                CombatSystem.AttackPlayer(p)
            end
        end
        task.wait()
    end
end

-- Управління станом
function CombatSystem.ToggleSpam()
    CombatSystem.Settings.SpamActive = not CombatSystem.Settings.SpamActive
    CombatSystem.UpdateButtons()
    CombatSystem.ShowNotification("Spam Melee: " .. (CombatSystem.Settings.SpamActive and "On ✅" or "Off ❌"))
end

function CombatSystem.UpdateButtons()
    if CombatSystem.SpamButton then
        CombatSystem.SpamButton.Text = "Spam (" .. (CombatSystem.Settings.SpamActive and "ON" or "OFF") .. ")"
        CombatSystem.SpamButton.BackgroundColor3 = CombatSystem.Settings.SpamActive and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(100, 100, 100)
    end
    
    if CombatSystem.SpamBindButton then
        CombatSystem.SpamBindButton.Text = "SpamBindP (" .. (CombatSystem.Settings.SpamBindEnabled and "ON" or "OFF") .. ")"
        CombatSystem.SpamBindButton.BackgroundColor3 = CombatSystem.Settings.SpamBindEnabled and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(100, 100, 100)
    end
end

-- Ініціалізація системи
function CombatSystem.InitCombatSystem()
    local function bindTeamChanged(p)
        p:GetPropertyChangedSignal("Team"):Connect(function()
            if CombatSystem.ShouldAttack(p) and p.Character then
                CombatSystem.AttackPlayer(p)
            end
        end)
    end

    local function onPlayerAdded(p)
        if p == CombatSystem.LocalPlayer then return end
        p.CharacterAdded:Connect(function()
            if CombatSystem.ShouldAttack(p) then
                CombatSystem.AttackPlayer(p)
            end
        end)
        bindTeamChanged(p)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        onPlayerAdded(p)
    end
    
    local playerAddedConn = Players.PlayerAdded:Connect(onPlayerAdded)
    table.insert(CombatSystem.Connections, playerAddedConn)
    
    local attackCoroutine = coroutine.create(CombatSystem.AttackLoop)
    coroutine.resume(attackCoroutine)
    table.insert(CombatSystem.Loops, attackCoroutine)
end

-- Сповіщення
function CombatSystem.ShowNotification(message)
    if getgenv().CC_Modules and getgenv().CC_Modules.NotificationSystem then
        getgenv().CC_Modules.NotificationSystem.ShowNotification(message)
    else
        warn("NotificationSystem не завантажено: " .. message)
    end
end

-- Деструктор
function CombatSystem.Destroy()
    CombatSystem.Settings.SpamActive = false
    
    for _, loop in pairs(CombatSystem.Loops) do
        if type(loop) == "thread" then
            coroutine.close(loop)
        end
    end
    
    for _, conn in pairs(CombatSystem.Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    
    if CombatSystem.SpamButton then
        CombatSystem.SpamButton:Destroy()
    end
    if CombatSystem.SpamBindButton then
        CombatSystem.SpamBindButton:Destroy()
    end
    
    print("✅ CombatSystem вимкнено")
end

return CombatSystem
