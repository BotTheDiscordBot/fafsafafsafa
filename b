local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "Script Kiddies | Blue Lock Rivals", LoadingTitle = "Loading Tools", LoadingSubtitle = "By Jahceere"})
local MainTab = Window:CreateTab("Main")

local toggles = {
    BallMagnet = false,
    AutoGoalAssist = false,
    AutoSprint = false,
    AutoGoalie = false,
    BoostSpeed = false
}

MainTab:CreateToggle({Name="Ball Magnet", CurrentValue=false, Callback=function(v) toggles.BallMagnet=v end})
MainTab:CreateToggle({Name="Auto Goal Assist", CurrentValue=false, Callback=function(v) toggles.AutoGoalAssist=v end})
MainTab:CreateToggle({Name="Auto Sprint", CurrentValue=false, Callback=function(v) toggles.AutoSprint=v end})
MainTab:CreateToggle({Name="Auto Goalie", CurrentValue=false, Callback=function(v) toggles.AutoGoalie=v end})
MainTab:CreateToggle({Name="Boost Speed", CurrentValue=false, Callback=function(v) toggles.BoostSpeed=v end})

local speedBoostValue = 2
local emergencyStop = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.X then
        emergencyStop = not emergencyStop
        Rayfield:Notify("CeereUI","Emergency Stop: "..tostring(emergencyStop),3)
    end
end)

local Ball = Workspace:WaitForChild("SoccerBall")
local function getGoalPosition()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("goal") and obj:IsA("BasePart") then
            return obj.Position
        end
    end
    return nil
end

local function disableAnkleBreak()
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v.Name:lower():find("ankle") and (v:IsA("BoolValue") or v:IsA("StringValue") or v:IsA("IntValue")) then
            pcall(function() v.Value = false end)
        end
    end
    local remote = ReplicatedStorage:FindFirstChild("RemoveAnkleBreak")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end)
    end
end

local function removeSlideCooldown()
    local char = LocalPlayer.Character
    if not char then return end
    local slideCooldown = char:FindFirstChild("SlideCooldown")
    if slideCooldown and slideCooldown:IsA("NumberValue") then
        slideCooldown.Value = 0
    end
end

RunService.RenderStepped:Connect(function()
    if emergencyStop then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    disableAnkleBreak()
    removeSlideCooldown()

    if toggles.AutoSprint and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 24
    else
        char.Humanoid.WalkSpeed = 16 + (toggles.BoostSpeed and speedBoostValue or 0)
    end

    if toggles.BallMagnet and Ball and Ball.Parent then
        local distance = (Ball.Position - hrp.Position).Magnitude
        if distance < 15 then
            Ball.CFrame = Ball.CFrame:Lerp(CFrame.new(hrp.Position + hrp.CFrame.LookVector * 2), 0.15)
        end
    end

    if toggles.AutoGoalAssist and Ball and Ball.Parent then
        local goalPos = getGoalPosition()
        if goalPos then
            local direction = (goalPos - Ball.Position).Unit
            Ball.Velocity = direction * 30
        end
    end

    if toggles.AutoGoalie and Ball and Ball.Parent then
        local goalPos = getGoalPosition()
        if goalPos then
            local directionToGoal = (goalPos - Ball.Position).Unit
            local ballVelocityDir = Ball.Velocity.Magnitude > 0 and Ball.Velocity.Unit or Vector3.new()
            local dot = directionToGoal:Dot(ballVelocityDir)
            local distanceToGoal = (goalPos - Ball.Position).Magnitude

            if dot > 0.8 and distanceToGoal < 30 then
                Ball.CFrame = Ball.CFrame:Lerp(CFrame.new(hrp.Position + hrp.CFrame.LookVector * 2), 0.05)
                local diveRemote = ReplicatedStorage:FindFirstChild("Dive")
                if diveRemote then
                    diveRemote:FireServer()
                end
            end
        end
    end
end)

print("✅ Blue Lock: Rivals Advanced Loaded Successfully | By Jahceere")
