-- ====================================================================
-- DH PREMIEM HUB v8.0: UTULMATE INJECTOR (BYPASS ALL DISPLAY BUG)
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старые зависшие копии кнопки, если они есть
if PlayerGui:FindFirstChild("DH_FinalButton") then PlayerGui.DH_FinalButton:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DH_FinalButton"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999 -- Самый высокий приоритет поверх игры
ScreenGui.Parent = PlayerGui

-- Твой фирменный кружок DH с темно-красным фоном
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0) -- Темно-красный фон
MenuBtn.Text = "DH"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 16
MenuBtn.Active = true
MenuBtn.Draggable = true -- Можно двигать пальцем по экрану телефона
MenuBtn.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = MenuBtn

-- Твоя красивая плавная RGB-подсветка вокруг кружка
local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 2.5
RGBStroke.Parent = MenuBtn

task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            RGBStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- НАЖАТИЕ НА КРУЖОК: Запускает мощный хаб со всеми функциями фарма!
MenuBtn.MouseButton1Click:Connect(function()
    print("DH Инжектор: Запуск стороннего топ-хаба...")
    
    -- Загружаем полноценный Redz Hub со всеми функциями (автофарм, телепорты, фрукты)
    loadstring(game:HttpGet("https://githubusercontent.com"))()
    
    -- После успешного запуска прячем наш кружок, чтобы он не мешал
    MenuBtn.Visible = false
end)

print("DH Инжектор v8.0 успешно запущен! Нажмите на кружок для вызова меню.")
