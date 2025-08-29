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

local function getCheckpoint46()
    local checkpoints = workspace:FindFirstChild("Checkpoints")
    if not checkpoints then return nil end
    return checkpoints:FindFirstChild("Checkpoint46")
end

local function getTeddyHandle()
    local love = workspace:FindFirstChild("Love Teddy")
    if not love then return nil end
    local val = love:FindFirstChild("ValentineTeddy")
    if not val then return nil end
    return val:FindFirstChild("Handle")
end

local function respawnAtBase()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
    local newChar = LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
    return newChar:WaitForChild("HumanoidRootPart", 5)
end

--== Main Logic ==--
task.spawn(function()
    task.wait(2) -- jeda biar map kebuka

    -- 1) Teleport ke Checkpoint46
    local cp46 = getCheckpoint46()
    if cp46 then
        teleportTo(cp46)
        task.wait(1)
    end

    -- 2) Teleport ke Teddy
    local teddy = getTeddyHandle()
    if teddy then
        teleportTo(teddy)
        task.wait(1)
    end

    -- 3) Respawn ke base
    respawnAtBase()
    task.wait(1)

    -- 4) Auto Rejoin
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
