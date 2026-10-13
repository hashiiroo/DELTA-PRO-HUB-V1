-- Загружаем популярную библиотеку Kavo UI для создания мобильного меню
local KavoUiLib = loadstring(game:HttpGet("https://githubusercontent.com"))()

-- Создаем адаптивное темное окно меню для экрана телефона
local Window = KavoUiLib.CreateLib("Delta Android Menu", "DarkTheme")

-- Вкладка функций передвижения
local MainTab = Window:NewTab("Фарм и Мувмент")
local MovementSection = MainTab:NewSection("Передвижение")

-- Переменные управления
local waterWalkActive = false
local waterWalkConnection = nil
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Логика хождения по воде
local function toggleWaterWalk(enabled)
    waterWalkActive = enabled
    
    if waterWalkActive then
        -- Подключаемся к кадровой частоте RenderStepped
        waterWalkConnection = RunService.RenderStepped:Connect(function()
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if humanoid then
                -- Если игра пытается переключить анимацию персонажа в режим плавания (Swimming)
                if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                    -- Принудительно возвращаем состояние обычной ходьбы (Running)
                    humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                end
            end
        end)
    else
        -- Отключаем отслеживание при выключении функции
        if waterWalkConnection then
            waterWalkConnection:Disconnect()
            waterWalkConnection = nil
        end
    end
end

-- Добавляем переключатель (Toggle) прямо в меню Delta
MovementSection:NewToggle("Хождение по воде", "Позволяет бегать по поверхности воды без погружения", function(state)
    toggleWaterWalk(state)
end)

-- Полезный бинд: Скрытие меню (на случай, если кнопка Delta перекрывает интерфейс)
MovementSection:NewKeybind("Скрыть интерфейс меню", "Кнопка для закрытия UI", Enum.KeyCode.RightControl, function()
    KavoUiLib:ToggleUI()
end)
