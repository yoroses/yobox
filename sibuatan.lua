-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

--== GUI ==--
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 380, 0, 250)
Frame.Position = UDim2.new(0.5, -190, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BackgroundTransparency = 0.2
Frame.Active = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(45,45,45)
Title.BackgroundTransparency = 0.1
Title.Text = "Auto Teleport GUI"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Dragging
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Info
local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, -20, 0, 24)
Status.Position = UDim2.new(0, 10, 0, 46)
Status.BackgroundTransparency = 1
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextColor3 = Color3.fromRGB(200, 220, 255)
Status.Text = "Status: idle"

-- Buttons (tetap ada)
local StartBeamBtn = Instance.new("TextButton", Frame)
StartBeamBtn.Size = UDim2.new(0.5, -15, 0, 36)
StartBeamBtn.Position = UDim2.new(0, 10, 1, -86)
StartBeamBtn.Text = "Start Beam ➜ Teddy"
StartBeamBtn.TextColor3 = Color3.fromRGB(255,255,255)
StartBeamBtn.BackgroundColor3 = Color3.fromRGB(0,140,0)

local StartSummitBtn = Instance.new("TextButton", Frame)
StartSummitBtn.Size = UDim2.new(0.5, -15, 0, 36)
StartSummitBtn.Position = UDim2.new(0.5, 5, 1, -86)
StartSummitBtn.Text = "Start Summit"
StartSummitBtn.TextColor3 = Color3.fromRGB(255,255,255)
StartSummitBtn.BackgroundColor3 = Color3.fromRGB(0,100,200)

local StopBtn = Instance.new("TextButton", Frame)
StopBtn.Size = UDim2.new(1, -20, 0, 36)
StopBtn.Position = UDim2.new(0, 10, 1, -46)
StopBtn.Text = "Stop Loop"
StopBtn.TextColor3 = Color3.fromRGB(255,255,255)
StopBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)

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

local function getRingBeam()
    local checkpoints = workspace:FindFirstChild("Checkpoints")
    if not checkpoints then return nil end
    local cp46 = checkpoints:FindFirstChild("Checkpoint46")
    if not cp46 then return nil end
    return cp46:FindFirstChild("Ring beam")
end

local function getTeddyHandle()
    local love = workspace:FindFirstChild("Love Teddy")
    if not love then return nil end
    local val = love:FindFirstChild("ValentineTeddy")
    if not val then return nil end
    return val:FindFirstChild("Handle")
end

local function getSummit()
    return workspace:FindFirstChild("Summit")
end

local function getSpawnBase()
    local spawnPart = workspace:FindFirstChild("SpawnLocation")
    if spawnPart and spawnPart:IsA("BasePart") then
        return spawnPart
    end
    return CFrame.new(0, 5, 0)
end

local function respawnAtBase()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
    local newChar = LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
    local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
    local base = getSpawnBase()
    if hrp then
        if typeof(base) == "Instance" then
            hrp.CFrame = base.CFrame + Vector3.new(0,5,0)
        else
            hrp.CFrame = base
        end
    end
end

--== Loop logic ==--
local looping = false
local currentLoop = nil

local function loopBeamTeddy()
    looping = true
    currentLoop = "Beam"
    while looping and currentLoop == "Beam" do
        Status.Text = "Status: teleport ke Ring beam..."
        local ring = getRingBeam()
        if ring then teleportTo(ring) else Status.Text = "Status: Ring beam tidak ditemukan"; break end
        task.wait(1)

        Status.Text = "Status: teleport ke Valentine Teddy..."
        local handle = getTeddyHandle()
        if handle then teleportTo(handle) else Status.Text = "Status: Teddy Handle tidak ditemukan"; break end

        Status.Text = "Status: respawn..."
        respawnAtBase()
        task.wait(0.3)
    end
    Status.Text = "Status: idle"
end

local function loopSummit()
    looping = true
    currentLoop = "Summit"
    while looping and currentLoop == "Summit" do
        Status.Text = "Status: respawn..."
        respawnAtBase()
        task.wait(2)

        Status.Text = "Status: teleport ke Summit..."
        local summit = getSummit()
        if summit then teleportTo(summit) else Status.Text = "Status: Summit tidak ditemukan"; break end

        task.wait(3)
    end
    Status.Text = "Status: idle"
end

--== Button actions ==--
StartBeamBtn.MouseButton1Click:Connect(function()
    if not looping then
        Status.Text = "Status: starting Beam ➜ Teddy..."
        task.spawn(loopBeamTeddy)
    end
end)

StartSummitBtn.MouseButton1Click:Connect(function()
    if not looping then
        Status.Text = "Status: starting Summit..."
        task.spawn(loopSummit)
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    looping = false
    Status.Text = "Status: stopping..."
end)

--== AUTO START ==
task.spawn(loopBeamTeddy) -- <--- langsung jalan tanpa klik tombol
