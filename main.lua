-- Защита от повторного запуска скрипта
if game:GetService("CoreGui"):FindFirstChild("IceWalkHubUI") then
    game:GetService("CoreGui"):FindFirstChild("IceWalkHubUI"):Destroy()
end

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Инициализация интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IceWalkHubUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Цветовая палитра (Тёмно-красный стиль DH)
local DarkRed = Color3.fromRGB(110, 0, 0)
local BrightRed = Color3.fromRGB(200, 0, 0)
local GlowColor = Color3.fromRGB(150, 0, 0)
local BgColor = Color3.fromRGB(20, 20, 20)

-- Глобальные переменные для логики хождения по воде
local iceWalkEnabled = false
local waterPlatform = nil
local iceTrackConnection = nil
local originalAnimTrack = nil

----------------------------------------------------------------
-- ПОИСК И АКТИВАЦИЯ АНИМАЦИИ ЛЬДА
----------------------------------------------------------------
local function getIceAnimation()
    -- Поиск стандартного ID анимации скольжения льда в Blox Fruits
    -- Если анимация загружена в ReplicatedStorage или у персонажа, берем её, иначе используем официальный ассет
    local iceAnimId = "rbxassetid://14456545164" -- Стандартный ID скольжения льда / бега Blox Fruits
    
    local animation = Instance.new("Animation")
    animation.AnimationId = iceAnimId
    return animation
end

local function toggleIceWalk(state)
    iceWalkEnabled = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if iceWalkEnabled then
        -- 1. Создаем невидимую прочную платформу чуть ниже ног для ходьбы по воде
        waterPlatform = Instance.new("Part")
        waterPlatform.Name = "IceWalkPlatform"
        waterPlatform.Size = Vector3.new(6, 0.5, 6)
        waterPlatform.Transparency = 1 -- Полностью невидимая
        waterPlatform.Anchored = true
        waterPlatform.CanCollide = true
        waterPlatform.Parent = workspace

        -- 2. Включаем кастомную анимацию скольжения
        local anim = getIceAnimation()
        originalAnimTrack = humanoid:WaitForChild("Animator"):LoadAnimation(anim)
        originalAnimTrack.Priority = Enum.AnimationPriority.Movement
        
        -- Постоянный цикл обновления позиции платформы под ногами
        iceTrackConnection = RunService.RenderStepped:Connect(function()
            if not iceWalkEnabled or not character or not character:Parent() then return end
            
            local currentPos = rootPart.Position
            -- Позиционируем платформу ровно на уровне воды или чуть ниже ног
            waterPlatform.Position = Vector3.new(currentPos.X, 4.5, currentPos.Z) -- 4.5 средняя высота воды в BF

            -- Если персонаж двигается, запускаем анимацию скольжения льда
            if humanoid.MoveDirection.Magnitude > 0 then
                if not originalAnimTrack.IsPlaying then
                    originalAnimTrack:Play()
                end
            else
                if originalAnimTrack.IsPlaying then
                    originalAnimTrack:Stop(0.3)
                end
            end
        end)
    else
        -- Отключение скрипта и очистка ресурсов
        if iceTrackConnection then iceTrackConnection:Disconnect() end
        if originalAnimTrack then originalAnimTrack:Stop() originalAnimTrack:Destroy() end
        if waterPlatform then waterPlatform:Destroy() end
    end
end

----------------------------------------------------------------
-- КРУГЛАЯ КНОПКА ЗАПУСКА "DH"
----------------------------------------------------------------
local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "CircleLogo"
CircleBtn.Parent = ScreenGui
CircleBtn.Size = UDim2.new(0, 65, 0, 65)
CircleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
CircleBtn.BackgroundColor3 = DarkRed
CircleBtn.Text = ""
CircleBtn.AutoButtonColor = false

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0)
UICornerBtn.Parent = CircleBtn

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, DarkRed),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 0))
})
UIGradient.Rotation = 45
UIGradient.Parent = CircleBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2.5
UIStroke.Color = GlowColor
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = CircleBtn

local LogoText = Instance.new("TextLabel")
LogoText.Parent = CircleBtn
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "DH"
LogoText.TextColor3 = Color3.fromRGB(255, 230, 230)
LogoText.TextSize = 24
LogoText.Font = Enum.Font.GothamBold

----------------------------------------------------------------
-- ГРАФИЧЕСКОЕ МЕНЮ
----------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 330, 0, 180)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -90)
MainFrame.BackgroundColor3 = BgColor
MainFrame.Visible = false

local UICornerFrame = Instance.new("UICorner")
UICornerFrame.CornerRadius = UDim.new(0, 10)
UICornerFrame.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Color = DarkRed
FrameStroke.Parent = MainFrame

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DH Hub | Visuals"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = BrightRed
CloseBtn.TextSize = 26

-- Контейнер для функций
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = MainFrame
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1

----------------------------------------------------------------
-- ЭЛЕМЕНТ: ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE) ХОЖДЕНИЯ ПО ВОДЕ
----------------------------------------------------------------
local ToggleFrame = Instance.new("Frame")
ToggleFrame.Name = "IceWalkToggle"
ToggleFrame.Parent = Content
ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleFrame

local ToggleText = Instance.new("TextLabel")
ToggleText.Parent = ToggleFrame
ToggleText.Size = UDim2.new(1, -60, 1, 0)
ToggleText.Position = UDim2.new(0, 10, 0, 0)
ToggleText.BackgroundTransparency = 1
ToggleText.Text = "Хождение по воде (Анимация Льда)"
ToggleText.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleText.TextSize = 13
ToggleText.Font = Enum.Font.GothamSemibold
ToggleText.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleFrame
ToggleBtn.Size = UDim2.new(0, 45, 0, 22)
ToggleBtn.Position = UDim2.new(1, -55, 0, 9)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text = ""

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = ToggleBtn

local ToggleBall = Instance.new("Frame")
ToggleBall.Parent = ToggleBtn
ToggleBall.Size = UDim2.new(0, 16, 0, 16)
ToggleBall.Position = UDim2.new(0, 3, 0, 3)
ToggleBall.BackgroundColor3 = Color3.fromRGB(150, 150, 150)

local BallCorner = Instance.new("UICorner")
BallCorner.CornerRadius = UDim.new(1, 0)
BallCorner.Parent = ToggleBall

-- Логика переключателя (Вкл/Выкл)
local toggled = false
ToggleBtn.MouseButton1Click:Connect(function()
    toggled = not toggled
    if toggled then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = DarkRed}):Play()
        TweenService:Create(ToggleBall, TweenInfo.new(0.2), {Position = UDim2.new(1, -19, 0, 3), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        toggleIceWalk(true)
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(ToggleBall, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0, 3), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        toggleIceWalk(false)
    end
end)

----------------------------------------------------------------
-- УПРАВЛЕНИЕ И ИНТЕРФЕЙС (Драг и клики)
----------------------------------------------------------------
CircleBtn.MouseEnter:Connect(function()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = BrightRed}):Play()
    TweenService:Create(CircleBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 68, 0, 68)}):Play()
end)

CircleBtn.MouseLeave:Connect(function()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = GlowColor}):Play()
    TweenService:Create(CircleBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 65, 0, 65)}):Play()
end)

CircleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
