-- LocalScript

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== VENTANA PRINCIPAL =====
local gui = Instance.new("ScreenGui")
gui.Name = "ChunkExporter"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0.9, 0, 0.75, 0)
main.Position = UDim2.new(0.05, 0, 0.12, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

-- ===== BARRA DE TÍTULO =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Chunk Exporter — Cutscene"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- ===== ÁREA DE STATUS (arriba, chica) =====
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 46)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = main

-- ===== ÁREA DE TEXTO (SCROLLABLE, con lista de labels) =====
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -120)
scrollFrame.Position = UDim2.new(0, 10, 0, 70)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = main

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = scrollFrame

-- ===== BOTÓN COPIAR =====
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -20, 0, 36)
copyBtn.Position = UDim2.new(0, 10, 1, -46)
copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
copyBtn.Text = "Copiar al portapapeles"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 15
copyBtn.Parent = main

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyBtn

-- ===== STATUS/LOG FUNCTIONS =====
local function status(msg, delay)
	statusLabel.Text = msg
	statusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	task.wait(delay or 0.4)
end

local function errorMsg(msg)
	statusLabel.Text = "[ERROR] " .. msg
	statusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	warn("[ChunkExporter] " .. msg)
end

-- Crea una línea de debug visible dentro del scroll (para diagnosticar)
local function addDebugLine(text, color)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = color or Color3.fromRGB(255, 200, 100)
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = scrollFrame
	return lbl
end

-- Crea un bloque de texto para un chunk (TextLabel individual, no un solo TextBox gigante)
local function addChunkLabel(name, value)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundTransparency = 1
	container.Parent = scrollFrame

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 18)
	header.BackgroundTransparency = 1
	header.Text = name .. ":"
	header.TextColor3 = Color3.fromRGB(120, 200, 255)
	header.Font = Enum.Font.GothamBold
	header.TextSize = 14
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = container

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, 0, 0, 0)
	valueLabel.Position = UDim2.new(0, 0, 0, 18)
	valueLabel.AutomaticSize = Enum.AutomaticSize.Y
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = (value ~= "" and value) or "(vacío)"
	valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	valueLabel.Font = Enum.Font.Code
	valueLabel.TextSize = 12
	valueLabel.TextWrapped = true
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.TextYAlignment = Enum.TextYAlignment.Top
	valueLabel.Parent = container

	container.Size = UDim2.new(1, 0, 0, 18)
end

-- ===== BÚSQUEDA SEGURA =====
local function safeWaitForChild(parent, name, timeout)
	timeout = timeout or 5
	local ok, result = pcall(function()
		local obj = parent:WaitForChild(name, timeout)
		if not obj then
			error("No se encontró \"" .. name .. "\" dentro de \"" .. parent.Name .. "\" (timeout)")
		end
		return obj
	end)

	if not ok then
		errorMsg(result)
		return nil
	end
	return result
end

-- ===== NAVEGACIÓN =====
-- Ruta: ReplicatedStorage > Controllers > EventController > Events > "Phase 2: Galaxy Introduction" > Cutscene
local fullResult = ""

local ok, err = pcall(function()

	status("Entrando a ReplicatedStorage...")
	local controllers = safeWaitForChild(RS, "Controllers")
	if not controllers then error("Detenido: falta Controllers") end

	status("Entré a Controllers...")
	local eventController = safeWaitForChild(controllers, "EventController")
	if not eventController then error("Detenido: falta EventController") end

	status("Entré ahora a EventController...")
	local events = safeWaitForChild(eventController, "Events")
	if not events then error("Detenido: falta Events") end

	status("Entrando a Events...")
	local phase2 = safeWaitForChild(events, "Phase 2: Galaxy Introduction")
	if not phase2 then error("Detenido: falta Phase 2: Galaxy Introduction") end

	status("Entre ahorita sí a Phase 2: Galaxy Introduction...")
	local cutscene = safeWaitForChild(phase2, "Cutscene")
	if not cutscene then error("Detenido: falta Cutscene") end

	status("Cutscene...")

	-- DEBUG: mostrar TODOS los hijos de Cutscene, sean o no StringValue
	local allChildren = cutscene:GetChildren()
	addDebugLine("Hijos totales en Cutscene: " .. #allChildren)
	for _, child in ipairs(allChildren) do
		addDebugLine("  -> " .. child.Name .. " (" .. child.ClassName .. ")", Color3.fromRGB(150,150,150))
	end

	-- ===== OBTENER Y ORDENAR CHUNKS =====
	local chunks = {}
	for _, child in ipairs(allChildren) do
		local num = child.Name:match("^Chunk_(%d+)$")
		if num and child:IsA("StringValue") then
			table.insert(chunks, {n = tonumber(num), name = child.Name, value = child.Value})
		end
	end

	if #chunks == 0 then
		errorMsg("No se encontraron StringValues con formato Chunk_N dentro de Cutscene (revisa la lista de arriba)")
		return
	end

	table.sort(chunks, function(a, b) return a.n < b.n end)

	status("Listo! (" .. #chunks .. " chunks encontrados)")

	local lines = {}
	for _, c in ipairs(chunks) do
		addChunkLabel(c.name, c.value)
		table.insert(lines, c.name .. ": " .. c.value)
	end

	fullResult = table.concat(lines, "\n")
	addDebugLine("Longitud total del texto: " .. #fullResult .. " caracteres", Color3.fromRGB(100,255,150))

end)

if not ok then
	errorMsg("Error inesperado: " .. tostring(err))
end

-- ===== COPIAR =====
copyBtn.MouseButton1Click:Connect(function()
	if fullResult == "" then
		errorMsg("No hay datos para copiar todavía.")
		return
	end

	local success, err2 = pcall(function()
		setclipboard(fullResult)
	end)

	if success then
		copyBtn.Text = "¡Copiado!"
	else
		copyBtn.Text = "Error al copiar"
		errorMsg("No se pudo usar setclipboard: " .. tostring(err2))
	end

	task.wait(1.5)
	copyBtn.Text = "Copiar al portapapeles"
end)
