--[[ DAIKI HUB | COMPACT EDITION ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then return end

-- Флаг жизни GUI; любой цикл проверяет его (защита от "ломающих деструкторов").
local uiAlive      = true
-- Состояние симуляции (Melee + телепорт к ближайшему NPC).
local simRunning   = false

-- Ссылки на элементы для драга / переключателя.
local dhButton     -- круглая кнопка DH 45x45
local mainFrame    -- главное окно 320x240
local headerBar    -- шапка 40px высотой

------------------------------------------------------------[ ПОСТРОЕНИЕ GUI ]
do
 local screenGui        = Instance.new("ScreenGui")
 screenGui.Name         = "DaikiHub"
 screenGui.IgnoreGuiInset       = true
 screenGui.Parent               =
  player.PlayerGui or game.CoreGui or workspace.CurrentCamera.ViewportFrame

 -------------------------------------------------------- [ГЛАВНОЕ ОКНО]
 mainFrame              = Instance.new("Frame", screenGui)
 mainFrame.Size                = UDim2.fromOffset(320, 240)
 mainFrame.Position            = UDim2.fromOffset(40,  60)
 mainFrame.BackgroundColor3    = Color3.fromRGB(20,20,20)
 mainFrame.BorderSizePixel     = 0
 local corner          : UICorner?=nil do local c=Instance.new(
                             "UICorner", mainFrame); c.CornerRadius=
                             UDim.new(0,10) ; corner=c end

 if false then print(corner) else print(nil==corner) end;
