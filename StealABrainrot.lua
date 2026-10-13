-- StealABrainrot.lua
-- ModuleScript: Crown Hub UI for the Steal A Brainrot experience
-- Place this ModuleScript under ReplicatedStorage > CrownHubModules and name it 'StealABrainrot'

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MODULE_NAME = "StealABrainrot"
local GUI_NAME = "CrownHub_" .. MODULE_NAME

local module = {}
local active = { gui = nil, conns = {} }

local function disconnectAll(connections)
    for _, c in ipairs(connections) do
        if type(c) == "RBXScriptConnection" or (type(c) == "userdata" and c.Disconnect) then
            pcall(function() c:Disconnect() end)
        end
    end
    table.clear(connections)
end

local function new(className, props)
    local obj = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then
                pcall(function() obj[k] = v end)
            end
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function tweenObject(object, props, info)
    info = info or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local ok, t = pcall(function() return TweenService:Create(object, info, props) end)
    if ok and t then t:Play() end
    return t
end

-- Draggable window adapted for this module
local function makeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos
    local userInputService = game:GetService("UserInputService")

    local function update(input)
        local delta = input.Position - mousePos
        local newPos = UDim2.new(0, framePos.X.Offset + delta.X, 0, framePos.Y.Offset + delta.Y)
        frame.Position = newPos
    end

    table.insert(active.conns, userInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.Target and input.Target:IsDescendantOf(frame) then
                dragging = true
                mousePos = input.Position
                framePos = { X = { Offset = frame.AbsolutePosition.X }, Y = { Offset = frame.AbsolutePosition.Y } }
                dragInput = input
            end
        end
    end))
    table.insert(active.conns, userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end))
    table.insert(active.conns, userInputService.InputEnded:Connect(function(input)
        if input == dragInput then dragging = false end
    end))
end

-- Build UI
local function buildUI()
    -- prevent duplicates
    local existing = PlayerGui:FindFirstChild(GUI_NAME)
    if existing then
        existing:Destroy()
    end

    local screenGui = new("ScreenGui", {Name = GUI_NAME, ResetOnSpawn = false, Parent = PlayerGui})
    local meta = new("Folder", {Name = "__CrownHubMeta", Parent = screenGui})
    new("BoolValue", {Name = "IsCrownHub", Value = true, Parent = meta})

    local window = new("Frame", {Name = "Window", Parent = screenGui, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0, 860, 0, 560), BackgroundColor3 = Color3.fromRGB(18,18,18), BorderSizePixel = 0})
    new("UICorner", {Parent = window, CornerRadius = UDim.new(0, 12)})

    local topBar = new("Frame", {Name = "TopBar", Parent = window, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
    local title = new("TextLabel", {Name = "Title", Parent = topBar, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(0, 380, 0, 32), BackgroundTransparency = 1, Text = "👑 Crown Hub - Steal A Brainrot", TextColor3 = Color3.fromRGB(240,240,240), Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left})

    local controls = new("Frame", {Parent = topBar, Size = UDim2.new(0,120,0,32), Position = UDim2.new(1,-136,0,6), BackgroundTransparency = 1})
    local function makeControlButton(name, text, color)
        local b = new("TextButton", {Name = name, Parent = controls, Size = UDim2.new(0,36,0,32), BackgroundColor3 = color, Text = text, TextColor3 = Color3.fromRGB(18,18,18), Font = Enum.Font.GothamSemibold, TextSize = 18, BorderSizePixel = 0})
        new("UICorner", {Parent = b, CornerRadius = UDim.new(0,6)})
        return b
    end
    local btnMin = makeControlButton("Minimize","—", Color3.fromRGB(252,215,0)); btnMin.Position = UDim2.new(1,-120,0,0)
    local btnRestore = makeControlButton("Restore","▣", Color3.fromRGB(255,203,71)); btnRestore.Position = UDim2.new(1,-80,0,0)
    local btnClose = makeControlButton("Close","✕", Color3.fromRGB(210,60,60)); btnClose.Position = UDim2.new(1,-40,0,0)

    local body = new("Frame", {Parent = window, Position = UDim2.new(0,0,0,44), Size = UDim2.new(1,0,1,-44), BackgroundTransparency = 1})
    local sidebar = new("Frame", {Parent = body, Size = UDim2.new(0,240,1,0), BackgroundColor3 = Color3.fromRGB(24,24,24)})
    new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,12)})
    local main = new("Frame", {Parent = body, Position = UDim2.new(0,240,0,0), Size = UDim2.new(1,-240,1,0), BackgroundColor3 = Color3.fromRGB(16,16,16)})
    new("UICorner", {Parent = main, CornerRadius = UDim.new(0,8)})

    local function makeSidebarButton(text)
        local b = new("TextButton", {Parent = sidebar, Size = UDim2.new(1, -20, 0, 48), BackgroundColor3 = Color3.fromRGB(28,24,20), Text = text, TextColor3 = Color3.fromRGB(245,245,245), Font = Enum.Font.Gotham, TextSize = 18, BorderSizePixel = 0})
        new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
        b.LayoutOrder = #sidebar:GetChildren()
        return b
    end

    local btnDashboard = makeSidebarButton("Dashboard")
    local btnGame = makeSidebarButton("Game")
    local btnSettings = makeSidebarButton("Settings")

    local function clearMain()
        for _, c in ipairs(main:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
    end

    local function showDashboard()
        clearMain()
        new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,16), Size = UDim2.new(1,-32,0,36), BackgroundTransparency = 1, Text = "Welcome to Crown Hub — Steal A Brainrot", TextColor3 = Color3.fromRGB(250,250,250), Font = Enum.Font.GothamBold, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left})
        new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,64), Size = UDim2.new(1,-32,0,72), BackgroundTransparency = 1, Text = "This client UI provides local tools and information. Use server-side scripts for authoritative game logic.", TextWrapped = true, TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 16})

        -- Show local rank or role from a folder (legitimate local read)
        local roleText = "Unknown"
        if LocalPlayer and LocalPlayer:FindFirstChild("Team") and LocalPlayer.Team then
            roleText = LocalPlayer.Team.Name
        end
        new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,152), Size = UDim2.new(1,-32,0,28), BackgroundTransparency = 1, Text = "Team: "..roleText, TextColor3 = Color3.fromRGB(230,230,230), Font = Enum.Font.GothamSemibold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})
    end

    local function showGame()
        clearMain()
        new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,16), Size = UDim2.new(1,-32,0,36), BackgroundTransparency = 1, Text = "Game Tools", TextColor3 = Color3.fromRGB(250,250,250), Font = Enum.Font.GothamBold, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left})

        -- Legitimate tool: local camera zoom slider (client-only)
        new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,64), Size = UDim2.new(0,220,0,24), BackgroundTransparency = 1, Text = "Local Camera Zoom:", TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
        local zoomBox = new("TextBox", {Parent = main, Position = UDim2.new(0,16,0,96), Size = UDim2.new(0,120,0,34), BackgroundColor3 = Color3.fromRGB(28,28,28), Text = "70", TextColor3 = Color3.fromRGB(240,240,240), Font = Enum.Font.Gotham, TextSize = 18, ClearTextOnFocus = false, BorderSizePixel = 0})
        new("UICorner", {Parent = zoomBox, CornerRadius = UDim.new(0,6)})
        local applyZoom = new("TextButton", {Parent = main, Position = UDim2.new(0,150,0,96), Size = UDim2.new(0,96,0,34), BackgroundColor3 = Color3.fromRGB(252,215,0), Text = "Apply", TextColor3 = Color3.fromRGB(18,18,18), Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0})
        new("UICorner", {Parent = applyZoom, CornerRadius = UDim.new(0,6)})

        local camera = workspace.CurrentCamera
        local originalFOV = camera and camera.FieldOfView or 70
        table.insert(active.conns, applyZoom.MouseButton1Click:Connect(function()
            local v = tonumber(zoomBox.Text)
            if v and v >= 30 and v <= 120 and camera then
                tweenObject(camera, {FieldOfView = v}, TweenInfo.new(0.35))
            else
                zoomBox.Text = tostring(originalFOV)
            end
        end))

        -- Placeholder: a label showing where to add server-integrated features
        new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,152), Size = UDim2.new(1,-32,0,36), BackgroundTransparency = 1, Text = "Placeholder: Add server-backed features in remote-enabled scripts (not implemented here).", TextWrapped = true, TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.GothamItalic, TextSize = 15})
    end

    local function showSettings()
        clearMain()
        new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,16), Size = UDim2.new(1,-32,0,36), BackgroundTransparency = 1, Text = "Settings", TextColor3 = Color3.fromRGB(250,250,250), Font = Enum.Font.GothamBold, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left})

        local uiScale = Instance.new("UIScale", window)
        uiScale.Name = "CrownHub_UIScale"
        uiScale.Scale = 1
        local scaleLabel = new("TextLabel", {Parent = main, Position = UDim2.new(0,16,0,72), Size = UDim2.new(0,220,0,24), BackgroundTransparency = 1, Text = "UI Scale:", TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
        local scaleBox = new("TextBox", {Parent = main, Position = UDim2.new(0,16,0,104), Size = UDim2.new(0,160,0,34), BackgroundColor3 = Color3.fromRGB(28,28,28), Text = "1.0", TextColor3 = Color3.fromRGB(240,240,240), Font = Enum.Font.Gotham, TextSize = 18, ClearTextOnFocus = false, BorderSizePixel = 0})
        new("UICorner", {Parent = scaleBox, CornerRadius = UDim.new(0,6)})
        local applyBtn = new("TextButton", {Parent = main, Position = UDim2.new(0,190,0,104), Size = UDim2.new(0,96,0,34), BackgroundColor3 = Color3.fromRGB(252,215,0), Text = "Apply", TextColor3 = Color3.fromRGB(18,18,18), Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0})
        new("UICorner", {Parent = applyBtn, CornerRadius = UDim.new(0,6)})
        table.insert(active.conns, applyBtn.MouseButton1Click:Connect(function()
            local v = tonumber(scaleBox.Text)
            if v and v > 0 and v <= 2 then uiScale.Scale = v else scaleBox.Text = tostring(uiScale.Scale) end
        end))
    end

    -- Wire navigation
    table.insert(active.conns, btnDashboard.MouseButton1Click:Connect(showDashboard))
    table.insert(active.conns, btnGame.MouseButton1Click:Connect(showGame))
    table.insert(active.conns, btnSettings.MouseButton1Click:Connect(showSettings))

    -- Control buttons
    local minimized = false
    table.insert(active.conns, btnMin.MouseButton1Click:Connect(function()
        if minimized then return end
        minimized = true
        tweenObject(window, {Size = UDim2.new(0, 300, 0, 44)}, TweenInfo.new(0.3))
    end))
    table.insert(active.conns, btnRestore.MouseButton1Click:Connect(function()
        if not minimized then return end
        minimized = false
        tweenObject(window, {Size = UDim2.new(0,860,0,560)}, TweenInfo.new(0.3))
    end))
    table.insert(active.conns, btnClose.MouseButton1Click:Connect(function()
        disconnectAll(active.conns)
        if screenGui then screenGui:Destroy() end
        active.gui = nil
    end))

    -- Make draggable and show initial page
    makeDraggable(window)
    showDashboard()

    active.gui = screenGui
end

function module.Init()
    if not LocalPlayer then warn("StealABrainrot: LocalPlayer not available") return end
    buildUI()
end

function module.Cleanup()
    if active.gui then
        disconnectAll(active.conns)
        pcall(function() active.gui:Destroy() end)
        active.gui = nil
    end
end

return module
