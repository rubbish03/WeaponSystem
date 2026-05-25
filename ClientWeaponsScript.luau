local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local playerChildAddedConnection
local replicatedStorageChildAddedConnection
local clientWeaponsScript
local weaponsSystemFolder

local WeaponsSystem -- Referencia global al módulo

local function setupWeaponsSystem()
	WeaponsSystem = require(weaponsSystemFolder.WeaponsSystem)
	if not WeaponsSystem.doingSetup and not WeaponsSystem.didSetup then
		WeaponsSystem.setup()
	end

	-- =========================================================
	-- ?? DOMADOR DE CÁMARA (Con Seguro Anti-Secuestro)
	-- =========================================================
	local player = Players.LocalPlayer

	local function updateCamera()
		local character = player.Character
		local hasWeaponEquipped = false
		local hum = nil

		-- ?? CHEQUEO DE SECUESTRO: Si está secuestrado, bloqueamos todo pase lo que pase
		local estaSecuestrado = player:GetAttribute("Secuestrado") == true

		if character and not estaSecuestrado then
			hum = character:FindFirstChildOfClass("Humanoid")
			local tool = character:FindFirstChildOfClass("Tool")
			-- Verificamos si lo que tiene en la mano es un arma de este sistema
			if tool and tool:FindFirstChild("WeaponType") then
				hasWeaponEquipped = true
			end
		end

		-- Apagamos/Prendemos la cámara del sistema
		if WeaponsSystem.camera then
			if type(WeaponsSystem.camera.setEnabled) == "function" then
				WeaponsSystem.camera:setEnabled(hasWeaponEquipped)
			else
				WeaponsSystem.camera.Enabled = hasWeaponEquipped
			end
		end

		-- Apagamos/Prendemos la mira (Crosshair) y los disparos
		if WeaponsSystem.gui then
			if type(WeaponsSystem.gui.setEnabled) == "function" then
				WeaponsSystem.gui:setEnabled(hasWeaponEquipped)
			else
				WeaponsSystem.gui.Enabled = hasWeaponEquipped
			end
		end

		-- ??? PARCHE POV: Regresamos los ojos a la cabeza y reseteamos el ancla
		if not hasWeaponEquipped then
			if hum then 
				hum.CameraOffset = Vector3.new(0, 0, 0) 
				workspace.CurrentCamera.CameraSubject = hum
			end
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end

	end

	-- ¡Forzamos a apagar la cámara en el instante que la compras!
	updateCamera()

	-- ?? ESCUCHAMOS EL ATRIBUTO: Si el pájaro lo agarra o lo suelta, forzamos actualización
	player:GetAttributeChangedSignal("Secuestrado"):Connect(updateCamera)

	-- Detectar cuando equipa (ChildAdded) o guarda (ChildRemoved) el arma
	player.CharacterAdded:Connect(function(char)
		char.ChildAdded:Connect(updateCamera)
		char.ChildRemoved:Connect(updateCamera)
	end)

	if player.Character then
		player.Character.ChildAdded:Connect(updateCamera)
		player.Character.ChildRemoved:Connect(updateCamera)
	end
	-- =========================================================
end

local function onReplicatedStorageChildAdded(child)
	if child.Name == "WeaponsSystem" then
		setupWeaponsSystem()
		replicatedStorageChildAddedConnection:Disconnect()
	end
end

local function onPlayerChildAdded(child)
	if child.Name == "PlayerScripts" then
		clientWeaponsScript.Parent = child
		playerChildAddedConnection:Disconnect()
	end
end

if script.Parent.Name ~= "PlayerScripts" then
	clientWeaponsScript = script:Clone()
	local PlayerScripts = script.Parent.Parent:FindFirstChild("PlayerScripts")

	if PlayerScripts ~= nil then
		clientWeaponsScript.Parent = PlayerScripts
	else
		playerChildAddedConnection = script.Parent.Parent.ChildAdded:Connect(onPlayerChildAdded)
	end
else
	weaponsSystemFolder = ReplicatedStorage:FindFirstChild("WeaponsSystem")
	if weaponsSystemFolder ~= nil then
		setupWeaponsSystem()
	else
		replicatedStorageChildAddedConnection = ReplicatedStorage.ChildAdded:Connect(onReplicatedStorageChildAdded)
	end
end