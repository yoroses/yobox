-- Fish It! Auto Fishing Hack untuk Roblox
-- Script ini dibuat khusus untuk game Fish It! dengan auto fishing lengkap
-- Kompatibel dengan KRNL, Synapse X, dan executor lainnya

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variabel untuk auto fishing
local autoFishEnabled = false
local autoShakeEnabled = false
local autoReelEnabled = false
local autoFishModeEnabled = false -- Fitur Auto Fish baru
local fishingConnection = nil
local shakeConnection = nil
local reelConnection = nil
local autoFishConnection = nil
local clickSpeed = 0.001 -- Super fast clicking
local currentTool = nil
local backgroundMode = true -- Enable background execution
local lastWindowFocus = true -- Track window focus state

-- Speed and Fly variables
local speedEnabled = false
local flyEnabled = false
local normalWalkSpeed = 16
local normalJumpPower = 50
local bodyVelocity = nil
local bodyAngularVelocity = nil

-- Fungsi untuk mencari elemen GUI Fish It!
local function findFishingElements()
    local elements = {
        fishingGui = nil,
        clickArea = nil,
        progressBar = nil
    }
    
    -- Cari GUI utama Fish It! - game ini menggunakan sistem klik langsung
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "FishItAutoFishingGUI" then
            -- Cari area yang bisa diklik untuk fishing
            local clickFrame = gui:FindFirstChild("ClickFrame", true) or
                             gui:FindFirstChild("FishingFrame", true) or
                             gui:FindFirstChild("GameFrame", true) or
                             gui:FindFirstChild("MainFrame", true)
            
            if clickFrame then
                elements.fishingGui = gui
                elements.clickArea = clickFrame
                
                -- Cari progress bar atau indicator
                local progressBar = gui:FindFirstChild("ProgressBar", true) or
                                  gui:FindFirstChild("Progress", true) or
                                  gui:FindFirstChild("Bar", true)
                if progressBar then
                    elements.progressBar = progressBar
                end
                break
            end
        end
    end
    
    return elements
end

-- Fungsi untuk melakukan click hanya di dalam game Roblox (Fish It! style)
local function performFastClick()
    -- Method yang lebih robust untuk background execution
    pcall(function()
        -- Method 1: VirtualInputManager (lebih stabil untuk background)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
    
    -- Fallback method jika VirtualInputManager gagal
    pcall(function()
        mouse1click()
    end)
end

-- Fungsi untuk auto clicking (Fish It! style - klik cepat terus menerus)
local function autoClickLoop()
    if autoFishEnabled then
        -- Fish It! hanya perlu klik cepat terus menerus
        performFastClick()
    end
end

-- Fungsi untuk auto fishing utama
local function autoFishingLoop()
    if autoFishEnabled then
        -- Cek apakah player sedang memegang fishing rod
        if character and character:FindFirstChildOfClass("Tool") then
            currentTool = character:FindFirstChildOfClass("Tool")
            if currentTool.Name:lower():find("rod") or currentTool.Name:lower():find("fish") then
                -- Fish It! menggunakan sistem klik untuk charge up dan klik cepat
                performFastClick()
            end
        else
            -- Jika tidak ada rod, tetap lakukan auto click untuk Fish It!
            performFastClick()
        end
    end
end

-- Fungsi untuk toggle auto fishing
local function toggleAutoFishing()
    autoFishEnabled = not autoFishEnabled
    
    if autoFishEnabled then
        print("[Fish It! Hack] Auto Clicking AKTIF (Background Mode) - Kecepatan: " .. math.floor(1/clickSpeed) .. " CPS")
        fishingConnection = RunService.Heartbeat:Connect(function()
            -- Check if we should continue in background mode
            if backgroundMode or UserInputService.WindowFocused then
                autoFishingLoop()
            end
            wait(clickSpeed)
        end)
    else
        print("[Fish It! Hack] Auto Clicking NONAKTIF")
        if fishingConnection then
            fishingConnection:Disconnect()
            fishingConnection = nil
        end
    end
end

-- Fungsi untuk toggle auto shake (sama dengan auto fishing untuk Fish It!)
local function toggleAutoShake()
    autoShakeEnabled = not autoShakeEnabled
    
    if autoShakeEnabled then
        print("[Fish It! Hack] Super Auto Click AKTIF (Background Mode) - Kecepatan: " .. math.floor(1/clickSpeed) .. " CPS")
        shakeConnection = RunService.Heartbeat:Connect(function()
            -- Check if we should continue in background mode
            if backgroundMode or UserInputService.WindowFocused then
                autoClickLoop()
            end
            wait(clickSpeed)
        end)
    else
        print("[Fish It! Hack] Super Auto Click NONAKTIF")
        if shakeConnection then
            shakeConnection:Disconnect()
            shakeConnection = nil
        end
    end
end

-- Fungsi untuk mengatur kecepatan click
local function setClickSpeed(speed)
    if speed and tonumber(speed) then
        clickSpeed = math.max(0.001, tonumber(speed)) -- Minimum 0.001 detik
        print("[Fish It! Hack] Kecepatan click diatur ke: " .. math.floor(1/clickSpeed) .. " CPS")
    end
end

-- Fungsi untuk mencari NPC Alex
local function findAlexNPC()
    print("[Fish It! Hack] Mencari NPC Alex di workspace...")
    
    -- Cari di workspace utama dengan pencarian yang lebih komprehensif
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local objName = obj.Name:lower()
            -- Cek berbagai variasi nama Alex
            if objName:find("alex") or objName == "alex" or obj.Name == "Alex" or obj.Name == "ALEX" then
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                if rootPart then
                    print("[Fish It! Hack] Ditemukan NPC Alex: " .. obj.Name .. " di posisi: " .. tostring(rootPart.Position))
                    return obj
                end
            end
            
            -- Cek jika ada Humanoid dengan nama Alex
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and objName:find("alex") then
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                if rootPart then
                    print("[Fish It! Hack] Ditemukan NPC Alex (Humanoid): " .. obj.Name .. " di posisi: " .. tostring(rootPart.Position))
                    return obj
                end
            end
        end
        
        -- Cek jika ada Part dengan nama Alex
        if obj:IsA("Part") and obj.Name:lower():find("alex") and obj.Parent:IsA("Model") then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
            if rootPart then
                print("[Fish It! Hack] Ditemukan NPC Alex (Part): " .. model.Name .. " di posisi: " .. tostring(rootPart.Position))
                return model
            end
        end
        
        -- Cek juga untuk StringValue atau ObjectValue yang mungkin berisi nama Alex
        if (obj:IsA("StringValue") or obj:IsA("ObjectValue")) and obj.Name:lower():find("alex") and obj.Parent:IsA("Model") then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
            if rootPart then
                print("[Fish It! Hack] Ditemukan NPC Alex (Value): " .. model.Name .. " di posisi: " .. tostring(rootPart.Position))
                return model
            end
        end
    end
    
    print("[Fish It! Hack] NPC Alex tidak ditemukan di workspace")
    return nil
end

-- Fungsi untuk teleport ke Alex (sekali saja)
local function teleportToAlex()
    print("[Fish It! Hack] Memulai teleport ke Alex...")
    
    local alexNPC = findAlexNPC()
    if alexNPC then
        local playerCharacter = player.Character
        if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
            local alexRootPart = alexNPC:FindFirstChild("HumanoidRootPart") or 
                               alexNPC:FindFirstChild("Torso") or 
                               alexNPC:FindFirstChild("UpperTorso")
            
            if alexRootPart then
                local alexPosition = alexRootPart.Position
                local playerPosition = playerCharacter.HumanoidRootPart.Position
                local distance = (alexPosition - playerPosition).Magnitude
                
                print("[Fish It! Hack] Jarak ke Alex: " .. math.floor(distance) .. " studs")
                
                -- Teleport sedikit di depan Alex agar tidak overlap
                local offsetPosition = alexPosition + Vector3.new(3, 0, 3)
                
                -- Gunakan CFrame dengan orientasi yang benar
                playerCharacter.HumanoidRootPart.CFrame = CFrame.new(offsetPosition, alexPosition)
                
                -- Verifikasi teleport berhasil
                wait(0.1)
                local newPosition = playerCharacter.HumanoidRootPart.Position
                local newDistance = (alexPosition - newPosition).Magnitude
                
                if newDistance < 10 then
                    print("[Fish It! Hack] Teleport ke Alex berhasil! Posisi: " .. tostring(offsetPosition))
                    return true
                else
                    print("[Fish It! Hack] Teleport ke Alex gagal, mencoba lagi...")
                    -- Retry dengan posisi yang berbeda
                    local retryPosition = alexPosition + Vector3.new(-3, 0, -3)
                    playerCharacter.HumanoidRootPart.CFrame = CFrame.new(retryPosition)
                    print("[Fish It! Hack] Retry teleport ke Alex dengan posisi: " .. tostring(retryPosition))
                    return true
                end
            else
                print("[Fish It! Hack] Alex ditemukan tapi tidak ada HumanoidRootPart/Torso")
            end
        else
            print("[Fish It! Hack] Player character tidak ditemukan")
        end
    else
        print("[Fish It! Hack] NPC Alex tidak ditemukan!")
    end
    return false
end

-- Fungsi untuk mencari NPC Jed
local function findJedNPC()
    print("[Fish It! Hack] Mencari NPC Jed di workspace...")
    
    -- Cari di workspace utama dengan pencarian yang lebih komprehensif
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local objName = obj.Name:lower()
            -- Cek berbagai variasi nama Jed/Jedd
            if objName:find("jed") or objName == "jed" or obj.Name == "Jed" or obj.Name == "JED" or obj.Name == "Jedd" or objName:find("jedd") then
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                if rootPart then
                    print("[Fish It! Hack] Ditemukan NPC Jed: " .. obj.Name .. " di posisi: " .. tostring(rootPart.Position))
                    return obj
                end
            end
            
            -- Cek jika ada Humanoid dengan nama Jed
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and (objName:find("jed") or objName:find("jedd")) then
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                if rootPart then
                    print("[Fish It! Hack] Ditemukan NPC Jed (Humanoid): " .. obj.Name .. " di posisi: " .. tostring(rootPart.Position))
                    return obj
                end
            end
        end
        
        -- Cek jika ada Part dengan nama Jed
        if obj:IsA("Part") and (obj.Name:lower():find("jed") or obj.Name:lower():find("jedd")) and obj.Parent:IsA("Model") then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
            if rootPart then
                print("[Fish It! Hack] Ditemukan NPC Jed (Part): " .. model.Name .. " di posisi: " .. tostring(rootPart.Position))
                return model
            end
        end
        
        -- Cek juga untuk StringValue atau ObjectValue yang mungkin berisi nama Jed
        if (obj:IsA("StringValue") or obj:IsA("ObjectValue")) and (obj.Name:lower():find("jed") or obj.Name:lower():find("jedd")) and obj.Parent:IsA("Model") then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
            if rootPart then
                print("[Fish It! Hack] Ditemukan NPC Jed (Value): " .. model.Name .. " di posisi: " .. tostring(rootPart.Position))
                return model
            end
        end
    end
    
    print("[Fish It! Hack] NPC Jed tidak ditemukan di workspace")
    return nil
end

-- Fungsi untuk teleport ke Jed (sekali saja)
local function teleportToJed()
    print("[Fish It! Hack] Memulai teleport ke Jed...")
    
    local jedNPC = findJedNPC()
    if jedNPC then
        local playerCharacter = player.Character
        if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
            local jedRootPart = jedNPC:FindFirstChild("HumanoidRootPart") or 
                               jedNPC:FindFirstChild("Torso") or 
                               jedNPC:FindFirstChild("UpperTorso")
            
            if jedRootPart then
                local jedPosition = jedRootPart.Position
                local playerPosition = playerCharacter.HumanoidRootPart.Position
                local distance = (jedPosition - playerPosition).Magnitude
                
                print("[Fish It! Hack] Jarak ke Jed: " .. math.floor(distance) .. " studs")
                
                -- Teleport sedikit di depan Jed agar tidak overlap
                local offsetPosition = jedPosition + Vector3.new(3, 0, 3)
                
                -- Gunakan CFrame dengan orientasi yang benar
                playerCharacter.HumanoidRootPart.CFrame = CFrame.new(offsetPosition, jedPosition)
                
                -- Verifikasi teleport berhasil
                wait(0.1)
                local newPosition = playerCharacter.HumanoidRootPart.Position
                local newDistance = (jedPosition - newPosition).Magnitude
                
                if newDistance < 10 then
                    print("[Fish It! Hack] Teleport ke Jed berhasil! Posisi: " .. tostring(offsetPosition))
                    return true
                else
                    print("[Fish It! Hack] Teleport ke Jed gagal, mencoba lagi...")
                    -- Retry dengan posisi yang berbeda
                    local retryPosition = jedPosition + Vector3.new(-3, 0, -3)
                    playerCharacter.HumanoidRootPart.CFrame = CFrame.new(retryPosition)
                    print("[Fish It! Hack] Retry teleport ke Jed dengan posisi: " .. tostring(retryPosition))
                    return true
                end
            else
                print("[Fish It! Hack] Jed ditemukan tapi tidak ada HumanoidRootPart/Torso")
            end
        else
            print("[Fish It! Hack] Player character tidak ditemukan")
        end
    else
        print("[Fish It! Hack] NPC Jed tidak ditemukan!")
    end
    return false
end

-- Variabel untuk Go to Player
local selectedPlayerName = ""
local playerListVisible = false

-- Fungsi untuk mendapatkan daftar semua player
local function getAllPlayers()
    local playerList = {}
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(playerList, otherPlayer)
        end
    end
    return playerList
end

-- Fungsi untuk teleport ke player tertentu
local function teleportToPlayer(targetPlayerName)
    print("[Fish It! Hack] Mencari player: " .. targetPlayerName)
    
    local targetPlayer = nil
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Name == targetPlayerName or otherPlayer.DisplayName == targetPlayerName then
            targetPlayer = otherPlayer
            break
        end
    end
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local playerCharacter = player.Character
        if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
            local playerPosition = playerCharacter.HumanoidRootPart.Position
            local distance = (targetPosition - playerPosition).Magnitude
            
            print("[Fish It! Hack] Jarak ke " .. targetPlayer.DisplayName .. ": " .. math.floor(distance) .. " studs")
            
            -- Teleport sedikit di belakang player target agar tidak overlap
            local offsetPosition = targetPosition + Vector3.new(-3, 0, -3)
            
            -- Gunakan CFrame dengan orientasi yang benar
            playerCharacter.HumanoidRootPart.CFrame = CFrame.new(offsetPosition, targetPosition)
            
            -- Verifikasi teleport berhasil
            wait(0.1)
            local newPosition = playerCharacter.HumanoidRootPart.Position
            local newDistance = (targetPosition - newPosition).Magnitude
            
            if newDistance < 15 then
                print("[Fish It! Hack] Teleport ke " .. targetPlayer.DisplayName .. " berhasil!")
                return true
            else
                print("[Fish It! Hack] Teleport ke " .. targetPlayer.DisplayName .. " gagal, mencoba lagi...")
                -- Retry dengan posisi yang berbeda
                local retryPosition = targetPosition + Vector3.new(3, 0, 3)
                playerCharacter.HumanoidRootPart.CFrame = CFrame.new(retryPosition)
                print("[Fish It! Hack] Retry teleport ke " .. targetPlayer.DisplayName)
                return true
            end
        else
            print("[Fish It! Hack] Player character tidak ditemukan")
        end
    else
        print("[Fish It! Hack] Player " .. targetPlayerName .. " tidak ditemukan atau tidak memiliki character!")
    end
    return false
end

-- Fungsi untuk toggle player list visibility
local function togglePlayerList()
    playerListVisible = not playerListVisible
    
    -- Update player list frame visibility
    if playerListFrame then
        playerListFrame.Visible = playerListVisible
        
        if playerListVisible then
            -- Update player list
            updatePlayerList()
        end
    end
end

-- Fungsi untuk update player list
local function updatePlayerList()
    if not playerListFrame then return end
    
    -- Clear existing buttons
    for _, child in pairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Name:find("PlayerButton") then
            child:Destroy()
        end
    end
    
    local playerList = getAllPlayers()
    local yOffset = 30
    
    for i, otherPlayer in pairs(playerList) do
        local playerButton = Instance.new("TextButton")
        playerButton.Name = "PlayerButton" .. i
        playerButton.Size = UDim2.new(1, -10, 0, 25)
        playerButton.Position = UDim2.new(0, 5, 0, yOffset)
        playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        playerButton.BorderSizePixel = 0
        playerButton.Text = otherPlayer.DisplayName .. " (@" .. otherPlayer.Name .. ")"
        playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        playerButton.TextScaled = true
        playerButton.Font = Enum.Font.Gotham
        playerButton.Parent = playerListFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = playerButton
        
        -- Event untuk teleport ke player
        playerButton.MouseButton1Click:Connect(function()
            teleportToPlayer(otherPlayer.Name)
            togglePlayerList() -- Hide list after selection
        end)
        
        yOffset = yOffset + 30
    end
    
    -- Update frame size based on number of players
    local frameHeight = math.max(100, yOffset + 10)
    playerListFrame.Size = UDim2.new(0, 250, 0, frameHeight)
end





-- Fungsi untuk mencari pinggir laut berdasarkan text atau part
local function findOceanEdge()
    -- Method 1: Cari berdasarkan text "Click to cast your rod!"
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "FishItAutoFishingGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    if obj.Text and obj.Text:lower():find("click to cast") then
                        print("[Fish It! Hack] Ditemukan area fishing berdasarkan text: " .. obj.Text)
                        return true
                    end
                end
            end
        end
    end
    
    -- Method 2: Cari berdasarkan part di workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") then
            -- Cari part yang berkaitan dengan fishing area
            if obj.Name:lower():find("water") or obj.Name:lower():find("ocean") or obj.Name:lower():find("sea") then
                local playerPos = character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
                if playerPos then
                    local distance = (obj.Position - playerPos).Magnitude
                    if distance < 9999 then -- Radius maksimum untuk teleport Alex/Jedd dari jarak manapun
                        print("[Fish It! Hack] Ditemukan area fishing berdasarkan part: " .. obj.Name)
                        return true
                    end
                end
            end
        end
    end
    
    return false
end





-- Fungsi untuk mencari lokasi pinggir laut untuk teleport
local function findOceanTeleportLocation()
    -- Cari spawn point atau area fishing yang aman
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            -- Cek apakah spawn dekat dengan area fishing
            local spawnPos = obj.Position
            for _, waterPart in pairs(workspace:GetDescendants()) do
                if waterPart:IsA("Part") and (waterPart.Name:lower():find("water") or waterPart.Name:lower():find("ocean")) then
                    local distance = (waterPart.Position - spawnPos).Magnitude
                    if distance < 100 then
                        print("[Fish It! Hack] Ditemukan lokasi teleport dekat air: " .. obj.Name)
                        return spawnPos + Vector3.new(0, 5, 0) -- Sedikit di atas spawn
                    end
                end
            end
        end
    end
    
    -- Fallback: cari part dengan nama yang mengindikasikan area fishing
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and (obj.Name:lower():find("dock") or obj.Name:lower():find("pier") or obj.Name:lower():find("fishing")) then
            print("[Fish It! Hack] Ditemukan area fishing: " .. obj.Name)
            return obj.Position + Vector3.new(0, 5, 0)
        end
    end
    
    -- Fallback terakhir: koordinat default yang biasanya dekat laut
    print("[Fish It! Hack] Menggunakan koordinat default untuk area fishing")
    return Vector3.new(0, 10, 0)
end

-- Fungsi untuk auto teleport ke pinggir laut
local function autoTeleportToOcean()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local teleportPos = findOceanTeleportLocation()
        character.HumanoidRootPart.CFrame = CFrame.new(teleportPos)
        print("[Fish It! Hack] Auto teleport ke pinggir laut: " .. tostring(teleportPos))
        return true
    end
    return false
end

-- Fungsi untuk Auto Fish loop
local function autoFishLoop()
    if autoFishModeEnabled then
        -- Cek apakah sudah di pinggir laut (dengan radius yang lebih besar)
        if not findOceanEdge() then
            -- Jika belum di pinggir laut, teleport dulu
            autoTeleportToOcean()
            wait(1) -- Tunggu setelah teleport
        end
        
        -- Lakukan auto click untuk fishing
        performFastClick()
    end
end

-- Fungsi untuk toggle Auto Fish
local function toggleAutoFish()
    autoFishModeEnabled = not autoFishModeEnabled
    
    if autoFishModeEnabled then
        print("[Fish It! Hack] Auto Fish AKTIF (Background Mode) - Auto teleport + Auto click")
        autoFishConnection = RunService.Heartbeat:Connect(function()
            -- Check if we should continue in background mode
            if backgroundMode or UserInputService.WindowFocused then
                autoFishLoop()
            end
            wait(clickSpeed)
        end)
    else
        print("[Fish It! Hack] Auto Fish NONAKTIF")
        if autoFishConnection then
            autoFishConnection:Disconnect()
            autoFishConnection = nil
        end
    end
end

-- Buat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishItAutoFishingGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 590)
mainFrame.Position = UDim2.new(1, -290, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Corner untuk frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐟 Fish It! Auto Fishing 🎣"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Auto Fishing Status
local fishingStatusLabel = Instance.new("TextLabel")
fishingStatusLabel.Name = "FishingStatusLabel"
fishingStatusLabel.Size = UDim2.new(1, -10, 0, 20)
fishingStatusLabel.Position = UDim2.new(0, 5, 0, 40)
fishingStatusLabel.BackgroundTransparency = 1
fishingStatusLabel.Text = "Auto Click: OFF"
fishingStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
fishingStatusLabel.TextScaled = true
fishingStatusLabel.Font = Enum.Font.Gotham
fishingStatusLabel.Parent = mainFrame

-- Auto Shake Status
local shakeStatusLabel = Instance.new("TextLabel")
shakeStatusLabel.Name = "ShakeStatusLabel"
shakeStatusLabel.Size = UDim2.new(1, -10, 0, 20)
shakeStatusLabel.Position = UDim2.new(0, 5, 0, 65)
shakeStatusLabel.BackgroundTransparency = 1
shakeStatusLabel.Text = "Super Click: OFF"
shakeStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
shakeStatusLabel.TextScaled = true
shakeStatusLabel.Font = Enum.Font.Gotham
shakeStatusLabel.Parent = mainFrame

-- Auto Fish Status
local autoFishStatusLabel = Instance.new("TextLabel")
autoFishStatusLabel.Name = "AutoFishStatusLabel"
autoFishStatusLabel.Size = UDim2.new(1, -10, 0, 20)
autoFishStatusLabel.Position = UDim2.new(0, 5, 0, 85)
autoFishStatusLabel.BackgroundTransparency = 1
autoFishStatusLabel.Text = "Auto Fish: OFF"
autoFishStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
autoFishStatusLabel.TextScaled = true
autoFishStatusLabel.Font = Enum.Font.Gotham
autoFishStatusLabel.Parent = mainFrame

-- Click Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0.5, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 5, 0, 110)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Click Delay:"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- Speed Input
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(0.4, -10, 0, 20)
speedInput.Position = UDim2.new(0.6, 0, 0, 110)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.BorderSizePixel = 0
speedInput.Text = tostring(clickSpeed)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextScaled = true
speedInput.Font = Enum.Font.Gotham
speedInput.PlaceholderText = "0.001"
speedInput.Parent = mainFrame





local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = speedInput



-- Auto Fishing Toggle Button
local fishingToggleButton = Instance.new("TextButton")
fishingToggleButton.Name = "FishingToggleButton"
fishingToggleButton.Size = UDim2.new(1, -10, 0, 30)
fishingToggleButton.Position = UDim2.new(0, 5, 0, 135)
fishingToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
fishingToggleButton.BorderSizePixel = 0
fishingToggleButton.Text = "🎣 START AUTO CLICK"
fishingToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
fishingToggleButton.TextScaled = true
fishingToggleButton.Font = Enum.Font.GothamBold
fishingToggleButton.Parent = mainFrame

local fishingButtonCorner = Instance.new("UICorner")
fishingButtonCorner.CornerRadius = UDim.new(0, 6)
fishingButtonCorner.Parent = fishingToggleButton

-- Auto Shake Toggle Button
local shakeToggleButton = Instance.new("TextButton")
shakeToggleButton.Name = "ShakeToggleButton"
shakeToggleButton.Size = UDim2.new(1, -10, 0, 30)
shakeToggleButton.Position = UDim2.new(0, 5, 0, 165)
shakeToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 220)
shakeToggleButton.BorderSizePixel = 0
shakeToggleButton.Text = "⚡ START SUPER CLICK"
shakeToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shakeToggleButton.TextScaled = true
shakeToggleButton.Font = Enum.Font.GothamBold
shakeToggleButton.Parent = mainFrame

-- Auto Fish Toggle Button
local autoFishToggleButton = Instance.new("TextButton")
autoFishToggleButton.Name = "AutoFishToggleButton"
autoFishToggleButton.Size = UDim2.new(1, -10, 0, 30)
autoFishToggleButton.Position = UDim2.new(0, 5, 0, 205)
autoFishToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
autoFishToggleButton.BorderSizePixel = 0
autoFishToggleButton.Text = "🐟 START AUTO FISH"
autoFishToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFishToggleButton.TextScaled = true
autoFishToggleButton.Font = Enum.Font.GothamBold
autoFishToggleButton.Parent = mainFrame

local autoFishButtonCorner = Instance.new("UICorner")
autoFishButtonCorner.CornerRadius = UDim.new(0, 6)
autoFishButtonCorner.Parent = autoFishToggleButton



-- Teleport to Alex Button (sekali saja)
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Size = UDim2.new(0.48, -2.5, 0, 30)
teleportButton.Position = UDim2.new(0, 5, 0, 245)
teleportButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
teleportButton.BorderSizePixel = 0
teleportButton.Text = "🚀 TELEPORT ALEX"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextScaled = true
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Parent = mainFrame

local teleportButtonCorner = Instance.new("UICorner")
teleportButtonCorner.CornerRadius = UDim.new(0, 6)
teleportButtonCorner.Parent = teleportButton

-- Teleport to Jed Button
local teleportJedButton = Instance.new("TextButton")
teleportJedButton.Name = "TeleportJedButton"
teleportJedButton.Size = UDim2.new(0.48, -2.5, 0, 30)
teleportJedButton.Position = UDim2.new(0.52, 2.5, 0, 245)
teleportJedButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
teleportJedButton.BorderSizePixel = 0
teleportJedButton.Text = "🚀 TELEPORT JED"
teleportJedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportJedButton.TextScaled = true
teleportJedButton.Font = Enum.Font.GothamBold
teleportJedButton.Parent = mainFrame

local teleportJedButtonCorner = Instance.new("UICorner")
teleportJedButtonCorner.CornerRadius = UDim.new(0, 6)
teleportJedButtonCorner.Parent = teleportJedButton

-- Go to Player Button
local goToPlayerButton = Instance.new("TextButton")
goToPlayerButton.Name = "GoToPlayerButton"
goToPlayerButton.Size = UDim2.new(1, -10, 0, 30)
goToPlayerButton.Position = UDim2.new(0, 5, 0, 285)
goToPlayerButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
goToPlayerButton.BorderSizePixel = 0
goToPlayerButton.Text = "👥 GO TO PLAYER (P)"
goToPlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
goToPlayerButton.TextScaled = true
goToPlayerButton.Font = Enum.Font.GothamBold
goToPlayerButton.Parent = mainFrame

local goToPlayerButtonCorner = Instance.new("UICorner")
goToPlayerButtonCorner.CornerRadius = UDim.new(0, 6)
goToPlayerButtonCorner.Parent = goToPlayerButton

-- Player List Frame
local playerListFrame = Instance.new("Frame")
playerListFrame.Name = "PlayerListFrame"
playerListFrame.Size = UDim2.new(0, 250, 0, 200)
playerListFrame.Position = UDim2.new(0, 270, 0, 50)
playerListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerListFrame.BorderSizePixel = 0
playerListFrame.Visible = false
playerListFrame.Parent = screenGui

local playerListFrameCorner = Instance.new("UICorner")
playerListFrameCorner.CornerRadius = UDim.new(0, 10)
playerListFrameCorner.Parent = playerListFrame

-- Player List Title
local playerListTitle = Instance.new("TextLabel")
playerListTitle.Name = "PlayerListTitle"
playerListTitle.Size = UDim2.new(1, 0, 0, 25)
playerListTitle.Position = UDim2.new(0, 0, 0, 0)
playerListTitle.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
playerListTitle.BorderSizePixel = 0
playerListTitle.Text = "Select Player to Teleport"
playerListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
playerListTitle.TextScaled = true
playerListTitle.Font = Enum.Font.GothamBold
playerListTitle.Parent = playerListFrame

local playerListTitleCorner = Instance.new("UICorner")
playerListTitleCorner.CornerRadius = UDim.new(0, 10)
playerListTitleCorner.Parent = playerListTitle

-- Background Mode Toggle Button
local backgroundButton = Instance.new("TextButton")
backgroundButton.Name = "BackgroundButton"
backgroundButton.Size = UDim2.new(1, -10, 0, 25)
backgroundButton.Position = UDim2.new(0, 5, 0, 385)
backgroundButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
backgroundButton.BorderSizePixel = 0
backgroundButton.Text = "Background Mode: ON"
backgroundButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backgroundButton.TextScaled = true
backgroundButton.Font = Enum.Font.Gotham
backgroundButton.Parent = mainFrame

local backgroundButtonCorner = Instance.new("UICorner")
backgroundButtonCorner.CornerRadius = UDim.new(0, 6)
backgroundButtonCorner.Parent = backgroundButton

-- Speed Hack Button
local speedButton = Instance.new("TextButton")
speedButton.Name = "SpeedButton"
speedButton.Size = UDim2.new(0.48, -2.5, 0, 25)
speedButton.Position = UDim2.new(0, 5, 0, 325)
speedButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0) -- Orange
speedButton.BorderSizePixel = 0
speedButton.Text = "Speed: OFF"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextScaled = true
speedButton.Font = Enum.Font.Gotham
speedButton.Parent = mainFrame

local speedButtonCorner = Instance.new("UICorner")
speedButtonCorner.CornerRadius = UDim.new(0, 6)
speedButtonCorner.Parent = speedButton

-- Speed Input TextBox
local speedInputBox = Instance.new("TextBox")
speedInputBox.Name = "SpeedInputBox"
speedInputBox.Size = UDim2.new(0.48, -2.5, 0, 25)
speedInputBox.Position = UDim2.new(0.52, 2.5, 0, 325)
speedInputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInputBox.BorderSizePixel = 0
speedInputBox.Text = "100"
speedInputBox.PlaceholderText = "Speed Value"
speedInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInputBox.TextScaled = true
speedInputBox.Font = Enum.Font.Gotham
speedInputBox.Parent = mainFrame

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 6)
speedInputCorner.Parent = speedInputBox

-- Fly Hack Button
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Size = UDim2.new(0.48, -2.5, 0, 25)
flyButton.Position = UDim2.new(0, 5, 0, 355)
flyButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple
flyButton.BorderSizePixel = 0
flyButton.Text = "Fly: OFF"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextScaled = true
flyButton.Font = Enum.Font.Gotham
flyButton.Parent = mainFrame

local flyButtonCorner = Instance.new("UICorner")
flyButtonCorner.CornerRadius = UDim.new(0, 6)
flyButtonCorner.Parent = flyButton

-- Fly Speed Input TextBox
local flySpeedInputBox = Instance.new("TextBox")
flySpeedInputBox.Name = "FlySpeedInputBox"
flySpeedInputBox.Size = UDim2.new(0.48, -2.5, 0, 25)
flySpeedInputBox.Position = UDim2.new(0.52, 2.5, 0, 355)
flySpeedInputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flySpeedInputBox.BorderSizePixel = 0
flySpeedInputBox.Text = "50"
flySpeedInputBox.PlaceholderText = "Fly Speed"
flySpeedInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedInputBox.TextScaled = true
flySpeedInputBox.Font = Enum.Font.Gotham
flySpeedInputBox.Parent = mainFrame

local flySpeedInputCorner = Instance.new("UICorner")
flySpeedInputCorner.CornerRadius = UDim.new(0, 6)
flySpeedInputCorner.Parent = flySpeedInputBox

local shakeButtonCorner = Instance.new("UICorner")
shakeButtonCorner.CornerRadius = UDim.new(0, 6)
shakeButtonCorner.Parent = shakeToggleButton



-- Info Label
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(1, -10, 0, 160)
infoLabel.Position = UDim2.new(0, 5, 0, 415)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Hotkeys:\nF - Auto Click\nG - Super Click\nH - Auto Fish\nT - Teleport Alex\nY - Teleport Jed\nP - Go to Player\nB - Background Mode\nX - Speed Hack\nC - Fly Hack\n\nSpeed: Ketik nilai di input box (1-500)\nFly Speed: Ketik nilai di input box (1-200)\nFly Controls: WASD + Space/Shift"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = mainFrame

-- Event handlers
speedInput.FocusLost:Connect(function()
    setClickSpeed(speedInput.Text)
    -- Update status jika auto shake aktif
    if autoShakeEnabled then
        shakeStatusLabel.Text = "Super Click: ON - " .. math.floor(1/clickSpeed) .. " CPS"
    end
end)



-- Auto Fishing Toggle
fishingToggleButton.MouseButton1Click:Connect(function()
    toggleAutoFishing()
    
    if autoFishEnabled then
        fishingToggleButton.Text = "🛑 STOP AUTO CLICK"
        fishingToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        fishingStatusLabel.Text = "Auto Click: ON"
        fishingStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        fishingToggleButton.Text = "🎣 START AUTO CLICK"
        fishingToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        fishingStatusLabel.Text = "Auto Click: OFF"
        fishingStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Auto Shake Toggle
shakeToggleButton.MouseButton1Click:Connect(function()
    toggleAutoShake()
    
    if autoShakeEnabled then
        shakeToggleButton.Text = "🛑 STOP SUPER CLICK"
        shakeToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        shakeStatusLabel.Text = "Super Click: ON - " .. math.floor(1/clickSpeed) .. " CPS"
        shakeStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        shakeToggleButton.Text = "⚡ START SUPER CLICK"
        shakeToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 220)
        shakeStatusLabel.Text = "Super Click: OFF"
        shakeStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Auto Fish Toggle
autoFishToggleButton.MouseButton1Click:Connect(function()
    toggleAutoFish()
    
    if autoFishModeEnabled then
        autoFishToggleButton.Text = "🛑 STOP AUTO FISH"
        autoFishToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        autoFishStatusLabel.Text = "Auto Fish: ON (Teleport + Click)"
        autoFishStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        autoFishToggleButton.Text = "🐟 START AUTO FISH"
        autoFishToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        autoFishStatusLabel.Text = "Auto Fish: OFF"
        autoFishStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)



-- Teleport Button Events
teleportButton.MouseButton1Click:Connect(function()
    teleportToAlex()
end)

teleportJedButton.MouseButton1Click:Connect(function()
    teleportToJed()
end)

-- Go to Player Button Event
goToPlayerButton.MouseButton1Click:Connect(function()
    togglePlayerList()
end)

-- Speed Input Box Events
speedInputBox.FocusLost:Connect(function(enterPressed)
    local speedValue = tonumber(speedInputBox.Text)
    if not speedValue then
        speedInputBox.Text = "100"
        speedValue = 100
    elseif speedValue < 1 then
        speedInputBox.Text = "1"
        speedValue = 1
    elseif speedValue > 500 then
        speedInputBox.Text = "500"
        speedValue = 500
    end
    
    -- Update speed if currently enabled
    if speedEnabled and character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = speedValue
        character.Humanoid.JumpPower = speedValue * 1.2
        print("[Fish It! Hack] Speed diperbarui: WalkSpeed: " .. speedValue .. ", JumpPower: " .. (speedValue * 1.2))
    end
end)

-- Fly Speed Input Box Events
flySpeedInputBox.FocusLost:Connect(function(enterPressed)
    local flySpeedValue = tonumber(flySpeedInputBox.Text)
    if not flySpeedValue then
        flySpeedInputBox.Text = "50"
        flySpeedValue = 50
    elseif flySpeedValue < 1 then
        flySpeedInputBox.Text = "1"
        flySpeedValue = 1
    elseif flySpeedValue > 200 then
        flySpeedInputBox.Text = "200"
        flySpeedValue = 200
    end
    
    print("[Fish It! Hack] Fly speed diperbarui: " .. flySpeedValue)
end)


-- Fungsi untuk toggle background mode
local function toggleBackgroundMode()
    backgroundMode = not backgroundMode
    backgroundButton.Text = "Background Mode: " .. (backgroundMode and "ON" or "OFF")
    backgroundButton.BackgroundColor3 = backgroundMode and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    
    local status = backgroundMode and "AKTIF" or "NONAKTIF"
    print("[Fish It! Hack] Background Mode " .. status .. " - Script akan " .. (backgroundMode and "tetap berjalan" or "berhenti") .. " saat tab tidak fokus")
end

-- Fungsi untuk toggle speed hack
local function toggleSpeed()
    speedEnabled = not speedEnabled
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if speedEnabled then
            normalWalkSpeed = humanoid.WalkSpeed
            normalJumpPower = humanoid.JumpPower
            
            local speedValue = tonumber(speedInputBox.Text) or 100
            if speedValue < 1 then speedValue = 1 end
            if speedValue > 500 then speedValue = 500 end
            
            humanoid.WalkSpeed = speedValue
            humanoid.JumpPower = speedValue * 1.2
            print("[Fish It! Hack] Speed Hack AKTIF - WalkSpeed: " .. speedValue .. ", JumpPower: " .. (speedValue * 1.2))
        else
            humanoid.WalkSpeed = normalWalkSpeed
            humanoid.JumpPower = normalJumpPower
            print("[Fish It! Hack] Speed Hack NONAKTIF - Speed normal")
        end
    end
end

-- Fungsi untuk toggle fly hack
local function toggleFly()
    flyEnabled = not flyEnabled
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        
        if flyEnabled then
            -- Update fly speed from input
            flySpeed = tonumber(flySpeedInputBox.Text) or 50
            if flySpeed < 1 then flySpeed = 1 end
            if flySpeed > 200 then flySpeed = 200 end
            
            -- Create BodyVelocity for fly
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart
            
            -- Create BodyAngularVelocity for stability
            bodyAngularVelocity = Instance.new("BodyAngularVelocity")
            bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
            bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
            bodyAngularVelocity.Parent = rootPart
            
            print("[Fish It! Hack] Fly Hack AKTIF - Speed: " .. flySpeed .. " - Gunakan WASD + Space/Shift untuk terbang")
        else
            -- Remove fly components
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
            if bodyAngularVelocity then
                bodyAngularVelocity:Destroy()
                bodyAngularVelocity = nil
            end
            print("[Fish It! Hack] Fly Hack NONAKTIF")
        end
    end
end

-- Background Button Event
backgroundButton.MouseButton1Click:Connect(function()
    toggleBackgroundMode()
end)

-- Speed Button Event
speedButton.MouseButton1Click:Connect(function()
    toggleSpeed()
    speedButton.Text = "Speed: " .. (speedEnabled and "ON" or "OFF")
    speedButton.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 140, 0)
end)

-- Fly Button Event
flyButton.MouseButton1Click:Connect(function()
    toggleFly()
    flyButton.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    flyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(138, 43, 226)
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- F untuk toggle auto fishing
        if input.KeyCode == Enum.KeyCode.F then
            toggleAutoFishing()
            
            if autoFishEnabled then
                fishingToggleButton.Text = "🛑 STOP AUTO CLICK"
                fishingToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
                fishingStatusLabel.Text = "Auto Click: ON"
                fishingStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                fishingToggleButton.Text = "🎣 START AUTO CLICK"
                fishingToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
                fishingStatusLabel.Text = "Auto Click: OFF"
                fishingStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        
        -- G untuk toggle auto shake
        if input.KeyCode == Enum.KeyCode.G then
            toggleAutoShake()
            
            if autoShakeEnabled then
                shakeToggleButton.Text = "🛑 STOP SUPER CLICK"
                shakeToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
                shakeStatusLabel.Text = "Super Click: ON - " .. math.floor(1/clickSpeed) .. " CPS"
                shakeStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                shakeToggleButton.Text = "⚡ START SUPER CLICK"
                shakeToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 220)
                shakeStatusLabel.Text = "Super Click: OFF"
                shakeStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        
        -- H untuk toggle auto fish
        elseif input.KeyCode == Enum.KeyCode.H then
            autoFishToggleButton.MouseButton1Click:Fire()
        
        -- T untuk teleport ke Alex (sekali saja)
        elseif input.KeyCode == Enum.KeyCode.T then
            teleportButton.MouseButton1Click:Fire()
        
        -- Y untuk teleport ke Jed
        elseif input.KeyCode == Enum.KeyCode.Y then
            teleportJedButton.MouseButton1Click:Fire()
        
        -- P untuk toggle player list
        elseif input.KeyCode == Enum.KeyCode.P then
            togglePlayerList()
        
        -- B untuk toggle background mode
         elseif input.KeyCode == Enum.KeyCode.B then
             toggleBackgroundMode()
         
         -- X untuk speed hack
         elseif input.KeyCode == Enum.KeyCode.X then
             toggleSpeed()
             speedButton.Text = "Speed: " .. (speedEnabled and "ON" or "OFF")
             speedButton.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 140, 0)
         
         -- C untuk fly hack
         elseif input.KeyCode == Enum.KeyCode.C then
             toggleFly()
             flyButton.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
             flyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(138, 43, 226)
         

     end
 end)

-- Window focus detection untuk debugging
UserInputService.WindowFocusReleased:Connect(function()
    lastWindowFocus = false
    if backgroundMode then
        print("[Fish It! Hack] Window tidak fokus - Background mode aktif, script tetap berjalan")
    else
        print("[Fish It! Hack] Window tidak fokus - Background mode nonaktif, script dihentikan")
    end
end)

UserInputService.WindowFocused:Connect(function()
    lastWindowFocus = true
    print("[Fish It! Hack] Window fokus kembali - Script berjalan normal")
end)

-- Fly movement variables
local flySpeed = 50
local keys = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    LeftShift = false
}

-- Key press detection for fly
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        keys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then
        keys.Space = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        keys.LeftShift = true
    end
end)

-- Key release detection for fly
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        keys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then
        keys.Space = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        keys.LeftShift = false
    end
end)

-- Fly movement loop
RunService.Heartbeat:Connect(function()
    if flyEnabled and bodyVelocity and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local velocity = Vector3.new(0, 0, 0)
        
        -- Update fly speed from input box
        local currentFlySpeed = tonumber(flySpeedInputBox.Text) or 50
        if currentFlySpeed < 1 then currentFlySpeed = 1 end
        if currentFlySpeed > 200 then currentFlySpeed = 200 end
        
        -- Calculate movement direction based on camera
        local cameraCFrame = camera.CFrame
        local forward = cameraCFrame.LookVector
        local right = cameraCFrame.RightVector
        local up = Vector3.new(0, 1, 0)
        
        -- Movement calculations
        if keys.W then
            velocity = velocity + forward * currentFlySpeed
        end
        if keys.S then
            velocity = velocity - forward * currentFlySpeed
        end
        if keys.A then
            velocity = velocity - right * currentFlySpeed
        end
        if keys.D then
            velocity = velocity + right * currentFlySpeed
        end
        if keys.Space then
            velocity = velocity + up * currentFlySpeed
        end
        if keys.LeftShift then
            velocity = velocity - up * currentFlySpeed
        end
        
        bodyVelocity.Velocity = velocity
    end
end)

-- Character respawn handler untuk speed dan fly
player.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to fully load
    
    -- Re-apply speed hack if it was enabled
    if speedEnabled then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 100
        humanoid.JumpPower = 120
        print("[Fish It! Hack] Speed hack re-applied after respawn")
    end
    
    -- Re-apply fly hack if it was enabled
    if flyEnabled then
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- Clean up old fly components
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
        if bodyAngularVelocity then
            bodyAngularVelocity:Destroy()
        end
        
        -- Create new fly components
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        bodyAngularVelocity.Parent = rootPart
        
        print("[Fish It! Hack] Fly hack re-applied after respawn")
    end
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Update character reference saat respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
end)

-- Cleanup saat player leave
player.AncestryChanged:Connect(function()
    if not player.Parent then
        if fishingConnection then
            fishingConnection:Disconnect()
        end
        if shakeConnection then
            shakeConnection:Disconnect()
        end
        if reelConnection then
            reelConnection:Disconnect()
        end
        if autoFishConnection then
            autoFishConnection:Disconnect()
        end

    end
end)

print("[Fish It! Auto Fishing Hack] Script loaded successfully!")
print("[Fish It! Auto Fishing Hack] Features:")
print("  - Auto Click (F): Klik otomatis super cepat")
print("  - Super Click (G): Klik otomatis dengan kecepatan maksimal")
print("  - Auto Fish (H): Auto teleport + auto click")
print("  - Teleport to Alex (T): Teleport ke NPC Alex")
print("  - Teleport to Jed (Y): Teleport ke NPC Jed")
print("  - Background Mode (B): Script tetap jalan saat tab tidak fokus")
print("  - Speed Hack (X): Meningkatkan WalkSpeed dan JumpPower (Custom Speed: 1-500)")
print("  - Fly Hack (C): Terbang dengan kontrol WASD + Space/Shift (Custom Speed: 1-200)")
print("  - Custom Speed: Ketik nilai kecepatan di input box sebelah tombol Speed/Fly")
print("[Fish It! Auto Fishing Hack] Background Mode: " .. (backgroundMode and "AKTIF" or "NONAKTIF"))
print("[Fish It! Auto Fishing Hack] Equip your fishing rod and start fishing!")
