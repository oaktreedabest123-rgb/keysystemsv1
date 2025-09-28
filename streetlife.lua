-- LocalScript in StarterPlayerScripts

-- Load Roblox services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Check if the library is loaded
if not getgenv().Lib then
    warn("Library not found! Please ensure the key system library is loaded.")
    return
end
local Lib = getgenv().Lib

-- Prevent duplicate UIs
if LocalPlayer.PlayerGui:FindFirstChild("LinkvertiseUI") then
    LocalPlayer.PlayerGui.LinkvertiseUI:Destroy()
end

-- Settings for the UI
local settings = {
    Debug = false,
    Title = "Linkvertise to Script",
    Description = "Click 'Get Script' for the script!",
    Link = "https://link-target.net/1403008/YsVwQfJTWQlK",
    SaveKey = false,
    Verify = function() return true end,
    Logo = "rbxassetid://9545003266" -- Placeholder; replace with your logo
}

-- Notification function
local function showNotification(message)
    if LocalPlayer.PlayerGui:FindFirstChild("LinkvertiseNotification") then
        LocalPlayer.PlayerGui.LinkvertiseNotification:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LinkvertiseNotification"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(1, -210, 1, -60)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 1, 0)
    text.Position = UDim2.new(0, 5, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.Gotham
    text.Parent = notification

    notification.BackgroundTransparency = 1
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 0})
    tweenIn:Play()
    tweenIn.Completed:Connect(function()
        wait(2)
        local tweenOut = TweenService:Create(notification, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

-- Override button creation
if Lib.CreateButton then
    local originalCreateButton = Lib.CreateButton
    Lib.CreateButton = function(text, color, callback)
        if text == "Get Key" then
            return originalCreateButton("Get Script", Color3.fromRGB(59, 130, 246), function()
                pcall(function()
                    setclipboard(settings.Link)
                    showNotification("Link copied to clipboard!")
                end)
                callback()
            end)
        end
        if text == "Discord" then
            return -- Skip Discord button
        end
        return originalCreateButton(text, color, callback)
    end
else
    warn("CreateButton not found in library.")
end

-- Patch Init to enforce customizations
local originalInit = Lib.Init
Lib.Init = function(self, settings)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LinkvertiseUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Force description to be exact
    local originalSettings = settings
    settings = {
        Debug = settings.Debug,
        Title = "Linkvertise to Script",
        Description = "Click 'Get Script' for the script!",
        Link = settings.Link,
        SaveKey = false,
        Verify = settings.Verify,
        Logo = settings.Logo
    }

    local result = originalInit(self, settings)
    
    -- Customize UI
    local background = screenGui:WaitForChild("...", 5)
    if background then
        -- Ensure single exit button
        local exitButtons = background:GetChildren()
        local exitButtonCount = 0
        local exitButton
        for _, child in ipairs(exitButtons) do
            if child.Name == "ExitButton" then
                exitButtonCount = exitButtonCount + 1
                if exitButtonCount == 1 then
                    exitButton = child
                else
                    child:Destroy()
                end
            end
        end
        -- Style exit button
        if exitButton then
            exitButton.Size = UDim2.new(0, 30, 0, 30)
            exitButton.Position = UDim2.new(1, -10, 0, 10)
            exitButton.ImageTransparency = 0.5
            local corner = exitButton:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = exitButton
        end
        -- Customize UI elements
        background.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        local list = background:FindFirstChild("List")
        if list then
            local first = list:FindFirstChild("First")
            if first then
                first.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
                first.Size = UDim2.new(1, 0, 0, 150)
                local frame = first:FindFirstChild("Frame")
                if frame then
                    local desc = frame:FindFirstChild("Desc")
                    if desc then
                        desc.Text = settings.Description -- Force description
                        desc.TextSize = 18
                        desc.TextWrapped = true
                    end
                    local nam = frame:FindFirstChild("Nam")
                    if nam then
                        nam.Text = settings.Title -- Force title
                    end
                end
            end
            local second = list:FindFirstChild("Second")
            if second then
                second:Destroy() -- Remove key input section
            end
            local third = list:FindFirstChild("third")
            if third then
                third.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
                third.Size = UDim2.new(1, 0, 0, 60)
            end
        end
    end
    return result
end

-- Initialize the UI
local success = Lib:Init(settings)
