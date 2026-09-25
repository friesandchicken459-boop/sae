--==================================================
-- STEAL AN EGG
-- MAIN SCRIPT - REDESIGNED
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

--==================================================
-- CLEANUP
--==================================================

for _,v in ipairs(pg:GetChildren()) do
	if v.Name == "StealAnEggDeveloperMenu"
	or v.Name == "EggDropGui"
	or v.Name == "DevMenuToggle"
	or v.Name == "EggVisualMessageGui"
	or v.Name == "StealAnEggLoader" then
		v:Destroy()
	end
end

for _,v in ipairs(Workspace:GetChildren()) do
	if v.Name == "DeveloperEggs_"..player.UserId then
		v:Destroy()
	end
end

--==================================================
-- SETTINGS
--==================================================

local EGG_SCALE = 1.65
local SPAWN_DISTANCE = 9
local SKY_HEIGHT = 4
local PICKUP_DISTANCE = 18
local MESSAGE_DURATION = 4.5

local folder = Instance.new("Folder")
folder.Name = "DeveloperEggs_"..player.UserId
folder.Parent = Workspace

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(17,18,21)
local PANEL = Color3.fromRGB(25,27,31)
local PANEL2 = Color3.fromRGB(32,34,39)
local STROKE = Color3.fromRGB(65,68,75)
local TEXT = Color3.fromRGB(235,237,240)
local MUTED = Color3.fromRGB(145,149,157)
local RED = Color3.fromRGB(220,38,38)
local RED2 = Color3.fromRGB(255,55,55)
local GREEN = Color3.fromRGB(75,190,110)

--==================================================
-- LOADING SCREEN
--==================================================

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "StealAnEggLoader"
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 999
loadingGui.Parent = pg

local loader = Instance.new("Frame")
loader.Size = UDim2.fromScale(1,1)
loader.BackgroundColor3 = BG
loader.Parent = loadingGui

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(1,0,0,60)
loadTitle.Position = UDim2.new(0,0,.38,0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "STEAL AN EGG"
loadTitle.Font = Enum.Font.GothamBold
loadTitle.TextSize = 38
loadTitle.TextColor3 = TEXT
loadTitle.Parent = loader

local phrases = {
	"W SCRIPT IS LOADING",
	"BEST SCRIPT IS LOADING RIGHT NOW TYPE SHI",
	"LOADING DEVELOPER TOOLS",
	"PREPARING THE EGGS",
	"INITIALIZING STEAL AN EGG"
}

local loadText = Instance.new("TextLabel")
loadText.Size = UDim2.new(1,0,0,30)
loadText.Position = UDim2.new(0,0,.49,0)
loadText.BackgroundTransparency = 1
loadText.Text = phrases[math.random(#phrases)]
loadText.Font = Enum.Font.GothamMedium
loadText.TextSize = 16
loadText.TextColor3 = MUTED
loadText.Parent = loader

local barBack = Instance.new("Frame")
barBack.Size = UDim2.fromOffset(420,6)
barBack.Position = UDim2.new(.5,-210,.56,0)
barBack.BackgroundColor3 = PANEL2
barBack.BorderSizePixel = 0
barBack.Parent = loader

Instance.new("UICorner",barBack).CornerRadius = UDim.new(1,0)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0,0,1,0)
bar.BackgroundColor3 = RED
bar.BorderSizePixel = 0
bar.Parent = barBack

Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

TweenService:Create(
	bar,
	TweenInfo.new(1.8,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
	{Size=UDim2.fromScale(1,1)}
):Play()

task.wait(2)

TweenService:Create(
	loader,
	TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
	{BackgroundTransparency=1}
):Play()

for _,v in ipairs(loader:GetChildren()) do
	if v:IsA("GuiObject") then
		TweenService:Create(
			v,
			TweenInfo.new(.35),
			{BackgroundTransparency=1,TextTransparency=1}
		):Play()
	end
end

task.wait(.5)
loadingGui:Destroy()

--==================================================
-- MAIN GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "StealAnEggDeveloperMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(570,620)
frame.Position = UDim2.new(.5,-285,.5,-310)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,18)

local outline = Instance.new("UIStroke")
outline.Color = STROKE
outline.Thickness = 1.5
outline.Parent = frame

--==================================================
-- HEADER
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,70)
header.BackgroundColor3 = PANEL
header.BorderSizePixel = 0
header.Parent = frame

Instance.new("UICorner",header).CornerRadius = UDim.new(0,18)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-40,0,30)
title.Position = UDim2.fromOffset(20,12)
title.BackgroundTransparency = 1
title.Text = "STEAL AN EGG"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = TEXT
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,-40,0,20)
subtitle.Position = UDim2.fromOffset(20,40)
subtitle.BackgroundTransparency = 1
subtitle.Text = "DEVELOPER CONSOLE"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextColor3 = MUTED
subtitle.Parent = header

--==================================================
-- WARNING
--==================================================

local warning = Instance.new("TextLabel")
warning.Size = UDim2.new(1,-40,0,62)
warning.Position = UDim2.fromOffset(20,84)
warning.BackgroundColor3 = Color3.fromRGB(55,20,22)
warning.Text =
	"⚠  THIS SCRIPT IS PAID, IF YOU GOT IT FOR FREE ITS PROBABLY RATTED"
warning.Font = Enum.Font.GothamBold
warning.TextSize = 13
warning.TextWrapped = true
warning.TextColor3 = RED2
warning.BorderSizePixel = 0
warning.Parent = frame

Instance.new("UICorner",warning).CornerRadius = UDim.new(0,10)

local warningStroke = Instance.new("UIStroke")
warningStroke.Color = RED
warningStroke.Thickness = 1
warningStroke.Parent = warning

--==================================================
-- MODE
--==================================================

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1,-40,0,20)
modeLabel.Position = UDim2.fromOffset(20,160)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "MODE"
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextSize = 12
modeLabel.TextColor3 = MUTED
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Parent = frame

local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(1,-40,0,42)
modeButton.Position = UDim2.fromOffset(20,185)
modeButton.BackgroundColor3 = PANEL
modeButton.Text = "DEVELOPER"
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 14
modeButton.TextColor3 = TEXT
modeButton.BorderSizePixel = 0
modeButton.AutoButtonColor = false
modeButton.Parent = frame

Instance.new("UICorner",modeButton).CornerRadius = UDim.new(0,9)

local creatorMode = false

modeButton.MouseButton1Click:Connect(function()
	creatorMode = not creatorMode
	modeButton.Text = creatorMode and "YOUTUBE CREATOR" or "DEVELOPER"
end)

--==================================================
-- EGG SECTION
--==================================================

local eggLabel = Instance.new("TextLabel")
eggLabel.Size = UDim2.new(1,-40,0,20)
eggLabel.Position = UDim2.fromOffset(20,245)
eggLabel.BackgroundTransparency = 1
eggLabel.Text = "EGG SPAWNER"
eggLabel.Font = Enum.Font.GothamBold
eggLabel.TextSize = 12
eggLabel.TextColor3 = MUTED
eggLabel.TextXAlignment = Enum.TextXAlignment.Left
eggLabel.Parent = frame

local function button(text,x,y,w)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(w,45)
	b.Position = UDim2.fromOffset(x,y)
	b.BackgroundColor3 = PANEL
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = TEXT
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Parent = frame

	Instance.new("UICorner",b).CornerRadius = UDim.new(0,9)

	local s = Instance.new("UIStroke")
	s.Color = STROKE
	s.Thickness = 1
	s.Parent = b

	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(.15),{
			BackgroundColor3=PANEL2
		}):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(.15),{
			BackgroundColor3=PANEL
		}):Play()
	end)

	return b
end

local aethronButton = button("AETHRON",20,270,170)
local kitsuneButton = button("KITSUNE",200,270,170)
local archButton = button("ARCHANGEL",380,270,170)

--==================================================
-- CONSOLE
--==================================================

local consoleLabel = Instance.new("TextLabel")
consoleLabel.Size = UDim2.new(1,-40,0,20)
consoleLabel.Position = UDim2.fromOffset(20,330)
consoleLabel.BackgroundTransparency = 1
consoleLabel.Text = "CONSOLE"
consoleLabel.Font = Enum.Font.GothamBold
consoleLabel.TextSize = 12
consoleLabel.TextColor3 = MUTED
consoleLabel.TextXAlignment = Enum.TextXAlignment.Left
consoleLabel.Parent = frame

local console = Instance.new("TextLabel")
console.Size = UDim2.new(1,-40,0,105)
console.Position = UDim2.fromOffset(20,355)
console.BackgroundColor3 = Color3.fromRGB(10,11,13)
console.Text =
	"> STEAL AN EGG CONSOLE\n> READY\n> TYPE A COMMAND BELOW"
console.Font = Enum.Font.Code
console.TextSize = 13
console.TextColor3 = Color3.fromRGB(190,195,200)
console.TextXAlignment = Enum.TextXAlignment.Left
console.TextYAlignment = Enum.TextYAlignment.Top
console.BorderSizePixel = 0
console.Parent = frame

Instance.new("UICorner",console).CornerRadius = UDim.new(0,9)

local consolePadding = Instance.new("UIPadding")
consolePadding.PaddingTop = UDim.new(0,12)
consolePadding.PaddingLeft = UDim.new(0,12)
consolePadding.Parent = console

local commandBox = Instance.new("TextBox")
commandBox.Size = UDim2.new(1,-40,0,42)
commandBox.Position = UDim2.fromOffset(20,470)
commandBox.BackgroundColor3 = PANEL
commandBox.PlaceholderText = 'tp "USERNAME"'
commandBox.PlaceholderColor3 = MUTED
commandBox.Text = ""
commandBox.TextColor3 = TEXT
commandBox.Font = Enum.Font.Code
commandBox.TextSize = 13
commandBox.TextXAlignment = Enum.TextXAlignment.Left
commandBox.ClearTextOnFocus = false
commandBox.BorderSizePixel = 0
commandBox.Parent = frame

Instance.new("UICorner",commandBox).CornerRadius = UDim.new(0,9)

local commandPadding = Instance.new("UIPadding")
commandPadding.PaddingLeft = UDim.new(0,12)
commandPadding.Parent = commandBox

local executeButton = button("EXECUTE",20,525,130)

--==================================================
-- SIMULATED CONSOLE
--==================================================

local function runFakeCommand(command)
	command = tostring(command):gsub("^%s+",""):gsub("%s+$","")

	if command == "" then return end

	local target = command:match('^tp%s+"([^"]+)"$')

	if target then
		console.Text =
			"> STEAL AN EGG CONSOLE\n"..
			"> "..command.."\n"..
			"> SUCCESSFULLY TP \""..target.."\""

	elseif command:lower() == "help" then
		console.Text =
			"> STEAL AN EGG CONSOLE\n"..
			"> AVAILABLE COMMANDS:\n"..
			"> tp \"USERNAME\"\n"..
			"> help"

	else
		console.Text =
			"> STEAL AN EGG CONSOLE\n"..
			"> "..command.."\n"..
			"> UNKNOWN COMMAND"
	end

	-- IMPORTANT:
	-- This console is visual only.
	-- No teleport is performed.
end

executeButton.MouseButton1Click:Connect(function()
	runFakeCommand(commandBox.Text)
	commandBox.Text = ""
end)

commandBox.FocusLost:Connect(function(enter)
	if enter then
		runFakeCommand(commandBox.Text)
		commandBox.Text = ""
	end
end)

--==================================================
-- MENU TOGGLE
--==================================================

local toggle = button("☰  DEV MENU",15,15,145)

toggle.Parent = gui

local toggleCorner = toggle:FindFirstChildOfClass("UICorner")
toggle.Position = UDim2.fromOffset(15,15)

toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local d = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset+d.X,
			startPos.Y.Scale,
			startPos.Y.Offset+d.Y
		)
	end
end)

--==================================================
-- K KEY
--==================================================

UIS.InputBegan:Connect(function(input,gp)
	if not gp and input.KeyCode == Enum.KeyCode.K then
		frame.Visible = not frame.Visible
	end
end)

--==================================================
-- EXISTING EGG FUNCTIONS
--==================================================
-- Keep your existing:
-- makePart
-- makeSphere
-- makeCylinder
-- makeWedge
-- makeFeather
-- addNeonSphere
-- addHighlight
-- addGlow
-- addGlowShell
-- addPulseRings
-- addSpark
-- addOrbitRing
-- addGraphicPetals
-- animateEggEffects
-- makeBlockyEgg
-- addBlockyShellHighlight
-- createAethron
-- createKitsune
-- createArchAngel
-- getGroundPosition
-- pickupEgg
-- dropEgg
-- createPickupPrompt
-- spawnEgg
--
-- They remain unchanged from the egg system you already built.

--==================================================
-- EGG BUTTON CONNECTIONS
--==================================================

aethronButton.MouseButton1Click:Connect(function()
	spawnEgg("Aethron")
end)

kitsuneButton.MouseButton1Click:Connect(function()
	spawnEgg("Kitsune")
end)

archButton.MouseButton1Click:Connect(function()
	spawnEgg("ArchAngel")
end)

--==================================================
-- START
--==================================================

frame.Visible = true
