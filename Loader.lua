-- Loader.lua
-- LocalScript: Crown Hub entry point for Roblox experiences.
-- This script is intended to be used as a LocalScript.
-- Place it in StarterPlayerScripts or StarterGui.

-- IMPORTANT:
-- Fill in your own PlaceIds in Studio.
-- Do NOT add real PlaceIds to the repository.
-- Example:
-- [123456789] = "StealAnEgg"
-- [987654321] = "StealABrainrot"
local Config = {
    -- Add your real PlaceIds here after copying the files into Roblox Studio.
    -- [YOUR_PLACE_ID_FOR_STEAL_AN_EGG] = "StealAnEgg",
    -- [YOUR_PLACE_ID_FOR_STEAL_A_BRAINROT] = "StealABrainrot",
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CURRENT_PLACE_ID = game.PlaceId

local function findModulesFolder()
    local folder = ReplicatedStorage:FindFirstChild("CrownHubModules")
    if folder then
        return folder
    end

    -- If the folder is missing, wait briefly and check once more.
    local ok, result = pcall(function()
        return ReplicatedStorage:WaitForChild("CrownHubModules", 5)
    end)

    if ok and result then
        return result
    end

    warn("CrownHub loader: ReplicatedStorage.CrownHubModules was not found. In Roblox Studio, create a Folder named 'CrownHubModules' under ReplicatedStorage and place the module scripts there.")
    return nil
end

local function selectModuleName(placeId)
    return Config[placeId]
end

local function safeRequire(moduleInstance)
    if not moduleInstance then
        return nil, "moduleInstance was nil"
    end

    local ok, result = pcall(function()
        return require(moduleInstance)
    end)

    if not ok then
        return nil, tostring(result)
    end

    return result, nil
end

local function safeInit(moduleTable)
    if type(moduleTable) ~= "table" then
        return false, "module did not return a table"
    end

    local initFn = moduleTable.Init
    if type(initFn) ~= "function" then
        return false, "module does not contain an Init() function"
    end

    local ok, err = pcall(function()
        initFn()
    end)

    if not ok then
        return false, tostring(err)
    end

    return true, nil
end

local function main()
    local moduleName = selectModuleName(CURRENT_PLACE_ID)
    if not moduleName then
        warn(string.format("CrownHub loader: No configured module for PlaceId %s. Update the Config table in Loader.lua with your own PlaceIds.", tostring(CURRENT_PLACE_ID)))
        return
    end

    local modulesFolder = findModulesFolder()
    if not modulesFolder then
        return
    end

    local moduleInstance = modulesFolder:FindFirstChild(moduleName)
    if not moduleInstance then
        warn(string.format("CrownHub loader: Module '%s' was not found in ReplicatedStorage.CrownHubModules. Make sure the ModuleScript exists under that folder with the exact name: %s.", tostring(moduleName), tostring(moduleName)))
        return
    end

    local moduleTable, requireError = safeRequire(moduleInstance)
    if not moduleTable then
        warn(string.format("CrownHub loader: Failed to require '%s': %s", tostring(moduleName), tostring(requireError)))
        return
    end

    local success, initError = safeInit(moduleTable)
    if not success then
        warn(string.format("CrownHub loader: Failed to initialize '%s': %s", tostring(moduleName), tostring(initError)))
        return
    end

    -- Init succeeded.
    -- print("CrownHub loaded: " .. tostring(moduleName))
end

if Players.LocalPlayer then
    task.defer(main)
else
    Players:GetPropertyChangedSignal("LocalPlayer"):Connect(function()
        if Players.LocalPlayer then
            task.defer(main)
        end
    end)
end
