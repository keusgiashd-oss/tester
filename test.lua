local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoDig = false,
    AutoPan = false,
    WalkSpeed = 16,
    Fly = false
}

-- GUI (gaya yang sama dengan tes yang berhasil)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 210, 0, 260)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundTransparency = 1
Title.Text = "Prospecting"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local y = 38

local function makeBtn(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 36)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    btn.Parent = Frame
    y = y + 42
    return btn
end

local digBtn = makeBtn("Auto Dig : OFF")
digBtn.MouseButton1Click:Connect(function()
    Settings.AutoDig = not Settings.AutoDig
    digBtn.Text = "Auto Dig : " .. (Settings.AutoDig and "ON" or "OFF")
    digBtn.BackgroundColor3 = Settings.AutoDig and Color3.fromRGB(0, 160, 50) or Color3.fromRGB(40, 60, 40)
end)

local panBtn = makeBtn("Auto Pan : OFF")
panBtn.MouseButton1Click:Connect(function()
    Settings.AutoPan = not Settings.AutoPan
    panBtn.Text = "Auto Pan : " .. (Settings.AutoPan and "ON" or "OFF")
    panBtn.BackgroundColor3 = Settings.AutoPan and Color3.fromRGB(0, 160, 50) or Color3.fromRGB(40, 60, 40)
end)

local flyBtn = makeBtn("Fly : OFF")
flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly : " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(0, 160, 50) or Color3.fromRGB(40, 60, 40)
end)

local speedBtn = makeBtn("Speed: 16")
speedBtn.MouseButton1Click:Connect(function()
    if Settings.WalkSpeed == 16 then
        Settings.WalkSpeed = 40
    elseif Settings.WalkSpeed == 40 then
        Settings.WalkSpeed = 60
    else
        Settings.WalkSpeed = 16
    end
    speedBtn.Text = "Speed: " .. Settings.WalkSpeed
end)

print("GUI OK")

-- Fungsi
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
    while task.wait(0.25) do
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
    while task.wait(0.2) do
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
    flyBV.Velocity = dir * 35
end)
