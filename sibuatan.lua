--== yagitu.lua (GitHub-ready, auto-loop + auto-rejoin) ==--

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

-- Koordinat teleport
local targetPosition = Vector3.new(1939, 1344, -2074)

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

local function rejoinMap()
    Status.Text = "Status: Rejoining map..."
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yoroses/yobox/main/yagitu.lua"))()
    ]])
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

--== Auto Loop Teleport + Rejoin ==
spawn(function()
    while true do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            teleportToCoordinate()
            wait(5)
            rejoinMap()
            wait(10) -- tunggu map reload
        else
            LocalPlayer.CharacterAdded:Wait()
        end
    end
end)
