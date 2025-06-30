local player = game.Players.LocalPlayer
local rs, ts, vu, uis = game:GetService("ReplicatedStorage"), game:GetService("TweenService"), game:GetService("VirtualUser"), game:GetService("UserInputService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "Script Kiddies Anomic Autofarm Suite", LoadingTitle = "Script Kiddies", LoadingSubtitle = "Universal Script Hub", ConfigurationSaving = false})
local MainTab = Window:CreateTab("Autofarm")

local state = {autofarm = false, antiAFK = false, earnings = 0}
local authorized = false

-- KEY INPUT
MainTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Enter key to enable",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if text == "Jahceere" then
            authorized = true
            Rayfield:Notify({Title = "Key Correct", Content = "Autofarm Unlocked.", Duration = 5})
        else
            Rayfield:Notify({Title = "Key Incorrect", Content = "Try again.", Duration = 5})
        end
    end
})

-- TOGGLES
MainTab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = false,
    Callback = function(v)
        if authorized then
            state.autofarm = v
            Rayfield:Notify({Title = "Autofarm", Content = v and "Enabled." or "Disabled.", Duration = 3})
        else
            Rayfield:Notify({Title = "Key Required", Content = "Enter key to enable.", Duration = 3})
        end
    end
})

local antiAFKStatus = MainTab:CreateParagraph({Title = "Anti-AFK: UNACTIVE", Content = "Toggle below to enable."})

MainTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Callback = function(v)
        state.antiAFK = v
        antiAFKStatus:Set("Anti-AFK: " .. (v and "ACTIVE" or "UNACTIVE"), "Status updated.")
    end
})

local EarningsParagraph = MainTab:CreateParagraph({Title = "Earnings", Content = "$0"})

-- SAFE TWEEN FUNCTION
local function safeTween(target, cf)
    if target then
        local tween = ts:Create(target, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = cf})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- ANTI-AFK LOOP
task.spawn(function()
    while task.wait(60) do
        if state.antiAFK then
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0,0))
        end
    end
end)

-- AUTOFARM LOOP
task.spawn(function()
    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    safeTween(player.Character.HumanoidRootPart, CFrame.new(1172.96, 94.122, -878.75))

    while task.wait(1) do
        if not state.autofarm or not authorized then continue end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Count owned printers
        local printers = {}
        for _, v in ipairs(workspace.Entities:GetChildren()) do
            if v.Name:lower():find("printer") and v:FindFirstChild("Properties") then
                local props = v.Properties
                local owner = props:FindFirstChild("Owner")
                if owner and (tostring(owner.Value) == tostring(player.UserId) or tostring(owner.Value) == player.Name) then
                    table.insert(printers, v)
                end
            end
        end

        -- Auto-buy printers until 6 owned
        if #printers < 6 then
            pcall(function()
                rs["_CS.Events"].PurchaseTeamItem:FireServer("Simple Printer", "Single", Color3.new(0,0,0))
            end)
            task.wait(3) -- anti-spam
        else
            -- Check if all printers have $1000
            local readyToCollect = true
            for _, printer in ipairs(printers) do
                local props = printer.Properties
                if props.CurrentPrinted.Value < 1000 then
                    readyToCollect = false
                    break
                end
            end

            if readyToCollect then
                for _, printer in ipairs(printers) do
                    local props = printer.Properties
                    local pos = printer.PrimaryPart and printer.PrimaryPart.Position or printer.Position
                    if (pos - hrp.Position).Magnitude > 15 then
                        safeTween(hrp, CFrame.new(pos.X, pos.Y + 5, pos.Z + 5))
                        task.wait(0.5)
                    end

                    pcall(function()
                        rs["_CS.Events"].LockPrinter:FireServer(printer)   -- unlock
                        task.wait(0.5)
                        rs["_CS.Events"].UsePrinter:FireServer(printer)    -- collect
                        task.wait(0.4)
                        rs["_CS.Events"].LockPrinter:FireServer(printer)   -- relock
                        state.earnings += props.CurrentPrinted.Value
                        EarningsParagraph:Set("Earnings", "$" .. state.earnings)
                    end)
                end
            end
        end
    end
end)
