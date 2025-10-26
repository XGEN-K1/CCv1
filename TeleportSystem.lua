-- TeleportSystem.lua
-- Система телепортації об'єктів (сейфи, NPC, дерева)

local TeleportSystem = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Налаштування
TeleportSystem.Settings = {
    CheckMobility = true,
    TeleportRadius = 20,
    OffsetDistance = 10
}

-- Змінні
TeleportSystem.Buttons = {}
TeleportSystem.LocalPlayer = Players.LocalPlayer

-- Ініціалізація
function TeleportSystem.Init(config)
    TeleportSystem.config = config or {}
    
    -- Створення кнопок
    TeleportSystem.CreateButtons()
    
    print("✅ TeleportSystem ініціалізовано")
end

-- Створення кнопок GUI
function TeleportSystem.CreateButtons()
    -- Кнопка Safes
    if TeleportSystem.config.SafesButtonParent then
        TeleportSystem.Buttons.Safes = Instance.new("TextButton")
        TeleportSystem.Buttons.Safes.Size = UDim2.new(0, 80, 0, 30)
        TeleportSystem.Buttons.Safes.Position = UDim2.new(0, 5, 0, 90)
        TeleportSystem.Buttons.Safes.BackgroundColor3 = Color3.fromRGB(40, 40, 200)
        TeleportSystem.Buttons.Safes.BackgroundTransparency = 0.7
        TeleportSystem.Buttons.Safes.Text = "Safes"
        TeleportSystem.Buttons.Safes.TextColor3 = Color3.new(1, 1, 1)
        TeleportSystem.Buttons.Safes.Font = Enum.Font.SourceSansBold
        TeleportSystem.Buttons.Safes.TextSize = 18
        TeleportSystem.Buttons.Safes.Parent = TeleportSystem.config.SafesButtonParent
        Instance.new("UICorner", TeleportSystem.Buttons.Safes).CornerRadius = UDim.new(0, 6)
        
        TeleportSystem.Buttons.Safes.MouseButton1Click:Connect(function()
            TeleportSystem.TeleportAllObjects()
        end)
    end
    
    -- Кнопка Lumber
    if TeleportSystem.config.LumberButtonParent then
        TeleportSystem.Buttons.Lumber = Instance.new("TextButton")
        TeleportSystem.Buttons.Lumber.Size = UDim2.new(0, 80, 0, 30)
        TeleportSystem.Buttons.Lumber.Position = UDim2.new(0, 5, 0, 330)
        TeleportSystem.Buttons.Lumber.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
        TeleportSystem.Buttons.Lumber.BackgroundTransparency = 0.7
        TeleportSystem.Buttons.Lumber.Text = "Lumber"
        TeleportSystem.Buttons.Lumber.TextColor3 = Color3.new(1, 1, 1)
        TeleportSystem.Buttons.Lumber.Font = Enum.Font.SourceSansBold
        TeleportSystem.Buttons.Lumber.TextSize = 18
        TeleportSystem.Buttons.Lumber.Parent = TeleportSystem.config.LumberButtonParent
        Instance.new("UICorner", TeleportSystem.Buttons.Lumber).CornerRadius = UDim.new(0, 6)
        
        TeleportSystem.Buttons.Lumber.MouseButton1Click:Connect(function()
            TeleportSystem.TeleportTrees()
        end)
    end
    
    -- Кнопка NPC
    if TeleportSystem.config.NPCButtonParent then
        TeleportSystem.Buttons.NPC = Instance.new("TextButton")
        TeleportSystem.Buttons.NPC.Size = UDim2.new(0, 38, 0, 25)
        TeleportSystem.Buttons.NPC.Position = UDim2.new(0, 47, 0, 150)
        TeleportSystem.Buttons.NPC.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        TeleportSystem.Buttons.NPC.BackgroundTransparency = 0.7
        TeleportSystem.Buttons.NPC.Text = "NPC"
        TeleportSystem.Buttons.NPC.TextColor3 = Color3.new(1, 1, 1)
        TeleportSystem.Buttons.NPC.Font = Enum.Font.SourceSansBold
        TeleportSystem.Buttons.NPC.TextSize = 12
        TeleportSystem.Buttons.NPC.Parent = TeleportSystem.config.NPCButtonParent
        Instance.new("UICorner", TeleportSystem.Buttons.NPC).CornerRadius = UDim.new(0, 6)
        
        TeleportSystem.Buttons.NPC.MouseButton1Click:Connect(function()
            TeleportSystem.TeleportNPCToTarget()
        end)
    end
    
    -- Кнопка Anch
    if TeleportSystem.config.NPCButtonParent then
        TeleportSystem.Buttons.Anch = Instance.new("TextButton")
        TeleportSystem.Buttons.Anch.Size = UDim2.new(0, 38, 0, 25)
        TeleportSystem.Buttons.Anch.Position = UDim2.new(0, 5, 0, 150)
        TeleportSystem.Buttons.Anch.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
        TeleportSystem.Buttons.Anch.BackgroundTransparency = 0.7
        TeleportSystem.Buttons.Anch.Text = "Anch (ON)"
        TeleportSystem.Buttons.Anch.TextColor3 = Color3.new(1, 1, 1)
        TeleportSystem.Buttons.Anch.Font = Enum.Font.SourceSansBold
        TeleportSystem.Buttons.Anch.TextSize = 12
        TeleportSystem.Buttons.Anch.TextScaled = true
        TeleportSystem.Buttons.Anch.Parent = TeleportSystem.config.NPCButtonParent
        Instance.new("UICorner", TeleportSystem.Buttons.Anch).CornerRadius = UDim.new(0, 6)
        
        TeleportSystem.Buttons.Anch.MouseButton1Click:Connect(function()
            TeleportSystem.Settings.CheckMobility = not TeleportSystem.Settings.CheckMobility
            TeleportSystem.Buttons.Anch.Text = "Anch ("..(TeleportSystem.Settings.CheckMobility and "ON" or "OFF")..")"
            TeleportSystem.Buttons.Anch.BackgroundColor3 = TeleportSystem.Settings.CheckMobility and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(80, 80, 80)
        end)
    end
end

-- Функція телепортації всіх об'єктів (сейфи, банкомати тощо)
function TeleportSystem.TeleportAllObjects()
    local character = TeleportSystem.LocalPlayer.Character
    if not character then 
        TeleportSystem.ShowNotification("Character not found")
        return 
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then 
        TeleportSystem.ShowNotification("HumanoidRootPart not found")
        return 
    end

    local teleportedCount = 0
    
    local function teleportPart(part)
        if part:IsA("BasePart") then
            local offset = humanoidRootPart.CFrame.LookVector * TeleportSystem.Settings.OffsetDistance
            local newPosition = humanoidRootPart.Position + offset
            part.CFrame = CFrame.new(newPosition)
            teleportedCount += 1
            return true
        end
        return false
    end

    -- 1. Пошук Safe.Safe.Part
    for _, outerSafe in ipairs(Workspace:GetChildren()) do
        if outerSafe.Name == "Safe" then
            for _, innerSafe in ipairs(outerSafe:GetChildren()) do
                if innerSafe.Name == "Safe" then
                    for _, part in ipairs(innerSafe:GetDescendants()) do
                        if part.Name == "Part" then
                            teleportPart(part)
                        end
                    end
                end
            end
        end
    end

    -- 2. Пошук MoneyMachines.ATM.ClosedLid
    if Workspace:FindFirstChild("MoneyMachines") then
        local moneyMachines = Workspace.MoneyMachines
        
        -- ATM
        for _, atm in ipairs(moneyMachines:GetChildren()) do
            if atm.Name == "ATM" and atm:FindFirstChild("ClosedLid") then
                teleportPart(atm.ClosedLid)
            end
        end
        
        -- Register всередині MoneyMachines
        for _, register in ipairs(moneyMachines:GetChildren()) do
            if register.Name == "Register" and register:FindFirstChild("Main") then
                teleportPart(register.Main)
            end
        end
    end

    -- 3. Пошук Register.Main (окремі Register у workspace)
    for _, register in ipairs(Workspace:GetChildren()) do
        if register.Name == "Register" and register:FindFirstChild("Main") then
            teleportPart(register.Main)
        end
    end

    -- 4. Пошук MoneyMachines.Safe Door.Safe Door.Prime
    if Workspace:FindFirstChild("MoneyMachines") then
        for _, safeDoor in ipairs(Workspace.MoneyMachines:GetDescendants()) do
            if safeDoor.Name == "Safe Door" then
                for _, safePart in ipairs(safeDoor:GetDescendants()) do
                    if safePart.Name == "Prime" then
                        teleportPart(safePart)
                    end
                end
            end
        end

        -- 5. Пошук Small Bank Safe
        for _, smallBankSafeOuter in ipairs(Workspace.MoneyMachines:GetChildren()) do
            if smallBankSafeOuter.Name == "Small Bank Safe" then
                for _, smallBankSafeInner in ipairs(smallBankSafeOuter:GetChildren()) do
                    if smallBankSafeInner.Name == "Small Bank Safe" then
                        for _, part in ipairs(smallBankSafeInner:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name == "Part" then
                                if teleportPart(part) then
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    TeleportSystem.ShowNotification(teleportedCount > 0 and ("Teleported: "..teleportedCount.." objects") or "Objects not found")
end

-- Функція телепортації дерев
function TeleportSystem.TeleportTrees()
    local player = TeleportSystem.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local targetNames = {"Prime"}

    local function isTargetParticle(name)
        for _, targetName in ipairs(targetNames) do
            if name == targetName then
                return true
            end
        end
        return false
    end

    local function optimizeParticle(part)
        part.CastShadow = false
        part.Material = Enum.Material.SmoothPlastic
        if part:IsA("BasePart") then
            part.Reflectance = 0
            part.Transparency = 0.5
        end
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") or child:IsA("ParticleEmitter") then
                child:Destroy()
            end
        end
    end

    local function teleportParticles()
        local count = 0
        for _, tree in ipairs(Workspace.TreeSpawns:GetDescendants()) do
            if tree:IsA("BasePart") and isTargetParticle(tree.Name) then
                local offset = humanoidRootPart.CFrame.LookVector * 10
                local newPosition = humanoidRootPart.Position + offset
                tree.CFrame = CFrame.new(newPosition)
                tree.Size = Vector3.new(0.5, 7, 0.5)
                optimizeParticle(tree)
                count += 1
            end
        end
        return count
    end

    if character then
        local count = teleportParticles()
        TeleportSystem.ShowNotification("Lumber: "..count.." trees teleported")
    else
        player.CharacterAdded:Connect(function()
            local count = teleportParticles()
            TeleportSystem.ShowNotification("Lumber: "..count.." trees teleported")
        end)
    end
end

-- Функція телепортації NPC до цілі
function TeleportSystem.TeleportNPCToTarget(targetName)
    local target = TeleportSystem.FindPlayer(targetName or "")
    
    if not target then
        TeleportSystem.ShowNotification("Target not found")
        return
    end
    
    local targetChar = target.Character
    local localChar = TeleportSystem.LocalPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        TeleportSystem.ShowNotification("Target has no character")
        return
    end
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then
        TeleportSystem.ShowNotification("Your character not found")
        return
    end
    
    local targetRootPos = targetChar.HumanoidRootPart.Position
    local localRootPos = localChar.HumanoidRootPart.Position
    local count = 0
    
    for _, npc in ipairs(Workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            if not Players:GetPlayerFromCharacter(npc) then
                local humanoid = npc:FindFirstChild("Humanoid")
                local root = npc:FindFirstChild("HumanoidRootPart")
                
                -- Перевірка на відстань
                local distance = (root.Position - localRootPos).Magnitude
                if distance > TeleportSystem.Settings.TeleportRadius then
                    continue
                end
                
                -- Перевірка на рухливість
                local canMove = true
                if TeleportSystem.Settings.CheckMobility then
                    canMove = not root.Anchored and humanoid.WalkSpeed > 0 and npc.PrimaryPart ~= nil
                end

                if canMove then
                    npc:MoveTo(targetRootPos)
                    count += 1
                end
            end
        end
    end
    
    TeleportSystem.ShowNotification("Teleported "..count.." NPCs to target")
end

-- Допоміжна функція пошуку гравця
function TeleportSystem.FindPlayer(input)
    input = string.lower(input)
    if input == "" then return nil end
    
    if input == "me" or input == "self" then
        return TeleportSystem.LocalPlayer
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

-- Сповіщення
function TeleportSystem.ShowNotification(message)
    if getgenv().CC_Modules and getgenv().CC_Modules.NotificationSystem then
        getgenv().CC_Modules.NotificationSystem.ShowNotification(message)
    else
        warn("NotificationSystem не завантажено: " .. message)
    end
end

-- Деструктор
function TeleportSystem.Destroy()
    for _, button in pairs(TeleportSystem.Buttons) do
        if button then
            button:Destroy()
        end
    end
    TeleportSystem.Buttons = {}
    
    print("✅ TeleportSystem вимкнено")
end

return TeleportSystem
