-- Prospecting Keyless - Delta Android Fix
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
    while task.wait(0.2) do
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
    while task.wait(0.15) do
        if Settings.AutoPan then
            pcall(function()
                equip("Pan") or equip("Rusty Pan") or equip("Plastic Pan") or equip("Gold Pan")
                local tool = getChar():FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
    end
end)

-- Auto Treasure
task.spawn(function()
    while task.wait(1) do
        if Settings.AutoTreasure then
            pcall(function()
                local root = getRoot()
                if not root then return end
                for _, obj in pairs(workspace:GetChildren()) do
                    local n = obj.Name:lower()
                    if n:find("geode") or n:find("treasure") then
                        local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
                        if part and (root.Position - part.Position).Magnitude < 80 then
                            root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.4)
                            local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then fireproximityprompt(prompt) end
                            break
                        end
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

-- Fly
local flyBV
RunService.Heartbeat:Connect(function()
    if not Settings.Fly then
        if flyBV then flyBV:Destroy(); flyBV = nil end
        return
    end
    local root = getRoot()
    if not root then return end
    if not flyBV or not flyBV.Parent then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = root
    end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
    flyBV.Velocity = dir * 40
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 380)
Frame.Position = UDim2.new(0.02, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,36)
Title.BackgroundTransparency = 1
Title.Text = "Prospecting Fix"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = Frame

local function makeToggle(name, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name .. " : OFF"
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = name .. (Settings[key] and " : ON" or " : OFF")
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 150, 60) or Color3.fromRGB(40, 40, 48)
    end)
end

makeToggle("Auto Dig", "AutoDig")
makeToggle("Auto Pan", "AutoPan")
makeToggle("Auto Treasure", "AutoTreasure")
makeToggle("Fly", "Fly")

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 38)
speedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
speedBtn.TextColor3 = Color3.new(1,1,1)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 14
speedBtn.Text = "Speed: 16"
speedBtn.Parent = Frame
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 8)

speedBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeed = Settings.WalkSpeed == 16 and 45 or Settings.WalkSpeed == 45 and 70 or 16
    speedBtn.Text = "Speed: " .. Settings.WalkSpeed
end)

print("Script fixed loaded!")
