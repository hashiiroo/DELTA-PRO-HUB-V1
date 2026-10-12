-- ====================================================================
-- DELTA HUB v4: ФАРМ + ANTI-AFK + АНТИ-АДМИН + ВОДА + ЛЕТАЮЩИЙ АВТОФАРМ
-- ====================================================================

_G.SafeAttack = false
_G.WalkOnWater = false
_G.NoWaterDamage = false
_G.FlyBotFarm = false -- Новая кнопка: Летающий фарм

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ADMIN_GROUPS = { 4342932, 1200769 }
local FarmSpeed = 85 -- Безопасная скорость полета для обхода античита

-- ====================================================================
-- СИСТЕМА ЗАЩИТЫ
-- ====================================================================
local function LeaveServer()
    _G.SafeAttack = false
    _G.FlyBotFarm = false
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
    task.wait(2)
    LocalPlayer:Kick("Анти-Админ: Экстренный выход!")
end

local function CheckPlayer(player)
    if player == LocalPlayer then return end
    pcall(function()
        for _, groupId in pairs(ADMIN_GROUPS) do
            if player:IsInGroup(groupId) then LeaveServer() return end
        end
        local name = player.Name:lower()
        if name:find("admin") or name:find("mod") or name:find("zioles") or name:find("uzoth") then LeaveServer() end
    end)
end

for _, p in pairs(Players:GetPlayers()) do CheckPlayer(p) end
Players.PlayerAdded:Connect(CheckPlayer)

pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ====================================================================
-- ЛОГИКА ЛЕТАЮЩЕГО ФАРМА БЛИЖАЙШИХ БОТОВ
-- ====================================================================

-- Функция поиска ближайшего живого врага
local function GetClosestEnemy()
    local Closest = nil
    local MaxDistance = math.huge
    local character = LocalPlayer.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Проверяем папку Enemies, стандартную для Blox Fruits
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, enemy in pairs(enemiesFolder:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local distance = (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < MaxDistance then
                        MaxDistance = distance
                        Closest = enemy
                    end
                end
            end
        end
    end
    return Closest
end

-- Поток плавного полета и удержания над ботом
task.spawn(function()
    while true do
        if _G.FlyBotFarm then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    
                    local targetEnemy = GetClosestEnemy()
                    if targetEnemy then
                        -- Отключаем гравитацию и физику падения во время полета
                        if not character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "BF_Velocity"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = character.HumanoidRootPart
                        end
                        
                        -- Точка зависания: ровно на 5 метров выше головы бота (чтобы он нас не достал)
                        local targetPos = targetEnemy.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
                        local distance = (targetPos - character.HumanoidRootPart.Position).Magnitude
                        
                        -- Плавное перемещение к цели
                        if distance > 2 then
                            character.HumanoidRootPart.BF_Velocity.Velocity = (targetPos - character.HumanoidRootPart.Position).Unit * FarmSpeed
                        else
                            character.HumanoidRootPart.BF_Velocity.Velocity = Vector3.new(0, 0, 0)
                        end
                        
                        -- Разворачиваем персонажа лицом к боту для ударов
                        character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position, targetEnemy.HumanoidRootPart.Position)
                        
                        -- Интегрированная авто-атака
                        if not character:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then character.Humanoid:EquipTool(tool) end
                        end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(850, 520))
                    else
                        -- Если мобов рядом нет, зависаем на месте
                        if character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                            character.HumanoidRootPart.BF_Velocity.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end)
        else
            -- Если фарм выключен, убираем силу полета и возвращаем обычную физику
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                        character.HumanoidRootPart.BF_Velocity:Destroy()
                    end
                end
            end)
        end
        task.wait(0.05) -- Частота обновления позиции
    end
end)

-- ====================================================================
-- ЛОГИКА ФУНКЦИЙ ВОДЫ
-- ====================================================================
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(30, 2, 30)
WaterPlatform.Transparency = 1 
WaterPlatform.Anchored = true
WaterPlatform.CanCollide = false
WaterPlatform.Parent = workspace

RunService.RenderStepped:Connect(function()
    pcall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and _G.WalkOnWater then
            local pos = character.HumanoidRootPart.Position
            if pos.Y <= 25 then 
                WaterPlatform.CFrame = CFrame.new(pos.X, 12, pos.Z)
                WaterPlatform.CanCollide = true
            else
                WaterPlatform.CanCollide = false
            end
        else
            WaterPlatform.CanCollide = false
        end
    end)
end)

task.spawn(function()
    while true do
        if _G.NoWaterDamage then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Water" or v.Name == "Sea" then
                        if v:IsA("Part") or v:IsA("MeshPart") then v.CanTouch = false end
                    end
                end
            end)
        else
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Water" or v.Name == "Sea" then
                        if v:IsA("Part") or v:IsA("MeshPart") then v.CanTouch = true end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- Обычный кликер (работает отдельно, если выключен полет)
task.spawn(function()
    while true do
        if _G.SafeAttack and not _G.FlyBotFarm then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    if not character:FindFirstChildOfClass("Tool") then
                        local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if tool then character.Humanoid:EquipTool(tool) end
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(850, 520))
                end
            end)
        end
        task.wait(0.15)
    end
end)

-- ====================================================================
-- ИНТЕРФЕЙС GUI (МОБИЛЬНЫЙ / DELTA)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local PulseBar = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local FlyFarmBtn = Instance.new("TextButton")      -- Кнопка полета
local WaterPlatformBtn = Instance.new("TextButton")
