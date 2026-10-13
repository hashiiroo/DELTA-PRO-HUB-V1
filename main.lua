_G.SafeFlyFarm = false -- Основной тумблер фарма

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local FarmSpeed = 75 -- Безопасная скорость полета для обхода анти-чита

-- ====================================================================
-- АВТОМАТИЧЕСКАЯ НЕВИДИМАЯ ЗАЩИТА ANTI-AFK (ОТ ВЫЛЕТА ЧЕРЕЗ 20 МИНУТ)
-- ====================================================================
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ====================================================================
-- УМНАЯ ФУНКЦИЯ ПОИСКА БЛИЖАЙШЕГО ЖИВОГО МОБА
-- ====================================================================
local function GetClosestEnemy()
    local Closest = nil
    local MaxDistance = math.huge
    local character = LocalPlayer.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Проверяем папку Enemies (стандарт для BF) или весь Workspace
        local targetsFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, enemy in pairs(targetsFolder:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                -- Не пытаемся фармить самого себя
                if enemy.Name ~= LocalPlayer.Name then
                    local distance = (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    -- Радиус авто-поиска мобов вокруг игрока — 250 метров
                    if distance < MaxDistance and distance < 250 then
                        MaxDistance = distance
                        Closest = enemy
                    end
                end
            end
        end
    end
    return Closest
end

-- ====================================================================
-- ОСНОВНОЙ ПОТОК ЛЕТАЮЩЕГО ФАРМА
-- ====================================================================
task.spawn(function()
    while true do
        if _G.SafeFlyFarm then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    
                    local targetEnemy = GetClosestEnemy()
                    if targetEnemy then
                        -- Создаем или удерживаем левитацию, отключая гравитацию Roblox
                        if not character.HumanoidRootPart:FindFirstChild("FarmVelocity") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "FarmVelocity"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = character.HumanoidRootPart
                        end
                        
                        -- Точка зависания: ровно на 6 метров ВЫШЕ моба (чтобы он не достал нас атаками)
                        local targetPos = targetEnemy.HumanoidRootPart.Position + Vector3.new(0, 6, 0)
                        local distance = (targetPos - character.HumanoidRootPart.Position).Magnitude
                        
                        -- Плавное и безопасное перемещение к мобу
                        if distance > 2 then
                            character.HumanoidRootPart.FarmVelocity.Velocity = (targetPos - character.HumanoidRootPart.Position).Unit * FarmSpeed
                        else
                            character.HumanoidRootPart.FarmVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                        
                        -- Разворачиваем персонажа лицом вниз к мобу для точных ударов
                        character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position, targetEnemy.HumanoidRootPart.Position)
                        
                        -- Автоматически экипируем боевой стиль или меч, если руки пусты
                        if not character:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then 
                                character.Humanoid:EquipTool(tool) 
                            end
                        end
                        
                        -- Безопасный кликер (эмуляция тапа по экрану телефона)
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(850, 520))
                    else
                        -- Если живых мобов рядом нет, аккуратно висим в воздухе и ждем спавна
                        if character.HumanoidRootPart:FindFirstChild("FarmVelocity") then
                            character.HumanoidRootPart.FarmVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end)
        else
            -- Если фарм выключен — полностью убираем левитацию и возвращаем обычную физику
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if character.HumanoidRootPart:FindFirstChild("FarmVelocity") then
                        character.HumanoidRootPart.FarmVelocity:Destroy()
                    end
                end
            end)
        end
        task.wait(0.05) -- Скорость обновления позиции (минимальная задержка для плавности)
    end
end)

-- ====================================================================
-- УЛЬТРА-ЛЕГКИЙ СЕНСОРНЫЙ ИНТЕРФЕЙС (GUI) ДЛЯ ТЕЛЕФОНА
-- ====================================================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
-- Удаляем дубликаты скрипта, если они зависли в памяти Delta
if PlayerGui:FindFirstChild("SafeFarmHubV6") then PlayerGui.SafeFarmHubV6:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeFarmHubV6"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 1. Круглая плавающая кнопка открытия/закрытия («MENU»)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 60, 0, 60)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0) -- Удобное дефолтное положение слева
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 14
MenuBtn.Active = true
MenuBtn.Draggable = true -- Кружок можно свободно двигать пальцем по экрану
MenuBtn.Parent = ScreenGui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(1, 0) -- Делает кнопку круглой
corner1.Parent = MenuBtn

-- 2. Маленькое аккуратное окно управления (Изначально скрыто)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 210, 0, 110)
Frame.Position = UDim2.new(0.5, -105, 0.5, -55) -- Четко по центру любого смартфона
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 10)
corner2.Parent = Frame

-- Заголовок окна
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  SAFE FLY FARM v6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 10)
corner3.Parent = Title

-- Единственная большая кнопка включения фарма
local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0.9, 0, 0, 45)
FarmButton.Position = UDim2.new(0.05, 0, 0.48, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
FarmButton.Text = "Фарм летая: ВЫКЛ"
FarmButton.TextColor3 = Color3.fromRGB(255, 80, 80)
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.TextSize = 14
FarmButton.Parent = Frame

local corner4 = Instance.new("UICorner")
corner4.CornerRadius = UDim.new(0, 8)
corner4.Parent = FarmButton

-- ====================================================================
-- ОБРАБОТКА НАЖАТИЙ НА СЕНСОРНОМ ЭКРАНЕ (ЗАЩИТА БУФЕРА ОБМЕНА)
-- ====================================================================

-- Тап по кнопке Фарма (считываем физический тач пальца)
FarmButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        _G.SafeFlyFarm = not _G.SafeFlyFarm
        if _G.SafeFlyFarm then
            FarmButton.Text = "Фарм летая: ВКЛ"
            FarmButton.TextColor3 = Color3.fromRGB(80, 255, 80)
            FarmButton.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
        else
            FarmButton.Text = "Фарм летая: ВЫКЛ"
            FarmButton.TextColor3 = Color3.fromRGB(255, 80, 80)
            FarmButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
    end
end)

-- Тап по круглой кнопке MENU (открывает/закрывает панель)
MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Frame.Visible = not Frame.Visible
    end
end)

print("Новый скрипт v6 успешно скомпилирован!")
