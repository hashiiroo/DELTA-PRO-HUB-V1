-- ====================================================================
-- DH PRO HUB v10.2: CLEAN BASE + RGB CIRCLE + STRONG TEXT GLOW
-- ====================================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Автоматический фоновый Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ====================================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА
-- ====================================================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("DH_BaseLayer") then PlayerGui.DH_BaseLayer:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DH_BaseLayer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Круглая кнопка DH с тёмно-красным фоном
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0) -- Тёмно-красный
MenuBtn.Text = "DH"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый цвет букв
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 16
MenuBtn.Active = true
MenuBtn.Draggable = true
MenuBtn.Parent = ScreenGui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(1, 0)
corner1.Parent = MenuBtn

-- 🌟 ИЗМЕНЕНО: СИЛЬНАЯ И ЯРКАЯ ПОДСВЕТКА БУКВ ВНУТРИ КРУЖКА
local TextGlow = Instance.new("UIStroke")
TextGlow.Thickness = 3.5 -- Сделали обводку букв толще и заметнее
TextGlow.Color = Color3.fromRGB(255, 50, 50) -- Более яркий, сочный красный цвет свечения
TextGlow.Transparency = 0 -- Убрали прозрачность, чтобы подсветка была максимально плотной
TextGlow.TargetToType = Enum.UIStrokeTargetToType or nil
TextGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
TextGlow.Parent = MenuBtn

-- РАДУЖНАЯ ПОДСВЕТКА ВОКРУГ КРУЖКА (RGB-обводка по краям)
local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 2.5
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent = MenuBtn

task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            RGBStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- Главная монолитная панель (Очищена от вкладок)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 210, 0, 60)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
local corner2 = Instance.new("UICorner") corner2.CornerRadius = UDim.new(0, 8) corner2.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  DELTA HUB v10.2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
local corner3 = Instance.new("UICorner") corner3.CornerRadius = UDim.new(0, 8) corner3.Parent = Title

-- Зона для будущих кнопок
local BtnArea = Instance.new("Frame")
BtnArea.Name = "BtnArea"
BtnArea.Parent = MainFrame
BtnArea.Position = UDim2.new(0.05, 0, 0.65, 0)
BtnArea.Size = UDim2.new(0.9, 0, 0, 0)
BtnArea.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = BtnArea
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Взаимодействие через физический тач смартфона
MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("База v10.2 со стабильной сильной подсветкой букв загружена!")
