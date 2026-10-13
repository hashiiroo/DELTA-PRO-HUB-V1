-- ====================================================================
-- DELTA MOBILE HUB: ВЕРСИЯ ДИЗАЙНА 4.0 (ОТКАТ НА 3 ВЕРСИИ НАЗАД)
-- ====================================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Автоматический фоновый Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ====================================================================
-- ВОЗВРАТ ПЕРВОНАЧАЛЬНОГО МОБИЛЬНОГО GUI (БЕЗ ПОДСВЕТОК)
-- ====================================================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("MobileSafeBF") then PlayerGui.DeltaMobileTouchV6:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileSafeBF"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 1. Круглая плавающая кнопка ярко-синего цвета с надписью «BF»
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "FloatingButton"
MenuBtn.Parent = ScreenGui
MenuBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
MenuBtn.Size = UDim2.new(0, 45, 0, 45) -- Аккуратный небольшой кружок
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Первоначальный ярко-синий цвет
MenuBtn.Text = "BF" -- Оригинальное название
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 18
MenuBtn.Active = true
MenuBtn.Draggable = true -- Кружок можно перетаскивать пальцем по экрану

local UICorner_Float = Instance.new("UICorner")
UICorner_Float.CornerRadius = UDim.new(1, 0) -- Идеально круглая форма
UICorner_Float.Parent = MenuBtn

-- 2. Главное окно настроек (Чистая база для сбора функций)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 210, 0, 50) -- Минимальный размер под пустую базу
MainFrame.Visible = false -- Изначально скрыто, пока не нажмешь на кружок
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner_Menu = Instance.new("UICorner")
UICorner_Menu.CornerRadius = UDim.new(0, 10) -- Скругленные края меню
UICorner_Menu.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  MOBILE CLICKER" -- Самый первый заголовок
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Зона для кнопок
local BtnArea = Instance.new("Frame")
BtnArea.Name = "BtnArea"
BtnArea.Parent = MainFrame
BtnArea.Position = UDim2.new(0.05, 0, 0.7, 0)
BtnArea.Size = UDim2.new(0.9, 0, 0, 0)
BtnArea.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = BtnArea
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Открытие/закрытие меню через InputBegan
MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Оригинальный дизайн успешно возвращен!")
