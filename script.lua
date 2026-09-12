-- BABFT Multi Feature Script
-- Features: Speed, Jump, Fly, Auto Farm, Noclip, Infinite Yield style tools

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Settings
local settings = {
    Speed = 50,
    JumpPower = 100,
    Flying = false,
    Noclip = false,
    AutoFarm = false,
    FlySpeed = 50
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BABFTGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 370)
Main.Position = UDim2.new(0.05, 0, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Title.Text = "BABFT Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

local UICorner2 = Instance.new("UICorner", Title)
UICorner2.CornerRadius = UDim.new(0, 10)

-- Buttons
local function createButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = Main
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Speed
createButton("Toggle Speed", 50, function()
    if humanoid.WalkSpeed == 16 then
        humanoid.WalkSpeed = settings.Speed
    else
        humanoid.WalkSpeed = 16
    end
end)

-- Jump
createButton("Toggle Jump", 95, function()
    if humanoid.JumpPower == 50 then
        humanoid.JumpPower = settings.JumpPower
        humanoid.UseJumpPower = true
    else
        humanoid.JumpPower = 50
    end
end)

-- Fly
local flying = false
local flyConnection

createButton("Toggle Fly", 140, function()
    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = root
        
        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * settings.FlySpeed or Vector3.zero
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
    end
end)

-- Noclip
local noclipConnection
createButton("Toggle Noclip", 185, function()
    settings.Noclip = not settings.Noclip
    if settings.Noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end)

-- Auto Farm (simple gold farm style)
createButton("Toggle Auto Farm", 230, function()
    settings.AutoFarm = not settings.AutoFarm
    if settings.AutoFarm then
        task.spawn(function()
            while settings.AutoFarm do
                local stage = workspace:FindFirstChild("BoatStages")
                if stage then
                    local gold = stage:FindFirstChild("NormalStages")
                    if gold then
                        for _, v in pairs(gold:GetDescendants()) do
                            if v.Name == "GoldenBlock" or v.Name:lower():find("gold") then
                                root.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                                break
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- Teleport to End
createButton("Teleport to End", 275, function()
    local endPart = workspace:FindFirstChild("BoatStages")
    if endPart then
        local normal = endPart:FindFirstChild("NormalStages")
        if normal and normal:FindFirstChild("TheEnd") then
            root.CFrame = normal.TheEnd.CFrame + Vector3.new(0, 10, 0)
        end
    end
end)

-- Destroy GUI
createButton("Close GUI", 320, function()
    ScreenGui:Destroy()
end)

-- Character Respawn Support
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end)

print("BABFT Script Loaded")
