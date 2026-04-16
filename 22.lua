--// Services
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--// Clean existing
local Container = game:GetService("CoreGui")
if Container:FindFirstChild("vibecodedGui") then
    Container.vibecodedGui:Destroy()
end

--// GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "vibecodedGui"
Gui.ResetOnSpawn = false
Gui.Parent = Container

--// Main window
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 250)
Frame.Position = UDim2.new(0.5, -200, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.Parent = Gui

local UICorner = Instance.new("UICorner", Frame)

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "vibecoded.xyz"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.Parent = Frame

--// Toggle button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 35, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -17)
OpenBtn.Text = "⬡"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenBtn.Parent = Gui

local isOpen = true

local function openUI()
    Frame.Visible = true
    OpenBtn.Visible = false
end

local function closeUI()
    Frame.Visible = false
    OpenBtn.Visible = true
end

OpenBtn.MouseButton1Click:Connect(openUI)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if isOpen then
            closeUI()
        else
            openUI()
        end
        isOpen = not isOpen
    end
end)

openUI()

--// return
local vibecoded = {}
function vibecoded.Notify(msg)
    print("[vibecoded.xyz]:", msg)
end

return vibecoded