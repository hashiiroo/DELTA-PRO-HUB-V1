-- Загружаем оригинальную UI библиотеку Redz Hub V5
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzLibV5/main/Source.Lua"))()

-- Создаем главное окно в стиле Redz Hub
local Window = redzlib:MakeWindow({
    Title = "Redz Hub Clone",
    SubTitle = "by AI Developer",
    SaveFolder = "Redz_Config_Mobile.lua"
})

-- Создаем вкладки (Tabs) на боковой панели
local MainTab = Window:MakeTab({"Главная", "home"})
local FarmTab = Window:MakeTab({"Автофарм", "swords"})
local TeleportTab = Window:MakeTab({"Телепорты", "map"})

-- Переменные для логики функций
local waterWalkActive = false
local waterWalkConnection = nil
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== ВКЛАДКА: ГЛАВНАЯ (МУВМЕНТ) ====================

MainTab:AddSection({"Функции Передвижения"})

-- Переключатель (Toggle) для хождения по воде в дизайне Redz Hub
local WaterToggle = MainTab:AddToggle({
    Name = "Хождение по воде (Water Walk)",
    Description = "Позволяет бегать по воде и не тонуть",
    Default = false,
    Callback = function(state)
        waterWalkActive = state
        
        if waterWalkActive then
            -- Цикл принудительного изменения физики гуманоида (без создания платформ)
            waterWalkConnection = RunService.RenderStepped:Connect(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                
                if humanoid then
                    -- Если игра переводит персонажа в режим плавания — возвращаем режим бега
                    if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                        humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                    end
                end
            end)
        else
            -- Отключаем отслеживание кадров
            if waterWalkConnection then
                waterWalkConnection:Disconnect()
                waterWalkConnection = nil
            end
        end
    end
})

-- Добавим ползунок скорости (Slider) — классика для скриптов Redz Hub
MainTab:AddSlider({
    Name = "Скорость бега (Speed)",
    Min = 16,
    Max = 250,
    Increase = 1,
    Default = 16,
    Callback = function(value)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

-- ==================== ВКЛАДКА: АВТОФАРМ (ЗАГОТОВКА) ====================

FarmTab:AddSection({"Настройки автоматизации"})

FarmTab:AddToggle({
    Name = "Авто-клик инструментом",
    Description = "Автоматически использует вещь в руках",
    Default = false,
    Callback = function(state)
        _G.AutoClick = state
        task.spawn(function()
            while _G.AutoClick do
                local character = LocalPlayer.Character
                local tool = character and character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                task.wait(0.1) -- Скорость кликов
            end
        end)
    end
})

-- ==================== ВКЛАДКА: ТЕЛЕПОРТЫ (ЗАГОТОВКА) ====================

TeleportTab:AddSection({"Быстрое перемещение"})

TeleportTab:AddButton({
    Name = "Телепорт в центр карты",
    Callback = function()
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(0, 50, 0) -- Координаты центра (X, Y, Z)
        end
    end
})
