-- =========================================================
-- ?? MÓDULO DE ASISTENCIA DE APUNTADO (AIM ASSIST)
-- =========================================================
local AimAssistModule = {}
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local intensidades = {
	["Leve"] = 0.15,
	["Moderado"] = 0.45,
	["Pronunciado"] = 0.85
}

function AimAssistModule.ObtenerDireccion(direccionOriginal, origen)
	local player = Players.LocalPlayer
	if not player then return direccionOriginal end

	-- Leemos lo que haya configurado tu UI
	local nivel = player:GetAttribute("AimAssistNivel")
	local activo = player:GetAttribute("AimAssistActivo")

	-- Si está apagado o no hay nivel, sale la bala recta normal
	if activo == false or not nivel or not intensidades[nivel] then
		return direccionOriginal
	end

	local fuerza = intensidades[nivel]
	local mejorObjetivo = nil
	local menorAngulo = 15 -- Qué tan cerca de la mira debe estar el enemigo para imantarlo

	for _, otroJugador in pairs(Players:GetPlayers()) do
		if otroJugador ~= player and otroJugador.Character then
			local hrp = otroJugador.Character:FindFirstChild("HumanoidRootPart")
			local hum = otroJugador.Character:FindFirstChild("Humanoid")

			if hrp and hum and hum.Health > 0 then
				local screenPos, visible = Camera:WorldToViewportPoint(hrp.Position)
				if visible then
					local centro = Camera.ViewportSize / 2
					local distAlCentro = (Vector2.new(screenPos.X, screenPos.Y) - centro).Magnitude

					if distAlCentro < menorAngulo * 10 then
						menorAngulo = distAlCentro
						mejorObjetivo = hrp
					end
				end
			end
		end
	end

	if mejorObjetivo then
		local direccionAlObjetivo = (mejorObjetivo.Position - origen).Unit
		return direccionOriginal:Lerp(direccionAlObjetivo, fuerza)
	end

	return direccionOriginal
end

return AimAssistModule