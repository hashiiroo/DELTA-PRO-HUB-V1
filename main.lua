-- DAIKI HUB - FIXED COMPACT VERSION
-- Автоматическое удаление старого интерфейса перед перезапуском
if game:GetService("CoreGui"):FindFirstChild("DaikiHubUI") then
    game:GetService("CoreGui").DaikiHubUI:Destroy()
end
if game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("DaikiHubUI") then
    game:GetService("Players").LocalPlayer.PlayerGui.DaikiHubUI:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Локальная переменная (теперь не конфликтует с прошлыми запусками)
local autoFarmActive = false

-- ========================================================
-- ИНТЕРФЕЙС "DAIKI HUB"
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaikiHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)

-- Безопасный выбор родителя интерфейса для Delta Executor
if game:GetService("CoreGui") then
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- КРУГЛАЯ КНОПКА МЕНЮ (Компактная 50х50)
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 50, 0, 50)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0) -- Тёмно-красный фон
MenuButton.Text = "DH"
MenuButton.TextSize = 18
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.ZIndex = 10
MenuButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = MenuButton

-- Контурная линия для кнопки
local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 2.5
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent = MenuButton

-- Безопасный цикл синхронной RGB-подсветки букв и контура
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        for i = 0, 1, 0.005 do
            if not MenuButton or not RGBStroke then break end
            local color = Color3.fromHSV(i, 1, 1)
            RGBStroke.Color = color
            MenuButton.TextColor3 = color
            task.wait(0.02)
        end
    end
end)

-- ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Глубокий чёрный
MainFrame.Visible = false
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Color = Color3.fromRGB(110, 0, 0)
FrameStroke.Parent = MainFrame

-- Шапка меню
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
Header.ZIndex = 6
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Daiki Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 7
Title.Parent = Header

-- КНОПКА ФАРМА
local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0, 260, 0, 45)
FarmButton.Position = UDim2.new(0.5, -130, 0.52, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FarmButton.Text = "Автофарм Ближайших Мобов: ВЫКЛ"
FarmButton.TextColor3 = Color3.fromRGB(180, 180, 180)
FarmButton.TextSize = 13
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.ZIndex = 6
FarmButton.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 6)
FarmCorner.Parent = FarmButton

local FarmStroke = Instance.new("UIStroke")
FarmStroke.Thickness = 1
FarmStroke.Color = Color3.fromRGB(50, 50, 50)
FarmStroke.Parent = FarmButton

-- КЛИК БЕЗ АНИМАЦИИ ИЗМЕНЕНИЯ РАЗМЕРА
MenuButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Простая система перетаскивания (Drag)
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
-- ЛОГИКА ФАРМА БЕЗ КОНФЛИКТОВ
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
        FarmButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
        FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        FarmStroke.Color = Color3.fromRGB(150, 0, 0)
        
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
        FarmStroke.Color = Color3.fromRGB(50, 50, 50)
    end
end

FarmButton.Activated:Connect(function()
    toggleAutoFarm(not autoFarmActive)
end)
