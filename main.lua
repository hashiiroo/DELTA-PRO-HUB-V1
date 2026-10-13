-- ====================================================================
-- DELTA PRO HUB: ПОЛНЫЙ ПЕРВОНАЧАЛЬНЫЙ ВИД (ИСПРАВЛЕННЫЙ)
-- ====================================================================

_G.SafeAttack = false
_G.FlyBotFarm = false
_G.WalkOnWater = false
_G.NoWaterDamage = false

-- Сервисы Roblox
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ADMIN_GROUPS = { 4342932, 1200769 }
local FarmSpeed = 80 -- Безопасная скорость полета для обхода античита

-- ====================================================================
-- СИСТЕМА ЗАЩИТЫ (АНТИ-АДМИН И ANTI-AFK)
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
    task.wait(1)
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

-- Невидимый Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ====================================================================
-- ЛОГИКА ФУНКЦИЙ ВОДЫ
-- ====================================================================

-- 1. Создание физической платформы под ногами
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(50, 2, 50)
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
                WaterPlatform.CFrame = CFrame.new(pos.X, 11, pos.Z)
                WaterPlatform.CanCollide = true
            else
                WaterPlatform.CanCollide = false
            end
        else
            WaterPlatform.CanCollide = false
        end
    end)
end)

-- 2. Отключение урона от касания воды
task.spawn(function()
    while true do
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Water" or v.Name == "Sea" then
                    if v:IsA("Part") or v:IsA("MeshPart") then 
                        v.CanTouch = not _G.NoWaterDamage 
                    end
                end
            end
        end)
        task.wait(3)
    end
end)

-- ====================================================================
-- ЛОГИКА АВТО-ФАРМА И ПОИСКА БОТОВ
-- ====================================================================

-- Функция поиска ближайшего врага
local function GetClosestEnemy()
    local Closest = nil
    local MaxDistance = math.huge
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local targets = workspace:FindFirstChild("Enemies") or workspace
        for _, enemy in pairs(targets:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                if enemy.Name ~= LocalPlayer.Name then
                    local distance = (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
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

-- Поток летающего автофарма
task.spawn(function()
    while true do
        if _G.FlyBotFarm then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local targetEnemy = GetClosestEnemy()
                    if targetEnemy then
                        -- Включаем левитацию
                        if not character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "BF_Velocity"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = character.HumanoidRootPart
                        end
                        
                        local targetPos = targetEnemy.HumanoidRootPart.Position + Vector3.new(0, 6, 0)
                        local distance = (targetPos - character.HumanoidRootPart.Position).Magnitude
                        
                        if distance > 2 then
                            character.HumanoidRootPart.BF_Velocity.Velocity = (targetPos - character.HumanoidRootPart.Position).Unit * FarmSpeed
                        else
                            character.HumanoidRootPart.BF_Velocity.Velocity = Vector3.new(0, 0, 0)
                        end
                        
                        character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position, targetEnemy.HumanoidRootPart.Position)
                        
                        -- Автоматически берем оружие и атакуем
                        if not character:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then character.Humanoid:EquipTool(tool) end
                        end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(850, 520))
                    else
                        if character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                            character.HumanoidRootPart.BF_Velocity.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end)
        else
            -- Возврат обычной физики персонажа
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                        character.HumanoidRootPart.BF_Velocity:Destroy()
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- Обычный кликер (работает на суше)
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
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("DeltaMobileV5") then PlayerGui.DeltaMobileV5:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMobileV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Круглая кнопка MENU
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 14
MenuBtn.Active = true
MenuBtn.Draggable = true
MenuBtn.Parent = ScreenGui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(1, 0)
corner1.Parent = MenuBtn

-- Панель настроек
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 210, 0, 210)
Frame.Position = UDim2.new(0.5, -105, 0.5, -105)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local corner2 = Instance.new("UICorner")
