-- Prospecting Delta Android - Tombol Pasti Muncul
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoDig = false,
    AutoPan = false,
    AutoTreasure = false,
    WalkSpeed = 16,
    Fly = false
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 320)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Prospecting"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

-- Tombol dibuat manual (biar pasti kelihatan)
local yPos = 40

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 36)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    yPos = yPos + 42
    return btn
end

local digBtn = createButton("Auto Dig : OFF", function()
    Settings.AutoDig = not Settings.AutoDig
    digBtn.Text = "Auto Dig : " .. (Settings.AutoDig and "ON" or "OFF")
    digBtn.BackgroundColor3 = Settings.AutoDig and Color3.fromRGB(0, 150, 60) or Color3.fromRGB(45, 45, 55)
end)

local panBtn = createButton("Auto Pan : OFF", function()
    Settings.AutoPan = not Settings.AutoPan
    panBtn.Text = "Auto Pan : " .. (Settings.AutoPan and "ON" or "OFF")
    panBtn.BackgroundColor3 = Settings.AutoPan and Color3.fromRGB(0, 150, 60) or Color3.fromRGB(45, 45, 55)
end)

local treasureBtn = createButton("Auto Treasure : OFF", function()
    Settings.AutoTreasure = not Settings.AutoTreasure
    treasureBtn.Text = "Auto Treasure : " .. (Settings.AutoTreasure and "ON" or "OFF")
    treasureBtn.BackgroundColor3 = Settings.AutoTreasure and Color3.fromRGB(0, 150, 60) or Color3.fromRGB(45, 45, 55)
end)

local flyBtn = createButton("Fly : OFF", function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly : " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(0, 150, 60) or Color3.fromRGB(45, 45, 55)
end)

local speedBtn = createButton("Speed: 16", function()
    if Settings.WalkSpeed == 16 then
        Settings.WalkSpeed = 40
    elseif Settings.WalkSpeed == 40 then
        Settings.WalkSpeed = 65
    else
        Settings.WalkSpeed = 16
    end
    speedBtn.Text = "Speed: " .. Settings.WalkSpeed
end)

print("GUI + Buttons Loaded!")

-- Fungsi dasar
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
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
    flyBV.Velocity = dir * 40
end)
