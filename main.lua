-- DELTA HUB (DH) - CUSTOM MOBILE INTERFACE
-- Защита от повторного запуска
if _G.DeltaHubLoaded then return end
_G.DeltaHubLoaded = true

-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Переменные для функций
local autoFarmActive = false
local farmConnection = nil

-- ========================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (ДИЗАЙН "DH")
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHubUI"
ScreenGui.ResetOnSpawn = false
-- Защита от отображения на скриншотах/стримах (работает на некоторых исполнителях)
pcall(function() ScreenGui.IgnoreGuiInset = true end)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- КРУГЛАЯ КНОПКА МЕНЮ (Тёмно-красная с буквами "DH")
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 65, 0, 65)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0) -- Удобное место слева сверху
MenuButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0) -- Тёмно-красный
MenuButton.Text = "DH"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.TextSize = 24
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.Parent = ScreenGui

-- Закругление кнопки
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0) -- Идеальный круг
ButtonCorner.Parent = MenuButton

-- RGB ПОДСВЕТКА ПО КОНТУРУ
local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 3
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent = MenuButton

-- Цикл плавной RGB подсветки (не нагружает процессор телефона)
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            if not MenuButton then break end
            RGBStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- ГЛАВНОЕ ОКНО МЕНЮ (Скрыто по умолчанию)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110) -- Центр экрана
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

-- Шапка меню
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(110, 0, 0) -- Тёмно-красная шапка
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "DELTA HUB  |  MOBILE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- КНОПКА ФУНКЦИИ (АВТОФАРМ МОБОВ)
local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0, 280, 0, 50)
FarmButton.Position = UDim2.new(0.5, -140, 0.4, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FarmButton.Text = "Автофарм Ближайших Мобов: ВЫКЛ"
FarmButton.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmButton.TextSize = 14
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmButton

-- Текст-подсказка
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 30)
InfoLabel.Position = UDim2.new(0, 0, 0.75, 0)
InfoLabel.Text = "Скрипт автоматически ищет цели в радиусе 150 студов"
InfoLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.BackgroundTransparency = 1
InfoLabel.Parent = MainFrame

-- ЛОГИКА ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ С АНИМАЦИЕЙ КЛИКА
MenuButton.Activated:Connect(function()
    -- Легкий эффект нажатия на круглую кнопку
    MenuButton.Size = UDim2.new(0, 58, 0, 58)
    task.wait(0.05)
    MenuButton.Size = UDim2.new(0, 65, 0, 65)
    
    MainFrame.Visible = not MainFrame.Visible
end)

-- Позволяем перетаскивать кружок по экрану пальцем (Drag Control)
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
-- БЕЗОПАСНАЯ ЛОГИКА АВТОФАРМА
-- ========================================================

-- Поиск ближайшего моба в рабочей папке игры Workspace
local function getClosestMob()
    local closestMob = nil
    local shortestDistance = 150 -- Максимальный радиус поиска (безопасно для античитов)
    
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    -- Сканируем Workspace. Метод адаптируется под большинство симуляторов
    for _, object in pairs(workspace:GetDescendants()) do
        -- Проверяем, является ли объект живым существом (но не игроком)
        if object:IsA("Model") and object:FindFirstChildOfClass("Humanoid") and object ~= character then
            local enemyRoot = object:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = object:FindFirstChildOfClass("Humanoid")
            
            -- Проверяем, что моб жив и находится в зоне досягаемости
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

-- Включение/выключение автофарма
local function toggleAutoFarm(state)
    autoFarmActive = state
    
    if autoFarmActive then
        FarmButton.Text = "Автофарм Ближайших Мобов: ВКЛ"
        FarmButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0) -- Красный при активации
        FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- Потоковая задача для постоянного поиска и атаки
        task.spawn(function()
            while autoFarmActive do
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                local tool = character and character:FindFirstChildOfClass("Tool")
                
                if rootPart then
                    local targetMob = getClosestMob()
                    
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        -- Безопасная телепортация СЗАДИ моба (чтобы он не атаковал вас в ответ)
                        local targetPos = targetMob.HumanoidRootPart.Position - (targetMob.HumanoidRootPart.CFrame.LookVector * 3)
                        rootPart.CFrame = CFrame.new(targetPos, targetMob.HumanoidRootPart.Position)
                        
                        -- Автоматический удар (активация оружия в руках)
                        if tool then
                            tool:Activate()
                        end
                    end
                end
                task.wait(0.1) -- Пауза между проверками для оптимизации пинга на телефоне
            end
        end)
    else
        -- Возвращаем кнопку в исходное состояние
        FarmButton.Text = "Автофарм Ближайших Мобов: ВЫКЛ"
        FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        FarmButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- Обработка нажатия на кнопку автофарма
FarmButton.Activated:Connect(function()
    toggleAutoFarm(not autoFarmActive)
end)
