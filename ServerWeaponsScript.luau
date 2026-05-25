local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local curWeaponsSystemFolder = script.Parent
local weaponsSystemFolder = ReplicatedStorage:FindFirstChild("WeaponsSystem")
local weaponsSystemInitialized = false

local function initializeWeaponsSystemAssets()
	if not weaponsSystemInitialized then
		print("?? [WEAPONS SYSTEM SERVIDOR] Inicializando assets visuales (partículas, agujeros de bala)...")
		local effectsFolder = weaponsSystemFolder.Assets.Effects
		local partNonZeroTransparencyValues = {
			["BulletHole"] = 1, ["Explosion"] = 1, ["Pellet"] = 1, ["Scorch"] = 1,
			["Bullet"] = 1, ["Plasma"] = 1, ["Railgun"] = 1,
		}
		local decalNonZeroTransparencyValues = { ["ScorchMark"] = 0.25 }
		local particleEmittersToDisable = { ["Smoke"] = true }
		local imageLabelNonZeroTransparencyValues = { ["Impact"] = 0.25 }

		for _, descendant in pairs(effectsFolder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				if partNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.Transparency = partNonZeroTransparencyValues[descendant.Name]
				else
					descendant.Transparency = 0
				end
			elseif descendant:IsA("Decal") then
				descendant.Transparency = 0
				if decalNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.Transparency = decalNonZeroTransparencyValues[descendant.Name]
				else
					descendant.Transparency = 0
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
				if particleEmittersToDisable[descendant.Name] ~= nil then
					descendant.Enabled = false
				else
					descendant.Enabled = true
				end
			elseif descendant:IsA("ImageLabel") then
				if imageLabelNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.ImageTransparency = imageLabelNonZeroTransparencyValues[descendant.Name]
				else
					descendant.ImageTransparency = 0
				end
			end
		end

		weaponsSystemInitialized = true
		print("? [WEAPONS SYSTEM SERVIDOR] Assets inicializados correctamente.")
	end
end

if weaponsSystemFolder == nil then
	print("?? [WEAPONS SYSTEM SERVIDOR] Creando carpeta WeaponsSystem en ReplicatedStorage...")
	weaponsSystemFolder = curWeaponsSystemFolder:Clone()
	initializeWeaponsSystemAssets()
	weaponsSystemFolder.Parent = ReplicatedStorage
end

if ServerScriptService:FindFirstChild("ServerWeaponsScript") == nil then
	script.Parent = ServerScriptService
	initializeWeaponsSystemAssets()

	local WeaponsSystem = require(weaponsSystemFolder.WeaponsSystem)
	if not WeaponsSystem.doingSetup and not WeaponsSystem.didSetup then
		print("?? [WEAPONS SYSTEM SERVIDOR] Configurando módulo principal (setup)...")
		WeaponsSystem.setup()
	end
	-- ?? AQUÍ ESTÁN LOS PRINTS PARA RASTREAR LA UI ??
	local function setupClientWeaponsScript(player)
		print("?? [WEAPONS SYSTEM] Intentando entregar UI nativa al jugador: " .. player.Name)

		-- Le damos un microsegundo para que su PlayerGui exista realmente
		local playerGui = player:WaitForChild("PlayerGui", 5)
		if not playerGui then
			warn("? [WEAPONS SYSTEM] Error: No se encontró el PlayerGui de " .. player.Name)
			return
		end

		local clientWeaponsScript = playerGui:FindFirstChild("ClientWeaponsScript")

		if clientWeaponsScript == nil then
			clientWeaponsScript = weaponsSystemFolder.ClientWeaponsScript:Clone()
			clientWeaponsScript.Parent = playerGui
			print("? [WEAPONS SYSTEM] ÉXITO: ClientWeaponsScript insertado en la pantalla de " .. player.Name)
		else
			print("?? [WEAPONS SYSTEM] OJO: " .. player.Name .. " ya tenía el script en su pantalla. No se copió de nuevo.")
		end
	end

	-- 1. Cuando un jugador nuevo entra por primera vez
	Players.PlayerAdded:Connect(function(player)
		setupClientWeaponsScript(player)

		-- ?? LA MAGIA: Cada vez que el jugador muera/respawnee, le volvemos a dar el script
		player.CharacterAdded:Connect(function()
			setupClientWeaponsScript(player)
		end)
	end)

	-- 2. Para los jugadores que ya estaban en el servidor (en Studio)
	for _, player in ipairs(Players:GetPlayers()) do
		setupClientWeaponsScript(player)

		player.CharacterAdded:Connect(function()
			setupClientWeaponsScript(player)
		end)
	end
end

if curWeaponsSystemFolder.Name == "WeaponsSystem" then
	curWeaponsSystemFolder:Destroy()
end