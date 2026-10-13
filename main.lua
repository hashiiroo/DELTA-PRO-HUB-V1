-- DAIKI HUB - ULTRALIGHT NO-CRASH VERSION
-- Жесткая принудительная очистка прошлых багнутых сессий
for _, oldUI in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if oldUI.Name == "DaikiHubUI" then oldUI:Destroy() end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local autoFarmActive = false

-- ========================================================
-- БЕЗОПАСНЫЙ ИНТЕРФЕЙС DAIKI HUB (БЕЗ UI-STROKE)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaikiHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- КРУГЛАЯ КНОПКА МЕНЮ (Компактная 50х50, без рискованных обводок)
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 50, 0, 50)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuButton.Text = "DH"
MenuButton.TextSize = 16
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.ZIndex = 10
MenuButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0) -- Делает идеальный круг
ButtonCorner.Parent = MenuButton

-- Чистый и безопасный цикл перелива RGB (меняет цвет фона кнопки и цвет букв крест-накрест)
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        for i = 0, 1, 0.005 do
            if not MenuButton then break end
            local mainColor = Color3.fromHSV(i, 1, 0.6) -- Тёмно-яркий оттенок для фона
            local textColor = Color3.fromHSV((i + 0.5) % 1, 1, 1) -- Контрастный RGB для букв
            
            MenuButton.BackgroundColor3 = mainColor
            MenuButton.TextColor3 = textColor
            task.wait(0.02)
        end
    end
end)

-- ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 140)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Угольно-чёрный
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

-- Верхняя шапка Daiki Hub
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(130, 0, 0) -- Насыщенный тёмно-красный
Header.BorderSizePixel = 0
Header.ZIndex = 6
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Daiki Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 7
Title.Parent = Header

-- КНОПКА ЕДИНСТВЕННОГО АВТОФАРМА
local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0, 240, 0, 42)
FarmButton.Position = UDim2.new(0.5, -120, 0.55, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FarmButton.BorderSizePixel = 0
FarmButton.Text = "Автофарм Ближайших Мобов: ВЫКЛ"
FarmButton.TextColor3 = Color3.fromRGB(180, 180, 180)
FarmButton.TextSize = 12
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.ZIndex = 6
FarmButton.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 6)
FarmCorner.Parent = FarmButton

-- КЛИК БЕЗ АНИМАЦИИ (Простое мгновенное открытие/закрытие)
MenuButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Система перетаскивания (Drag-and-Drop) адаптированная под мобильный тачскрин
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
-- ЛОГИКА ФАРМА БЕЗ СБОЕВ
-- ========================================================

RunService.Stepped:Connect(function()
    if autoFarmActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function getClosestMob()
    local closestMob = nil
    local shortestDistance = 300
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

local function toggleAutoFarm(state)
    autoFarmActive = state
    
    if autoFarmActive then
        FarmButton.Text = "Автофарм Ближайших Мобов: ВКЛ"
        FarmButton.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
        FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        task.spawn(function()
            while autoFarmActive do
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    local targetMob = getClosestMob()
                    
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        if backpack and not character:FindFirstChildOfClass("Tool") then
                            local combat = backpack:FindFirstChild("Combat") or backpack:FindFirstChildOfClass("Tool")
                            if combat then combat.Parent = character end
                        end
                        
                        rootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        FarmButton.Text = "Автофарм Ближайших Мобов: ВЫКЛ"
        FarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        FarmButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

FarmButton.Activated:Connect(function()
    toggleAutoFarm(not autoFarmActive)
end)
