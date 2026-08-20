local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "RayfieldFPSPro"
screenGui.ResetOnSpawn = false

local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end 
    end)
end

local sButton = Instance.new("TextButton", screenGui)
sButton.Name = "SButton"
sButton.Size = UDim2.new(0, 50, 0, 50)
sButton.Position = UDim2.new(0.1, 0, 0.1, 0)
sButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sButton.Text = "S"
sButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sButton.TextSize = 25
sButton.ZIndex = 10
Instance.new("UICorner", sButton).CornerRadius = UDim.new(1, 0)
makeDraggable(sButton)

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 320)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
makeDraggable(mainFrame)

local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Size = UDim2.new(0, 100, 0, 30)
fpsLabel.Position = UDim2.new(0.02, 0, 0.8, 0)
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.BackgroundTransparency = 0.4
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
fpsLabel.Text = "FPS: 60"
fpsLabel.Visible = false
Instance.new("UICorner", fpsLabel)
makeDraggable(fpsLabel)

local pingLabel = Instance.new("TextLabel", screenGui)
pingLabel.Size = UDim2.new(0, 100, 0, 30)
pingLabel.Position = UDim2.new(0.02, 0, 0.86, 0)
pingLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pingLabel.BackgroundTransparency = 0.4
pingLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
pingLabel.Text = "PING: 0ms"
pingLabel.Visible = false
Instance.new("UICorner", pingLabel)
makeDraggable(pingLabel)

RunService.RenderStepped:Connect(function(dt)
    fpsLabel.Text = "FPS: " .. math.floor(1/dt)
    local pingSuccess, pingValue = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if pingSuccess then
        pingLabel.Text = "PING: " .. math.floor(pingValue) .. "ms"
    end
end)

sButton.MouseButton1Click:Connect(function() 
    mainFrame.Visible = not mainFrame.Visible 
end)

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -120, 1, 0)
container.Position = UDim2.new(0, 120, 0, 0)
container.BackgroundTransparency = 1

local scrollFrame = Instance.new("ScrollingFrame", container)
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
scrollFrame.ScrollBarThickness = 4

local function CreateToggle(name, callback)
    local active = false
    local toggleIndex = #scrollFrame:GetChildren()
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, toggleIndex * 45 + 10)
    btn.Text = name .. ": ВЫКЛ"
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
     btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
        btn.Text = name .. ": " .. (active and "ВКЛ" or "ВЫКЛ")
        callback(active)
    end)
end

CreateToggle("Показать FPS", function(on) fpsLabel.Visible = on end)
CreateToggle("Показать PING", function(on) pingLabel.Visible = on end)

CreateToggle("Отключить тени", function(on)
    for _, v in pairs(Workspace:GetDescendants()) do 
        if v:IsA("BasePart") then 
            v.CastShadow = not on 
        end 
    end
end)

CreateToggle("Мягкий свет (Без блика)", function(on)
    -- Отключаем только глобальные тени карты, сохраняя яркость (Brightness) неизменной
    Lighting.GlobalShadows = not on
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = not on
        end
    end
end)

CreateToggle("Отключить эффекты", function(on)
    for _, v in pairs(Workspace:GetDescendants()) do 
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then 
            v.Enabled = not on 
        end 
    end
end)

CreateToggle("Убрать текстуры", function(on)
    for _, v in pairs(Workspace:GetDescendants()) do 
        if v:IsA("Decal") or v:IsA("Texture") then 
            v.Transparency = on and 1 or 0 
        end 
    end
end)
