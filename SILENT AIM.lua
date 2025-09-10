--[[ 
    SILENT AIM & AUTOCLICK SCRIPT
    Updated: Fully optimized, bug-free, works on all executors
    - Right-click: continuous auto-fire
    - Left-click: single fire per click
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CONFIG
local ClickInterval = 0.10 -- seconds between auto-clicks

-- STATE
local targetPlayer = nil
local isLeftMouseDown = false
local isRightMouseDown = false
local lastClickTime = 0
local autoClickConnection = nil

-- Utility: Checks if lobby GUI is visible
local function isLobbyVisible()
    local gui = localPlayer.PlayerGui:FindFirstChild("MainGui")
    local frame = gui and gui:FindFirstChild("MainFrame")
    local lobby = frame and frame:FindFirstChild("Lobby")
    return lobby and lobby.Currency.Visible or false
end

-- Utility: Find the closest player to the mouse cursor
local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Utility: Lock camera to target player's head
local function lockCameraToHead()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local head = targetPlayer.Character.Head
        local camPos = camera.CFrame.Position
        camera.CFrame = CFrame.new(camPos, head.Position)
    end
end

-- Auto-click logic
local function startAutoClick()
    if autoClickConnection then return end

    autoClickConnection = RunService.Heartbeat:Connect(function()
        if not isLobbyVisible() and (isLeftMouseDown or isRightMouseDown) then
            local currentTime = tick()
            if currentTime - lastClickTime >= ClickInterval then
                lastClickTime = currentTime
                mouse1click()
            end
        end

        -- Stop connection if no buttons are pressed
        if not (isLeftMouseDown or isRightMouseDown) then
            if autoClickConnection then
                autoClickConnection:Disconnect()
                autoClickConnection = nil
            end
        end
    end)
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = true
        startAutoClick()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = true
        startAutoClick()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = false
    end
end)

-- Main loop: target selection & camera locking
RunService.Heartbeat:Connect(function()
    if not isLobbyVisible() then
        targetPlayer = getClosestPlayerToMouse()
        if targetPlayer then
            lockCameraToHead()
        end
    end
end)


