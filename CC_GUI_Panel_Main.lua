-- CC_GUI_Panel_Main.lua
-- Основний GUI скрипт - точка входу

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end 
if game.PlaceId ~= 6924952561 then
    return
end
wait(1)

-- Базові сервіси
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Конфігурація URL для модулів
local MODULE_URLS = {
    ModuleLoader = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/ModuleLoader.lua",
    NotificationSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/NotificationSystem.lua",
    RenegadeGunSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/RenegadeGunSystem.lua",
    StompSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/StompSystem.lua",
    CombatSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/CombatSystem.lua",
    TeleportSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/TeleportSystem.lua",
    PlayerSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/PlayerSystem.lua",
    UtilitySystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/UtilitySystem.lua",
    AmmoShopSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/AmmoShopSystem.lua",
    AimSystem = "https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/AimSystem.lua"
}
-- 🎯 QUICK AIM LOAD
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/XGEN-K1/CCv1/refs/heads/main/AimSystem.lua"))()
end)

if success and result then
    print("✅ AIM System loaded!")
    result.Init(nil, {AimKey = "t", DeselectKey = "j", ShootKey = "v", TriggerKey = "h", SwitchTargetKey = "b"})
    if getgenv().AIM then
        AIM.Enable()
        print("🎯 Press T to target | B to switch | J to clear")
    end
else
    warn("❌ FAILED: " .. tostring(result))
end

-- Глобальні змінні
local Modules = {}
local activeConnections = {}
local screenGui = nil

-- Функція завантаження модулів
local function LoadModules()
    print("🔄 Завантаження модулів...")
    
    -- Спочатку завантажуємо ModuleLoader
    local loaderSuccess, ModuleLoader = pcall(function()
        return loadstring(game:HttpGet(MODULE_URLS.ModuleLoader))()
    end)
    
    if loaderSuccess and ModuleLoader then
        Modules = ModuleLoader.LoadAll(MODULE_URLS)
        print("✅ Всі модулі завантажено!")
        return true
    else
        warn("❌ Помилка завантаження ModuleLoader: " .. tostring(ModuleLoader))
        return false
    end
end

-- Функція створення основного GUI
local function CreateMainGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GAS"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    screenGui.Archivable = false

    -- Основний фрейм
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 580, 0, 378)
    frame.Position = UDim2.new(0.5, -290, 0.5, -189)
    frame.AnchorPoint = Vector2.new(0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    frame.Visible = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    -- Панелі
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 90, 0, 368)
    leftPanel.Position = UDim2.new(0, 5, 0, 5)
    leftPanel.BackgroundTransparency = 1
    leftPanel.Parent = frame

    local middlePanel = Instance.new("Frame")
    middlePanel.Size = UDim2.new(0, 90, 0, 368)
    middlePanel.Position = UDim2.new(0, 100, 0, 5)
    middlePanel.BackgroundTransparency = 1
    middlePanel.Parent = frame

    local rightmiddlePanel = Instance.new("Frame")
    rightmiddlePanel.Size = UDim2.new(0, 90, 0, 368)
    rightmiddlePanel.Position = UDim2.new(0, 195, 0, 5)
    rightmiddlePanel.BackgroundTransparency = 1
    rightmiddlePanel.Parent = frame

    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(0, 280, 0, 368)
    rightPanel.Position = UDim2.new(0, 290, 0, 5)
    rightPanel.BackgroundTransparency = 1
    rightPanel.Parent = frame

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "XGEN"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = rightmiddlePanel

    -- Кнопка закриття
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    closeButton.BackgroundTransparency = 0.7
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Parent = rightPanel
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

    -- Кнопка фільтра
    local filterButton = Instance.new("TextButton")
    filterButton.Size = UDim2.new(0, 30, 0, 30)
    filterButton.Position = UDim2.new(1, -70, 0, 0)
    filterButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    filterButton.BackgroundTransparency = 0.7
    filterButton.Text = "F"
    filterButton.TextColor3 = Color3.new(1, 1, 1)
    filterButton.Font = Enum.Font.SourceSansBold
    filterButton.TextSize = 18
    filterButton.Parent = rightPanel
    Instance.new("UICorner", filterButton).CornerRadius = UDim.new(0, 6)

    return {
        ScreenGui = screenGui,
        MainFrame = frame,
        Panels = {
            Left = leftPanel,
            Middle = middlePanel,
            RightMiddle = rightmiddlePanel,
            Right = rightPanel
        },
        CloseButton = closeButton,
        FilterButton = filterButton
    }
end

-- Функція ініціалізації всіх систем
local function InitializeSystems(gui)
    print("🔄 Ініціалізація систем...")
    
    -- Ініціалізація Renegade системи
    if Modules.RenegadeGunSystem then
        Modules.RenegadeGunSystem.Init(gui.Panels.RightMiddle, {
            CursorAimKey = Enum.KeyCode.M,
            SelfShootKey = Enum.KeyCode.K
        })
    else
        warn("❌ RenegadeGunSystem не завантажено")
    end
    
    -- Ініціалізація Stomp системи
    if Modules.StompSystem then
        Modules.StompSystem.Init(gui.Panels.Middle, {
            ToggleKey = Enum.KeyCode.Y,
            StompEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Stomp")
        })
    else
        warn("❌ StompSystem не завантажено")
    end
    
    -- Ініціалізація Combat системи
    if Modules.CombatSystem then
        Modules.CombatSystem.Init(gui.Panels.Middle, {
            ActivateKey = Enum.KeyCode.P
        })
    else
        warn("❌ CombatSystem не завантажено")
    end
    
    -- Ініціалізація Utility системи
    if Modules.UtilitySystem then
        Modules.UtilitySystem.Init({
            VRButtonParent = gui.Panels.Middle,
            GhostButtonParent = gui.Panels.Middle,
            GateButtonParent = gui.Panels.RightMiddle,
            LumberButtonParent = gui.Panels.Middle,
            GrabButtonParent = gui.Panels.RightMiddle,
            AimSettingsParent = gui.Panels.RightMiddle,
            BoomboxParent = gui.Panels.RightMiddle
        })
    else
        warn("❌ UtilitySystem не завантажено")
    end
    
    -- Ініціалізація Player системи
    if Modules.PlayerSystem then
        Modules.PlayerSystem.Init(gui.Panels.Left)
    else
        warn("❌ PlayerSystem не завантажено")
    end
    
    -- Ініціалізація Teleport системи
    if Modules.TeleportSystem then
        Modules.TeleportSystem.Init({
            SafesButtonParent = gui.Panels.Middle,
            NPCButtonParent = gui.Panels.Left,
            LumberButtonParent = gui.Panels.Middle
        })
    else
        warn("❌ TeleportSystem не завантажено")
    end
    
    -- Ініціалізація AmmoShop системи
    if Modules.AmmoShopSystem then
        Modules.AmmoShopSystem.Init(gui.Panels.Right, gui.FilterButton)
    else
        warn("❌ AmmoShopSystem не завантажено")
    end
    
    print("✅ Всі системи ініціалізовано!")
end

-- Функція обробки закриття
local function SetupCloseHandler(gui, closeButton)
    closeButton.MouseButton1Click:Connect(function()
        -- Викликаємо деструктори модулів
        for name, module in pairs(Modules) do
            if module and module.Destroy then
                pcall(module.Destroy)
            end
        end
        
        -- Відключаємо всі з'єднання
        for _, connection in pairs(activeConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        -- Видаляємо GUI
        gui.ScreenGui:Destroy()
        
        -- Повідомлення про вимкнення
        if Modules.NotificationSystem then
            Modules.NotificationSystem.ShowNotification("All functions stopped and GUI removed")
        end
        
        print("✅ GUI вимкнено")
    end)
end

-- Функція перемикання видимості GUI
local function SetupToggleGUI(gui)
    local hidebind = Enum.KeyCode.L
    local toggleConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == hidebind then
            gui.MainFrame.Visible = not gui.MainFrame.Visible
        end
    end)
    table.insert(activeConnections, toggleConn)
end

-- Основна функція ініціалізації
local function Main()
    print("🚀 Запуск CC GUI Panel...")
    
    -- Завантажуємо модулі
    if not LoadModules() then
        warn("Не вдалося завантажити модулі")
        return
    end
    
    -- Створюємо GUI
    local gui = CreateMainGUI()
    
    -- Налаштовуємо обробники
    SetupCloseHandler(gui, gui.CloseButton)
    SetupToggleGUI(gui)
    
    -- Ініціалізуємо системи
    InitializeSystems(gui)
    
    -- Стартові повідомлення
    if Modules.NotificationSystem then
        Modules.NotificationSystem.ShowNotification("Натисніть [Y] для перемикання Stomp")
        Modules.NotificationSystem.ShowNotification("Натисніть [L] для перемикання GUI")
        Modules.NotificationSystem.ShowNotification("Натисніть [K] для Self Shoot | [M] для Cursor Aim")
    end
    
    print("✅ CC GUI Panel успішно запущено!")
end

-- Запускаємо головну функцію
Main()

-- Експортуємо глобальні змінні для доступу з модулів
return {
    Modules = Modules,
    ActiveConnections = activeConnections,
    Player = player,
    Players = Players
}
