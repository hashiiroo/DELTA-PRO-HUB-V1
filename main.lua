-- Защита от повторного запуска скрипта
if game:GetService("CoreGui"):FindFirstChild("DarkRedHubUI") then
    game:GetService("CoreGui"):FindFirstChild("DarkRedHubUI"):Destroy()
end

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkRedHubUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ПЕРЕМЕННЫЕ ЦВЕТА
local DarkRed = Color3.fromRGB(110, 0, 0)
local BrightRed = Color3.fromRGB(200, 0, 0)
local GlowColor = Color3.fromRGB(150, 0, 0)
local BgColor = Color3.fromRGB(20, 20, 20)

----------------------------------------------------------------
-- 1. СОЗДАНИЕ КРУГЛОЙ КНОПКИ (ЛОГОТИПА "DH")
----------------------------------------------------------------
local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "CircleLogo"
CircleBtn.Parent = ScreenGui
CircleBtn.Size = UDim2.new(0, 65, 0, 65) -- Размер как у Redz Hub
CircleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
CircleBtn.BackgroundColor3 = DarkRed
CircleBtn.Text = ""
CircleBtn.AutoButtonColor = false

-- Делаем кнопку круглой
local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0)
UICornerBtn.Parent = CircleBtn

-- Подсветка (Glow / Тень) вокруг кружка
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, DarkRed),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 0))
})
UIGradient.Rotation = 45
UIGradient.Parent = CircleBtn

-- Обводка для эффекта неонового свечения
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2.5
UIStroke.Color = GlowColor
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = CircleBtn

-- Буквы "DH" по центру
local LogoText = Instance.new("TextLabel")
LogoText.Parent = CircleBtn
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "DH"
LogoText.TextColor3 = Color3.fromRGB(255, 230, 230)
LogoText.TextSize = 24
LogoText.Font = Enum.Font.GothamBold
LogoText.TextXAlignment = Enum.TextXAlignment.Center
LogoText.TextYAlignment = Enum.TextYAlignment.Center

----------------------------------------------------------------
-- 2. СОЗДАНИЕ МАЛЕНЬКОГО ПУСТОГО МЕНЮ
----------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 350, 0, 220) -- Аккуратное маленькое меню
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
MainFrame.BackgroundColor3 = BgColor
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Скрыто при запуске

-- Скругление углов меню
local UICornerFrame = Instance.new("UICorner")
UICornerFrame.CornerRadius = UDim.new(0, 10)
UICornerFrame.Parent = MainFrame

-- Обводка меню с подсветкой
local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Color = DarkRed
FrameStroke.Parent = MainFrame

-- Шапка меню (Верхняя панель)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

-- Название в шапке
local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DH Hub | Blox Fruits"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия меню (крестик)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = BrightRed
CloseBtn.TextSize = 26
CloseBtn.Font = Enum.Font.Gotham

-- Контейнер для будущего контента (скриптов)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Container"
ContentContainer.Parent = MainFrame
ContentContainer.Size = UDim2.new(1, -20, 1, -50)
ContentContainer.Position = UDim2.new(0, 10, 0, 45)
ContentContainer.BackgroundTransparency = 1

-- Временный текст-заглушка внутри меню
local PlaceholderText = Instance.new("TextLabel")
PlaceholderText.Parent = ContentContainer
PlaceholderText.Size = UDim2.new(1, 0, 1, 0)
PlaceholderText.BackgroundTransparency = 1
PlaceholderText.Text = "[ Место для ваших функций ]"
PlaceholderText.TextColor3 = Color3.fromRGB(100, 100, 100)
PlaceholderText.TextSize = 14
PlaceholderText.Font = Enum.Font.GothamItalic

----------------------------------------------------------------
-- 3. ЛОГИКА, АНИМАЦИИ И ФУНКЦИОНАЛ
----------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Анимация подсветки при наведении на кружок (Hover)
CircleBtn.MouseEnter:Connect(function()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = BrightRed}):Play()
    TweenService:Create(CircleBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 68, 0, 68)}):Play()
end)

CircleBtn.MouseLeave:Connect(function()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = GlowColor}):Play()
    TweenService:Create(CircleBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 65, 0, 65)}):Play()
end)

-- Открытие/Закрытие меню по нажатию на кружок
CircleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Функция перетаскивания (Drag) для кружка и меню
local function makeDraggable(frame, dragAnchor)
    local dragging, dragInput, dragStart, startPos
    dragAnchor = dragAnchor or frame

    dragAnchor.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    dragAnchor.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(CircleBtn)
makeDraggable(MainFrame, TopBar)
