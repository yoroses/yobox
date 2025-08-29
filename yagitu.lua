--== yagitu_countdown_respawn.lua ==--

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Koordinat teleport
local targetPosition = Vector3.new(1939, 1344, -2074)
local waitAfterTP = 10 -- detik sebelum respawn

--== GUI Setup ==--
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 380, 0, 200)
Frame.Position = UDim2.new(0.5, -190, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BackgroundTransparency = 0.2
Frame.Active = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,36)
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

-- Status label
local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1,-20,0,24)
Status.Position = UDim2.new(0,10,0,46)
Status.BackgroundTransparency = 1
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextColor3 = Color3.fromRGB(200,220,255)
Status.Text = "Status: idle"

--== Helpers ==--
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function teleportToCoordinate()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(targetPosition)
        Status.Text = "Status: Teleported to X:"..math.floor(targetPosition.X).." Y:"..math.floor(targetPosition.Y).." Z:"..math.floor(targetPosition.Z)
    end
end

local function respawnCharacter()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        Status.Text = "Status: Respawning..."
        char:BreakJoints() -- memaksa respawn
    end
end

--== Auto Loop Teleport + Respawn ==--
spawn(function()
    while true do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            teleportToCoordinate()
            Status.Text = "Status: Waiting "..waitAfterTP.." seconds before respawn..."
            task.wait(waitAfterTP)
            respawnCharacter()
            -- Tunggu character respawn
            LocalPlayer.CharacterAdded:Wait()
            task.wait(1)
        else
            LocalPlayer.CharacterAdded:Wait()
        end
    end
end)
