-- DAIKI HUB - ADVANCED COMPACT EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local autoFarmActive = false

-- Очистка старых интерфейсов перед запуском
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DaikiHubUI") then
    LocalPlayer.PlayerGui.DaikiHubUI:Destroy()
end

-- ========================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaikiHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- КРУГЛАЯ КНОПКА МЕНЮ (45х45, статичный фон, RGB на буквах)
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

-- Исключительно внутренний RGB перелив для текста "DH"
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

-- ШАПКА МЕНЮ (Зона перетаскивания)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
Header.BorderSizePixel = 0
Header.ZIndex = 6
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Раздельный заголовок: Крупный DAIKI HUB
local TitleMain = Instance.new("TextLabel")
TitleMain.Size = UDim2.new(0, 80, 1, 0)
TitleMain.Position = UDim2.new(0, 12, 0, 0)
TitleMain.Text = "DAIKI HUB"
TitleMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleMain.TextSize = 15
TitleMain.Font = Enum.Font.SourceSansBold
TitleMain.TextXAlignment = Enum.TextXAlignment.Left
TitleMain.BackgroundTransparency = 1
TitleMain.ZIndex = 7
TitleMain.Parent = Header

-- Раздельный заголовок: Маленький COMPACT EDITION
local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(0, 150, 1, 0)
TitleSub.Position = UDim2.new(0, 92, 0, 0) -- Смещение вправо после основного текста
TitleSub.Text = "| COMPACT EDITION"
TitleSub.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleSub.TextSize = 11 -- Уменьшенный размер
TitleSub.Font = Enum.Font.SourceSans
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.BackgroundTransparency = 1
TitleSub.ZIndex = 7
TitleSub.Parent = Header

-- КНОПКА "СКРЫТЬ" (—)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -65, 0.5, -15)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 7
MinimizeButton.Parent = Header

-- КНОПКА "ЗАКРЫТЬ" (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
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
InfoLabel.BackgroundTransparency = 1
InfoLabel.ZIndex = 6
InfoLabel.Parent = MainFrame

-- РЕГУЛЯТОР РАЗМЕРА МЕНЮ (Resize в правом нижнем углу)
local ResizeButton = Instance.new("TextButton")
ResizeButton.Name = "ResizeButton"
ResizeButton.Size = UDim2.new(0, 16, 0, 16)
ResizeButton.Position = UDim2.new(1, -16, 1, -16)
ResizeButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
ResizeButton.Text = "◢"
ResizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResizeButton.TextSize = 10
ResizeButton.ZIndex = 8
ResizeButton.Parent = MainFrame

local ResizeCorner = Instance.new("UICorner")
ResizeCorner.CornerRadius = UDim.new(0, 4)
ResizeCorner.Parent = ResizeButton

-- ========================================================
-- СИСТЕМЫ УПРАВЛЕНИЯ И ИНТЕРФЕЙСА
-- ========================================================

-- Переключение видимости по кружку
MenuButton.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Действие кнопки "Скрыть" (—)
MinimizeButton.Activated:Connect(function()
    MainFrame.Visible = false
end)

-- Действие кнопки "Закрыть" (X)
CloseButton.Activated:Connect(function()
    autoFarmActive = false
    ScreenGui:Destroy()
end)

-- Логика перетаскивания кружка
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

-- СВОБОДНОЕ ПЕРЕМЕЩЕНИЕ ВСЕГО МЕНЮ ЗА СЧЕТ ШАПКИ (Header Drag)
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
    if input == dragFrameInput and dragFrameActive then
        local delta = input.Position - dragFrameStart
        MainFrame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragFrameActive = false end
end)

-- ИЗМЕНЕНИЕ РАЗМЕРА ОКНА (Resize Control)
local resizing = false
local resizeStartPos, resizeStartSize
ResizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true; resizeStartPos = input.Position; resizeStartSize = MainFrame.Size
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStartPos
        -- Ограничиваем минимальный размер (не меньше 260х180), чтобы элементы не ломались
        local newX = math.max(260, resizeStartSize.X.Offset + delta.X)
        local newY = math.max(180, resizeStartSize.Y.Offset + delta.Y)
        
        MainFrame.Size = UDim2.new(0, newX, 0, newY)
        FarmButton.Size = UDim2.new(0, newX - 40, 0, 50)
        FarmButton.Position = UDim2.new(0.5, -(newX - 40)/2, 0.35, 0)
        InfoLabel.Position = UDim2.new(0, 0, 0.65, 0)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
end)

