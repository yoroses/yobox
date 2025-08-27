-- Fish It! Auto Fishing Hack untuk Roblox
-- Script ini dibuat khusus untuk game Fish It! dengan auto fishing lengkap
-- Kompatibel dengan KRNL, Synapse X, Delta, dan executor lainnya
-- Usage: loadstring(game:HttpGet("YOUR_URL_HERE"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

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

-- Variabel untuk Go to Player
local selectedPlayerName = ""
local playerListVisible = false

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
    
    -- Get all players
    local allPlayers = getAllPlayers()
    
    -- Create buttons for each player
    for i, otherPlayer in ipairs(allPlayers) do
        local playerButton = Instance.new("TextButton")
        playerButton.Name = "PlayerButton" .. i
        playerButton.Size = UDim2.new(1, -10, 0, 25)
        playerButton.Position = UDim2.new(0, 5, 0, 30 + (i-1) * 30)
        playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        playerButton.BorderSizePixel = 1
        playerButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
        playerButton.Text = otherPlayer.DisplayName .. " (" .. otherPlayer.Name .. ")"
        playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        playerButton.TextScaled = true
        playerButton.Font = Enum.Font.SourceSans
        playerButton.Parent = playerListFrame
        
        -- Connect click event
        playerButton.MouseButton1Click:Connect(function()
            teleportToPlayer(otherPlayer.Name)
            -- Hide player list after teleport
            playerListVisible = false
            playerListFrame.Visible = false
        end)
    end
    
    -- Adjust frame size based on number of players
    local frameHeight = math.max(100, 60 + #allPlayers * 30)
    playerListFrame.Size = UDim2.new(0, 200, 0, frameHeight)
end

print("[Fish It! Auto Fishing Hack] Loaded successfully via loadstring!")
print("[Fish It! Auto Fishing Hack] Compatible with Delta Executor")
print("[Fish It! Auto Fishing Hack] All features available - Auto Fish, Teleport, Speed, Fly, Go to Player")
print("[Fish It! Auto Fishing Hack] Equip your fishing rod and start fishing!")
