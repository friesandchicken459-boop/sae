--==================================================
-- STEAL AN EGG - CO-DEVELOPER TEST MENU
-- FULL MAIN VERSION
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CLEAN UP PREVIOUS VERSION
--==================================================

for _, object in ipairs(playerGui:GetChildren()) do
	if object.Name == "StealAnEggDeveloperMenu"
		or object.Name == "EggDropGui"
		or object.Name == "DevMenuToggle"
		or object.Name == "EggVisualMessageGui" then
		object:Destroy()
	end
end

for _, object in ipairs(Workspace:GetChildren()) do
	if object.Name == "DeveloperEggs_" .. player.UserId then
		object:Destroy()
	end
end

--==================================================
-- SETTINGS
--==================================================

local EGG_SCALE = 1.65

-- Eggs spawn closer to the player.
local SPAWN_DISTANCE = 9

-- Eggs only drop a small distance before landing.
local SKY_HEIGHT = 4

-- Easier pickup.
local PICKUP_DISTANCE = 18

-- Lower egg brightness.
local EGG_LIGHT_MULTIPLIER = 0.38

-- Lower neon intensity.
local EGG_NEON_TRANSPARENCY = 0.18

local MESSAGE_DURATION = 4.5

--==================================================
-- EGG FOLDER
--==================================================

local eggFolder = Instance.new("Folder")
eggFolder.Name = "DeveloperEggs_" .. player.UserId
eggFolder.Parent = Workspace

--==================================================
-- COLORS
--==================================================

local COLORS = {
	White = Color3.fromRGB(255, 252, 235),
	Cream = Color3.fromRGB(225, 220, 190),

	Gold = Color3.fromRGB(255, 190, 25),
	BrightGold = Color3.fromRGB(255, 225, 60),
	Yellow = Color3.fromRGB(255, 235, 65),
	DarkGold = Color3.fromRGB(190, 125, 5),

	Pink = Color3.fromRGB(255, 35, 190),
	HotPink = Color3.fromRGB(255, 0, 145),
	LightPink = Color3.fromRGB(255, 120, 225),
	DarkPink = Color3.fromRGB(190, 0, 105),

	Red = Color3.fromRGB(220, 25, 35),
	BrightRed = Color3.fromRGB(255, 50, 55),
	DarkRed = Color3.fromRGB(105, 10, 15),

	Gray = Color3.fromRGB(105, 105, 105),
	DarkGray = Color3.fromRGB(55, 55, 55),
	Black = Color3.fromRGB(20, 20, 20),
}

--==================================================
-- BASIC PART CREATORS
--==================================================

local function makePart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic

	if material == Enum.Material.Neon then
		part.Transparency = EGG_NEON_TRANSPARENCY
	end

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = true
	part.CanQuery = true
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent

	return part
end

local function makeSphere(parent, name, size, position, color, material)
	local part = makePart(
		parent,
		name,
		size,
		CFrame.new(position),
		color,
		material
	)

	part.Shape = Enum.PartType.Ball

	return part
end

local function makeCylinder(parent, name, size, cframe, color, material)
	local part = makePart(
		parent,
		name,
		size,
		cframe,
		color,
		material
	)

	part.Shape = Enum.PartType.Cylinder

	return part
end

local function makeWedge(parent, name, size, cframe, color, material)
	local part = makePart(
		parent,
		name,
		size,
		cframe,
		color,
		material
	)

	part.Shape = Enum.PartType.Wedge

	return part
end

local function makeFeather(parent, position, size, color, rotation)
	local feather = makePart(
		parent,
		"Feather",
		size,
		CFrame.new(position) *
			CFrame.Angles(
				math.rad(rotation.X),
				math.rad(rotation.Y),
				math.rad(rotation.Z)
			),
		color,
		Enum.Material.SmoothPlastic
	)

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Wedge
	mesh.Scale = Vector3.new(1, 1, 0.45)
	mesh.Parent = feather

	return feather
end

local function addNeonSphere(parent, name, size, position, color)
	return makeSphere(
		parent,
		name,
		size,
		position,
		color,
		Enum.Material.Neon
	)
end

--==================================================
-- FX HELPERS
--==================================================

local function addHighlight(parent, adornee, color, brightness)
	local h = Instance.new("Highlight")
	h.Name = "EggGlow"
	h.Adornee = adornee

	h.FillColor = color
	h.FillTransparency = 0.82

	h.OutlineColor = color
	h.OutlineTransparency = 0.25

	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = parent

	return h
end

local function addGlow(parent, position, color, size, brightness)
	local p = Instance.new("Part")

	p.Name = "Glow"
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(size, size, size)
	p.Position = position

	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Transparency = 1

	p.Parent = parent

	local light = Instance.new("PointLight")

	light.Color = color
	light.Brightness =
		(brightness or 2) *
		EGG_LIGHT_MULTIPLIER

	light.Range = size * 2.2
	light.Shadows = false

	light.Parent = p

	p:SetAttribute(
		"BaseBrightness",
		light.Brightness
	)

	return p
end

local function addGlowShell(parent, position, color, radius, brightness)
	for i = 1, 3 do
		local p = Instance.new("Part")

		p.Name = "GlowShell" .. i
		p.Shape = Enum.PartType.Ball

		local r =
			radius *
			(1 + i * 0.22)

		p.Size =
			Vector3.new(
				r,
				r,
				r
			)

		p.Position = position
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Transparency = 1
		p.Parent = parent

		local light =
			Instance.new("PointLight")

		light.Color = color

		light.Brightness =
			(brightness / i) *
			EGG_LIGHT_MULTIPLIER

		light.Range =
			radius *
			(4 + i)

		light.Shadows = false
		light.Parent = p

		p:SetAttribute(
			"BaseBrightness",
			light.Brightness
		)
	end
end

local function addPulseRings(parent, color, scale)
	for i = 1, 3 do
		local ring = makeCylinder(
			parent,
			"EnergyRing" .. i,
			Vector3.new(
				0.12 + i * 0.08,
				(6.5 + i * 1.7) * scale,
				(6.5 + i * 1.7) * scale
			),
			CFrame.new(0, 0, 0) *
				CFrame.Angles(
					0,
					0,
					math.rad(90)
				),
			color,
			Enum.Material.Neon
		)

		ring.Transparency =
			0.32 +
			i * 0.10
	end
end

local function addSpark(parent, position, color, size)
	local s = makeSphere(
		parent,
		"Spark",
		Vector3.new(
			size,
			size,
			size
		),
		position,
		color,
		Enum.Material.Neon
	)

	local a0 = Instance.new("Attachment")
	a0.Position =
		Vector3.new(
			0,
			-size / 2,
			0
		)
	a0.Parent = s

	local a1 = Instance.new("Attachment")
	a1.Position =
		Vector3.new(
			0,
			size / 2,
			0
		)
	a1.Parent = s

	local trail = Instance.new("Trail")

	trail.Attachment0 = a0
	trail.Attachment1 = a1

	trail.Lifetime = 0.25
	trail.LightEmission = 1

	trail.Color =
		ColorSequence.new(color)

	trail.Transparency =
		NumberSequence.new(
			0.25,
			1
		)

	trail.Parent = s

	return s
end

local function addOrbitRing(parent, radius, y, color, thickness)
	local ring = makeCylinder(
		parent,
		"EnergyRing",
		Vector3.new(
			thickness or 0.22,
			radius,
			radius
		),
		CFrame.new(
			0,
			y,
			0
		) *
		CFrame.Angles(
			0,
			0,
			math.rad(90)
		),
		color,
		Enum.Material.Neon
	)

	ring.Transparency = 0.30

	return ring
end

local function addGraphicPetals(
	parent,
	count,
	radius,
	y,
	colorA,
	colorB
)
	for i = 1, count do
		local a =
			(i / count) *
			math.pi *
			2

		local x =
			math.cos(a) *
			radius

		local z =
			math.sin(a) *
			radius

		local petal =
			makeSphere(
				parent,
				"GraphicPetal",
				Vector3.new(
					1.1,
					0.25,
					2.4
				) * EGG_SCALE,
				Vector3.new(
					x,
					y,
					z
				),
				(i % 2 == 0)
					and colorA
					or colorB,
				Enum.Material.Neon
			)

		petal.CFrame =
			CFrame.new(
				x,
				y,
				z
			) *
			CFrame.Angles(
				0,
				-a,
				math.rad(18)
			)

		petal.Transparency = 0.28
	end
end

--==================================================
-- ANIMATED FX
--==================================================

local function animateEggEffects(model)
	local effects = {}
	local startingPivot =
		model:GetPivot()

	for _, obj in ipairs(
		model:GetDescendants()
	) do
		if obj:IsA("BasePart") then

			if obj.Name == "EnergyRing"
				or string.match(
					obj.Name,
					"^EnergyRing"
				)
				or obj.Name == "Glow"
				or string.match(
					obj.Name,
					"GlowShell"
				)
				or obj.Name == "Spark"
				or obj.Name == "GraphicPetal"
				or obj.Name == "AethronHalo"
				or obj.Name == "AngelHalo" then

				local light =
					obj:FindFirstChildOfClass(
						"PointLight"
					)

				table.insert(
					effects,
					{
						part = obj,

						relative =
							startingPivot:ToObjectSpace(
								obj.CFrame
							),

						baseSize =
							obj.Size,

						baseBrightness =
							light
								and light.Brightness
								or nil,
					}
				)
			end
		end
	end

	local startTime =
		os.clock()

	task.spawn(
		function()
			while model.Parent do
				local t =
					os.clock() -
					startTime

				local currentPivot =
					model:GetPivot()

				for index, effect in ipairs(
					effects
				) do

					local part =
						effect.part

					if part
						and part.Parent then

						local relative =
							effect.relative

						if string.match(
							part.Name,
							"^EnergyRing"
						) then

							local speed =
								index % 2 == 0
								and 1.5
								or -1.1

							part.CFrame =
								currentPivot *
								relative *
								CFrame.Angles(
									t * speed,
									t * speed * 0.6,
									t * speed * 1.4
								)

						elseif part.Name ==
							"AethronHalo"

							or part.Name ==
							"AngelHalo" then

							local bob =
								math.sin(
									t * 2.2
								) *
								0.45

							part.CFrame =
								currentPivot *
								relative *
								CFrame.new(
									0,
									bob,
									0
								) *
								CFrame.Angles(
									0,
									t * 1.4,
									math.sin(
										t * 2
									) * 0.08
								)

						elseif part.Name ==
							"Spark" then

							local radius =
								Vector3.new(
									relative.Position.X,
									0,
									relative.Position.Z
								).Magnitude

							local angle =
								math.atan2(
									relative.Position.Z,
									relative.Position.X
								) +
								t *
								(
									1.2 +
									index *
									0.04
								)

							local y =
								relative.Position.Y +
								math.sin(
									t * 3 +
									index
								) *
								1.2

							local pos =
								Vector3.new(
									math.cos(
										angle
									) *
										radius,

									y,

									math.sin(
										angle
									) *
										radius
								)

							part.CFrame =
								currentPivot *
								CFrame.new(pos)

							local pulse =
								1 +
								math.sin(
									t * 6 +
									index
								) *
								0.20

							part.Size =
								effect.baseSize *
								pulse

						elseif part.Name ==
							"GraphicPetal" then

							local radius =
								Vector3.new(
									relative.Position.X,
									0,
									relative.Position.Z
								).Magnitude

							local angle =
								math.atan2(
									relative.Position.Z,
									relative.Position.X
								) +
								t * 0.8

							local bob =
								math.sin(
									t * 2 +
									index
								) *
								0.7

							local pos =
								Vector3.new(
									math.cos(
										angle
									) *
										radius,

									relative.Position.Y +
										bob,

									math.sin(
										angle
									) *
										radius
								)

							part.CFrame =
								currentPivot *
								CFrame.new(pos) *
								CFrame.Angles(
									0,
									-angle,
									math.rad(18)
								)

						elseif part.Name ==
							"Glow"

							or string.match(
								part.Name,
								"GlowShell"
							) then

							local pulse =
								1 +
								math.sin(
									t * 3.5 +
									index
								) *
								0.12

							part.Size =
								effect.baseSize *
								pulse

							local light =
								part:FindFirstChildOfClass(
									"PointLight"
								)

							if light
								and effect.baseBrightness then

								light.Brightness =
									effect.baseBrightness *
									(
										0.88 +
										math.sin(
											t * 4 +
											index
										) *
										0.12
									)
							end
						end
					end
				end

				RunService.RenderStepped:Wait()
			end
		end
	)
end

--==================================================
-- BLOCKY EGG
--==================================================

local function makeBlockyEgg(
	parent,
	name,
	scale,
	baseColor,
	material
)
	local model =
		Instance.new("Model")

	model.Name = name
	model.Parent = parent

	local layers = {
		{
			y = -5.0,
			sx = 7.8,
			sy = 2.2,
			sz = 6.8
		},

		{
			y = -2.8,
			sx = 9.6,
			sy = 2.5,
			sz = 7.8
		},

		{
			y = 0.0,
			sx = 10.4,
			sy = 2.8,
			sz = 8.4
		},

		{
			y = 2.8,
			sx = 9.5,
			sy = 2.6,
			sz = 7.8
		},

		{
			y = 5.2,
			sx = 7.2,
			sy = 2.2,
			sz = 6.2
		},

		{
			y = 7.0,
			sx = 4.8,
			sy = 1.5,
			sz = 4.4
		},
	}

	local centerPart

	for i, layer in ipairs(
		layers
	) do

		local part =
			makePart(
				model,
				name ..
					"Block" ..
					i,

				Vector3.new(
					layer.sx,
					layer.sy,
					layer.sz
				) * scale,

				CFrame.new(
					0,
					layer.y * scale,
					0
				),

				baseColor,

				material or
					Enum.Material.SmoothPlastic
			)

		if i == 3 then
			centerPart =
				part
		end
	end

	model.PrimaryPart =
		centerPart

	return model, centerPart
end

local function addBlockyShellHighlight(model, color)
	local h =
		Instance.new("Highlight")

	h.Name =
		"BlockyShellGlow"

	h.Adornee =
		model

	h.FillColor =
		color

	h.FillTransparency =
		0.92

	h.OutlineColor =
		color

	h.OutlineTransparency =
		0.15

	h.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	h.Parent =
		model
end

--==================================================
-- AETHRON
--==================================================

local function createAethron()
	local model =
		Instance.new("Model")

	model.Name =
		"AethronEgg"

	model.Parent =
		eggFolder

	local blockyBody, center =
		makeBlockyEgg(
			model,
			"AethronCenter",
			EGG_SCALE * 0.78,
			COLORS.White,
			Enum.Material.SmoothPlastic
		)

	addBlockyShellHighlight(
		blockyBody,
		COLORS.BrightGold
	)

	model.PrimaryPart =
		center

	for i = -2, 2 do
		makePart(
			model,
			"GoldCenter",

			Vector3.new(
				1.35,
				9.5,
				0.65
			) * EGG_SCALE,

			CFrame.new(
				i * 1.35 *
					EGG_SCALE,

				0,

				-4.05 *
					EGG_SCALE
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					i * 7
				)
			),

			i == 0
				and COLORS.BrightGold
				or COLORS.Gold,

			Enum.Material.Neon
		)
	end

	addNeonSphere(
		model,
		"CenterGlow",

		Vector3.new(
			2.2,
			3.1,
			1.0
		) * EGG_SCALE,

		Vector3.new(
			0,
			-0.3 *
				EGG_SCALE,
			-4.35 *
				EGG_SCALE
		),

		COLORS.BrightGold
	)

	for i = 1, 7 do
		local x =
			-(4.8 +
				i * 1.25) *
			EGG_SCALE

		local y =
			(4.8 -
				i * 1.12) *
			EGG_SCALE

		makeFeather(
			model,

			Vector3.new(
				x,
				y,
				0
			),

			Vector3.new(
				3.3,
				7.5,
				2.1
			) * EGG_SCALE,

			i % 2 == 0
				and COLORS.BrightGold
				or COLORS.Gold,

			Vector3.new(
				0,
				0,
				-28
			)
		)
	end

	for i = 1, 7 do
		local x =
			(4.8 +
				i * 1.25) *
			EGG_SCALE

		local y =
			(4.8 -
				i * 1.12) *
			EGG_SCALE

		makeFeather(
			model,

			Vector3.new(
				x,
				y,
				0
			),

			Vector3.new(
				3.3,
				7.5,
				2.1
			) * EGG_SCALE,

			i % 2 == 0
				and COLORS.BrightRed
				or COLORS.DarkRed,

			Vector3.new(
				0,
				0,
				28
			)
		)
	end

	for side = -1, 1, 2 do
		for i = 1, 3 do
			makeFeather(
				model,

				Vector3.new(
					side *
						(4.0 +
							i * 0.8) *
						EGG_SCALE,

					(3.0 -
						i * 1.0) *
						EGG_SCALE,

					-0.7 *
						EGG_SCALE
				),

				Vector3.new(
					2.3,
					5.2,
					1.5
				) * EGG_SCALE,

				COLORS.White,

				Vector3.new(
					0,
					0,
					side * 24
				)
			)
		end
	end

	local halo =
		makeCylinder(
			model,
			"AethronHalo",

			Vector3.new(
				1.0,
				6.5,
				6.5
			) * EGG_SCALE,

			CFrame.new(
				0,
				11.5 *
					EGG_SCALE,
				0
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(90)
			),

			COLORS.BrightGold,

			Enum.Material.Neon
		)

	halo.Transparency =
		0.25

	local light =
		Instance.new("PointLight")

	light.Color =
		COLORS.BrightGold

	light.Brightness =
		2.6

	light.Range =
		18

	light.Shadows =
		false

	light.Parent =
		halo

	addHighlight(
		model,
		center,
		COLORS.BrightGold
	)

	addGlow(
		model,

		Vector3.new(
			0,
			1 *
				EGG_SCALE,
			0
		),

		COLORS.BrightGold,

		2.5,

		3
	)

	addGlowShell(
		model,

		Vector3.new(
			0,
			0,
			0
		),

		COLORS.BrightGold,

		5 *
			EGG_SCALE,

		7
	)

	addPulseRings(
		model,
		COLORS.BrightGold,
		EGG_SCALE *
			0.55
	)

	addOrbitRing(
		model,

		9.5 *
			EGG_SCALE,

		0,

		COLORS.BrightGold,

		0.28 *
			EGG_SCALE
	)

	addOrbitRing(
		model,

		11.0 *
			EGG_SCALE,

		3.2 *
			EGG_SCALE,

		COLORS.Red,

		0.18 *
			EGG_SCALE
	)

	for i = 1, 8 do
		local a =
			(i / 8) *
			math.pi *
			2

		addSpark(
			model,

			Vector3.new(
				math.cos(a) *
					8.5 *
					EGG_SCALE,

				(
					math.sin(a * 2) *
					3 +
					2
				) *
					EGG_SCALE,

				math.sin(a) *
					4.8 *
					EGG_SCALE
			),

			i % 2 == 0
				and COLORS.BrightGold
				or COLORS.BrightRed,

			0.42 *
				EGG_SCALE
		)
	end

	addGraphicPetals(
		model,
		10,

		8.0 *
			EGG_SCALE,

		7.0 *
			EGG_SCALE,

		COLORS.Gold,
		COLORS.Red
	)

	animateEggEffects(
		model
	)

	return model
end

--==================================================
-- KITSUNE
--==================================================

local function createKitsune()
	local model =
		Instance.new("Model")

	model.Name =
		"KitsuneEgg"

	model.Parent =
		eggFolder

	local blockyBody, center =
		makeBlockyEgg(
			model,
			"KitsuneCenter",
			EGG_SCALE * 0.82,
			COLORS.Cream,
			Enum.Material.SmoothPlastic
		)

	addBlockyShellHighlight(
		blockyBody,
		COLORS.HotPink
	)

	model.PrimaryPart =
		center

	local lowerFace =
		makeSphere(
			model,
			"GrayFace",

			Vector3.new(
				8.5,
				7.0,
				1.2
			) * EGG_SCALE,

			Vector3.new(
				0,
				-2.4 *
					EGG_SCALE,
				-4.0 *
					EGG_SCALE
			),

			COLORS.Gray,

			Enum.Material.SmoothPlastic
		)

	local faceMesh =
		Instance.new("SpecialMesh")

	faceMesh.MeshType =
		Enum.MeshType.Sphere

	faceMesh.Scale =
		Vector3.new(
			0.95,
			0.72,
			0.35
		)

	faceMesh.Parent =
		lowerFace

	addNeonSphere(
		model,
		"PinkTop",

		Vector3.new(
			6.5,
			3.2,
			5.8
		) * EGG_SCALE,

		Vector3.new(
			0,
			6.1 *
				EGG_SCALE,
			-0.1 *
				EGG_SCALE
		),

		COLORS.HotPink
	)

	local forehead =
		makePart(
			model,
			"PinkForehead",

			Vector3.new(
				4.3,
				4.8,
				1.0
			) * EGG_SCALE,

			CFrame.new(
				0,
				4.0 *
					EGG_SCALE,
				-4.25 *
					EGG_SCALE
			),

			COLORS.HotPink,

			Enum.Material.Neon
		)

	local foreheadMesh =
		Instance.new(
			"SpecialMesh"
		)

	foreheadMesh.MeshType =
		Enum.MeshType.Sphere

	foreheadMesh.Scale =
		Vector3.new(
			0.72,
			0.95,
			0.35
		)

	foreheadMesh.Parent =
		forehead

	makePart(
		model,
		"ForeheadDiamond",

		Vector3.new(
			1.5,
			1.5,
			0.45
		) * EGG_SCALE,

		CFrame.new(
			0,
			4.15 *
				EGG_SCALE,
			-4.85 *
				EGG_SCALE
		) *
		CFrame.Angles(
			0,
			0,
			math.rad(45)
		),

		COLORS.LightPink,

		Enum.Material.Neon
	)

	for side = -1, 1, 2 do
		makeWedge(
			model,
			"FoxEar",

			Vector3.new(
				4.4,
				7.5,
				3.6
			) * EGG_SCALE,

			CFrame.new(
				side *
					3.7 *
					EGG_SCALE,

				6.7 *
					EGG_SCALE,

				0
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					side * -10
				)
			),

			COLORS.HotPink,

			Enum.Material.Neon
		)

		makeWedge(
			model,
			"InnerEar",

			Vector3.new(
				2.1,
				4.5,
				1.8
			) * EGG_SCALE,

			CFrame.new(
				side *
					3.7 *
					EGG_SCALE,

				6.7 *
					EGG_SCALE,

				-1.5 *
					EGG_SCALE
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					side * -10
				)
			),

			COLORS.LightPink,

			Enum.Material.Neon
		)
	end

	for side = -1, 1, 2 do
		for i = 1, 4 do
			local x =
				side *
				(
					4.8 +
					i * 0.9
				) *
				EGG_SCALE

			local y =
				(
					-2.2 +
					i * 1.0
				) *
				EGG_SCALE

			local tail =
				makeSphere(
					model,
					"FoxTail",

					Vector3.new(
						3.0,
						5.0,
						3.0
					) * EGG_SCALE,

					Vector3.new(
						x,
						y,
						0.15 *
							EGG_SCALE
					),

					i % 2 == 0
						and COLORS.LightPink
						or COLORS.HotPink,

					Enum.Material.Neon
				)

			tail.Transparency =
				0.22

			local tailMesh =
				Instance.new(
					"SpecialMesh"
				)

			tailMesh.MeshType =
				Enum.MeshType.Sphere

			tailMesh.Scale =
				Vector3.new(
					0.7,
					1.25,
					0.65
				)

			tailMesh.Parent =
				tail
		end
	end

	for side = -1, 1, 2 do
		makePart(
			model,
			"FaceMark",

			Vector3.new(
				1.0,
				2.5,
				0.55
			) * EGG_SCALE,

			CFrame.new(
				side *
					2.0 *
					EGG_SCALE,

				-1.5 *
					EGG_SCALE,

				-4.6 *
					EGG_SCALE
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					side * 28
				)
			),

			COLORS.DarkGray,

			Enum.Material.SmoothPlastic
		)

		addNeonSphere(
			model,
			"Eye",

			Vector3.new(
				0.75,
				0.75,
				0.5
			) * EGG_SCALE,

			Vector3.new(
				side *
					1.9 *
					EGG_SCALE,

				1.0 *
					EGG_SCALE,

				-4.65 *
					EGG_SCALE
			),

			COLORS.DarkPink
		)
	end

	addHighlight(
		model,
		center,
		COLORS.HotPink
	)

	addGlow(
		model,

		Vector3.new(
			0,
			2 *
				EGG_SCALE,
			0
		),

		COLORS.HotPink,

		2.8,

		3.5
	)

	addGlowShell(
		model,

		Vector3.new(
			0,
			0,
			0
		),

		COLORS.HotPink,

		5 *
			EGG_SCALE,

		7
	)

	addPulseRings(
		model,
		COLORS.HotPink,
		EGG_SCALE *
			0.55
	)

	addOrbitRing(
		model,

		9.0 *
			EGG_SCALE,

		-1.0 *
			EGG_SCALE,

		COLORS.HotPink,

		0.28 *
			EGG_SCALE
	)

	addOrbitRing(
		model,

		10.2 *
			EGG_SCALE,

		3.8 *
			EGG_SCALE,

		COLORS.LightPink,

		0.16 *
			EGG_SCALE
	)

	for i = 1, 10 do
		local a =
			(i / 10) *
			math.pi *
			2

		addSpark(
			model,

			Vector3.new(
				math.cos(a) *
					8.0 *
					EGG_SCALE,

				3 *
					EGG_SCALE +
					math.sin(a * 3) *
					3 *
					EGG_SCALE,

				math.sin(a) *
					4.5 *
					EGG_SCALE
			),

			i % 2 == 0
				and COLORS.HotPink
				or COLORS.LightPink,

			0.38 *
				EGG_SCALE
		)
	end

	addGraphicPetals(
		model,
		8,

		7.3 *
			EGG_SCALE,

		7.4 *
			EGG_SCALE,

		COLORS.HotPink,
		COLORS.LightPink
	)

	animateEggEffects(
		model
	)

	return model
end

--==================================================
-- ARCHANGEL
-- REFERENCE DESIGN
-- NO EFFECTS
-- NO GLOW
-- NO RINGS
-- NO SPARKS
-- NO HIGHLIGHT
-- NO ANIMATION
--==================================================

local function createArchAngel()
	local model =
		Instance.new("Model")

	model.Name =
		"ArchAngelEgg"

	model.Parent =
		eggFolder

	--==================================================
	-- WHITE BLOCKY EGG BODY
	--==================================================

	local bodyLayers = {
		{
			y = -5.1,
			sx = 7.4,
			sy = 1.9,
			sz = 6.4,
		},

		{
			y = -3.2,
			sx = 9.6,
			sy = 2.4,
			sz = 7.7,
		},

		{
			y = -0.7,
			sx = 10.8,
			sy = 2.7,
			sz = 8.4,
		},

		{
			y = 2.0,
			sx = 10.0,
			sy = 2.5,
			sz = 7.9,
		},

		{
			y = 4.3,
			sx = 8.1,
			sy = 2.1,
			sz = 6.6,
		},

		{
			y = 6.0,
			sx = 6.0,
			sy = 1.7,
			sz = 5.2,
		},

		{
			y = 7.25,
			sx = 3.9,
			sy = 1.25,
			sz = 3.8,
		},
	}

	local centerPart

	for i, layer in ipairs(
		bodyLayers
	) do

		local part =
			makePart(
				model,

				"ArchAngelWhiteBlock" ..
					i,

				Vector3.new(
					layer.sx,
					layer.sy,
					layer.sz
				) * EGG_SCALE,

				CFrame.new(
					0,
					layer.y *
						EGG_SCALE,
					0
				),

				i % 2 == 0
					and Color3.fromRGB(
						239,
						239,
						244
					)
					or Color3.fromRGB(
						250,
						250,
						253
					),

				Enum.Material.SmoothPlastic
			)

		if i == 3 then
			centerPart =
				part
		end
	end

	model.PrimaryPart =
		centerPart

	--==================================================
	-- SUBTLE WHITE BLOCK SEAMS
	--==================================================

	local seamColor =
		Color3.fromRGB(
			218,
			220,
			228
		)

	for _, y in ipairs({
		-4.05,
		-1.95,
		0.65,
		3.15,
		5.15
	}) do

		makePart(
			model,

			"WhiteSeam",

			Vector3.new(
				8.8,
				0.10,
				6.9
			) * EGG_SCALE,

			CFrame.new(
				0,
				y *
					EGG_SCALE,
				-3.78 *
					EGG_SCALE
			),

			seamColor,

			Enum.Material.SmoothPlastic
		)
	end

	--==================================================
	-- GOLD COLORS
	--==================================================

	local goldDark =
		Color3.fromRGB(
			197,
			145,
			24
		)

	local gold =
		Color3.fromRGB(
			235,
			183,
			48
		)

	local goldLight =
		Color3.fromRGB(
			255,
			213,
			82
		)

	--==================================================
	-- GOLD CENTER STRIPE
	--==================================================

	makePart(
		model,

		"GoldCenterBottom",

		Vector3.new(
			1.35,
			3.0,
			0.48
		) * EGG_SCALE,

		CFrame.new(
			0,
			-4.0 *
				EGG_SCALE,
			-4.15 *
				EGG_SCALE
		),

		gold,

		Enum.Material.SmoothPlastic
	)

	makePart(
		model,

		"GoldCenterMiddle",

		Vector3.new(
			1.65,
			4.7,
			0.48
		) * EGG_SCALE,

		CFrame.new(
			0,
			-1.0 *
				EGG_SCALE,
			-4.45 *
				EGG_SCALE
		),

		goldLight,

		Enum.Material.SmoothPlastic
	)

	makePart(
		model,

		"GoldCenterTop",

		Vector3.new(
			1.05,
			2.5,
			0.48
		) * EGG_SCALE,

		CFrame.new(
			0,
			2.45 *
				EGG_SCALE,
			-4.15 *
				EGG_SCALE
		),

		gold,

		Enum.Material.SmoothPlastic
	)

	makePart(
		model,

		"GoldCenterHighlight",

		Vector3.new(
			0.34,
			3.8,
			0.12
		) * EGG_SCALE,

		CFrame.new(
			-0.28 *
				EGG_SCALE,

			-1.0 *
				EGG_SCALE,

			-4.74 *
				EGG_SCALE
		),

		goldLight,

		Enum.Material.SmoothPlastic
	)

	--==================================================
	-- GOLD TOP CAP
	--==================================================

	makePart(
		model,

		"GoldCrownLower",

		Vector3.new(
			6.3,
			1.55,
			5.5
		) * EGG_SCALE,

		CFrame.new(
			0,
			5.45 *
				EGG_SCALE,
			-0.25 *
				EGG_SCALE
		),

		gold,

		Enum.Material.SmoothPlastic
	)

	makePart(
		model,

		"GoldCrownMiddle",

		Vector3.new(
			5.0,
			1.6,
			4.5
		) * EGG_SCALE,

		CFrame.new(
			0,
			6.55 *
				EGG_SCALE,
			-0.15 *
				EGG_SCALE
		),

		goldLight,

		Enum.Material.SmoothPlastic
	)

	makePart(
		model,

		"GoldCrownUpper",

		Vector3.new(
			3.6,
			1.6,
			3.5
		) * EGG_SCALE,

		CFrame.new(
			0,
			7.7 *
				EGG_SCALE,
			-0.05 *
				EGG_SCALE
		),

		gold,

		Enum.Material.SmoothPlastic
	)

	--==================================================
	-- GOLD TOP SPIKE
	--==================================================

	makeWedge(
		model,

		"GoldTopSpikeLower",

		Vector3.new(
			3.2,
			2.8,
			2.8
		) * EGG_SCALE,

		CFrame.new(
			0,
			8.95 *
				EGG_SCALE,
			-0.05 *
				EGG_SCALE
		),

		goldLight,

		Enum.Material.SmoothPlastic
	)

	makeWedge(
		model,

		"GoldTopSpikeMiddle",

		Vector3.new(
			2.25,
			3.0,
			2.15
		) * EGG_SCALE,

		CFrame.new(
			0,
			10.55 *
				EGG_SCALE,
			-0.05 *
				EGG_SCALE
		),

		gold,

		Enum.Material.SmoothPlastic
	)

	makeWedge(
		model,

		"GoldTopSpike",

		Vector3.new(
			1.35,
			3.4,
			1.35
		) * EGG_SCALE,

		CFrame.new(
			0,
			12.35 *
				EGG_SCALE,
			-0.05 *
				EGG_SCALE
		),

		goldLight,

		Enum.Material.SmoothPlastic
	)

	--==================================================
	-- GOLD SIDE PIECES
	--==================================================

	for side = -1, 1, 2 do

		makePart(
			model,

			"GoldSideUpper",

			Vector3.new(
				1.8,
				3.8,
				2.3
			) * EGG_SCALE,

			CFrame.new(
				side *
					4.15 *
					EGG_SCALE,

				4.0 *
					EGG_SCALE,

				-0.05 *
					EGG_SCALE
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					side * -12
				)
			),

			gold,

			Enum.Material.SmoothPlastic
		)

		makePart(
			model,

			"GoldSideMiddle",

			Vector3.new(
				1.35,
				4.6,
				2.0
			) * EGG_SCALE,

			CFrame.new(
				side *
					4.7 *
					EGG_SCALE,

				1.7 *
					EGG_SCALE,

				-0.05 *
					EGG_SCALE
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					side * -18
				)
			),

			goldDark,

			Enum.Material.SmoothPlastic
		)

		makePart(
			model,

			"GoldSideLower",

			Vector3.new(
				1.0,
				3.0,
				1.7
			) * EGG_SCALE,

			CFrame.new(
				side *
					4.95 *
					EGG_SCALE,

				-1.0 *
					EGG_SCALE,

				-0.05 *
					EGG_SCALE
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					side * -22
				)
			),

			gold,

			Enum.Material.SmoothPlastic
		)
	end

	--==================================================
	-- SMALL GOLD TOP SIDE SPIKES
	--==================================================

	for side = -1, 1, 2 do

		makeWedge(
			model,

			"GoldSideSpike",

			Vector3.new(
				1.25,
				3.4,
				1.5
			) * EGG_SCALE,

			CFrame.new(
				side *
					2.8 *
					EGG_SCALE,

				8.2 *
					EGG_SCALE,

				-0.10 *
					EGG_SCALE
			) *
			CFrame.Angles(
				0,
				0,
				math.rad(
					side * -18
				)
			),

			goldLight,

			Enum.Material.SmoothPlastic
		)
	end

	--==================================================
	-- IMPORTANT:
	-- ARCHANGEL HAS ZERO EFFECTS
	--==================================================

	return model
end

--==================================================
-- GROUND POSITION
--==================================================

local function getGroundPosition(
	position,
	eggHeight
)
	local rayParams =
		RaycastParams.new()

	rayParams.FilterType =
		Enum.RaycastFilterType.Exclude

	rayParams.FilterDescendantsInstances = {
		player.Character,
		eggFolder
	}

	rayParams.IgnoreWater = true

	local result =
		Workspace:Raycast(
			position +
				Vector3.new(
					0,
					120,
					0
				),

			Vector3.new(
				0,
				-300,
				0
			),

			rayParams
		)

	if result then
		return Vector3.new(
			position.X,

			result.Position.Y +
				eggHeight / 2 +
				1,

			position.Z
		)
	end

	return position
end

--==================================================
-- PICKUP / DROP
--==================================================

local carriedEgg = nil
local carryConnection = nil
local dropLockedUntil = 0

--==================================================
-- DROP GUI
--==================================================

local dropGui =
	Instance.new("ScreenGui")

dropGui.Name =
	"EggDropGui"

dropGui.ResetOnSpawn = false
dropGui.Parent = playerGui

local dropText =
	Instance.new("TextLabel")

dropText.Name =
	"DropText"

dropText.Size =
	UDim2.fromOffset(
		220,
		45
	)

dropText.Position =
	UDim2.new(
		0.5,
		-110,
		0.82,
		0
	)

dropText.BackgroundColor3 =
	Color3.fromRGB(
		20,
		20,
		25
	)

dropText.BackgroundTransparency =
	0.15

dropText.Text =
	"E  TO  DROP"

dropText.Font =
	Enum.Font.GothamBold

dropText.TextSize =
	20

dropText.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

dropText.Visible =
	false

dropText.Parent =
	dropGui

local dropCorner =
	Instance.new("UICorner")

dropCorner.CornerRadius =
	UDim.new(
		0,
		10
	)

dropCorner.Parent =
	dropText

local dropStroke =
	Instance.new("UIStroke")

dropStroke.Thickness =
	2

dropStroke.Color =
	Color3.new(
		1,
		1,
		1
	)

dropStroke.Parent =
	dropText

--==================================================
-- PICKUP PROMPT
--==================================================

local pickupEgg

local function createPickupPrompt(egg)
	if not egg
		or not egg.Parent then
		return
	end

	local primary =
		egg.PrimaryPart

	if not primary
		or not primary:IsA("BasePart") then
		return
	end

	primary.CanQuery = true
	primary.CanTouch = true

	for _, object in ipairs(
		egg:GetDescendants()
	) do
		if object:IsA(
			"ProximityPrompt"
		) then
			object:Destroy()
		end
	end

	local prompt =
		Instance.new(
			"ProximityPrompt"
		)

	prompt.Name =
		"PickupEgg"

	prompt.ActionText =
		"Pick Up"

	prompt.ObjectText =
		egg.Name

	prompt.KeyboardKeyCode =
		Enum.KeyCode.E

	prompt.HoldDuration =
		2

	prompt.MaxActivationDistance =
		PICKUP_DISTANCE

	prompt.RequiresLineOfSight =
		false

	prompt.Style =
		Enum.ProximityPromptStyle.Default

	prompt.Enabled =
		true

	prompt.Parent =
		primary

	prompt.Triggered:Connect(
		function(
			triggeringPlayer
		)
			if triggeringPlayer ~=
				player then
				return
			end

			if carriedEgg then
				return
			end

			pickupEgg(
				egg,
				prompt
			)
		end
	)

	return prompt
end

--==================================================
-- PICKUP EGG
--==================================================

pickupEgg =
	function(
		egg,
		prompt
	)
		if carriedEgg then
			return
		end

		if not egg
			or not egg.Parent then
			return
		end

		local character =
			player.Character

		if not character then
			return
		end

		local root =
			character:FindFirstChild(
				"HumanoidRootPart"
			)

		if not root then
			return
		end

		carriedEgg =
			egg

		dropLockedUntil =
			os.clock() +
			0.6

		for _, object in ipairs(
			egg:GetDescendants()
		) do
			if object:IsA(
				"ProximityPrompt"
			) then

				object.Enabled =
					false

				object:Destroy()
			end
		end

		dropText.Visible =
			true

		if carryConnection then
			carryConnection:Disconnect()
			carryConnection = nil
		end

		carryConnection =
			RunService.RenderStepped:Connect(
				function()

					if not carriedEgg
						or not carriedEgg.Parent then

						if carryConnection then
							carryConnection:Disconnect()
							carryConnection = nil
						end

						dropText.Visible =
							false

						carriedEgg =
							nil

						return
					end

					local currentCharacter =
						player.Character

					if not currentCharacter then
						return
					end

					local currentRoot =
						currentCharacter:FindFirstChild(
							"HumanoidRootPart"
						)

					if not currentRoot then
						return
					end

					local carryPosition =
						currentRoot.Position +

						currentRoot.CFrame.LookVector *
						4 +

						Vector3.new(
							0,
							1.5,
							0
						)

					carriedEgg:PivotTo(
						CFrame.new(
							carryPosition
						)
					)
				end
			)
	end

--==================================================
-- DROP EGG
--==================================================

local function dropEgg()
	if not carriedEgg then
		return
	end

	if os.clock() <
		dropLockedUntil then
		return
	end

	local egg =
		carriedEgg

	carriedEgg =
		nil

	if carryConnection then
		carryConnection:Disconnect()
		carryConnection = nil
	end

	dropText.Visible =
		false

	if not egg
		or not egg.Parent then
		return
	end

	local character =
		player.Character

	local root =
		character
		and character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		createPickupPrompt(
			egg
		)

		return
	end

	local _, size =
		egg:GetBoundingBox()

	local dropPosition =
		root.Position +

		root.CFrame.LookVector *
		5

	local ground =
		getGroundPosition(
			dropPosition,
			size.Y
		)

	egg:PivotTo(
		CFrame.new(
			ground
		)
	)

	task.defer(
		function()
			if egg
				and egg.Parent then

				createPickupPrompt(
					egg
				)
			end
		end
	)
end

--==================================================
-- E TO DROP
--==================================================

UserInputService.InputBegan:Connect(
	function(
		input,
		gameProcessed
	)

		if gameProcessed then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode ==
			Enum.KeyCode.E then

			if carriedEgg
				and os.clock() >=
				dropLockedUntil then

				dropEgg()
			end
		end
	end
)

--==================================================
-- SPAWN EGG
--==================================================

local function spawnEgg(
	eggType
)
	if carriedEgg then
		return
	end

	local character =
		player.Character

	if not character then
		return
	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return
	end

	local front =
		root.Position +

		root.CFrame.LookVector *
		SPAWN_DISTANCE

	local model

	if eggType ==
		"Aethron" then

		model =
			createAethron()

	elseif eggType ==
		"Kitsune" then

		model =
			createKitsune()

	elseif eggType ==
		"ArchAngel" then

		model =
			createArchAngel()
	end

	if not model then
		return
	end

	local _, size =
		model:GetBoundingBox()

	local ground =
		getGroundPosition(
			front,
			size.Y
		)

	local start =
		ground +

		Vector3.new(
			0,
			SKY_HEIGHT,
			0
		)

	local startCFrame =
		CFrame.new(start)

	local endCFrame =
		CFrame.new(ground)

	model:PivotTo(
		startCFrame
	)

	local cframeValue =
		Instance.new(
			"CFrameValue"
		)

	cframeValue.Value =
		startCFrame

	cframeValue.Parent =
		model

	local connection

	connection =
		cframeValue:GetPropertyChangedSignal(
			"Value"
		):Connect(
			function()

				if model.Parent then
					model:PivotTo(
						cframeValue.Value
					)
				end
			end
		)

	local tweenInfo =
		TweenInfo.new(
			1.15,
			Enum.EasingStyle.Bounce,
			Enum.EasingDirection.Out
		)

	local tween =
		TweenService:Create(
			cframeValue,
			tweenInfo,
			{
				Value =
					endCFrame
			}
		)

	tween:Play()

	tween.Completed:Connect(
		function()

			if connection then
				connection:Disconnect()
				connection = nil
			end

			if model.Parent then
				model:PivotTo(
					endCFrame
				)

				if model.PrimaryPart then
					model.PrimaryPart.CanQuery =
						true

					model.PrimaryPart.CanTouch =
						true
				end

				createPickupPrompt(
					model
				)
			end

			if cframeValue then
				cframeValue:Destroy()
			end
		end
	)
end

--==================================================
-- GUI
--==================================================

local gui =
	Instance.new("ScreenGui")

gui.Name =
	"StealAnEggDeveloperMenu"

gui.ResetOnSpawn =
	false

gui.Parent =
	playerGui

local frame =
	Instance.new("Frame")

frame.Name =
	"MainFrame"

frame.Size =
	UDim2.fromOffset(
		330,
		385
	)

frame.Position =
	UDim2.new(
		0.5,
		-165,
		0.5,
		-192
	)

frame.BorderSizePixel =
	0

frame.BackgroundColor3 =
	Color3.fromRGB(
		255,
		0,
		0
	)

frame.Parent =
	gui

local frameCorner =
	Instance.new("UICorner")

frameCorner.CornerRadius =
	UDim.new(
		0,
		15
	)

frameCorner.Parent =
	frame

--==================================================
-- TITLE BAR
--==================================================

local titleBar =
	Instance.new("Frame")

titleBar.Size =
	UDim2.new(
		1,
		0,
		0,
		55
	)

titleBar.BackgroundTransparency =
	1

titleBar.Parent =
	frame

local title =
	Instance.new("TextLabel")

title.Size =
	UDim2.fromScale(
		1,
		1
	)

title.BackgroundTransparency =
	1

title.Text =
	"🌈 DEVELOPER MENU"

title.Font =
	Enum.Font.GothamBold

title.TextSize =
	21

title.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

title.Parent =
	titleBar

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(
	text,
	y
)
	local button =
		Instance.new(
			"TextButton"
		)

	button.Size =
		UDim2.new(
			0.86,
			0,
			0,
			48
		)

	button.Position =
		UDim2.new(
			0.07,
			0,
			0,
			y
		)

	button.BackgroundColor3 =
		Color3.fromRGB(
			25,
			25,
			30
		)

	button.BackgroundTransparency =
		0.05

	button.Text =
		text

	button.Font =
		Enum.Font.GothamBold

	button.TextSize =
		15

	button.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	button.AutoButtonColor =
		false

	button.Parent =
		frame

	local corner =
		Instance.new(
			"UICorner"
		)

	corner.CornerRadius =
		UDim.new(
			0,
			9
		)

	corner.Parent =
		button

	return button
end

--==================================================
-- BUTTONS
--==================================================

local developerButton =
	createButton(
		"👑 CO-DEVELOPER: ON",
		60
	)

local aethronButton =
	createButton(
		"Spawn Aethron Egg",
		115
	)

local kitsuneButton =
	createButton(
		"Spawn Kitsune Egg",
		170
	)

local archAngelButton =
	createButton(
		"Spawn ArchAngel Egg",
		225
	)

--==================================================
-- SCREEN MESSAGE SECTION
--==================================================

local messageTitle =
	Instance.new("TextLabel")

messageTitle.Size =
	UDim2.new(
		0.86,
		0,
		0,
		24
	)

messageTitle.Position =
	UDim2.new(
		0.07,
		0,
		0,
		286
	)

messageTitle.BackgroundTransparency =
	1

messageTitle.Text =
	"SCREEN MESSAGE"

messageTitle.Font =
	Enum.Font.GothamBold

messageTitle.TextSize =
	13

messageTitle.TextXAlignment =
	Enum.TextXAlignment.Left

messageTitle.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

messageTitle.Parent =
	frame

local messageInput =
	Instance.new("TextBox")

messageInput.Size =
	UDim2.new(
		0.61,
		0,
		0,
		42
	)

messageInput.Position =
	UDim2.new(
		0.07,
		0,
		0,
		316
	)

messageInput.BackgroundColor3 =
	Color3.fromRGB(
		25,
		25,
		30
	)

messageInput.BackgroundTransparency =
	0.05

messageInput.BorderSizePixel =
	0

messageInput.ClearTextOnFocus =
	false

messageInput.Text =
	""

messageInput.PlaceholderText =
	"Type a message..."

messageInput.PlaceholderColor3 =
	Color3.fromRGB(
		150,
		150,
		150
	)

messageInput.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

messageInput.TextSize =
	13

messageInput.Font =
	Enum.Font.Gotham

messageInput.TextXAlignment =
	Enum.TextXAlignment.Left

messageInput.Parent =
	frame

local messageInputCorner =
	Instance.new("UICorner")

messageInputCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

messageInputCorner.Parent =
	messageInput

local messageInputPadding =
	Instance.new("UIPadding")

messageInputPadding.PaddingLeft =
	UDim.new(
		0,
		12
	)

messageInputPadding.PaddingRight =
	UDim.new(
		0,
		10
	)

messageInputPadding.Parent =
	messageInput

local showMessageButton =
	Instance.new("TextButton")

showMessageButton.Size =
	UDim2.new(
		0.22,
		0,
		0,
		42
	)

showMessageButton.Position =
	UDim2.new(
		0.71,
		0,
		0,
		316
	)

showMessageButton.BackgroundColor3 =
	Color3.fromRGB(
		25,
		25,
		30
	)

showMessageButton.BackgroundTransparency =
	0.05

showMessageButton.BorderSizePixel =
	0

showMessageButton.Text =
	"SHOW"

showMessageButton.Font =
	Enum.Font.GothamBold

showMessageButton.TextSize =
	13

showMessageButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

showMessageButton.AutoButtonColor =
	false

showMessageButton.Parent =
	frame

local showMessageCorner =
	Instance.new("UICorner")

showMessageCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

showMessageCorner.Parent =
	showMessageButton

local messageHint =
	Instance.new("TextLabel")

messageHint.Size =
	UDim2.new(
		0.86,
		0,
		0,
		18
	)

messageHint.Position =
	UDim2.new(
		0.07,
		0,
		0,
		360
	)

messageHint.BackgroundTransparency =
	1

messageHint.Text =
	"Shows at the top for 4.5 seconds"

messageHint.Font =
	Enum.Font.Gotham

messageHint.TextSize =
	9

messageHint.TextXAlignment =
	Enum.TextXAlignment.Left

messageHint.TextColor3 =
	Color3.fromRGB(
		175,
		175,
		175
	)

messageHint.Parent =
	frame

--==================================================
-- SCREEN MESSAGE
--==================================================

local messageGui =
	Instance.new(
		"ScreenGui"
	)

messageGui.Name =
	"EggVisualMessageGui"

messageGui.ResetOnSpawn =
	false

messageGui.IgnoreGuiInset =
	true

messageGui.DisplayOrder =
	100

messageGui.Parent =
	playerGui

local messageFrame =
	Instance.new("Frame")

messageFrame.Name =
	"MessageFrame"

messageFrame.AnchorPoint =
	Vector2.new(
		0.5,
		0
	)

messageFrame.Size =
	UDim2.fromOffset(
		560,
		88
	)

messageFrame.Position =
	UDim2.new(
		0.5,
		0,
		0,
		-110
	)

messageFrame.BackgroundColor3 =
	Color3.fromRGB(
		18,
		20,
		26
	)

messageFrame.BackgroundTransparency =
	0.04

messageFrame.BorderSizePixel =
	0

messageFrame.Parent =
	messageGui

local messageCorner =
	Instance.new("UICorner")

messageCorner.CornerRadius =
	UDim.new(
		0,
		14
	)

messageCorner.Parent =
	messageFrame

local messageStroke =
	Instance.new("UIStroke")

messageStroke.Thickness =
	2

messageStroke.Color =
	Color3.fromRGB(
		65,
		65,
		75
	)

messageStroke.Transparency =
	0.15

messageStroke.Parent =
	messageFrame

local messageAccent =
	Instance.new("Frame")

messageAccent.Size =
	UDim2.fromOffset(
		4,
		62
	)

messageAccent.Position =
	UDim2.fromOffset(
		8,
		13
	)

messageAccent.BackgroundColor3 =
	Color3.fromRGB(
		255,
		190,
		25
	)

messageAccent.BorderSizePixel =
	0

messageAccent.Parent =
	messageFrame

local messageAccentCorner =
	Instance.new("UICorner")

messageAccentCorner.CornerRadius =
	UDim.new(
		0,
		3
	)

messageAccentCorner.Parent =
	messageAccent

--==================================================
-- FACE-ONLY REAL ROBLOX AVATAR
--==================================================

local avatarImage =
	Instance.new("ImageLabel")

avatarImage.Name =
	"ActualRobloxFace"

avatarImage.Size =
	UDim2.fromOffset(
		66,
		66
	)

avatarImage.Position =
	UDim2.fromOffset(
		18,
		11
	)

avatarImage.BackgroundColor3 =
	Color3.fromRGB(
		30,
		30,
		37
	)

avatarImage.BackgroundTransparency =
	0

avatarImage.BorderSizePixel =
	0

avatarImage.Image =
	""

avatarImage.ScaleType =
	Enum.ScaleType.Crop

avatarImage.Parent =
	messageFrame

local avatarCorner =
	Instance.new("UICorner")

avatarCorner.CornerRadius =
	UDim.new(
		0,
		12
	)

avatarCorner.Parent =
	avatarImage

local avatarStroke =
	Instance.new("UIStroke")

avatarStroke.Thickness =
	1

avatarStroke.Color =
	Color3.fromRGB(
		70,
		70,
		80
	)

avatarStroke.Transparency =
	0.15

avatarStroke.Parent =
	avatarImage

local function updateMessageAvatar()
	task.spawn(
		function()

			local success, image =
				pcall(
					function()

						local content =
							Players:GetUserThumbnailAsync(
								player.UserId,

								Enum.ThumbnailType.HeadShot,

								Enum.ThumbnailSize.Size150x150
							)

						return content
					end
				)

			if success
				and image then

				avatarImage.Image =
					image
			end
		end
	)
end

updateMessageAvatar()

--==================================================
-- REAL ROBLOX USERNAME
--==================================================

local messageName =
	Instance.new("TextLabel")

messageName.Name =
	"Username"

messageName.Size =
	UDim2.new(
		1,
		-110,
		0,
		20
	)

messageName.Position =
	UDim2.fromOffset(
		98,
		12
	)

messageName.BackgroundTransparency =
	1

messageName.Text =
	player.Name ..
	":"

messageName.Font =
	Enum.Font.GothamBold

messageName.TextSize =
	13

messageName.TextXAlignment =
	Enum.TextXAlignment.Left

messageName.TextColor3 =
	Color3.fromRGB(
		255,
		210,
		60
	)

messageName.Parent =
	messageFrame

local messageText =
	Instance.new("TextLabel")

messageText.Name =
	"Message"

messageText.Size =
	UDim2.new(
		1,
		-112,
		0,
		42
	)

messageText.Position =
	UDim2.fromOffset(
		98,
		33
	)

messageText.BackgroundTransparency =
	1

messageText.Text =
	""

messageText.Font =
	Enum.Font.GothamMedium

messageText.TextSize =
	16

messageText.TextWrapped =
	true

messageText.TextXAlignment =
	Enum.TextXAlignment.Left

messageText.TextYAlignment =
	Enum.TextYAlignment.Center

messageText.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

messageText.Parent =
	messageFrame

local messageToken =
	0

local function showScreenMessage(text)
	messageToken += 1

	local thisToken =
		messageToken

	messageName.Text =
		player.Name ..
		":"

	messageText.Text =
		tostring(text)

	updateMessageAvatar()

	messageFrame.Position =
		UDim2.new(
			0.5,
			0,
			0,
			-110
		)

	messageFrame.BackgroundTransparency =
		1

	messageName.TextTransparency =
		1

	messageText.TextTransparency =
		1

	messageAccent.BackgroundTransparency =
		1

	avatarImage.ImageTransparency =
		1

	local slideIn =
		TweenService:Create(
			messageFrame,

			TweenInfo.new(
				0.45,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			),

			{
				Position =
					UDim2.new(
						0.5,
						0,
						0,
						18
					),

				BackgroundTransparency =
					0.04,
			}
		)

	local nameIn =
		TweenService:Create(
			messageName,

			TweenInfo.new(
				0.3
			),

			{
				TextTransparency =
					0
			}
		)

	local textIn =
		TweenService:Create(
			messageText,

			TweenInfo.new(
				0.35
			),

			{
				TextTransparency =
					0
			}
		)

	local accentIn =
		TweenService:Create(
			messageAccent,

			TweenInfo.new(
				0.25
			),

			{
				BackgroundTransparency =
					0
			}
		)

	local avatarIn =
		TweenService:Create(
			avatarImage,

			TweenInfo.new(
				0.25
			),

			{
				ImageTransparency =
					0
			}
		)

	slideIn:Play()
	nameIn:Play()
	textIn:Play()
	accentIn:Play()
	avatarIn:Play()

	task.delay(
		MESSAGE_DURATION,
		function()

			if thisToken ~=
				messageToken then
				return
			end

			local slideOut =
				TweenService:Create(
					messageFrame,

					TweenInfo.new(
						0.4,
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.In
					),

					{
						Position =
							UDim2.new(
								0.5,
								0,
								0,
								-110
							),

						BackgroundTransparency =
							1,
					}
				)

			local nameOut =
				TweenService:Create(
					messageName,

					TweenInfo.new(
						0.25
					),

					{
						TextTransparency =
							1
					}
				)

			local textOut =
				TweenService:Create(
					messageText,

					TweenInfo.new(
						0.25
					),

					{
						TextTransparency =
							1
					}
				)

			local accentOut =
				TweenService:Create(
					messageAccent,

					TweenInfo.new(
						0.2
					),

					{
						BackgroundTransparency =
							1
					}
				)

			local avatarOut =
				TweenService:Create(
					avatarImage,

					TweenInfo.new(
						0.2
					),

					{
						ImageTransparency =
							1
					}
				)

			slideOut:Play()
			nameOut:Play()
			textOut:Play()
			accentOut:Play()
			avatarOut:Play()
		end
	)
end

--==================================================
-- MESSAGE BUTTON
--==================================================

showMessageButton.MouseButton1Click:Connect(
	function()

		local text =
			messageInput.Text

		if not text then
			return
		end

		text =
			text:gsub(
				"^%s+",
				""
			)

		text =
			text:gsub(
				"%s+$",
				""
			)

		if text == "" then
			return
		end

		showScreenMessage(
			text
		)

		messageInput.Text =
			""
	end
)

messageInput.FocusLost:Connect(
	function(
		enterPressed
	)

		if enterPressed then

			local text =
				messageInput.Text

			if text then

				text =
					text:gsub(
						"^%s+",
						""
					)

				text =
					text:gsub(
						"%s+$",
						""
					)
			end

			if text
				and text ~= "" then

				showScreenMessage(
					text
				)

				messageInput.Text =
					""
			end
		end
	end
)

--==================================================
-- CO-DEVELOPER OVERHEAD TAG
--==================================================

local coDeveloperEnabled =
	true

local developerTag = nil

local function removeCoDeveloperTag()
	if developerTag then
		developerTag:Destroy()
		developerTag = nil
	end

	local character =
		player.Character

	if character then

		local oldTag =
			character:FindFirstChild(
				"CoDeveloperTag"
			)

		if oldTag then
			oldTag:Destroy()
		end
	end
end

local function createCoDeveloperTag()
	if not coDeveloperEnabled then
		removeCoDeveloperTag()
		return
	end

	local character =
		player.Character

	if not character then
		return
	end

	local head =
		character:FindFirstChild(
			"Head"
		)

	if not head then
		return
	end

	removeCoDeveloperTag()

	local billboard =
		Instance.new(
			"BillboardGui"
		)

	billboard.Name =
		"CoDeveloperTag"

	billboard.Adornee =
		head

	billboard.Size =
		UDim2.fromOffset(
			260,
			55
		)

	billboard.StudsOffset =
		Vector3.new(
			0,
			3.5,
			0
		)

	billboard.AlwaysOnTop =
		true

	billboard.MaxDistance =
		100

	billboard.ResetOnSpawn =
		false

	billboard.Parent =
		head

	local text =
		Instance.new(
			"TextLabel"
		)

	text.Name =
		"TagText"

	text.Size =
		UDim2.fromScale(
			1,
			1
		)

	text.BackgroundTransparency =
		1

	text.Text =
		"👑 CO-DEVELOPER"

	text.Font =
		Enum.Font.GothamBold

	text.TextScaled =
		true

	text.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	text.TextStrokeTransparency =
		0

	text.TextStrokeColor3 =
		Color3.fromRGB(
			0,
			0,
			0
		)

	text.Parent =
		billboard

	developerTag =
		billboard
end

developerButton.MouseButton1Click:Connect(
	function()

		coDeveloperEnabled =
			not coDeveloperEnabled

		if coDeveloperEnabled then

			developerButton.Text =
				"👑 CO-DEVELOPER: ON"

			createCoDeveloperTag()

		else

			developerButton.Text =
				"👑 CO-DEVELOPER: OFF"

			removeCoDeveloperTag()
		end
	end
)

--==================================================
-- CHARACTER RESPAWN
--==================================================

player.CharacterAdded:Connect(
	function(character)

		if carryConnection then
			carryConnection:Disconnect()
			carryConnection = nil
		end

		carriedEgg =
			nil

		dropText.Visible =
			false

		local head =
			character:WaitForChild(
				"Head",
				10
			)

		if head
			and coDeveloperEnabled then

			task.wait(0.25)

			createCoDeveloperTag()
		end

		task.wait(0.5)

		updateMessageAvatar()
	end
)

--==================================================
-- SPAWN BUTTONS
--==================================================

aethronButton.MouseButton1Click:Connect(
	function()

		if coDeveloperEnabled then
			spawnEgg(
				"Aethron"
			)
		end
	end
)

kitsuneButton.MouseButton1Click:Connect(
	function()

		if coDeveloperEnabled then
			spawnEgg(
				"Kitsune"
			)
		end
	end
)

archAngelButton.MouseButton1Click:Connect(
	function()

		if coDeveloperEnabled then
			spawnEgg(
				"ArchAngel"
			)
		end
	end
)

--==================================================
-- DRAGGING
--==================================================

local dragging =
	false

local dragStart
local startPosition

titleBar.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			dragging =
				true

			dragStart =
				input.Position

			startPosition =
				frame.Position
		end
	end
)

titleBar.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			dragging =
				false
		end
	end
)

UserInputService.InputChanged:Connect(
	function(input)

		if not dragging then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.MouseMovement then

			return
		end

		local delta =
			input.Position -
			dragStart

		frame.Position =
			UDim2.new(
				startPosition.X.Scale,

				startPosition.X.Offset +
					delta.X,

				startPosition.Y.Scale,

				startPosition.Y.Offset +
					delta.Y
			)
	end
)

--==================================================
-- DEV MENU BUTTON
--==================================================

local menuToggleGui =
	Instance.new(
		"ScreenGui"
	)

menuToggleGui.Name =
	"DevMenuToggle"

menuToggleGui.ResetOnSpawn =
	false

menuToggleGui.Parent =
	playerGui

local menuToggle =
	Instance.new(
		"TextButton"
	)

menuToggle.Name =
	"MenuToggle"

menuToggle.Size =
	UDim2.fromOffset(
		145,
		42
	)

menuToggle.Position =
	UDim2.fromOffset(
		15,
		15
	)

menuToggle.BackgroundColor3 =
	Color3.fromRGB(
		25,
		25,
		30
	)

menuToggle.BackgroundTransparency =
	0.05

menuToggle.Text =
	"👑 DEV MENU"

menuToggle.Font =
	Enum.Font.GothamBold

menuToggle.TextSize =
	16

menuToggle.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

menuToggle.AutoButtonColor =
	false

menuToggle.Parent =
	menuToggleGui

local menuToggleCorner =
	Instance.new(
		"UICorner"
	)

menuToggleCorner.CornerRadius =
	UDim.new(
		0,
		10
	)

menuToggleCorner.Parent =
	menuToggle

local menuToggleStroke =
	Instance.new(
		"UIStroke"
	)

menuToggleStroke.Thickness =
	2

menuToggleStroke.Parent =
	menuToggle

menuToggle.MouseButton1Click:Connect(
	function()

		frame.Visible =
			not frame.Visible
	end
)

--==================================================
-- K TO OPEN / CLOSE
--==================================================

UserInputService.InputBegan:Connect(
	function(
		input,
		gameProcessed
	)

		if gameProcessed then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Keyboard then

			return
		end

		if input.KeyCode ==
			Enum.KeyCode.K then

			frame.Visible =
				not frame.Visible
		end
	end
)

--==================================================
-- RAINBOW EFFECT
--==================================================

local hue = 0

RunService.RenderStepped:Connect(
	function(
		deltaTime
	)

		hue =
			(
				hue +
				deltaTime *
				0.15
			) % 1

		local rainbow =
			Color3.fromHSV(
				hue,
				1,
				1
			)

		frame.BackgroundColor3 =
			rainbow

		title.TextColor3 =
			rainbow

		developerButton.TextColor3 =
			rainbow

		aethronButton.TextColor3 =
			rainbow

		kitsuneButton.TextColor3 =
			rainbow

		archAngelButton.TextColor3 =
			rainbow

		menuToggleStroke.Color =
			rainbow
	end
)

--==================================================
-- START CO-DEVELOPER TAG
--==================================================

task.defer(
	function()

		createCoDeveloperTag()

		updateMessageAvatar()
	end
)

--==================================================
-- AUTO OPEN
--==================================================

frame.Visible =
	true
