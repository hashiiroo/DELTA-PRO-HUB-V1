-- ====================================================================
-- DELTA PRO HUB v6.1: RGB CIRCLE + "DH" NAME + SAFE FLY FARM
-- ====================================================================

_G.SafeFlyFarm = false

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local FarmSpeed = 75

-- ANTI-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ПОИСК БОТОВ
local function GetClosestEnemy()
    local Closest = nil
    local MaxDistance = math.huge
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local targetsFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, enemy in pairs(targetsFolder:GetChildren()) do
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

-- ПОТОК ЛЕТАЮЩЕГО ФАРМА
task.spawn(function()
    while true do
        if _G.SafeFlyFarm then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local targetEnemy = GetClosestEnemy()
                    if targetEnemy then
                        if not character.HumanoidRootPart:FindFirstChild("FarmVelocity") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "FarmVelocity"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = character.HumanoidRootPart
                        end
                        local targetPos = targetEnemy.HumanoidRootPart.Position + Vector3.new(0, 6, 0)
                        local distance = (targetPos - character.HumanoidRootPart.Position).Magnitude
                        if distance > 2 then
                            character.HumanoidRootPart.FarmVelocity.Velocity = (targetPos - character.HumanoidRootPart.Position).Unit * FarmSpeed
                        else
                            character.HumanoidRootPart.FarmVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                        character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position, targetEnemy.HumanoidRootPart.Position)
                        if not character:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then character.Humanoid:EquipTool(tool) end
                        end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(850, 520))
                    else
                        if character.HumanoidRootPart:FindFirstChild("FarmVelocity") then
                            character.HumanoidRootPart.FarmVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end)
        else
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if character.HumanoidRootPart:FindFirstChild("FarmVelocity") then
                        character.HumanoidRootPart.FarmVelocity:Destroy()
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- ИНТЕРФЕЙС GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("SafeFarmHubV6_1") then PlayerGui.SafeFarmHubV6_1:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeFarmHubV6_1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Круглая кнопка DH с темно-красным фоном
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0) -- Темно-красный фон
MenuBtn.Text = "DH" -- Переименовано в DH
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 16
MenuBtn.Active = true
MenuBtn.Draggable = true
MenuBtn.Parent = ScreenGui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(1, 0)
corner1.Parent = MenuBtn

-- Элемент обводки (UIStroke) для создания RGB подсветки вокруг кружка
local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 3 -- Толщина подсветки
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent = MenuBtn

-- Поток для плавной смены цветов радуги (RGB подсветка)
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            RGBStroke.Color = Color3.fromHSV(i, 1, 1) -- Плавный переход по цветовому спектру
            task.wait(0.02) -- Скорость переливания радуги
        end
    end
end)

-- Главная панель настроек
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 210, 0, 110)
Frame.Position = UDim2.new(0.5, -105, 0.5, -55)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 10)
corner2.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  DELTA HUB v6.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 10)
corner3.Parent = Title

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

-- ЛОГИКА НАЖАТИЙ
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

MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Frame.Visible = not Frame.Visible
    end
end)

print("Скрипт v6.1 с RGB подсветкой готов!")
