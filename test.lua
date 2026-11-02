-- Prospecting Keyless - Delta Android Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
    while task.wait(0.15) do
        if Settings.AutoDig then
            pcall(function()
                equip("Shovel")
                local tool = getChar():FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
    end
end)

-- Auto Pan
task.spawn(function()
    while task.wait(0.12) do
        if Settings.AutoPan then
            pcall(function()
                equip("Pan") or equip("Rusty Pan") or equip("Plastic Pan")
                local tool = getChar():FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while task.wait(3) do
        if Settings.AutoSell then
            pcall(function()
                local merchant
                for _, v in pairs(workspace:GetDescendants()) do
                    local n = v.Name:lower()
                    if n:find("merchant") or n:find("sell") then
                        local part = v:IsA("BasePart") and v or (v:IsA("Model") and v.PrimaryPart)
                        if part then
                            merchant = part
                            break
                        end
                    end
                end
                if merchant and getRoot() then
                    getRoot().CFrame = merchant.CFrame + Vector3.new(0, 4, 0)
                    task.wait(0.6)
                    local prompt = merchant:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end)
        end
    end
end)

-- Auto Treasure / Geode
task.spawn(function()
    while task.wait(0.8) do
        if Settings.AutoTreasure then
            pcall(function()
                local root = getRoot()
                if not root then return end
                local closest, dist = nil, 100
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
                    task.wait(0.3)
                    local prompt = closest:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end)
        end
    end
end)

-- Auto Totem
task.spawn(function()
    while task.wait(4) do
        if Settings.AutoTotem then
            pcall(function()
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool.Name:lower():find("totem") then
                        tool.Parent = getChar()
                        tool:Activate()
                        task.wait(0.4)
                    end
                end
            end)
        end
    end
end)

-- WalkSpeed
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum and Settings.WalkSpeed > 16 then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

-- Fly (Toggle)
local flyBV
RunService.Heartbeat:Connect(function()
    if not Settings.Fly then
        if flyBV then flyBV:Destroy() flyBV = nil end
        return
    end
    local root = getRoot()
    if not root then return end
    if not flyBV or not flyBV.Parent then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = root
    end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
    flyBV.Velocity = dir * 45
end)

-- ESP
task.spawn(function()
    while task.wait(1.2) do
        if Settings.ESP then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("geode") and not obj:FindFirstChild("ESP") then
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "ESP"
                    bill.Size = UDim2.new(0, 120, 0, 40)
                    bill.AlwaysOnTop = true
                    bill.Parent = obj
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = "GEODE"
                    label.TextColor3 = Color3.fromRGB(0, 255, 100)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 16
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

-- ========== GUI Android Friendly ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProspectingAndroid"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 420)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Prospecting Delta"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = Frame

local function makeToggle(name, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Text = name .. " : OFF"
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = name .. (Settings[key] and " : ON" or " : OFF")
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 160, 70) or Color3.fromRGB(35, 35, 42)
    end)
end

makeToggle("Auto Dig", "AutoDig")
makeToggle("Auto Pan", "AutoPan")
makeToggle("Auto Sell", "AutoSell")
makeToggle("Auto Treasure", "AutoTreasure")
makeToggle("Auto Totem", "AutoTotem")
makeToggle("Geode ESP", "ESP")
makeToggle("Fly", "Fly")

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 40)
speedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 15
speedBtn.Text = "Speed: 16"
speedBtn.Parent = Frame
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 8)

speedBtn.MouseButton1Click:Connect(function()
    if Settings.WalkSpeed == 16 then
        Settings.WalkSpeed = 40
    elseif Settings.WalkSpeed == 40 then
        Settings.WalkSpeed = 70
    else
        Settings.WalkSpeed = 16
    end
    speedBtn.Text = "Speed: " .. Settings.WalkSpeed
end)

print("Prospecting Delta Android loaded!")
