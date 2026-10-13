-- StealAnEgg.lua
-- ModuleScript: Crown Hub UI for the Steal An Egg experience
-- Place this ModuleScript under ReplicatedStorage > CrownHubModules and name it 'StealAnEgg'

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")

local MODULE_NAME = "StealAnEgg"
local GUI_NAME = "CrownHub_" .. MODULE_NAME

local module = {}
local active = { gui = nil, conns = {} }

local function disconnectAll(connections)
    for _, connection in ipairs(connections) do
        if typeof(connection) == "RBXScriptConnection" then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end
    table.clear(connections)
end

local function new(className, props)
    local obj = Instance.new(className)
    if props then
        for key, value in pairs(props) do
            if key ~= "Parent" then
                pcall(function()
                    obj[key] = value
                end)
            end
        end
        if props.Parent then
            obj.Parent = props.Parent
        end
    end
    return obj
end

local function tweenObject(object, props, info)
    info = info or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local ok, tween = pcall(function()
        return TweenService:Create(object, info, props)
    end)
    if ok and tween then
        tween:Play()
    end
    return tween
end

local function makeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    table.insert(active.conns, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.Target and input.Target:IsDescendantOf(frame) then
                dragging = true
                dragInput = input
                dragStart = input.Position
                startPos = frame.Position
            end
        end
    end))

    table.insert(active.conns, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end))

    table.insert(active.conns, UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
        end
    end))
end

local function clearMain(main)
    for _, child in ipairs(main:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function buildUI()
    if not PlayerGui then
        warn("StealAnEgg: PlayerGui is not available.")
        return
    end

    local existing = PlayerGui:FindFirstChild(GUI_NAME)
    if existing then
        existing:Destroy()
        disconnectAll(active.conns)
        active.gui = nil
    end

    local screenGui = new("ScreenGui", {
        Name = GUI_NAME,
        ResetOnSpawn = false,
        Parent = PlayerGui,
    })

    local meta = new("Folder", { Name = "__CrownHubMeta", Parent = screenGui })
    new("BoolValue", { Name = "IsCrownHub", Value = true, Parent = meta })

    local window = new("Frame", {
        Name = "Window",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 900, 0, 600),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
    })
    new("UICorner", { Parent = window, CornerRadius = UDim.new(0, 12) })

    local topBar = new("Frame", {
        Name = "TopBar",
        Parent = window,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
    })

    new("TextLabel", {
        Name = "Title",
        Parent = topBar,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(0, 320, 0, 32),
        BackgroundTransparency = 1,
        Text = "👑 Crown Hub - Steal An Egg",
        TextColor3 = Color3.fromRGB(230, 230, 230),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local controls = new("Frame", {
        Name = "Controls",
        Parent = topBar,
        Size = UDim2.new(0, 120, 0, 32),
        Position = UDim2.new(1, -136, 0, 8),
        BackgroundTransparency = 1,
    })

    local function makeControlButton(name, text, bg)
        local button = new("TextButton", {
            Name = name,
            Parent = controls,
            Size = UDim2.new(0, 36, 0, 32),
            BackgroundColor3 = bg,
            Text = text,
            TextColor3 = Color3.fromRGB(18, 18, 18),
            Font = Enum.Font.GothamSemibold,
            TextSize = 18,
            BorderSizePixel = 0,
        })
        new("UICorner", { Parent = button, CornerRadius = UDim.new(0, 6) })
        return button
    end

    local btnMin = makeControlButton("Minimize", "—", Color3.fromRGB(252, 215, 0))
    btnMin.Position = UDim2.new(1, -120, 0, 0)

    local btnRestore = makeControlButton("Restore", "▣", Color3.fromRGB(255, 203, 71))
    btnRestore.Position = UDim2.new(1, -80, 0, 0)

    local btnClose = makeControlButton("Close", "✕", Color3.fromRGB(210, 60, 60))
    btnClose.Position = UDim2.new(1, -40, 0, 0)

    local body = new("Frame", {
        Name = "Body",
        Parent = window,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(1, 0, 1, -48),
        BackgroundTransparency = 1,
    })

    local sidebar = new("Frame", {
        Name = "Sidebar",
        Parent = body,
        Size = UDim2.new(0, 260, 1, 0),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
    })
    new("UICorner", { Parent = sidebar, CornerRadius = UDim.new(0, 12) })

    local main = new("Frame", {
        Name = "Main",
        Parent = body,
        Position = UDim2.new(0, 260, 0, 0),
        Size = UDim2.new(1, -260, 1, 0),
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
    })
    new("UICorner", { Parent = main, CornerRadius = UDim.new(0, 8) })

    new("UIListLayout", {
        Parent = sidebar,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local function makeSidebarButton(text)
        local button = new("TextButton", {
            Parent = sidebar,
            Size = UDim2.new(1, -20, 0, 48),
            BackgroundColor3 = Color3.fromRGB(28, 24, 20),
            Text = text,
            TextColor3 = Color3.fromRGB(245, 245, 245),
            Font = Enum.Font.Gotham,
            TextSize = 18,
            BorderSizePixel = 0,
        })
        new("UICorner", { Parent = button, CornerRadius = UDim.new(0, 8) })
        return button
    end

    local btnDashboard = makeSidebarButton("Dashboard")
    local btnGame = makeSidebarButton("Game")
    local btnSettings = makeSidebarButton("Settings")

    local function showDashboard()
        clearMain(main)

        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 16),
            Size = UDim2.new(1, -32, 0, 36),
            BackgroundTransparency = 1,
            Text = "Welcome to Crown Hub — Steal An Egg",
            TextColor3 = Color3.fromRGB(250, 250, 250),
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 64),
            Size = UDim2.new(1, -32, 0, 110),
            BackgroundTransparency = 1,
            Text = "This dashboard shows safe, local-only utilities. Server-side logic should be added in your authorized Roblox game scripts.",
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 16,
        })

        local playerText = LocalPlayer and LocalPlayer.Name or "Unknown"
        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 200),
            Size = UDim2.new(1, -32, 0, 28),
            BackgroundTransparency = 1,
            Text = "Player: " .. playerText,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            Font = Enum.Font.GothamSemibold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local eggCount = 0
        if LocalPlayer and LocalPlayer:FindFirstChild("leaderstats") then
            local eggsValue = LocalPlayer.leaderstats:FindFirstChild("Eggs")
            if eggsValue and eggsValue:IsA("IntValue") then
                eggCount = eggsValue.Value
            end
        end

        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 238),
            Size = UDim2.new(1, -32, 0, 36),
            BackgroundTransparency = 1,
            Text = "Eggs: " .. tostring(eggCount),
            TextColor3 = Color3.fromRGB(235, 235, 200),
            Font = Enum.Font.Gotham,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    end

    local function showGame()
        clearMain(main)

        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 16),
            Size = UDim2.new(1, -32, 0, 36),
            BackgroundTransparency = 1,
            Text = "Game Utilities",
            TextColor3 = Color3.fromRGB(250, 250, 250),
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 64),
            Size = UDim2.new(1, -32, 0, 70),
            BackgroundTransparency = 1,
            Text = "These examples are local-only and safe for your own Roblox experience. Replace placeholder content with your valid game-specific UI when ready.",
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 16,
        })

        local fovLabel = new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 152),
            Size = UDim2.new(0, 240, 0, 24),
            BackgroundTransparency = 1,
            Text = "Local FOV Boost:",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local fovToggle = new("TextButton", {
            Parent = main,
            Position = UDim2.new(0, 270, 0, 148),
            Size = UDim2.new(0, 120, 0, 32),
            BackgroundColor3 = Color3.fromRGB(255, 203, 71),
            Text = "Enable",
            TextColor3 = Color3.fromRGB(18, 18, 18),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            BorderSizePixel = 0,
        })
        new("UICorner", { Parent = fovToggle, CornerRadius = UDim.new(0, 6) })

        local camera = workspace.CurrentCamera
        local originalFOV = camera and camera.FieldOfView or 70
        local boosted = false

        table.insert(active.conns, fovToggle.MouseButton1Click:Connect(function()
            if not camera then return end
            boosted = not boosted
            if boosted then
                tweenObject(camera, { FieldOfView = 90 }, TweenInfo.new(0.4))
                fovToggle.Text = "Disable"
                fovToggle.BackgroundColor3 = Color3.fromRGB(252, 215, 0)
            else
                tweenObject(camera, { FieldOfView = originalFOV }, TweenInfo.new(0.4))
                fovToggle.Text = "Enable"
                fovToggle.BackgroundColor3 = Color3.fromRGB(255, 203, 71)
            end
        end))

        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 200),
            Size = UDim2.new(1, -32, 0, 40),
            BackgroundTransparency = 1,
            Text = "Placeholder: add authorized gameplay UI here when your actual experience logic is ready.",
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamItalic,
            TextSize = 15,
        })
    end

    local function showSettings()
        clearMain(main)

        new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 16),
            Size = UDim2.new(1, -32, 0, 36),
            BackgroundTransparency = 1,
            Text = "Settings",
            TextColor3 = Color3.fromRGB(250, 250, 250),
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local scaleLabel = new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 72),
            Size = UDim2.new(0, 320, 0, 24),
            BackgroundTransparency = 1,
            Text = "UI Scale:",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local scaleInput = new("TextBox", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 104),
            Size = UDim2.new(0, 160, 0, 34),
            BackgroundColor3 = Color3.fromRGB(28, 28, 28),
            Text = "1.0",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            Font = Enum.Font.Gotham,
            TextSize = 18,
            ClearTextOnFocus = false,
            BorderSizePixel = 0,
        })
        new("UICorner", { Parent = scaleInput, CornerRadius = UDim.new(0, 6) })

        local applyBtn = new("TextButton", {
            Parent = main,
            Position = UDim2.new(0, 190, 0, 104),
            Size = UDim2.new(0, 96, 0, 34),
            BackgroundColor3 = Color3.fromRGB(252, 215, 0),
            Text = "Apply",
            TextColor3 = Color3.fromRGB(18, 18, 18),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            BorderSizePixel = 0,
        })
        new("UICorner", { Parent = applyBtn, CornerRadius = UDim.new(0, 6) })

        local uiScale = Instance.new("UIScale")
        uiScale.Parent = window
        uiScale.Scale = 1

        table.insert(active.conns, applyBtn.MouseButton1Click:Connect(function()
            local v = tonumber(scaleInput.Text)
            if v and v > 0 and v <= 2 then
                uiScale.Scale = v
            else
                scaleInput.Text = tostring(uiScale.Scale)
            end
        end))

        local themeLabel = new("TextLabel", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 160),
            Size = UDim2.new(0, 240, 0, 24),
            BackgroundTransparency = 1,
            Text = "Accent Theme:",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local themeToggle = new("TextButton", {
            Parent = main,
            Position = UDim2.new(0, 16, 0, 196),
            Size = UDim2.new(0, 120, 0, 34),
            BackgroundColor3 = Color3.fromRGB(255, 203, 71),
            Text = "Gold",
            TextColor3 = Color3.fromRGB(18, 18, 18),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            BorderSizePixel = 0,
        })
        new("UICorner", { Parent = themeToggle, CornerRadius = UDim.new(0, 6) })

        local darkAccent = true
        table.insert(active.conns, themeToggle.MouseButton1Click:Connect(function()
            darkAccent = not darkAccent
            if darkAccent then
                themeToggle.Text = "Gold"
                themeToggle.BackgroundColor3 = Color3.fromRGB(255, 203, 71)
            else
                themeToggle.Text = "Bronze"
                themeToggle.BackgroundColor3 = Color3.fromRGB(205, 133, 63)
            end
        end))
    end

    table.insert(active.conns, btnDashboard.MouseButton1Click:Connect(showDashboard))
    table.insert(active.conns, btnGame.MouseButton1Click:Connect(showGame))
    table.insert(active.conns, btnSettings.MouseButton1Click:Connect(showSettings))

    local minimized = false

    table.insert(active.conns, btnMin.MouseButton1Click:Connect(function()
        if minimized then return end
        minimized = true
        tweenObject(window, { Size = UDim2.new(0, 300, 0, 48) }, TweenInfo.new(0.3))
    end))

    table.insert(active.conns, btnRestore.MouseButton1Click:Connect(function()
        if not minimized then return end
        minimized = false
        tweenObject(window, { Size = UDim2.new(0, 900, 0, 600) }, TweenInfo.new(0.3))
    end))

    table.insert(active.conns, btnClose.MouseButton1Click:Connect(function()
        disconnectAll(active.conns)
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        active.gui = nil
    end))

    makeDraggable(window)
    showDashboard()

    active.gui = screenGui
end

function module.Init()
    if not LocalPlayer then
        warn("StealAnEgg: LocalPlayer is not available.")
        return
    end

    if active.gui and active.gui.Parent then
        return
    end

    buildUI()
end

function module.Cleanup()
    disconnectAll(active.conns)
    if active.gui and active.gui.Parent then
        active.gui:Destroy()
    end
    active.gui = nil
end

return module
