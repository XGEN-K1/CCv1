-- // ==========================
-- // 🔥 AIMBOT WITH GUI (full)
-- // ==========================
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end 
if game.PlaceId ~= 6924952561 then
    return
end
wait(1)

local AimBotSettings = {
    Enabled = true,
    BindsEnabled = true,
    Key = "t",
    DeselectKey = "j",
    ShootKey = "v",
    UseVKey = true,
    TriggerKey = "h",
    SwitchTargetKey = "b",
    FOV = math.huge,
    interval = 0,
    LeadFactor = 0.8,
    BulletSpread = 0,
    ShowBeam = true,
    BeamMode = "Prediction",
    DOT = false,
    horiscoof = 1,
    verticalcoof = 0.00
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local CC = Workspace.CurrentCamera

-- ===============================
-- 🔔 Notifications
-- ===============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomNotifGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local NotifFrame = Instance.new("Frame")
NotifFrame.Parent = ScreenGui
NotifFrame.AnchorPoint = Vector2.new(1, 0)
NotifFrame.Position = UDim2.new(1, -20, 0, 20)
NotifFrame.Size = UDim2.new(0, 300, 1, -40)
NotifFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = NotifFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Padding = UDim.new(0, 6)

local function Notify(msg, color, duration)
    color = color or Color3.fromRGB(255, 255, 255)
    duration = duration or 3
    local item = Instance.new("TextLabel")
    item.Size = UDim2.new(1, 0, 0, 30)
    item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    item.BackgroundTransparency = 0.2
    item.TextColor3 = color
    item.Text = msg
    item.Font = Enum.Font.GothamBold
    item.TextSize = 14
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextTransparency = 1
    item.Parent = NotifFrame
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
    TweenService:Create(item, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    task.delay(duration, function()
        if item and item.Parent then
            TweenService:Create(item, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.wait(0.3)
            item:Destroy()
        end
    end)
end

-- ===============================
-- 🎯 Aimbot Core
-- ===============================
local Plr
local enabled = false
local shooting = false
local triggerMode = false

-- Beam
local lineBeam, fromAttachment, toAttachment
local function cleanupBeam()
    if lineBeam then lineBeam:Destroy(); lineBeam = nil end
    if fromAttachment then fromAttachment:Destroy(); fromAttachment = nil end
    if toAttachment then toAttachment.Parent:Destroy(); toAttachment = nil end
end
local function initBeam()
    if lineBeam then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    fromAttachment = Instance.new("Attachment", myChar.HumanoidRootPart)
    local dummy = Instance.new("Part")
    dummy.Anchored = true
    dummy.CanCollide = false
    dummy.Transparency = 1
    dummy.Size = Vector3.new(0.1,0.1,0.1)
    dummy.Parent = Workspace
    toAttachment = Instance.new("Attachment", dummy)
    lineBeam = Instance.new("Beam", Workspace)
    lineBeam.Attachment0 = fromAttachment
    lineBeam.Attachment1 = toAttachment
    lineBeam.Width0 = 0.1
    lineBeam.Width1 = 0.1
    lineBeam.FaceCamera = true
end

-- Lead calc (prediction)
local function calculateLeadPosition(target, ping)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local targetPart = target.Character.HumanoidRootPart
    local targetPos = targetPart.Position + Vector3.new(0, targetPart.Size.Y/2, 0)
    local targetVel = targetPart.Velocity
    local char = LocalPlayer.Character
    local localPos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or CC.CFrame.Position
    local distance = (targetPos - localPos).Magnitude
    local bulletSpeed = 1000
    local timeToHit = distance / bulletSpeed + (ping / 1000) * 0.7
    timeToHit = math.min(timeToHit, 0.25)
    local dynamicLead = AimBotSettings.LeadFactor * (1 - math.min(distance / 2000, 0.8))
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalLead = horizontalVel * timeToHit * dynamicLead * AimBotSettings.horiscoof
    local verticalLead = Vector3.new(0, targetVel.Y * timeToHit * AimBotSettings.verticalcoof, 0)
    local gravityComp = Vector3.new(0, -Workspace.Gravity * (timeToHit ^ 2) * 0.2, 0)
    return targetPos + horizontalLead + verticalLead + gravityComp
end

-- Spread
local function applySpread(position)
    if AimBotSettings.BulletSpread > 0 then
        local offset = Vector3.new(
            (math.random() - 0.5) * 2 * AimBotSettings.BulletSpread,
            (math.random() - 0.5) * 2 * AimBotSettings.BulletSpread,
            (math.random() - 0.5) * 2 * AimBotSettings.BulletSpread
        )
        return position + offset
    end
    return position
end

-- Shooting
local function getCursorTargetPosition()
    local ray = CC:ScreenPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    return res and res.Position or ray.Origin + ray.Direction * 1000
end
local function shootAtCursor()
    local pos = applySpread(getCursorTargetPosition())
    local tool = Workspace[LocalPlayer.Name]:FindFirstChildOfClass("Tool")
    if tool then ReplicatedStorage.RemoteEvents.ShootGun:FireServer(pos, tool) end
end
local function shootAtTarget()
    if not Plr or not Plr.Character then return end
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    local pos = applySpread(calculateLeadPosition(Plr, ping) or Plr.Character.HumanoidRootPart.Position)
    local tool = Workspace[LocalPlayer.Name]:FindFirstChildOfClass("Tool")
    if tool then ReplicatedStorage.RemoteEvents.ShootGun:FireServer(pos, tool) end
end
local function startShooting()
    shooting = true
    while shooting and AimBotSettings.Enabled do
        if enabled and Plr then shootAtTarget() else shootAtCursor() end
        task.wait(AimBotSettings.interval)
    end
end

-- Update Beam
RunService.RenderStepped:Connect(function()
    if AimBotSettings.ShowBeam then
        initBeam()
        if lineBeam and toAttachment then
            local pos
            if enabled and Plr then
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                pos = (AimBotSettings.BeamMode == "Prediction") and calculateLeadPosition(Plr, ping) or (Plr.Character and Plr.Character.HumanoidRootPart.Position)
            else
                pos = getCursorTargetPosition()
            end
            if pos then toAttachment.WorldPosition = pos end
        end
    else cleanupBeam() end
end)

-- Keybinds
local keyConnections = {}
local function setupKeybinds()
    -- Disconnect old connections
    for _, conn in pairs(keyConnections) do
        conn:Disconnect()
    end
    keyConnections = {}

    -- Create new connections
    keyConnections.mouseKeyDown = mouse.KeyDown:Connect(function(k)
        if not AimBotSettings.Enabled or not AimBotSettings.BindsEnabled then return end
        if k == AimBotSettings.Key then
            local closest, shortest
            shortest = AimBotSettings.FOV
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local pos = CC:WorldToViewportPoint(v.Character.PrimaryPart.Position)
                    local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude
                    if dist < shortest then closest = v; shortest = dist end
                end
            end
            if closest then Plr = closest; enabled = true; Notify("Target: "..Plr.Name, Color3.fromRGB(150,200,255), 2) end
        elseif k == AimBotSettings.DeselectKey then
            enabled, Plr = false, nil
            cleanupBeam()
            Notify("Target cleared", Color3.fromRGB(255,150,150), 2)
        elseif k == AimBotSettings.ShootKey and not shooting and AimBotSettings.UseVKey then startShooting()
        elseif k == AimBotSettings.TriggerKey then triggerMode = not triggerMode; Notify("Trigger: "..tostring(triggerMode), Color3.fromRGB(255,255,100), 2)
        elseif k == AimBotSettings.SwitchTargetKey and Plr then
            local players = Players:GetPlayers()
            local currentIndex = table.find(players, Plr) or 0
            for i = 1, #players do
                local nextIndex = (currentIndex + i - 1) % #players + 1
                local nextPlayer = players[nextIndex]
                if nextPlayer ~= LocalPlayer and nextPlayer.Character and nextPlayer.Character:FindFirstChild("Humanoid") and nextPlayer.Character.Humanoid.Health > 0 then
                    Plr = nextPlayer
                    Notify("Switched to: "..Plr.Name, Color3.fromRGB(150,200,255), 2)
                    break
                end
            end
        end
    end)

    keyConnections.mouseKeyUp = mouse.KeyUp:Connect(function(k) 
        if k == AimBotSettings.ShootKey and AimBotSettings.UseVKey then 
            shooting = false 
        end 
    end)

    keyConnections.mouseButton1Up = mouse.Button1Up:Connect(function() 
        if triggerMode then 
            shooting = false 
        end 
    end)
end

setupKeybinds()

-- ===============================
-- 📋 GUI for settings (30% smaller)
-- ===============================
local GUI = Instance.new("ScreenGui")
GUI.Name = "AimBotGUI"
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui
GUI.Enabled = false

-- Main frame with 30% reduced size
local Frame = Instance.new("Frame", GUI)
Frame.Size = UDim2.new(0, 245, 0, 385) -- Original 350x550 reduced by 30%
Frame.Position = UDim2.new(0.5, -122.5, 0.5, -192.5)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8)

-- Scroll frame with proper layout
local ScrollFrame = Instance.new("ScrollingFrame", Frame)
ScrollFrame.Size = UDim2.new(1, -14, 1, -70) -- Adjusted for smaller size
ScrollFrame.Position = UDim2.new(0, 7, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4 -- Thinner scrollbar
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 7) -- Smaller padding
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Update canvas size when layout changes
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 14)
end)

-- Dragging functionality
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title with smaller font
local Title = Instance.new("TextLabel", Frame)
Title.Text = "🎯 AimBot Settings"
Title.Size = UDim2.new(1, -50, 0, 28) -- Smaller
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14 -- Smaller font
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close button (smaller)
local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0, 42, 0, 21) -- Smaller
Close.Position = UDim2.new(1, -49, 0, 3)
Close.Text = "Close"
Close.BackgroundColor3 = Color3.fromRGB(50,50,50)
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.Font = Enum.Font.Gotham
Close.TextSize = 12 -- Smaller font
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)
Close.MouseButton1Click:Connect(function() 
    GUI.Enabled = false 
end)

-- ===============================
-- ⚙️ Settings Controls (smaller)
-- ===============================
local controlElements = {}
local controlOrder = 0

local function createToggle(name, default, callback)
    controlOrder = controlOrder + 1
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -7, 0, 21) -- Smaller
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name..": "..tostring(default)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11 -- Smaller font
    btn.Parent = ScrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    
    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.Text = name..": "..tostring(default)
        callback(default)
    end)
    
    controlElements[name] = btn
    return btn
end

local function createSlider(name, min, max, default, callback, step)
    controlOrder = controlOrder + 1
    step = step or 1
    
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, -7, 0, 35) -- Smaller
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Text = name..": "..default
    label.Size = UDim2.new(1, 0, 0, 14) -- Smaller
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11 -- Smaller font
    label.Parent = container
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 14) -- Smaller
    slider.Position = UDim2.new(0, 0, 0, 18)
    slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
    slider.Text = ""
    slider.Parent = container
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0,6)
    
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(100,200,100)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.Parent = slider
    
    slider.MouseButton1Down:Connect(function(x,y)
        local moveConn
        moveConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
                fill.Size = UDim2.new(rel,0,1,0)
                local rawVal = min + (max-min)*rel
                local val = math.floor(rawVal/step+0.5)*step
                if step < 1 then val = tonumber(string.format("%.2f", val)) end
                label.Text = name..": "..val
                callback(val)
            end
        end)
        UserInputService.InputEnded:Wait()
        moveConn:Disconnect()
    end)
    
    controlElements[name] = container
    return container
end

local function createKeybindButton(name, currentKey, callback)
    controlOrder = controlOrder + 1
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -7, 0, 21) -- Smaller
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name..": "..tostring(currentKey)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11 -- Smaller font
    btn.Parent = ScrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    
    local waitingForInput = false
    
    btn.MouseButton1Click:Connect(function()
        if not waitingForInput then
            waitingForInput = true
            btn.Text = "Press any key..."
            btn.BackgroundColor3 = Color3.fromRGB(80,40,40)
            
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                local key
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode.Name
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    key = "MouseButton1"
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    key = "MouseButton2"
                else
                    return
                end
                
                conn:Disconnect()
                waitingForInput = false
                btn.Text = name..": "..key
                btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
                callback(key)
                setupKeybinds() -- Rebind keys after change
                Notify(name.." set to: "..key, Color3.fromRGB(150,200,255), 2)
            end)
        end
    end)
    
    controlElements[name] = btn
    return btn
end

-- Add controls for each setting (smaller)
createToggle("Enabled", AimBotSettings.Enabled, function(v) AimBotSettings.Enabled = v end)
createToggle("ShowBeam", AimBotSettings.ShowBeam, function(v) AimBotSettings.ShowBeam = v end)
createToggle("UseVKey", AimBotSettings.UseVKey, function(v) AimBotSettings.UseVKey = v end)
createSlider("FOV", 50, 2000, AimBotSettings.FOV == math.huge and 500 or AimBotSettings.FOV, function(v) AimBotSettings.FOV = v end, 1)
createSlider("interval", 0, 500, AimBotSettings.interval*1000, function(v) AimBotSettings.interval = v/1000 end, 1)
createSlider("LeadFactor", 0, 1000, AimBotSettings.LeadFactor*100, function(v) AimBotSettings.LeadFactor = v/100 end, 1)
createSlider("BulletSpread", 0, 5, AimBotSettings.BulletSpread, function(v) AimBotSettings.BulletSpread = v end, 0.01)

-- Keybind buttons (smaller)
createKeybindButton("Aim Key", AimBotSettings.Key, function(v) AimBotSettings.Key = v end)
createKeybindButton("Deselect Key", AimBotSettings.DeselectKey, function(v) AimBotSettings.DeselectKey = v end)
createKeybindButton("Shoot Key", AimBotSettings.ShootKey, function(v) AimBotSettings.ShootKey = v end)
createKeybindButton("Trigger Key", AimBotSettings.TriggerKey, function(v) AimBotSettings.TriggerKey = v end)
createKeybindButton("Switch Target", AimBotSettings.SwitchTargetKey, function(v) AimBotSettings.SwitchTargetKey = v end)

-- Save/Load settings
local function saveSettings()
    local json = HttpService:JSONEncode(AimBotSettings)
    if writefile then
        writefile("ccaimsettings.txt", json)
        Notify("Settings saved", Color3.fromRGB(100,255,100), 2)
    else
        Notify("Cannot save settings", Color3.fromRGB(255,100,100), 2)
    end
end

local function loadSettings()
    if readfile and isfile and isfile("ccaimsettings.txt") then
        local success, result = pcall(function()
            local json = readfile("ccaimsettings.txt")
            return HttpService:JSONDecode(json)
        end)
        
        if success and result then
            for k,v in pairs(result) do
                if AimBotSettings[k] ~= nil then
                    AimBotSettings[k] = v
                end
            end
            Notify("Settings loaded", Color3.fromRGB(100,255,100), 2)
            return true
        end
    end
    return false
end

local function resetSettings()
    local defaults = {
        Enabled = true,
        BindsEnabled = true,
        Key = "t",
        DeselectKey = "j",
        ShootKey = "v",
        UseVKey = true,
        TriggerKey = "h",
        SwitchTargetKey = "b",
        FOV = math.huge,
        interval = 0,
        LeadFactor = 0.6,
        BulletSpread = 0,
        ShowBeam = true,
        BeamMode = "Prediction",
        DOT = false
    }
    
    for k,v in pairs(defaults) do
        AimBotSettings[k] = v
    end
    
    -- Update GUI elements
    controlElements["Enabled"].Text = "Enabled: true"
    controlElements["ShowBeam"].Text = "ShowBeam: true"
    controlElements["UseVKey"].Text = "UseVKey: true"
    controlElements["Aim Key"].Text = "Aim Key: t"
    controlElements["Deselect Key"].Text = "Deselect Key: j"
    controlElements["Shoot Key"].Text = "Shoot Key: v"
    controlElements["Trigger Key"].Text = "Trigger Key: h"
    controlElements["Switch Target"].Text = "Switch Target: b"
    
    setupKeybinds() -- Reset keybinds
    Notify("Settings reset", Color3.fromRGB(255,150,150), 2)
end

-- Save/Reset buttons (smaller)
local buttonContainer = Instance.new("Frame", Frame)
buttonContainer.Size = UDim2.new(1, -14, 0, 28) -- Smaller
buttonContainer.Position = UDim2.new(0, 7, 1, -35)
buttonContainer.BackgroundTransparency = 1

local saveBtn = Instance.new("TextButton", buttonContainer)
saveBtn.Size = UDim2.new(0.48, 0, 1, 0)
saveBtn.Position = UDim2.new(0, 0, 0, 0)
saveBtn.Text = "Save"
saveBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextSize = 11 -- Smaller font
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)
saveBtn.MouseButton1Click:Connect(saveSettings)

local resetBtn = Instance.new("TextButton", buttonContainer)
resetBtn.Size = UDim2.new(0.48, 0, 1, 0)
resetBtn.Position = UDim2.new(0.52, 0, 0, 0)
resetBtn.Text = "Reset"
resetBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 11 -- Smaller font
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,6)
resetBtn.MouseButton1Click:Connect(resetSettings)

-- Auto-load settings on startup
loadSettings()

-- ===============================
-- 🌐 Global control
-- ===============================
getgenv().ToggleAimGUI = function(state)
    GUI.Enabled = state
end

getgenv().DestroyAimScript = function()
    GUI:Destroy()
    ScreenGui:Destroy()
    cleanupBeam()
    for _, conn in pairs(keyConnections) do
        conn:Disconnect()
    end
    getgenv().StandaloneAim = nil
    getgenv().ToggleAimGUI = nil
    getgenv().DestroyAimScript = nil
    Notify = function() end
end

-- Save globals
getgenv().StandaloneAim = {
    Settings = AimBotSettings,
    Notify = Notify
}
