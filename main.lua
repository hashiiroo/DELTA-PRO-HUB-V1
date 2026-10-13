_G.SafeFlyFarm = false
_G.SafeAttack = false
_G.AutoHaki = false
_G.WalkOnWater = false
_G.NoWaterDamage = false

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local FarmSpeed = 75
local ADMIN_GROUPS = { 4342932, 1200769 }

-- ANTI-AFK (Облегченный)
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ANTI-ADMIN
local function LeaveServer()
    _G.SafeFlyFarm = false
    _G.SafeAttack = false
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
    task.wait(1)
    LocalPlayer:Kick("DH HUB: Защита!")
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

-- АВТО-ХАКИ
task.spawn(function()
    while true do
        if _G.AutoHaki then
            pcall(function()
                if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                end
            end)
        end
        task.wait(5) -- Увеличили задержку до 5 секунд для снижения нагрузки
    end
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

-- ПОТОК ПОЛЕТА
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
        task.wait(0.07) -- Замедлили опрос физики до 0.07 (убирает лаги телефона)
    end
end)

-- ОБЫЧНЫЙ КЛИКЕР
task.spawn(function()
    while true do
        if _G.SafeAttack and not _G.SafeFlyFarm then
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
        task.wait(0.2)
    end
end)

-- ВОДНАЯ ПЛАТФОРМА
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(60, 2, 60)
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

-- УРОН ВОДЫ
task.spawn(function()
    while true do
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Water" or v.Name == "Sea" then
                    if v:IsA("Part") or v:IsA("MeshPart") then v.CanTouch = not _G.NoWaterDamage end
                end
            end
        end)
        task.wait(4)
    end
end)

-- СОЗДАНИЕ ИНТЕРФЕЙСА (БЕЗ ТЯЖЕЛЫХ ЦИКЛОВ И АНИМАЦИЙ)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("DH_LiteCard") then PlayerGui.DH_PremiumCard:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DH_LiteCard"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Круглая кнопка DH (Темно-красный фон)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
MenuBtn.Text = "DH"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 16
MenuBtn.Active = true
MenuBtn.Draggable = true
MenuBtn.Parent = ScreenGui

local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = MenuBtn

-- Обычная статичная обводка (Не лагает)
local Stroke = Instance.new("UIStroke") Stroke.Thickness = 2; Stroke.Color = Color3.fromRGB(255, 0, 0); Stroke.Parent = MenuBtn

-- Панель настроек (Прямоугольная, классическая)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 240)
MainFrame.Position = UDim2.new(0.5, -105, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 10) c2.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  DELTA HUB v9.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 10) c3.Parent = Title

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 5)
List.SortOrder = Enum.SortOrder.LayoutOrder

tion()

	TweenService:Create(
		button,
		TweenInfo.new(
			0.18,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			BackgroundColor3 = ACCENT,

			Size = originalSize,
			Position = originalPosition
		}
	):Play()

	TweenService:Create(
		buttonStroke,
		TweenInfo.new(0.18),
		{
			Transparency = 0.82
		}
	):Play()

end)

--==================================================
-- COPY ACTION
--==================================================

button.MouseButton1Click:Connect(function()

	-- Click animation
	TweenService:Create(
		button,
		TweenInfo.new(0.08),
		{
			Size = UDim2.new(1, -42, 0, 46)
		}
	):Play()

	task.wait(0.08)

	TweenService:Create(
		button,
		TweenInfo.new(0.12),
		{
			Size = originalSize
		}
	):Play()

	-- Copy
	setclipboard(SCRIPT_LINK)

	-- Change text
	buttonText.Text = "LINK COPIED!"

	-- Change to orange
	TweenService:Create(
		button,
		TweenInfo.new(0.2),
		{
			BackgroundColor3 = COPIED_COLOR
		}
	):Play()

	-- Wait
	task.wait(1.5)

	-- Return to normal
	buttonText.Text = "COPY LINK SCRIPT"

	TweenService:Create(
		button,
		TweenInfo.new(0.2),
		{
			BackgroundColor3 = ACCENT
		}
	):Play()

end)

--==================================================
-- CLOSE ANIMATION
--==================================================

local function closeGui()

	TweenService:Create(
		frame,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.In
		),
		{
			Size = UDim2.fromOffset(340, 210),

			Position = UDim2.new(
				0.5,
				0,
				0.5,
				15
			)
		}
	):Play()

	TweenService:Create(
		stroke,
		TweenInfo.new(0.2),
		{
			Transparency = 1
		}
	):Play()

	task.wait(0.25)

	gui:Destroy()

end

close.MouseButton1Click:Connect(closeGui)

--==================================================
-- OPEN ANIMATION
--==================================================

frame.Size = UDim2.fromOffset(330, 200)

TweenService:Create(
	frame,
	TweenInfo.new(
		0.45,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	),
	{
		Size = UDim2.fromOffset(380, 235),

		-- Perfect center
		Position = UDim2.new(
			0.5,
			0,
			0.5,
			0
		)
	}
):Play()

--==================================================
-- BORDER PULSE
--==================================================

task.spawn(function()

	while gui.Parent do

		TweenService:Create(
			stroke,
			TweenInfo.new(
				1.2,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				Transparency = 0.75
			}
		):Play()

		task.wait(1.2)

		TweenService:Create(
			stroke,
			TweenInfo.new(
				1.2,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				Transparency = 0.35
			}
		):Play()

		task.wait(1.2)

	end

end)
