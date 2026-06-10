local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local playerChildAddedConnection
local replicatedStorageChildAddedConnection
local clientWeaponsScript
local weaponsSystemFolder

local WeaponsSystem -- Referencia global al modulo

local function setupWeaponsSystem()
	WeaponsSystem = require(weaponsSystemFolder.WeaponsSystem)
	if not WeaponsSystem.doingSetup and not WeaponsSystem.didSetup then
		WeaponsSystem.setup()
	end

	-- =========================================================
	-- DOMADOR DE CAMARA (Con seguro anti-secuestro)
	-- =========================================================
	local player = Players.LocalPlayer

	local function setWeaponGuiEnabled(enabled)
		if not WeaponsSystem.gui then
			return
		end

		if type(WeaponsSystem.gui.setEnabled) == "function" then
			pcall(function()
				WeaponsSystem.gui:setEnabled(enabled)
			end)
		else
			WeaponsSystem.gui.Enabled = enabled
		end

		if not enabled then
			if type(WeaponsSystem.gui.setCrosshairEnabled) == "function" then
				pcall(function()
					WeaponsSystem.gui:setCrosshairEnabled(false)
				end)
			end
			if type(WeaponsSystem.gui.setScopeEnabled) == "function" then
				pcall(function()
					WeaponsSystem.gui:setScopeEnabled(false)
				end)
			end
		end
	end

	local function forceDisableWeaponGui()
		setWeaponGuiEnabled(false)
		task.defer(function()
			setWeaponGuiEnabled(false)
		end)
		task.delay(0.1, function()
			setWeaponGuiEnabled(false)
		end)
	end

	local function updateCamera()
		local character = player.Character
		local hasWeaponEquipped = false
		local equippedTool = nil
		local hum = nil

		-- CHEQUEO DE SECUESTRO: Si esta secuestrado, bloqueamos todo pase lo que pase.
		local estaSecuestrado = player:GetAttribute("Secuestrado") == true

		if character and not estaSecuestrado then
			hum = character:FindFirstChildOfClass("Humanoid")
			local tool = character:FindFirstChildOfClass("Tool")
			-- Verificamos si lo que tiene en la mano es un arma de este sistema.
			if tool and tool:FindFirstChild("WeaponType") then
				hasWeaponEquipped = true
				equippedTool = tool
			end
		end

		local activeWeapon = WeaponsSystem.currentWeapon
		local hasActiveWeapon = hasWeaponEquipped and activeWeapon ~= nil and activeWeapon.instance == equippedTool

		-- Apagamos/Prendemos la camara del sistema segun el Tool equipado.
		if WeaponsSystem.camera then
			if type(WeaponsSystem.camera.setEnabled) == "function" then
				WeaponsSystem.camera:setEnabled(hasWeaponEquipped)
			else
				WeaponsSystem.camera.Enabled = hasWeaponEquipped
			end
		end

		-- La mira requiere arma interna activa, no solo un Tool en la mano.
		if hasActiveWeapon then
			setWeaponGuiEnabled(true)
			if WeaponsSystem.camera and type(WeaponsSystem.camera.updateZoomState) == "function" then
				WeaponsSystem.camera:updateZoomState()
			end
		else
			forceDisableWeaponGui()
		end

		-- PARCHE POV: Regresamos los ojos a la cabeza y reseteamos el ancla.
		if not hasWeaponEquipped then
			if hum then
				hum.CameraOffset = Vector3.new(0, 0, 0)
				workspace.CurrentCamera.CameraSubject = hum
			end
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end
	end

	updateCamera()

	player:GetAttributeChangedSignal("Secuestrado"):Connect(updateCamera)

	if WeaponsSystem.CurrentWeaponChanged then
		WeaponsSystem.CurrentWeaponChanged.Event:Connect(function()
			updateCamera()
			task.defer(updateCamera)
		end)
	end

	player.CharacterAdded:Connect(function(char)
		char.ChildAdded:Connect(updateCamera)
		char.ChildRemoved:Connect(updateCamera)
		task.defer(updateCamera)
	end)

	player.CharacterRemoving:Connect(function()
		forceDisableWeaponGui()
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
