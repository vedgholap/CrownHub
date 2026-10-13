-- StealAnEgg.lua
-- ModuleScript: Crown Hub UI for the Steal An Egg experience
-- Place this ModuleScript under ReplicatedStorage > CrownHubModules (name: "StealAnEgg")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local module = {}
local connections = {}
local guiName = "CrownHub_StealAnEgg"

-- Utility: create instance helper
local function new(className, props)
    local inst = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then
                inst.Parent = v
            else
                inst[k] = v
            end
        end
    end
    return inst
end

-- Clean up function removes GUI and disconnects events
local function cleanup(screenGui)
    for _, c in pairs(connections) do
        if c and c.Disconnect then
            c:Disconnect()
        elseif typeof(c) == "RBXScriptConnection" then
            c:Disconnect()
        end
    end
    connections = {}

    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end

-- Drag handling for a frame
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    connections[#connections + 1] = dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            connections[#connections + 1] = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    connections[#connections + 1] = game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- Build and show the main UI
local function buildUI(player)
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end

    -- Avoid duplicate GUIs
    local existing = playerGui:FindFirstChild(guiName)
    if existing then
        cleanup(existing)
    end

    local screenGui = new("ScreenGui", {Name = guiName, ResetOnSpawn = false, Parent = playerGui})

    -- Root window
    local window = new("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 720, 0, 480),
        Position = UDim2.new(0.5, -360, 0.5, -240),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    new("UICorner", {Parent = window, CornerRadius = UDim.new(0, 12)})

    -- Top bar (draggable) with crown title and controls
    local topBar = new("Frame", {
        Parent = window,
        Size = UDim2.new(1, 0, 0, 48),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
    })
    new("UICorner", {Parent = topBar, CornerRadius = UDim.new(0, 12)})

    local title = new("TextLabel", {
        Parent = topBar,
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundTransparency = 1,
        Text = "👑 Crown Hub — Steal An Egg",
        TextColor3 = Color3.fromRGB(245, 245, 245),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = false,
        Position = UDim2.new(0, 16, 0, 0),
    })

    -- Control buttons (minimize, restore, close)
    local buttonContainer = new("Frame", {Parent = topBar, Size = UDim2.new(0, 140, 1, 0), Position = UDim2.new(1, -150, 0, 0), BackgroundTransparency = 1})

    local function makeControlIcon(text, posX)
        local btn = new("TextButton", {
            Parent = buttonContainer,
            Size = UDim2.new(0, 36, 0, 28),
            Position = UDim2.new(0, posX, 0, 10),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Text = text,
            TextColor3 = Color3.fromRGB(240, 220, 120), -- gold accent
            Font = Enum.Font.GothamBold,
            TextSize = 18,
        })
        new("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})
        return btn
    end

    local btnMin = makeControlIcon("—", 0)
    local btnRestore = makeControlIcon("□", 46)
    local btnClose = makeControlIcon("✕", 92)

    -- Sidebar
    local sidebar = new("Frame", {
        Parent = window,
        Size = UDim2.new(0, 180, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    })
    new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 12)})

    -- Sidebar buttons
    local pages = {"Dashboard", "Game", "Settings"}
    local pageFrames = {}
    local selectedPage = "Dashboard"

    local sidebarLayout = new("UIListLayout", {Parent = sidebar, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
    sidebarLayout.Padding = UDim.new(0, 8)

    for i, name in ipairs(pages) do
        local btn = new("TextButton", {
            Parent = sidebar,
            Size = UDim2.new(1, -24, 0, 40),
            Position = UDim2.new(0, 12, 0, 12 + (i - 1) * 48),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            Text = "  " .. name,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            AutoButtonColor = false,
        })
        new("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})

        btn.MouseButton1Click:Connect(function()
            selectedPage = name
            for k, f in pairs(pageFrames) do
                f.Visible = (k == name)
            end
        end)
    end

    -- Main content area
    local content = new("Frame", {
        Parent = window,
        Size = UDim2.new(1, -180, 1, -48),
        Position = UDim2.new(0, 180, 0, 48),
        BackgroundTransparency = 1,
    })

    -- Page helper
    local function makePage(name)
        local f = new("Frame", {Parent = content, Size = UDim2.new(1, -24, 1, -24), Position = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1})
        f.Visible = false
        pageFrames[name] = f
        return f
    end

    -- Dashboard
    local dashboard = makePage("Dashboard")
    dashboard.Visible = true
    local welcome = new("TextLabel", {
        Parent = dashboard,
        Size = UDim2.new(1, -36, 0, 80),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "Welcome to Crown Hub — Steal An Egg\nClean UI, gold accents, safe features only.",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
    })

    local info = new("TextLabel", {
        Parent = dashboard,
        Size = UDim2.new(1, -36, 0, 120),
        Position = UDim2.new(0, 0, 0, 96),
        BackgroundTransparency = 1,
        Text = "Game information:\n- PlaceId: <placeholder>\n- Mode: client UI only\n\nNo exploit functions are provided. Implement server features in your experience using RemoteEvents/RemoteFunctions under your control.",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
    })

    -- Game page (game-specific legitimate features)
    local gamePage = makePage("Game")
    do
        local label = new("TextLabel", {Parent = gamePage, Size = UDim2.new(1, -36, 0, 40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "Game Features (Legit)", TextColor3 = Color3.fromRGB(245,245,245), Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})

        -- Example: local setting toggle (placeholder) — safe to include
        local autoCollectToggle = new("TextButton", {Parent = gamePage, Size = UDim2.new(0, 220, 0, 40), Position = UDim2.new(0, 0, 0, 56), BackgroundColor3 = Color3.fromRGB(28,28,28), Text = "Auto-collect eggs: OFF", TextColor3 = Color3.fromRGB(240,240,240), Font = Enum.Font.Gotham, TextSize = 16})
        new("UICorner", {Parent = autoCollectToggle, CornerRadius = UDim.new(0,8)})

        local autoCollectEnabled = false
        connections[#connections + 1] = autoCollectToggle.MouseButton1Click:Connect(function()
            autoCollectEnabled = not autoCollectEnabled
            autoCollectToggle.Text = "Auto-collect eggs: " .. (autoCollectEnabled and "ON" or "OFF")
            -- Placeholder: Implement actual auto-collect server-side in your own experience.
        end)

        local placeholderInfo = new("TextLabel", {Parent = gamePage, Size = UDim2.new(1, -36, 0, 120), Position = UDim2.new(0, 0, 0, 112), BackgroundTransparency = 1, Text = "Note: The toggle above is a local UI setting only. To perform game actions, implement server-side handlers in your experience and trigger them via RemoteEvents you control.", TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.Gotham, TextSize = 14, TextWrapped = true})
    end

    -- Settings page
    local settingsPage = makePage("Settings")
    do
        local label = new("TextLabel", {Parent = settingsPage, Size = UDim2.new(1, -36, 0, 40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "Settings", TextColor3 = Color3.fromRGB(245,245,245), Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})

        local scaleLabel = new("TextLabel", {Parent = settingsPage, Size = UDim2.new(0, 200, 0, 24), Position = UDim2.new(0, 0, 0, 48), BackgroundTransparency = 1, Text = "UI Scale:", TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        local scaleInput = new("TextBox", {Parent = settingsPage, Size = UDim2.new(0, 80, 0, 28), Position = UDim2.new(0, 100, 0, 44), Text = "1", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(230,230,230), BackgroundColor3 = Color3.fromRGB(28,28,28)})
        new("UICorner", {Parent = scaleInput, CornerRadius = UDim.new(0,6)})

        connections[#connections + 1] = scaleInput.FocusLost:Connect(function(enter)
            if enter then
                local v = tonumber(scaleInput.Text)
                if v and v > 0.5 and v <= 2 then
                    window.Size = UDim2.new(0, 720 * v, 0, 480 * v)
                else
                    scaleInput.Text = "1"
                end
            end
        end)

        local themeToggle = new("TextButton", {Parent = settingsPage, Size = UDim2.new(0, 180, 0, 36), Position = UDim2.new(0, 0, 0, 88), BackgroundColor3 = Color3.fromRGB(28,28,28), Text = "Theme: Gold & Black", TextColor3 = Color3.fromRGB(240,220,120), Font = Enum.Font.Gotham, TextSize = 14})
        new("UICorner", {Parent = themeToggle, CornerRadius = UDim.new(0,8)})
        connections[#connections + 1] = themeToggle.MouseButton1Click:Connect(function()
            -- This is a theme label toggle; implementation could change colors across UI.
            -- For now, just animate the button to indicate action.
            local tween = TweenService:Create(themeToggle, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40,40,40)})
            tween:Play()
            tween.Completed:Wait()
            TweenService:Create(themeToggle, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28,28,28)}):Play()
        end)
    end

    -- Connect control buttons
    local minimized = false
    local previousSize, previousPos

    connections[#connections + 1] = btnMin.MouseButton1Click:Connect(function()
        if minimized then return end
        minimized = true
        previousSize = window.Size
        previousPos = window.Position
        TweenService:Create(window, TweenInfo.new(0.25), {Size = UDim2.new(0, 300, 0, 40)}):Play()
    end)

    connections[#connections + 1] = btnRestore.MouseButton1Click:Connect(function()
        if not minimized then return end
        minimized = false
        if previousSize then
            TweenService:Create(window, TweenInfo.new(0.25), {Size = previousSize, Position = previousPos}):Play()
        end
    end)

    connections[#connections + 1] = btnClose.MouseButton1Click:Connect(function()
        cleanup(screenGui)
    end)

    -- Make window draggable by topBar
    makeDraggable(window, topBar)

    -- subtle entrance animation
    window.Position = UDim2.new(0.5, 0, 0.5, 50)
    window.Size = UDim2.new(0, 720, 0, 480)
    TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -360, 0.5, -240)}):Play()

    -- store cleanup so module can be cleaned externally
    connections._screenGui = screenGui
    return screenGui
end

function module.Init()
    local player = Players.LocalPlayer
    if not player then return end
    -- Build UI
    buildUI(player)
end

function module.Clean()
    local player = Players.LocalPlayer
    if not player then return end
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        local sg = playerGui:FindFirstChild(guiName)
        cleanup(sg)
    end
end

return module
