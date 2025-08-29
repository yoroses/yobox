--== Auto Execute Saat Rejoin ==--
queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/yoroses/yobox/refs/heads/main/sibuatan.lua'))()")

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

--== Helpers ==--
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function teleportTo(part)
    local hrp = getHRP()
    if hrp and part and part:IsA("BasePart") then
        hrp.CFrame = part.CFrame + Vector3.new(0,5,0)
    end
end

local function getTeddyHandle()
    local love = workspace:FindFirstChild("Love Teddy")
    if not love then return nil end
    local val = love:FindFirstChild("ValentineTeddy")
    if not val then return nil end
    return val:FindFirstChild("Handle")
end

--== Main Logic ==--
task.wait(2) -- kasih jeda biar map kebuka

local teddy = getTeddyHandle()
if teddy then
    teleportTo(teddy)
    task.wait(1)
end

-- langsung rejoin otomatis
TeleportService:Teleport(game.PlaceId, LocalPlayer)
