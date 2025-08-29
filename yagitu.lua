-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

-- Koordinat teleport
local targetPosition = Vector3.new(1939, 1344, -2074)

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 100)
Frame.Position = UDim2.new(0.5, -150, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BackgroundTransparency = 0.3
Frame.Active = true
Frame.Draggable = true -- bisa drag

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 0.2
Title.BackgroundColor3 = Color3.fromRGB(45,45,45)
Title.Text = "Auto Teleport Script"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1,-20,0,50)
StatusLabel.Position = UDim2.new(0,10,0,40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255,255,0)
StatusLabel.Text = "Preparing auto teleport..."
StatusLabel.TextWrapped = true

-- Fungsi teleport
local function teleport()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = character:WaitForChild("HumanoidRootPart")
    HRP.CFrame = CFrame.new(targetPosition)
    StatusLabel.Text = "Teleported → X:"..math.floor(targetPosition.X).." Y:"..math.floor(targetPosition.Y).." Z:"..math.floor(targetPosition.Z)
end

-- Fungsi rejoin map
local function rejoin()
    local placeId = game.PlaceId
    StatusLabel.Text = "Rejoining map..."
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- Loop otomatis teleport → delay 5 detik → rejoin
spawn(function()
    while true do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            teleport()
            wait(5)
            rejoin()
            wait(10) -- tunggu map reload sepenuhnya
        else
            LocalPlayer.CharacterAdded:Wait()
        end
    end
end)
