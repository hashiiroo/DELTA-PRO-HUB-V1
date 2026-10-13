--[[
 DAIKI HUB  |  COMPACT EDITION
 Мобильный UI-симулятор для Blox Fruits (личный QA-тест).

 Таргет: любая ближайшая Model (NPC) в радиусе 300 студов.
 Внедрение:
   A) как LocalScript (.luau) через executor;
   B) loadstring(game:HttpGet(raw_url))() из GitHub raw.
]]

------------------------------------------------------------[ ИМПОРТЫ ]-----
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInput      = game:GetService("UserInputService")

------------------------------------------------------------[ ПЕРЕМЕННЫЕ ]---
local player         = Players.LocalPlayer
if not player then return end

-- Флаг жизни GUI. Любой цикл проверяет его -> Destructor X() не ломает тики.
local uiAlive        = true

-- Состояние авто-экипировки Melee + телепорта.
local simRunning     = false

-- Ссылки на динамические элементы (для драга / переключателя).
local dhButton       -- круглая кнопка "DH"  45x45
local mainFrame      -- главное окно         320x240
local headerBar      -- шапка                40px высота

-------------------------------------------------------------[ ПОСТРОЕНИЕ ]--
do
 local screenGui                = Instance.new("ScreenGui")
 screenGui.Name                 = "DaikiHub"
 screenGui.IgnoreGuiInset       = true          -- не мешает мобильным панелям экрана
 -- Родитель надёжно с учётом разных исполнителей:
 screenGui.Parent               =
     player.PlayerGui or game.CoreGui or workspace.CurrentCamera.ViewportFrame

---------------------------------------------------------------- [ГЛАВНОЕ]
 mainFrame                      = Instance.new("Frame", screenGui)
 mainFrame.Size                 = UDim2.fromOffset(320, 240)
 mainFrame.Position             = UDim2.fromOffset(40,  60)
 mainFrame.BackgroundColor3     = Color3.fromRGB(20,20,20)
 mainFrame.BorderSizePixel      = 0
 local mainCorner               :UICorner?=nIl; do local c=Instance.new("UICorner", mainFrame); c.CornerRadius=UDim.new(0,10); end;

------------------------------------------------------------------- [ШАПКА]
 headerBar                      : Frame?                  ...
