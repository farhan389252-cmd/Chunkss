local RS = game:GetService("ReplicatedStorage")

local eventController = RS.Controllers:FindFirstChild("EventController")
local phase2 = eventController:FindFirstChild("Phase 2: Galaxy Introduction")

-- Buscar todos los ChunkX y ordenarlos numéricamente
local chunks = {}
for , child in ipairs(phase2:GetChildren()) do
local num = child.Name:match("^Chunk(%d+)$")
if num and child:IsA("StringValue") then
table.insert(chunks, {n = tonumber(num), name = child.Name, value = child.Value})
end
end

table.sort(chunks, function(a, b) return a.n < b.n end)

local lines = {}
for _, c in ipairs(chunks) do
table.insert(lines, c.name .. ": " .. c.value)
end

local result = table.concat(lines, "\n")

setclipboard(result)
print(result)
