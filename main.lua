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

-- ===== STATUS =====
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

-- ===== SCROLL =====
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

-- ===== BOTÓN COPIAR TODO =====
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -20, 0, 36)
copyBtn.Position = UDim2.new(0, 10, 1, -46)
copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
copyBtn.Text = "Copiar TODO al portapapeles"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 15
copyBtn.Parent = main

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyBtn

-- ===== HELPERS =====
local function status(msg)
    statusLabel.Text = msg
    statusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
end

local function errorMsg(msg)
    statusLabel.Text = "[ERROR] " .. msg
    statusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
    warn("[ChunkExporter] " .. msg)
end

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
end

local CHUNK_SIZE = 50000 -- caracteres por parte copiable

-- Crea un bloque por chunk con botón "Copiar parte N/M"
local function addChunkBlock(chunkName, chunkValue, layoutOrder)
    -- Dividir en partes de CHUNK_SIZE
    local parts = {}
    for i = 1, #chunkValue, CHUNK_SIZE do
        table.insert(parts, chunkValue:sub(i, i + CHUNK_SIZE - 1))
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    container.BorderSizePixel = 0
    container.LayoutOrder = layoutOrder
    container.Parent = scrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = container

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Padding = UDim.new(0, 4)
    innerLayout.Parent = container

    -- Header del chunk
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = chunkName .. " — " .. #chunkValue .. " chars — " .. #parts .. " parte(s)"
    header.TextColor3 = Color3.fromRGB(120, 200, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 0
    header.Parent = container

    -- Botón por cada parte
    for i, part in ipairs(parts) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(50, 110, 190)
        btn.Text = "📋 Copiar parte " .. i .. "/" .. #parts .. " (" .. #part .. " chars)"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.LayoutOrder = i
        btn.Parent = container

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        local capturedPart = part
        local capturedI = i
        local capturedTotal = #parts
        btn.MouseButton1Click:Connect(function()
            local ok, err2 = pcall(function()
                setclipboard(capturedPart)
            end)
            if ok then
                btn.Text = "✅ ¡Copiado parte " .. capturedI .. "/" .. capturedTotal .. "!"
                status("Copiado: " .. chunkName .. " parte " .. capturedI .. "/" .. capturedTotal)
            else
                btn.Text = "❌ Error al copiar"
                errorMsg("setclipboard falló: " .. tostring(err2))
            end
            task.wait(1.5)
            btn.Text = "📋 Copiar parte " .. capturedI .. "/" .. capturedTotal .. " (" .. #capturedPart .. " chars)"
        end)
    end
end

-- ===== NAVEGACIÓN =====
local allChunks = {}
local fullResult = ""

local ok, err = pcall(function()
    status("Buscando chunks...")

    local controllers = RS:WaitForChild("Controllers", 5)
    if not controllers then error("Falta Controllers") end

    local eventController = controllers:WaitForChild("EventController", 5)
    if not eventController then error("Falta EventController") end

    local events = eventController:WaitForChild("Events", 5)
    if not events then error("Falta Events") end

    local phase2 = events:WaitForChild("Phase 2: Galaxy Introduction", 5)
    if not phase2 then error("Falta Phase 2: Galaxy Introduction") end

    local cutscene = phase2:WaitForChild("Cutscene", 5)
    if not cutscene then error("Falta Cutscene") end

    local allChildren = cutscene:GetChildren()
    addDebugLine("Hijos en Cutscene: " .. #allChildren)

    local chunks = {}
    for _, child in ipairs(allChildren) do
        local num = child.Name:match("^Chunk_(%d+)$")
        if num and child:IsA("StringValue") then
            table.insert(chunks, {n = tonumber(num), name = child.Name, value = child.Value})
        end
    end

    if #chunks == 0 then
        errorMsg("No se encontraron Chunk_N StringValues")
        return
    end

    table.sort(chunks, function(a, b) return a.n < b.n end)
    status("✅ " .. #chunks .. " chunks encontrados")

    local lines = {}
    for i, c in ipairs(chunks) do
        allChunks[i] = c
        addChunkBlock(c.name, c.value, i)
        table.insert(lines, c.name .. ": " .. c.value)
    end

    fullResult = table.concat(lines, "\n")
    addDebugLine("Total: " .. #fullResult .. " chars", Color3.fromRGB(100, 255, 150))
end)

if not ok then
    errorMsg("Error: " .. tostring(err))
end

-- ===== COPIAR TODO =====
copyBtn.MouseButton1Click:Connect(function()
    if fullResult == "" then
        errorMsg("No hay datos.")
        return
    end
    local ok2, err2 = pcall(function()
        setclipboard(fullResult)
    end)
    if ok2 then
        copyBtn.Text = "✅ ¡Todo copiado!"
    else
        copyBtn.Text = "❌ Error — usa los botones por chunk"
        errorMsg("setclipboard falló con el texto completo: " .. tostring(err2))
    end
    task.wait(2)
    copyBtn.Text = "Copiar TODO al portapapeles"
end)
