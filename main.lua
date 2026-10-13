-- БЕЗОПАСНЫЙ МОБИЛЬНЫЙ СКРИПТ (Стиль RedzHub)
-- Проверка на повторный запуск (Anti-Crash)
if _G.ScriptLoaded then 
    print("[SafeScript]: Скрипт уже запущен!")
    return 
end
_G.ScriptLoaded = true

-- Безопасная загрузка UI-библиотеки RedzHub V5
local success, redzlib = pcall(function()
    return loadstring(game:HttpGet("https://githubusercontent.com"))()
end)

if not success or not redzlib then
    warn("[SafeScript]: Не удалось загрузить UI-библиотеку RedzHub.")
    _G.ScriptLoaded = false
    return
end

-- Создание главного окна
local Window = redzlib:MakeWindow({
    Title = "Safe Mobile Hub",
    SubTitle = "Delta Android Edition",
    SaveFolder = "SafeScriptConfig.lua"
})

-- Создание вкладок
local MainTab = Window:MakeTab({"Главная", "home"})
local PlayerTab = Window:MakeTab({"Игрок", "user"})

-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Переменные для функций
local waterWalkActive = false
local waterWalkConnection = nil

-- ========================================================
-- ЛОГИКА БЕЗОПАСНОГО ХОЖДЕНИЯ ПО ВОДЕ
-- ========================================================
local function toggleWaterWalk(state)
    waterWalkActive = state
    
    -- Очищаем старое соединение, если оно существовало
    if waterWalkConnection then
        waterWalkConnection:Disconnect()
        waterWalkConnection = nil
    end
    
    if waterWalkActive then
        -- Безопасный цикл кадровой синхронизации
        waterWalkConnection = RunService.RenderStepped:Connect(function()
            -- Проверяем, существует ли персонаж в данный момент
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Если игра переводит персонажа в плавание — переключаем в бег без нарушения физики
            if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end)
        print("[SafeScript]: Хождение по воде ВКЛЮЧЕНО")
    else
        print("[SafeScript]: Хождение по воде ВЫКЛЮЧЕНО")
    end
end

-- Автоматический сброс функций при смерти персонажа (Защита от багов)
LocalPlayer.CharacterRemoving:Connect(function()
    if waterWalkActive then
        toggleWaterWalk(false)
        -- Возвращаем включение после респавна через небольшую задержку
        task.spawn(function()
            LocalPlayer.CharacterAdded:Wait()
            task.wait(1)
            if waterWalkActive == false then 
                toggleWaterWalk(true)
            end
        end)
    end
end)

-- ========================================================
-- ИНТЕРФЕЙС МЕНЮ
-- ========================================================

MainTab:AddSection({"Основной функционал"})

-- Кнопка хождения по воде
MainTab:AddToggle({
    Name = "Хождение по воде (Water Walk)",
    Description = "Позволяет бегать по воде. Безопасно для античитов.",
    Default = false,
    Callback = function(state)
        toggleWaterWalk(state)
    end
})

PlayerTab:AddSection({"Настройки персонажа"})

-- Безопасный слайдер скорости (Максимум 100 во избежание кика античитом)
PlayerTab:AddSlider({
    Name = "Скорость (WalkSpeed)",
    Min = 16,
    Max = 100,
    Increase = 1,
    Default = 16,
    Callback = function(value)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.WalkSpeed = value
        end
    end
})

-- Безопасный слайдер прыжка
PlayerTab:AddSlider({
    Name = "Сила прыжка (JumpPower)",
    Min = 50,
    Max = 150,
    Increase = 1,
    Default = 50,
    Callback = function(value)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value
        end
    end
})
