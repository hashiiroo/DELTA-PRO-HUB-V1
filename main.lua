-- DELTA HUB (DH) - BLOX FRUITS SAFE EDITION
if _G.DeltaHubLoaded then return end
_G.DeltaHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local autoFarmActive = false
local currentTarget = nil
local lastTargetTime = 0

-- ========================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (ДИЗАЙН "DH")
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- КРУГЛАЯ КНОПКА МЕНЮ
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 65, 0, 65)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
MenuButton.Text = "DH"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.TextSize = 24
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = MenuButton

local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 3
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent = MenuButton

task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            if not MenuButton then break end
            RGBStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "DH | SAFE ANTI-BAN FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0, 280, 0, 50)
FarmButton.Position = UDim2.new(0.5, -140, 0.35, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FarmButton.Text = "Безопасный Автофарм: ВЫКЛ"
FarmButton.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmButton.TextSize = 14
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmButton

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 40)
InfoLabel.Position = UDim2.new(0, 0, 0.7, 0)
InfoLabel.Text = "Защита: Плавный обход детекции движения,\nрандомизация позиций клика и Anti-Stuck"
InfoLabel.TextColor3 = Color3.fromRGB(0, 180, 100) -- Зеленый (Безопасно)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.SourceSansItalic
InfoLabel.BackgroundTransparency = 1
InfoLabel.Parent = MainFrame

-- ЛОГИКА ИНТЕРФЕЙСА (ОТКРЫТИЕ И ПЕРЕТАСКИВАНИЕ)
MenuButton.Activated:Connect(function()
    MenuButton.Size = UDim2.new(0, 58, 0, 58)
    task.wait(0.05)
    MenuButton.Size = UDim2.new(0, 65, 0, 65)
    MainFrame.Visible = not MainFrame.Visible
end)

local dragging, dragInput, dragStart, startPos
MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MenuButton.Position
    end
end)
MenuButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MenuButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MenuButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ========================================================
-- СИСТЕМА БЕЗОПАСНОСТИ (ANTI-BAN MECHANICS)
-- ========================================================

-- Безопасный Noclip (Прохождение сквозь стены во время полета)
RunService.Stepped:Connect(function()
    if autoFarmActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Функция плавного перемещения (Tween) для обхода детектора телепортации
local function safeTween(targetCFrame)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local speed = 250 -- Оптимальная легитная скорость полета
    local duration = distance / speed

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- Автоматическое взятие оружия ближнего боя
local function equipWeapon()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    if character and backpack and not character:FindFirstChildOfClass("Tool") then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.Name == "Combat") then
                tool.Parent = character
                break
            end
        end
    end
end

-- Поиск ближайшего живого NPC
local function getClosestMob()
    local closestMob = nil
    local shortestDistance = 400
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    
    for _, object in pairs(enemiesFolder:GetChildren()) do
        if object:IsA("Model") and object:FindFirstChild("Humanoid") and object ~= character then
            local enemyRoot = object:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = object:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestMob = object
                end
            end
        end
    end
    return closestMob
end

-- Цикл автофарма
local function toggleAutoFarm(state)
    autoFarmActive = state
    
    if autoFarmActive then
        FarmButton.Text = "Безопасный Автофарм: ВКЛ"
        FarmButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
        FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        task.spawn(function()
            while autoFarmActive do
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    local targetMob = getClosestMob()
                    
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        -- Смена цели или Anti-Stuck проверка (не дольше 5 секунд на одного застрявшего моба)
                        if currentTarget ~= targetMob then
                            currentTarget = targetMob
                            lastTargetTime = tick()
                        elseif tick() - lastTargetTime > 5 then
                            -- Игнорируем забагованного моба
                            targetMob.Humanoid.Health = 0 
                        end

                        equipWeapon()
                        
                        -- ГЕНЕРАЦИЯ РАНДОМИЗИРОВАННЫХ СМЕЩЕНИЙ (Обход паттернов античита)
                        local randomX = math.random(-8, 8) / 10
                        local randomZ = math.random(-8, 8) / 10
                        local randomY = math.random(45, 55) / 10 -- Удерживает высоту от 4.5 до 5.5 метров над мобом
                        
                        local targetPos = targetMob.HumanoidRootPart.Position + Vector3.new(randomX, randomY, randomZ)
                        local targetCFrame = CFrame.new(targetPos, targetMob.HumanoidRootPart.Position)
                        
                        -- Если мы далеко, летим плавно через Tween. Если близко — удерживаем позицию
                        local currentDistance = (rootPart.Position - targetMob.HumanoidRootPart.Position).Magnitude
                        if currentDistance > 30 then
                                
