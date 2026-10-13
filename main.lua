local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("DH_DesignLayer") then PlayerGui.DH_DesignLayer:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DH_DesignLayer"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999
ScreenGui.Parent = PlayerGui

local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0) -- Тёмно-красный
MenuBtn.Text = "DH"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 16
MenuBtn.Active = true
MenuBtn.Draggable = true
MenuBtn.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = MenuBtn

local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 2.5
RGBStroke.Parent = MenuBtn

task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            RGBStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

print("Дизайн DH успешно загружен!")
