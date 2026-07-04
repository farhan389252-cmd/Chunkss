-- LocalScript

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== VENTANA PRINCIPAL =====
local gui = Instance.new("ScreenGui")
gui.Name = "ChunkExporter"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0.9, 0, 0.85, 0)
main.Position = UDim2.new(0.05, 0, 0.07, 0)
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
titleLabel.Text = "Chunk Exporter — dpaste"
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

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = scrollFrame

-- ===== BOTÓN SUBIR TODO =====
local uploadBtn = Instance.new("TextButton")
uploadBtn.Size = UDim2.new(1, -20, 0, 36)
uploadBtn.Position = UDim2.new(0, 10, 1, -46)
uploadBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
uploadBtn.Text = "⬆ Subir todos los chunks a dpaste"
uploadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
uploadBtn.Font = Enum.Font.GothamBold
uploadBtn.TextSize = 14
uploadBtn.Parent = main

local uploadCorner = Instance.new("UICorner")
uploadCorner.CornerRadius = UDim.new(0, 8)
uploadCorner.Parent = uploadBtn

-- ===== HELPERS =====
local function setStatus(msg, color)
    statusLabel.Text = msg
    statusLabel.TextColor3 = color or Color3.fromRGB(150, 200, 255)
end

local function addDebugLine(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255, 200, 100)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = scrollFrame
end

-- ===== UPLOAD A DPASTE =====
local function uploadToDpaste(text)
    local response = HttpService:PostAsync(
        "https://dpaste.com/api/v2/",
        "content=" .. HttpService:UrlEncode(text) .. "&syntax=text&expiry_days=7",
        Enum.HttpContentType.ApplicationUrlEncoded
    )
    return response and response:match("https://dpaste%.com/%S+")
end

-- ===== BLOQUE POR CHUNK =====
local function addChunkBlock(chunkName, chunkValue, layoutOrder)
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

    local innerPad = Instance.new("UIPadding")
    innerPad.PaddingTop = UDim.new(0, 6)
    innerPad.PaddingLeft = UDim.new(0, 8)
    innerPad.PaddingRight = UDim.new(0, 8)
    innerPad.PaddingBottom = UDim.new(0, 6)
    innerPad.Parent = container

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Padding = UDim.new(0, 4)
    innerLayout.Parent = container

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = chunkName .. " — " .. #chunkValue .. " chars"
    header.TextColor3 = Color3.fromRGB(120, 200, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 0
    header.Parent = container

    local linkLabel = Instance.new("TextLabel")
    linkLabel.Size = UDim2.new(1, 0, 0, 18)
    linkLabel.BackgroundTransparency = 1
    linkLabel.Text = "Sin subir aún"
    linkLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    linkLabel.Font = Enum.Font.Code
    linkLabel.TextSize = 12
    linkLabel.TextXAlignment = Enum.TextXAlignment.Left
    linkLabel.TextWrapped = true
    linkLabel.LayoutOrder = 1
    linkLabel.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 110, 190)
    btn.Text = "⬆ Subir este chunk"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.LayoutOrder = 2
    btn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local copyLinkBtn = Instance.new("TextButton")
    copyLinkBtn.Size = UDim2.new(1, 0, 0, 30)
    copyLinkBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    copyLinkBtn.Text = "📋 Copiar link"
    copyLinkBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    copyLinkBtn.Font = Enum.Font.GothamBold
    copyLinkBtn.TextSize = 12
    copyLinkBtn.LayoutOrder = 3
    copyLinkBtn.Parent = container

    local copyLinkCorner = Instance.new("UICorner")
    copyLinkCorner.CornerRadius = UDim.new(0, 6)
    copyLinkCorner.Parent = copyLinkBtn

    local currentLink = ""

    btn.MouseButton1Click:Connect(function()
        btn.Text = "⏳ Subiendo..."
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        setStatus("Subiendo " .. chunkName .. "...")

        local ok, result = pcall(uploadToDpaste, chunkValue)
        if ok and result then
            currentLink = result
            linkLabel.Text = result
            linkLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
            btn.Text = "✅ Subido"
            btn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
            copyLinkBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 190)
            copyLinkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            setStatus("✅ " .. chunkName .. ": " .. result, Color3.fromRGB(100, 255, 150))
        else
            linkLabel.Text = "❌ Error al subir"
            linkLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
            btn.Text = "⬆ Reintentar"
            btn.BackgroundColor3 = Color3.fromRGB(50, 110, 190)
            setStatus("❌ Error: " .. tostring(result), Color3.fromRGB(255, 90, 90))
        end
    end)

    copyLinkBtn.MouseButton1Click:Connect(function()
        if currentLink == "" then
            setStatus("Sube el chunk primero", Color3.fromRGB(255, 200, 100))
            return
        end
        local ok2, err2 = pcall(function()
            setclipboard(currentLink)
        end)
        if ok2 then
            copyLinkBtn.Text = "✅ Link copiado!"
            task.wait(1.5)
            copyLinkBtn.Text = "📋 Copiar link"
        else
            setStatus("Error al copiar: " .. tostring(err2), Color3.fromRGB(255, 90, 90))
        end
    end)

    return function() return currentLink end
end

-- ===== CARGAR CHUNKS =====
local chunkBlocks = {}

local ok, err = pcall(function()
    setStatus("Buscando chunks...")

    local controllers = RS:WaitForChild("Controllers", 5)
    local eventController = controllers:WaitForChild("EventController", 5)
    local events = eventController:WaitForChild("Events", 5)
    local phase2 = events:WaitForChild("Phase 2: Galaxy Introduction", 5)
    local cutscene = phase2:WaitForChild("Cutscene", 5)

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
        setStatus("❌ No se encontraron chunks", Color3.fromRGB(255, 90, 90))
        return
    end

    table.sort(chunks, function(a, b) return a.n < b.n end)
    setStatus("✅ " .. #chunks .. " chunks listos")

    for i, c in ipairs(chunks) do
        local getLinkFn = addChunkBlock(c.name, c.value, i)
        table.insert(chunkBlocks, {
            name = c.name,
            value = c.value,
            getLink = getLinkFn
        })
    end

    addDebugLine("Sube cada chunk individualmente o usa el botón de abajo", Color3.fromRGB(100, 255, 150))
end)

if not ok then
    setStatus("❌ Error: " .. tostring(err), Color3.fromRGB(255, 90, 90))
end

-- ===== SUBIR TODOS =====
uploadBtn.MouseButton1Click:Connect(function()
    if #chunkBlocks == 0 then
        setStatus("No hay chunks cargados", Color3.fromRGB(255, 200, 100))
        return
    end

    uploadBtn.Text = "⏳ Subiendo..."
    uploadBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

    local links = {}
    for _, block in ipairs(chunkBlocks) do
        setStatus("Subiendo " .. block.name .. "...")
        local ok2, result = pcall(uploadToDpaste, block.value)
        if ok2 and result then
            table.insert(links, block.name .. ": " .. result)
        else
            table.insert(links, block.name .. ": ERROR - " .. tostring(result))
        end
        task.wait(0.5)
    end

    -- Subir índice con todos los links
    local index = table.concat(links, "\n")
    local ok3, indexLink = pcall(uploadToDpaste, index)

    uploadBtn.Text = "✅ Todos subidos"
    uploadBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)

    if ok3 and indexLink then
        setStatus("✅ Índice: " .. indexLink, Color3.fromRGB(100, 255, 150))
        addDebugLine("📋 Índice de links: " .. indexLink, Color3.fromRGB(100, 255, 150))
        pcall(function() setclipboard(indexLink) end)
    else
        setStatus("✅ Subidos — revisa cada chunk", Color3.fromRGB(100, 255, 150))
    end
end)
