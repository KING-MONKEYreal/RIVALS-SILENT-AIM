--[[ 
    SILENT AIM AUTOCLICK SCRIPT (Updated & Optimized)
    - Right-click: Automatic continuous fire
    - Left-click: Single fire per click
    - Works on all executors
    - Optimized for performance and stability
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Config
local ClickInterval = 0.10 -- Delay between automatic clicks
local targetPlayer = nil

-- State
local isLeftMouseDown = false
local isRightMouseDown = false
local autoClickConnection = nil
local lastClickTime = 0

-- Utility: Check if the lobby is visible
local function isLobbyVisible()
    local gui = localPlayer.PlayerGui:FindFirstChild("MainGui")
    if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("Lobby") then
        return gui.MainFrame.Lobby.Currency.Visible
    end
    return false
end

-- Utility: Get the closest player to the mouse
local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local dist = (screenPos - mousePos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Utility: Lock camera to target head
local function lockCameraToHead()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local head = targetPlayer.Character.Head
        local camPos = camera.CFrame.Position
        local dir = (head.Position - camPos).Unit
        camera.CFrame = CFrame.new(camPos, head.Position)
    end
end

-- Automatic click handling
local function autoClick()
    if autoClickConnection then return end

    autoClickConnection = RunService.Heartbeat:Connect(function(dt)
        if not isLobbyVisible() then
            local now = tick()
            if (isLeftMouseDown or isRightMouseDown) and now - lastClickTime >= ClickInterval then
                lastClickTime = now
                -- Fire the mouse click
                mouse1click()
            end
        end

        -- Disconnect if no buttons are pressed
        if not (isLeftMouseDown or isRightMouseDown) then
            autoClickConnection:Disconnect()
            autoClickConnection = nil
        end
    end)
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = true
        autoClick()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = true
        autoClick()
    end
end)

UserInputService.InputEnded:Connect(function(input, isProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = false
    end
end)

-- Main loop: Update target and lock camera
RunService.Heartbeat:Connect(function()
    if not isLobbyVisible() then
        targetPlayer = getClosestPlayerToMouse()
        if targetPlayer then
            lockCameraToHead()
        end
    end
end)
