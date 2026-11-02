-- Prospecting Delta Android - GUI First
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI dibuat paling awal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProspectingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 200)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Prospecting"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.8, 0)
Status.BackgroundTransparency = 1
Status.Text = "Script Loaded!"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.Parent = Frame

print("GUI Created Successfully")
