_G.SafeAttack = false
_G.FlyBotFarm = false
_G.WalkOnWater = false
_G.NoWaterDamage = false
_G.AutoHaki = false

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
        local url = "https://roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local servers = HttpService:JSONDecode(game:HttpGet(url))
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
    task.wait(1.5)
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

-- 3. АВТО-ХАКИ (ВОЛЯ)
task.spawn(function()
    while true do
        if _G.AutoHaki then
            pcall(function()
                if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                end
            end)
        end
        task.wait(4)
    end
end)

-- 4. ПОИСК ДЛЯ ЛЕТАЮЩЕГО ФАРМА
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

-- 5. ПОТОК ПОЛЕТА И ФАРМА
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

-- 6. ОБЫЧНЫЙ АВТОКЛИКЕР
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

-- 7. ФУНКЦИИ ВОДЫ
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
-- ИНТЕРФЕЙС GUI С РЕЖИМОМ ТЕЛЕФОННОГО ТАЧА (INPUT BEGAN)
-- ====================================================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("DeltaMobileTouchV6") then PlayerGui.DeltaMobileTouchV6:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMobileTouchV6"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Кружок открытия DH с RGB-подсветкой
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
MenuBtn.Text = "DH"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 14
MenuBtn.Active = true
MenuBtn.Draggable = true
MenuBtn.Parent = ScreenGui

local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = MenuBtn

local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 2.5
RGBStroke.Parent = MenuBtn
task.spawn(function() while true do for i = 0, 1, 0.005 do RGBStroke.Color = Color3.fromHSV(i, 1, 1) task.wait(0.02) end end end)

-- Панель настроек
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.5, -105, 0.5, -125)
MainFrame.Size = UDim2.new(0, 210, 0, 250)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  DELTA HUB V6.3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
