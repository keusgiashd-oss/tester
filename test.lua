-- Prospecting! Keyless Hub
-- Auto Farm + Treasure + Sell + Totem + ESP + Fly

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoDig = false,
    AutoPan = false,
    AutoSell = false,
    AutoTreasure = false,
    AutoTotem = false,
    WalkSpeed = 16,
    Fly = false,
    ESP = false
}

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function equip(name)
    local c = getChar()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not c or not bp then return end
    local tool = c:FindFirstChild(name) or bp:FindFirstChild(name)
    if tool and tool.Parent ~= c then
        tool.Parent = c
    end
    return tool
end

-- Auto Dig
task.spawn(function()
    while task.wait(0.12) do
        if Settings.AutoDig then
            pcall(function()
                equip("Shovel")
                local tool = getChar():FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
    end
end)

-- Auto Pan + Shake
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoPan then
            pcall(function()
                equip("Pan") or equip("Rusty Pan") or equip("Plastic Pan")
                local tool = getChar():FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
    end
end)

-- Auto Sell (teleport ke merchant kalau ada)
task.spawn(function()
    while task.wait(2) do
        if Settings.AutoSell then
            pcall(function()
                local merchant
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("merchant") or v.Name:lower():find("sell") then
                        if v:IsA("BasePart") or (v:IsA("Model") and v.PrimaryPart) then
                            merchant = v:IsA("BasePart") and v or v.PrimaryPart
                            break
                        end
                    end
                end
                if merchant and getRoot() then
                    getRoot().CFrame = merchant.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.5)
                    -- coba interact
                    local prompt = merchant:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end)
        end
    end
end)

-- Auto Treasure / Geode
task.spawn(function()
    while task.wait(0.6) do
        if Settings.AutoTreasure then
            pcall(function()
                local root = getRoot()
                if not root then return end
                local closest, dist = nil, 120
                for _, obj in pairs(workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if n:find("geode") or n:find("treasure") or n:find("chest") then
                        local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
                        if part then
                            local d = (root.Position - part.Position).Magnitude
                            if d < dist then
                                closest = part
                                dist = d
                            end
                        end
                    end
                end
                if closest then
                    root.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.2)
                    local prompt = closest:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end)
        end
    end
end)

-- Auto Totem (place nearby)
task.spawn(function()
    while task.wait(3) do
        if Settings.AutoTotem then
            pcall(function()
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool.Name:lower():find("totem") then
                        tool.Parent = getChar()
                        tool:Activate()
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

-- WalkSpeed
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum and Settings.WalkSpeed ~= 16 then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

-- Fly
local flying = false
local flySpeed = 50
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F and Settings.Fly then
        flying = not flying
        local root = getRoot()
        if root then
            if flying then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVel"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.Parent = root
            else
                local bv = root:FindFirstChild("FlyVel")
                if bv then bv:Destroy() end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not Settings.Fly or not flying then return end
    local root = getRoot()
    if not root then return end
    local bv = root:FindFirstChild("FlyVel")
    if not bv then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
    bv.Velocity = dir * flySpeed
end)

-- Geode ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "GeodeESP"
espFolder.Parent = game:GetService("CoreGui")

task.spawn(function()
    while task.wait(1) do
        if Settings.ESP then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("geode") and not obj:FindFirstChild("ESP") then
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "ESP"
                    bill.Size = UDim2.new(0, 100, 0, 40)
                    bill.AlwaysOnTop = true
                    bill.Parent = obj
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = "GEODE"
                    label.TextColor3 = Color3.fromRGB(0, 255, 100)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = bill
                end
            end
        else
            for _, obj in pairs(workspace:GetDescendants()) do
                local esp = obj:FindFirstChild("ESP")
                if esp then esp:Destroy() end
            end
        end
    end
end)

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProspectingKeyless"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 380)
Frame.Position = UDim2.new(0.02, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundTransparency = 1
Title.Text = "Prospecting Keyless"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = Frame

local function toggle(name, key, yOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = name .. " : OFF"
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = name .. (Settings[key] and " : ON" or " : OFF")
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 150, 60) or Color3.fromRGB(35, 35, 42)
    end)
end

toggle("Auto Dig", "AutoDig")
toggle("Auto Pan/Shake", "AutoPan")
toggle("Auto Sell", "AutoSell")
toggle("Auto Treasure", "AutoTreasure")
toggle("Auto Totem", "AutoTotem")
toggle("Geode ESP", "ESP")
toggle("Fly (F)", "Fly")

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 32)
speedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 13
speedBtn.Text = "WalkSpeed: 16"
speedBtn.Parent = Frame
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)

speedBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeed = Settings.WalkSpeed == 16 and 50 or Settings.WalkSpeed == 50 and 100 or 16
    speedBtn.Text = "WalkSpeed: " .. Settings.WalkSpeed
end)

local codeBtn = Instance.new("TextButton")
codeBtn.Size = UDim2.new(0.9, 0, 0, 32)
codeBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 20)
codeBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
codeBtn.Font = Enum.Font.GothamBold
codeBtn.TextSize = 13
codeBtn.Text = "Redeem Codes"
codeBtn.Parent = Frame
Instance.new("UICorner", codeBtn).CornerRadius = UDim.new(0, 6)

codeBtn.MouseButton1Click:Connect(function()
    -- Tambahkan kode yang kamu tahu di sini
    local codes = {"UPDATE", "PROSPECTING", "RELEASE"} -- ganti sesuai kode aktif
    for _, code in pairs(codes) do
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RedeemCode"):FireServer(code)
        end)
    end
    codeBtn.Text = "Codes Redeemed!"
    task.wait(2)
    codeBtn.Text = "Redeem Codes"
end)

print("Prospecting Keyless loaded! Tekan F untuk Fly.")
