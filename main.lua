-- LocalScript

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PART_SIZE = 50000 -- caracteres por botón

-- ===== GUI =====
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

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

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
titleLabel.Text = "Chunk Exporter — Clipboard"
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
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Status
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

-- Scroll
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.Position = UDim2.new(0, 10, 0, 70)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = main
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)

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

-- ===== HELPERS =====
local function setStatus(msg, color)
    statusLabel.Text = msg
    statusLabel.TextColor3 = color or Color3.fromRGB(150, 200, 255)
end

local function makeBtn(parent, text, color, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 110, 190)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.LayoutOrder = order or 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- ===== BLOQUE POR CHUNK =====
local function addChunkBlock(chunkName, chunkValue, layoutOrder)
    local parts = {}
    for i = 1, #chunkValue, PART_SIZE do
        table.insert(parts, chunkValue:sub(i, i + PART_SIZE - 1))
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    container.BorderSizePixel = 0
    container.LayoutOrder = layoutOrder
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

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

    -- Header
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

    -- Botón por parte
    for i, part in ipairs(parts) do
        local capturedPart = part
        local capturedI = i
        local total = #parts
        local btn = makeBtn(
            container,
            "📋 Copiar parte " .. i .. "/" .. total .. " (" .. #part .. " chars)",
            Color3.fromRGB(50, 110, 190),
            i
        )
        btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(function()
                setclipboard(capturedPart)
            end)
            if ok then
                btn.Text = "✅ Copiado parte " .. capturedI .. "/" .. total
                setStatus("✅ " .. chunkName .. " parte " .. capturedI .. "/" .. total .. " copiada")
            else
                btn.Text = "❌ Error"
                setStatus("❌ Error: " .. tostring(err), Color3.fromRGB(255, 90, 90))
            end
            task.wait(1.5)
            btn.Text = "📋 Copiar parte " .. capturedI .. "/" .. total .. " (" .. #capturedPart .. " chars)"
        end)
    end
end

-- ===== CARGAR CHUNKS =====
local ok, err = pcall(function()
    setStatus("Buscando chunks...")

    local controllers = RS:WaitForChild("Controllers", 5)
    local eventController = controllers:WaitForChild("EventController", 5)
    local events = eventController:WaitForChild("Events", 5)
    local phase2 = events:WaitForChild("Phase 2: Galaxy Introduction", 5)
    local cutscene = phase2:WaitForChild("Cutscene", 5)

    local chunks = {}
    for _, child in ipairs(cutscene:GetChildren()) do
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
    setStatus("✅ " .. #chunks .. " chunks — " .. #chunks .. " bloques listos")

    for i, c in ipairs(chunks) do
        addChunkBlock(c.name, c.value, i)
    end
end)

if not ok then
    setStatus("❌ " .. tostring(err), Color3.fromRGB(255, 90, 90))
end
