-- Tes GUI Delta Android
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 80)
Frame.Position = UDim2.new(0.1, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Frame.Parent = ScreenGui

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundTransparency = 1
Label.Text = "GUI BERHASIL MUNCUL!"
Label.TextColor3 = Color3.new(1,1,1)
Label.Font = Enum.Font.GothamBold
Label.TextSize = 16
Label.Parent = Frame

print("Tes GUI jalan")
