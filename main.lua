-- DAIKI HUB - ADVANCED COMPACT & OPTIMIZED EDITION (Blox Fruits)
-- Поддерживает: ПК и Мобильные эксплоиты (Delta, Codex, Fluxus)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Очистка старой копии
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DaikiHubUI") then
    LocalPlayer.PlayerGui.DaikiHubUI:Destroy()
end

-- ========================================================
-- ГЛОБАЛЬНЫЕ НАСТРОЙКИ (ПЕРЕМЕННЫЕ ДЛЯ СЛАЙДЕРОВ)
-- ========================================================
local Config = {
    AutoFarm = false,
    SafeMode = false,
    AntiAFK = true,
    WalkSpeed = 16,
    FlyActive = false,
    FlySpeed = 50,
    AttackCooldown = 0.4,
    BlazingFast = false,
    FarmDistance = 5 -- Расстояние над мобом в студах
}

-- Предотвращение вылета за АФК (Anti-AFK)
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end)

-- ========================================================
-- СОЗДАНИЕ СОВРЕМЕННОГО ИНТЕРФЕЙСА (СТИЛЬ DAIKI HUB)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaikiHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.IgnoreGuiInset = true end)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- КРУГЛАЯ КНОПКА МЕНЮ
local MenuButton = Instance.new("TextButton")
MenuButton.Size = UDim2.new(0, 45, 0, 45)
MenuButton.Position = UDim2.new(0.05, 0, 0.15, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
MenuButton.Text = "DH"
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.TextSize = 16
MenuButton.ZIndex = 10
MenuButton.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = MenuButton

-- RGB Перелив для кнопки DH
task.spawn(function()
    while task.wait(0.02) do
        if not MenuButton then break end
        MenuButton.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 280)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Visible = false
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- ШАПКА МЕНЮ
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
Header.ZIndex = 6
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local TitleMain = Instance.new("TextLabel")
TitleMain.Size = UDim2.new(0, 200, 1, 0)
TitleMain.Position = UDim2.new(0, 12, 0, 0)
TitleMain.Text = "DAIKI HUB | BLOX FRUITS"
TitleMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleMain.Font = Enum.Font.SourceSansBold
TitleMain.TextSize = 14
TitleMain.TextXAlignment = Enum.TextXAlignment.Left
TitleMain.BackgroundTransparency = 1
TitleMain.ZIndex = 7
TitleMain.Parent = Header

-- Кнопка закрытия (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 7
CloseBtn.Parent = Header
CloseBtn.Activated:Connect(function() ScreenGui:Destroy() Config.AutoFarm = false end)

-- ПАНЕЛЬ ВКЛАДОК (Слева)
local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 120, 1, -40)
TabPanel.Position = UDim2.new(0, 0, 0, 40)
TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabPanel.ZIndex = 5
TabPanel.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabPanel
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- КОНТЕЙНЕР ДЛЯ СТРАНИЦ (Справа)
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -50)
ContentContainer.Position = UDim2.new(0, 125, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 5
ContentContainer.Parent = MainFrame

-- ========================================================
-- ФУНКЦИОНАЛ СОЗДАНИЯ ЭЛЕМЕНТОВ ИНТЕРФЕЙСА
-- ========================================================
local tabs = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.ZIndex = 6
    TabBtn.Parent = TabPanel

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 2, 0)
    Page.ScrollBarThickness = 2
    Page.ZIndex = 6
    Page.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.Padding = UDim.new(0, 6)

    TabBtn.Activated:Connect(function()
        for _, t in pairs(tabs) do t.page.Visible = false t.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
    end)

    table.insert(tabs, {btn = TabBtn, page = Page})
    if #tabs == 1 then Page.Visible = true TabBtn.BackgroundColor3 = Color3.fromRGB(110, 0, 0) end
    return Page
end

-- Переключатель (Toggle)
local function AddToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 45, 0, 20)
    Btn.Position = UDim2.new(1, -55, 0.5, -10)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
    Btn.Text = default and "ВКЛ" or "ВЫКЛ"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 11
    Btn.Parent = Frame
    
    local state = default
    Btn.Activated:Connect(function()
        state = not state
        Btn.Text = state and "ВКЛ" or "ВЫКЛ"
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- Ползунок (Slider)
local function AddSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.new(0, 8, 0, 2)
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -16, 0, 6)
    SliderBar.Position = UDim2.new(0, 8, 0, 28)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.Parent = Frame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
    SliderFill.Parent = SliderBar

    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (max - min) * pos)
        Label.Text = text .. ": " .. value
        callback(value)
    end

    local dragging = false
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Простая кнопка (Button)
local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -5, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = parent
 
