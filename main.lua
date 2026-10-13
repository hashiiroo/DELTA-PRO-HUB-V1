-- DAIKI HUB - COMPACT EDITION (ABSOLUTE FIX)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local autoFarmActive = false

-- Очистка старых интерфейсов перед запуском
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("DaikiHubUI") then
        LocalPlayer.PlayerGui.DaikiHubUI:Destroy()
    end
end)

-- ========================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaikiHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- КРУГЛАЯ КНОПКА МЕНЮ
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 45, 0, 45)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
MenuButton.Text = "DH"
MenuButton.TextSize = 15
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.ZIndex = 10
MenuButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = MenuButton

-- RGB перелив только на буквы "DH"
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        for i = 0, 1, 0.005 do
            if not MenuButton then break end
            MenuButton.TextColor3 = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

-- ШАПКА МЕНЮ
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
Header.BorderSizePixel = 0
Header.ZIndex = 6
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- СБЛИЖЕННЫЙ ЗАГОЛОВОК КАПСОМ
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 7
TitleLabel.Text = "DAIKI HUB  |  COMPACT EDITION"
TitleLabel.Parent = Header

-- КНОПКА "СКРЫТЬ" (Исправлена синтаксическая ошибка)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -65, 0.5, -15)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 7
MinimizeButton.Parent = Header

-- КНОПКА "ЗАКРЫТЬ"
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.ZIndex = 7
CloseButton.Parent = Header

-- КНОПКА ФАРМА
local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0, 280, 0, 50)
FarmButton.Position = UDim2.new(0.5, -140, 0.35, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FarmButton.Text = "Автофарм Ближайших Мобов: ВЫКЛ"
FarmButton.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmButton.TextSize = 14
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.ZIndex = 6
FarmButton.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmButton

-- ТЕКСТ ОПИСАНИЯ
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 40)
InfoLabel.Position = UDim2.new(0, 0, 0.7, 0)
InfoLabel.Text = "Автоматически экипирует Ближний бой (Melee)\nи удерживает позицию. Радиус: 300 студов."
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextXAlignment = Enum.TextXAlignment.Center
InfoLabel.BackgroundTransparency = 1
InfoLabel.ZIndex = 6
InfoLabel.Parent = MainFrame

-- ========================================================
-- СИСТЕМЫ УПРАВЛЕНИЯ И ИНТЕРФЕЙСА
-- ========================================================

MenuButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

MinimizeButton.Activated:Connect(function()
    MainFrame.Visible = false
end)

CloseButton.Activated:Connect(function()
    autoFarmActive = false
    ScreenGui:Destroy()
end)

-- Перетаскивание кружка
local dragBtnActive, dragBtnInput, dragBtnStart, startBtnPos
MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragBtnActive = true; dragBtnStart = input.Position; startBtnPos = MenuButton.Position
    end
end)
MenuButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragBtnInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragBtnInput and dragBtnActive then
        local delta = input.Position - dragBtnStart
        MenuButton.Position = UDim2.new(startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X, startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y)
    end
end)
MenuButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragBtnActive = false end
end)

-- Перетаскивание всего меню за шапку
local dragFrameActive, dragFrameInput, dragFrameStart, startFramePos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragFrameActive = true; dragFrameStart = input.Position; startFramePos = MainFrame.Position
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragFrameInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragFrameActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragFrameStart
        MainFrame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragFrameActive = false end
end)

-- ========================================================
-- ФУНКЦИОНАЛ ФАРМА
-- ========================================================

RunService.Stepped:Connect(function()
    if autoFarmActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
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
                    shortestDistance = distance; closestMob = object
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
                                
