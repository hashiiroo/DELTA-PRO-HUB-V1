-- DAIKI HUB - FINAL COMPACT EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local autoFarmActive = false

-- Очистка старых остатков UI перед запуском
local existingUI = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DaikiHubUI")
if existingUI then existingUI:Destroy() end

-- ========================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (ДИЗАЙН "DAIKI HUB")
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaikiHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- КРУГЛАЯ КНОПКА МЕНЮ (Маленькая, без подсветки и анимаций)
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 45, 0, 45)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0) -- Строгий тёмно-красный
MenuButton.Text = "DH"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белые буквы
MenuButton.TextSize = 15
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.ZIndex = 10
MenuButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = MenuButton

-- ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА (Прежний размер 320х240)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Прежний цвет меню
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

-- Шапка меню
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(110, 0, 0) -- Тёмно-красная шапка
Header.BorderSizePixel = 0
Header.ZIndex = 6
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "DAIKI HUB | COMPACT EDITION" -- Кастомное название большими буквами
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 7
Title.Parent = Header

-- КНОПКА ФАРМА
local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0, 280, 0, 50)
FarmButton.Position = UDim2.new(0.5, -140, 0.35, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FarmButton.BorderSizePixel = 0
FarmButton.Text = "Автофарм Ближайших Мобов: ВЫКЛ"
FarmButton.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmButton.TextSize = 14
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.ZIndex = 6
FarmButton.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmButton

-- МАЛЕНЬКОЕ ОПИСАНИЕ ФУНКЦИИ И ЧИСЛО РАДИУСА
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 40)
InfoLabel.Position = UDim2.new(0, 0, 0.7, 0)
InfoLabel.Text = "Автоматически экипирует Ближний бой (Melee)\nи удерживает позицию. Радиус: 300 студов."
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.BackgroundTransparency = 1
InfoLabel.ZIndex = 6
InfoLabel.Parent = MainFrame

-- МГНОВЕННЫЙ КЛИК БЕЗ АНИМАЦИИ
MenuButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Перетаскивание кружка по экрану пальцем
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
-- СТАБИЛЬНАЯ ЛОГИКА ФАРМА
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
    local shortestDistance = 300 -- Число радиуса из описания
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
        FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        FarmButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

FarmButton.Activated:Connect(function()
    toggleAutoFarm(not autoFarmActive)
end)
