_G.SafeAttack = false
_G.FlyBotFarm = false
_G.WalkOnWater = false
_G.NoWaterDamage = false

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ADMIN_GROUPS = { 4342932, 1200769 }
local FarmSpeed = 80

-- 1. АНТИ-АДМИН
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
    LocalPlayer:Kick("Безопасный выход!")
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

-- 2. ANTI-AFK 
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- 3. ПОИСК ДЛЯ ЛЕТАЮЩЕГО ФАРМА
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
                    if distance < MaxDistance and distance < 300 then
                        MaxDistance = distance
                        Closest = enemy
                    end
                end
            end
        end
    end
    return Closest
end

-- 4. ПОТОК ПОЛЕТА И ФАРМА
task.spawn(function()
    while true do
        if _G.FlyBotFarm then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local targetEnemy = GetClosestEnemy()
                    if targetEnemy then
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
                        
                        if not character:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then character.Humanoid:EquipTool(tool) end
                        end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(850, 520))
                    else
                        if character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                            character.HumanoidRootPart.BF_Velocity.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end)
        else
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

-- 5. ОБЫЧНЫЙ АВТОКЛИКЕР
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

-- 6. ФУНКЦИИ ВОДЫ
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(40, 2, 40)
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
        task.wait(4)
    end
end)

-- ====================================================================
-- УЛЬТРА-ЛЕГКИЙ ИНТЕРФЕЙС GUI (ИСПРАВЛЕНЫ КООРДИНАТЫ МОБИЛОК)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local FloatingButton = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "DeltaFixV5_1"
ScreenGui.ResetOnSpawn = false

-- Кружок открытия (Сделали чуть больше для удобства тапа)
FloatingButton.Parent = ScreenGui
FloatingButton.Position = UDim2.new(0.1, 0, 0.25, 0)
FloatingButton.Size = UDim2.new(0, 55, 0, 55)
FloatingButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
FloatingButton.Text = "MENU"
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.Font = Enum.Font.SourceSansBold
FloatingButton.TextSize = 14
FloatingButton.Active = true
FloatingButton.Draggable = true
local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = FloatingButton

-- Панель настроек (Теперь жестко привязана к центру экрана)
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.5, -105, 0.5, -110) -- Ровно центр экрана смартфона
MainFrame.Size = UDim2.new(0, 210, 0, 220)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true -- Всё еще можно двигать после открытия
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  DELTA HUB V5.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local BtnArea = Instance.new("Frame")
BtnArea.Parent = MainFrame
BtnArea.Position = UDim2.new(0.05, 0, 0.2, 0)
BtnArea.Size = UDim2.new(0.9, 0, 0.75, 0)
BtnArea.BackgroundTransparency = 1

UIListLayout.Parent = BtnArea
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
-- ====================================================================
-- DELTA LIGHT HUB v5: LIGHTWEIGHT & FIXED FOR MOBILE
-- ====================================================================

_G.SafeAttack = false
_G.FlyBotFarm = false
_G.WalkOnWater = false
_G.NoWaterDamage = false

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ADMIN_GROUPS = { 4342932, 1200769 }
local FarmSpeed = 80 -- Немного снизили скорость для стабильности на слабых телефонах

-- 1. АНТИ-АДМИН (ТИХИЙ СЕРВЕР ХОП)
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
    LocalPlayer:Kick("Безопасный выход!")
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

-- 2. ANTI-AFK 
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- 3. ПОИСК ДЛЯ ЛЕТАЮЩЕГО ФАРМА
local function GetClosestEnemy()
    local Closest = nil
    local MaxDistance = math.huge
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Проверяем как Enemies, так и общий Workspace на случай изменения структуры игры
        local targets = workspace:FindFirstChild("Enemies") or workspace
        for _, enemy in pairs(targets:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                -- Игнорируем самого себя
                if enemy.Name ~= LocalPlayer.Name then
                    local distance = (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < MaxDistance and distance < 300 then -- Радиус поиска 300 метров
                        MaxDistance = distance
                        Closest = enemy
                    end
                end
            end
        end
    end
    return Closest
end

-- 4. ПОТОК ПОЛЕТА И ФАРМА
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
                        
                        -- Атака
                        if not character:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then character.Humanoid:EquipTool(tool) end
                        end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(850, 520))
                    else
                        if character.HumanoidRootPart:FindFirstChild("BF_Velocity") then
                            character.HumanoidRootPart.BF_Velocity.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end)
        else
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

-- 5. ОБЫЧНЫЙ АВТОКЛИКЕР (ДЛЯ ФАРМА ВРУЧНУЮ)
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

-- 6. ФУНКЦИИ ВОДЫ
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(40, 2, 40)
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
        task.wait(4)
    end
end)

-- ====================================================================
-- УЛЬТРА-ЛЕГКИЙ ИНТЕРФЕЙС GUI (ДЛЯ СЛАБЫХ ТЕЛЕФОНОВ И DELTA)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local FloatingButton = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "DeltaFixV5"
ScreenGui.ResetOnSpawn = false

-- Кружок открытия
FloatingButton.Parent = ScreenGui
FloatingButton.Position = UDim2.new(0.15, 0, 0.25, 0)
FloatingButton.Size = UDim2.new(0, 45, 0, 45)
FloatingButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
FloatingButton.Text = "MENU"
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.Font = Enum.Font.SourceSansBold
FloatingButton.TextSize = 14
FloatingButton.Active = true
FloatingButton.Draggable = true
local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = FloatingButton

-- Панель
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 210, 0, 220)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  DELTA HUB V5"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local BtnArea = Instance.new("Frame")
BtnArea.Parent = MainFrame
