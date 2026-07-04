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

-- ===== ÁREA DE TEXTO (SCROLLABLE) =====
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -95)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = main

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -16, 0, 0)
textBox.Position = UDim2.new(0, 8, 0, 8)
textBox.AutomaticSize = Enum.AutomaticSize.Y
textBox.BackgroundTransparency = 1
textBox.MultiLine = true
textBox.ClearTextOnFocus = false
textBox.TextEditable = false
textBox.TextWrapped = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
textBox.Font = Enum.Font.Code
textBox.TextSize = 14
textBox.Text = ""
textBox.Parent = scrollFrame

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

-- ===== FUNCIÓN PARA IR AGREGANDO LÍNEAS DE PROGRESO =====
local log = {}
local function status(msg, delay)
	table.insert(log, msg)
	textBox.Text = table.concat(log, "\n")
	task.wait(delay or 0.4)
end

-- ===== NAVEGACIÓN CON MENSAJES =====
status("Entrando a ReplicatedStorage...")
local controllers = RS:WaitForChild("Controllers")

status("Entré a Controllers...")
local eventController = controllers:WaitForChild("EventController")

status("Entré ahora a EventController...")
local events = eventController:WaitForChild("Events")

status("Entrando a Events...")
local phase2 = events:WaitForChild("Phase 2: Galaxy Introduction")

status("Entre ahorita sí a Phase 2: Galaxy Introduction...")
local cutscene = phase2:WaitForChild("Cutscene")

status("Cutscene...")

-- ===== OBTENER Y ORDENAR CHUNKS =====
local chunks = {}
for _, child in ipairs(cutscene:GetChildren()) do
	local num = child.Name:match("^Chunk_(%d+)$")
	if num and child:IsA("StringValue") then
		table.insert(chunks, {n = tonumber(num), name = child.Name, value = child.Value})
	end
end

table.sort(chunks, function(a, b) return a.n < b.n end)

status("Listo!")

local lines = {}
for _, c in ipairs(chunks) do
	table.insert(lines, c.name .. ": " .. c.value)
end

local result = table.concat(lines, "\n")

-- Añadir los chunks al final del log de progreso
table.insert(log, result)
textBox.Text = table.concat(log, "\n")

-- ===== COPIAR =====
copyBtn.MouseButton1Click:Connect(function()
	local success = pcall(function()
		setclipboard(result)
	end)

	if success then
		copyBtn.Text = "¡Copiado!"
	else
		copyBtn.Text = "Error al copiar (revisa Output)"
		print(result)
	end

	task.wait(1.5)
	copyBtn.Text = "Copiar al portapapeles"
end)
