local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
while not player do
    task.wait()
    player = Players.LocalPlayer
end

local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local fovVisiblePreference = false
local fovRadius = 120
local autoShootEnabled = false
local autoShootAgresivoEnabled = false
local silentAimManualEnabled = false
local silentAimFovEnabled = false
local silentAimTargetPart = "Cabeza"
local teamCheckEnabled = true
local espEnabled = false
local espColor = Color3.fromRGB(255, 255, 255)
local espSettings = { Glow = true }
local espLinesEnabled = false

local KillAllEnabled = false

local hitboxEnabled = false
local hitboxInvisible = false
local hitboxSize = 3.5
local hitboxColor = Color3.fromRGB(255, 0, 0)
local hitboxSizeX = 2.2
local hitboxSizeY = 2.8
local hitboxSizeZ = 1.8

local animacionActualActiva = nil
local misAnimacionesOriginales = nil

local enemyCache = {}
local UIElements = {}
local tokyowamiEffects = {}
local NotificationsEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexvyrHub_Overlays"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = player:WaitForChild("PlayerGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "NexvyrESPFolder"
espFolder.Parent = screenGui

local function makeDraggable(guiObject, objectToMove, callback)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false

    local function isClickInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    guiObject.InputBegan:Connect(function(input)
        if not isClickInput(input) then
            return
        end
        dragging = true
        moved = false
        dragStart = input.Position
        startPos = objectToMove.Position
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input ~= dragInput then
            return
        end
        if not dragging then
            return
        end

        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then
            moved = true
        end
        if moved then
            objectToMove.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not isClickInput(input) then
            return
        end
        if not dragging then
            return
        end

        dragging = false
        if not moved and callback then
            callback()
        end
    end)
end

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NexvyrMinimalNotifs"
NotifContainer.Size = UDim2.new(0, 300, 0.5, 0)
NotifContainer.AnchorPoint = Vector2.new(1, 1)
NotifContainer.Position = UDim2.new(1, -20, 1, -20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = screenGui

local layout = Instance.new("UIListLayout", NotifContainer)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

local function showBottomMessage(text)
    if not NotificationsEnabled then
        return
    end
end

local WindUI
local _version = "1.6.66"
local uiFileName = "WindUI_Cache_v" .. _version .. ".txt"
local timeFileName = "WindUI_Cache_v" .. _version .. "_Time.txt"

local ok, result = pcall(function()
    local cacheValido = false

    if isfile and isfile(timeFileName) and readfile then
        local savedTime = tonumber(readfile(timeFileName))
        if savedTime and (os.time() - savedTime) < 86400 then
            cacheValido = true
        end
    end

    if cacheValido and isfile and isfile(uiFileName) then
        return loadstring(readfile(uiFileName))()
    else
        local codigoUi = game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua")

        if writefile then
            writefile(uiFileName, codigoUi)
            writefile(timeFileName, tostring(os.time()))
        end

        return loadstring(codigoUi)()
    end
end)

if ok and result then
    WindUI = result
else
    warn("Error al cargar WindUI: " .. tostring(result))
    return
end

local Window = WindUI:CreateWindow({
    Title = "NEXVYRHUB | DUELS <font color='#FFD700'>[v2.1]</font>",
    Theme = "Crimson",
    Author = "By 7.dui🇲🇽",
    Folder = "NexvyrHub_WindUI",
    Icon = "rbxassetid://88304008295495",
    Acrylic = false,
    Transparent = false,
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open NexvyrHub",
        CornerRadius = UDim.new(1),
        StrokeThickness = 1,
        Enabled = true,
        Draggable = true,
        Scale = 0.8,
        Color = ColorSequence.new(Color3.fromHex("#110070"), Color3.fromHex("#300364"))
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default"
    }
})

WindUI:SetTheme("Crimson")

local MainSection = Window:Section({
    Title = "Funciones Principales",
    Opened = true
})

local TrollSection = Window:Section({
    Title = "Configs & Extra",
    Opened = true
})

local OwnersSection = Window:Section({
    Title = "Owners",
    Opened = true
})

local Tabs = {
    Inicio = MainSection:Tab({ Title = "Inicio", Icon = "solar:home-bold" }),
    Aim = MainSection:Tab({ Title = "Aimbot", Icon = "solar:target-bold" }),
    Vis = MainSection:Tab({ Title = "Visuales", Icon = "solar:eye-bold" }),
    Farm = MainSection:Tab({ Title = "AutoFarm", Icon = "solar:dollar-bold" }),
    KillAll = MainSection:Tab({ Title = "Kill All", Icon = "solar:skull-bold" }),
    RachaFarm = MainSection:Tab({ Title = "Racha Farm", Icon = "solar:flame-bold" }),
    Graficos = MainSection:Tab({ Title = "Gráficos", Icon = "solar:palette-bold" }),
    Animaciones = MainSection:Tab({ Title = "Animaciones", Icon = "solar:smile-circle-bold" }),
    Com = TrollSection:Tab({ Title = "Comunidad", Icon = "solar:chat-line-bold" }),
    Owners = OwnersSection:Tab({ Title = "Owners", Icon = "solar:crown-bold" }),
    Avisos = OwnersSection:Tab({ Title = "Avisos", Icon = "solar:shield-warning-bold" })
}

local function updateMyTeam()
    enemyCache = {}
end

local function updateEnemy(p)
    enemyCache[p] = nil
end

player:GetPropertyChangedSignal("Team"):Connect(updateMyTeam)
player:GetPropertyChangedSignal("TeamColor"):Connect(updateMyTeam)
player:GetAttributeChangedSignal("Team"):Connect(updateMyTeam)

local function setupPlayerEvents(p)
    p:GetPropertyChangedSignal("Team"):Connect(function()
        updateEnemy(p)
    end)

    p:GetPropertyChangedSignal("TeamColor"):Connect(function()
        updateEnemy(p)
    end)

    p:GetAttributeChangedSignal("Team"):Connect(function()
        updateEnemy(p)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then
        setupPlayerEvents(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    setupPlayerEvents(p)
end)

Players.PlayerRemoving:Connect(function(p)
    updateEnemy(p)
end)

local function isEnemy(targetPlayer)
    if not teamCheckEnabled then
        return true
    end

    if targetPlayer == player then
        return false
    end

    if enemyCache[targetPlayer] ~= nil then
        return enemyCache[targetPlayer]
    end

    local isDiff = true

    if player.Team ~= nil and targetPlayer.Team ~= nil then
        isDiff = (player.Team ~= targetPlayer.Team)
    else
        local pAttr = player:GetAttribute("Team") or player:GetAttribute("team")
        local tAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")

        if pAttr ~= nil and tAttr ~= nil then
            isDiff = (pAttr ~= tAttr)
        elseif player.TeamColor.Name ~= "White" and player.TeamColor.Name ~= "Medium stone grey" then
            isDiff = (player.TeamColor ~= targetPlayer.TeamColor)
        end
    end

    enemyCache[targetPlayer] = isDiff
    return isDiff
end

local function estaEnLobby()
    local char = player.Character
    if not char then
        return true
    end

    if char:FindFirstChildOfClass("ForceField") then
        return true
    end

    if player.Team then
        local tName = string.lower(player.Team.Name)
        if string.find(tName, "lobby")
            or string.find(tName, "spectat")
            or string.find(tName, "espectador")
            or string.find(tName, "menu")
            or string.find(tName, "dead") then
            return true
        end
    end

    return false
end

local function esEnemigoValido(targetPlayer)
    if not targetPlayer or targetPlayer == player then
        return false
    end

    if not isEnemy(targetPlayer) then
        return false
    end

    local char = targetPlayer.Character
    if not char then
        return false
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        return false
    end

    if char:FindFirstChildOfClass("ForceField") then
        return false
    end

    if targetPlayer.Team then
        local tName = string.lower(targetPlayer.Team.Name)
        if string.find(tName, "lobby")
            or string.find(tName, "spectat")
            or string.find(tName, "espectador")
            or string.find(tName, "menu")
            or string.find(tName, "dead") then
            return false
        end
    end

    return true
end

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    return setmetatable({ Items = {} }, ConnectionManager)
end

function ConnectionManager:Add(task)
    self.Items[#self.Items + 1] = task
    return task
end

function ConnectionManager:Cleanup()
    for i = #self.Items, 1, -1 do
        local item = self.Items[i]
        self.Items[i] = nil

        local t = typeof(item)
        if t == "RBXScriptConnection" then
            pcall(function()
                item:Disconnect()
            end)
        elseif t == "Instance" then
            pcall(function()
                item:Destroy()
            end)
        elseif t == "function" then
            pcall(item)
        end
    end
end

local function limpiarHitboxes()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        local character = targetPlayer.Character
        if character then
            local hitbox = character:FindFirstChild("GhostHitbox")
            if hitbox then
                hitbox:Destroy()
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not hitboxEnabled then
        return
    end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and isEnemy(targetPlayer) then
            local character = targetPlayer.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")

                if rootPart and humanoid and humanoid.Health > 0 then
                    local hitbox = character:FindFirstChild("GhostHitbox")

                    if not hitbox then
                        hitbox = Instance.new("Part")
                        hitbox.Name = "GhostHitbox"
                        hitbox.Size = Vector3.new(
                            hitboxSize * hitboxSizeX,
                            hitboxSize * hitboxSizeY,
                            hitboxSize * hitboxSizeZ
                        )
                        hitbox.Transparency = hitboxInvisible and 1 or 0.6
                        hitbox.Color = hitboxColor
                        hitbox.CanCollide = false
                        hitbox.Massless = true
                        hitbox.CanQuery = true
                        hitbox.CFrame = rootPart.CFrame
                        hitbox.Parent = character

                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = rootPart
                        weld.Part1 = hitbox
                        weld.Parent = hitbox
                    else
                        hitbox.Size = Vector3.new(
                            hitboxSize * hitboxSizeX,
                            hitboxSize * hitboxSizeY,
                            hitboxSize * hitboxSizeZ
                        )
                        hitbox.Transparency = hitboxInvisible and 1 or 0.6
                        hitbox.Color = hitboxColor
                        hitbox.CanQuery = true
                    end
                else
                    local hitbox = character:FindFirstChild("GhostHitbox")
                    if hitbox then
                        hitbox:Destroy()
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO TELEPORT MAIN/ALT (versión completa tipo RysHub)
-- ============================================================

local PadZoneConfig = {
    ["Right Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone1", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone2", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone3", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone4", MainPad = "Pad1", AltPad = "Pad2" }
    },
    ["Left Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone5", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone6", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone7", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone8", MainPad = "Pad1", AltPad = "Pad2" }
    }
}

AutoTeleportMainAlt = {}
AutoTeleportMainAlt.__index = AutoTeleportMainAlt

function AutoTeleportMainAlt.new()
    return setmetatable({
        Running            = false,
        Connections        = ConnectionManager.new(),
        Acc                = 0,
        TickInterval       = 0.5,
        ActiveRole         = nil,
        DuelType           = "1v1",
        PlatformRow        = "Right Platforms",
        LastTeleport       = 0,
        LastVote           = 0,
        LastCancel         = 0,
        TeleportCooldown   = 0.5,
        VoteCooldown       = 1,
        CancelCooldown     = 1,
        VotedMap           = nil,
        HighlightedPad     = nil,
        PadColors          = {},
        ManualHold         = false,
    }, AutoTeleportMainAlt)
end

function AutoTeleportMainAlt:GetActiveRole()
    if self.ActiveRole == "Main" then
        return "Main"
    end
    if self.ActiveRole == "Alt" then
        return "Alt"
    end
    return nil
end

function AutoTeleportMainAlt:GetRoot()
    local char = player.Character
    if not char then
        return nil
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        return root
    end
    return nil
end

function AutoTeleportMainAlt:GetHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function AutoTeleportMainAlt:Attr(name)
    local v = player:GetAttribute(name)
    if typeof(v) == "string" and v ~= "" then
        return v
    end
    return nil
end

function AutoTeleportMainAlt:Snapshot()
    local gameAttr = self:Attr("Game")
    local mapAttr  = self:Attr("Map")
    local char     = player.Character
    local hum      = char and char:FindFirstChildOfClass("Humanoid")
    local root     = char and char:FindFirstChild("HumanoidRootPart")
    local alive    = hum ~= nil and hum.Health > 0 and root ~= nil

    return {
        Game   = gameAttr,
        Map    = mapAttr,
        InGame = gameAttr ~= nil,
        InMap  = gameAttr ~= nil and mapAttr ~= nil,
        Alive  = alive,
    }
end

function AutoTeleportMainAlt:IsOnMatch()
    local s = self:Snapshot()
    return s and s.InGame == true and s.InMap ~= true and s.Alive
end

function AutoTeleportMainAlt:IsQueued()
    return self:Snapshot().InGame == true
end

function AutoTeleportMainAlt:ResolvePad(role)
    local rowConfig = PadZoneConfig[self.PlatformRow] or PadZoneConfig["Right Platforms"]
    local cfg = rowConfig[self.DuelType] or rowConfig["1v1"]

    local padZones = workspace:FindFirstChild("PadZones")
    if not padZones then
        return nil
    end

    local zone = padZones:FindFirstChild(cfg.ZoneName)
    if not zone then
        return nil
    end

    local padName = (role == "Alt") and cfg.AltPad or cfg.MainPad
    local holder = zone:FindFirstChild(padName)
    if not holder then
        return nil
    end

    local pad = holder:FindFirstChild("Pad")
    if pad and pad:IsA("BasePart") then
        return pad
    end

    return nil
end

function AutoTeleportMainAlt:IsOnPad(pad)
    if not pad then
        return false
    end

    local root = self:GetRoot()
    if not root then
        return false
    end

    local rel  = pad.CFrame:PointToObjectSpace(root.Position)
    local half = pad.Size / 2

    return math.abs(rel.X) <= half.X + 0.5
       and math.abs(rel.Z) <= half.Z + 0.5
       and rel.Y >= -(half.Y + 6)
       and rel.Y <= half.Y + 14
end

function AutoTeleportMainAlt:MarkPad(pad, isAlt)
    if not pad then
        self:UnmarkPad()
        return
    end

    if self.HighlightedPad == pad then
        return
    end

    self:UnmarkPad()

    self.HighlightedPad = pad
    self.PadColors[pad] = {
        Color        = pad.Color,
        Transparency = pad.Transparency,
    }

    pcall(function()
        pad.Color = isAlt and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 145, 255)
        pad.Transparency = 0.5
    end)
end

function AutoTeleportMainAlt:UnmarkPad()
    if self.HighlightedPad and self.PadColors[self.HighlightedPad] then
        local pad    = self.HighlightedPad
        local saved  = self.PadColors[pad]
        pcall(function()
            if pad.Parent then
                pad.Color        = saved.Color
                pad.Transparency = saved.Transparency
            end
        end)
    end
    self.HighlightedPad = nil
end

function AutoTeleportMainAlt:FindVoteRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net  = pkgs and pkgs:FindFirstChild("Networking")
    local r    = net and net:FindFirstChild("RF/Voting/Vote")
    if r and r:IsA("RemoteFunction") then
        return r
    end
    return nil
end

function AutoTeleportMainAlt:FindVisibleMapVote()
    local pg     = player:FindFirstChild("PlayerGui")
    local main   = pg and pg:FindFirstChild("Main")
    local mv     = main and main:FindFirstChild("MapVoting")
    local holder = mv and mv:FindFirstChild("VotingHolder")
    if not holder then
        return nil
    end

    for _, b in ipairs(holder:GetChildren()) do
        if b:IsA("ImageButton") and b.Visible and b.Name ~= "" then
            return b.Name
        end
    end

    return nil
end

function AutoTeleportMainAlt:VoteMap()
    local s = self:Snapshot()
    if not self:IsOnMatch() then
        return
    end
    if self.VotedMap == s.Game then
        return
    end

    local now = os.clock()
    if now - (self.LastVote or 0) < self.VoteCooldown then
        return
    end
    self.LastVote = now

    local target = self:FindVisibleMapVote()
    local rf     = self:FindVoteRemote()
    if not (target and rf) then
        return
    end

    self.VotedMap = s.Game
    pcall(function()
        rf:InvokeServer(target)
    end)
end

function AutoTeleportMainAlt:FindSetStateRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net  = pkgs and pkgs:FindFirstChild("Networking")
    local r    = net and net:FindFirstChild("RE/Match/SetStatePlr")
    if r and r:IsA("RemoteEvent") then
        return r
    end
    return nil
end

function AutoTeleportMainAlt:CancelQueue()
    local now = os.clock()
    if now - (self.LastCancel or 0) < self.CancelCooldown then
        return
    end

    local ev = self:FindSetStateRemote()
    if not ev then
        return
    end

    self.LastCancel = now
    pcall(function()
        ev:FireServer("REMOVE")
    end)
end

function AutoTeleportMainAlt:HideGameFrame()
    local pg   = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local mgf  = main and main:FindFirstChild("MainGameFrame")
    if mgf and mgf:IsA("GuiObject") then
        pcall(function()
            mgf.Visible = false
        end)
    end
end

function AutoTeleportMainAlt:HoldCenter()
    local hum  = self:GetHumanoid()
    local root = self:GetRoot()
    if hum and root then
        pcall(function()
            hum:MoveTo(root.Position)
        end)
    end
end

function AutoTeleportMainAlt:Teleport(pad)
    if not pad then
        return
    end

    local root = self:GetRoot()
    local hum  = self:GetHumanoid()
    if not (root and hum) then
        return
    end

    pcall(function()
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity  = Vector3.zero
        self:CancelQueue()
        self:HideGameFrame()
        hum:MoveTo(pad.Position)
    end)
end

function AutoTeleportMainAlt:Process()
    if not self.Running then
        return
    end

    local s = self:Snapshot()

    if s.InGame then
        self:UnmarkPad()
        self:HoldCenter()
        self:VoteMap()
        return
    end

    local role = self:GetActiveRole()
    if not role then
        self:UnmarkPad()
        return
    end

    local pad = self:ResolvePad(role)
    self:MarkPad(pad, role == "Alt")
    if not pad then
        return
    end
    if self:IsOnPad(pad) then
        return
    end

    local now = os.clock()
    if not self.ManualHold and now - (self.LastTeleport or 0) < self.TeleportCooldown then
        return
    end
    self.LastTeleport = now

    self:Teleport(pad)
end

function AutoTeleportMainAlt:Kick()
    if not self.Running then
        return
    end
    self:Process()
end

function AutoTeleportMainAlt:Start()
    if self.Running then
        return
    end

    self.Running = true
    self.Acc = 0
    self.LastTeleport = 0
    self.LastVote = 0
    self.LastCancel = 0

    self.Connections:Add(player:GetAttributeChangedSignal("Game"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))

    self.Connections:Add(player:GetAttributeChangedSignal("Map"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))

    self.Connections:Add(player:GetAttributeChangedSignal("Team"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))

    self.Connections:Add(RunService.Heartbeat:Connect(function(dt)
        if not self.Running then
            return
        end
        self.Acc = self.Acc + dt
        if self.Acc >= self.TickInterval then
            self.Acc = 0
            self:Process()
        end
    end))

    self:Process()
end

function AutoTeleportMainAlt:Stop()
    if not self.Running then
        return
    end

    self.Running = false
    self.Connections:Cleanup()
    self.Connections = ConnectionManager.new()
    self:UnmarkPad()
    self.VotedMap = nil
end

AutoTeleportMainAltInstance = AutoTeleportMainAlt.new()

-- ============================================================
-- KILL ALL (versión completa del segundo script)
-- ============================================================

local KILLALL_HEIGHT_OFFSET = 1
local KILLALL_PITCH_DEGREES = 90
local KILLALL_SWING_INTERVAL = 0.5

KillAll = {}
KillAll.__index = KillAll

function KillAll.new()
    return setmetatable({
        running = false,
        connections = ConnectionManager.new(),
        savedCollisions = {},
        swingAccumulator = 0,
        targetFloor = nil,
        lastTarget = nil,
        repositioned = false,
        activeRole = nil,
        AlwaysOn = false,
        EnforceToken = 0
    }, KillAll)
end

function KillAll:DisableCollisions()
    local char = player.Character
    if not char then
        return
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            if self.savedCollisions[part] == nil then
                self.savedCollisions[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end

function KillAll:RestoreCollisions()
    for part, value in pairs(self.savedCollisions) do
        if part.Parent then
            pcall(function()
                part.CanCollide = value
            end)
        end
    end
    table.clear(self.savedCollisions)
end

function KillAll:GetRoot(p)
    local char = p and p.Character
    if not char then
        return nil
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        return root
    end

    return nil
end

function KillAll:GetHumanoid(p)
    local char = p and p.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function KillAll:GetClosestEnemy()
    local myRoot = self:GetRoot(player)
    if not myRoot then
        return nil
    end

    local best = nil
    local bestDist = nil

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and esEnemigoValido(other) then
            local hum = self:GetHumanoid(other)
            local root = self:GetRoot(other)

            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude

                if not bestDist or dist < bestDist then
                    best = root
                    bestDist = dist
                end
            end
        end
    end

    return best
end

function KillAll:GetFloorY(targetRoot)
    local hum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    local hip = hum and tonumber(hum.HipHeight) or 2
    return targetRoot.Position.Y - hip - targetRoot.Size.Y / 2
end

function KillAll:IsInMatch()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then
        return false
    end

    local main = gui:FindFirstChild("Main") or gui
    local gameFrame = main:FindFirstChild("MainGameFrame")
    local score = gameFrame and gameFrame:FindFirstChild("IngameScore")
    local timer = score and score:FindFirstChild("Timer")

    if not timer then
        return false
    end
    if not (timer:IsA("TextLabel") or timer:IsA("TextButton") or timer:IsA("TextBox")) then
        return false
    end

    return tostring(timer.Text or ""):match("^%s*%d+:%d%d%s*$") ~= nil
end

function KillAll:IsSameMatch(otherPlayer)
    local myMap = player:GetAttribute("Map")
    local myGame = player:GetAttribute("Game")

    if myMap == nil or myGame == nil then
        return true
    end

    local oMap = otherPlayer:GetAttribute("Map")
    local oGame = otherPlayer:GetAttribute("Game")

    if oMap == nil or oGame == nil then
        return true
    end

    return oMap == myMap and oGame == myGame
end

function KillAll:ResetState()
    self.targetFloor = nil
    self.lastTarget = nil
    self.repositioned = false

    self:RestoreCollisions()

    local hum = self:GetHumanoid(player)
    if hum and hum.PlatformStand then
        pcall(function()
            hum.PlatformStand = false
        end)
    end
end

function KillAll:IsKnife(tool)
    if not (tool and tool:IsA("Tool")) then
        return false
    end

    if tool:FindFirstChild("fire") or tool:FindFirstChild("showBeam") then
        return false
    end

    return tool:FindFirstChild("Slash") ~= nil or tool:FindFirstChild("SlashStart") ~= nil
end

function KillAll:FindKnife()
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if self:IsKnife(child) then
                return child, true
            end
        end
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if self:IsKnife(child) then
                return child, false
            end
        end
    end

    return nil, false
end

function KillAll:SwingKnife(dt)
    self.swingAccumulator = self.swingAccumulator + dt

    if self.swingAccumulator < KILLALL_SWING_INTERVAL then
        return
    end

    self.swingAccumulator = 0

    local tool, equipped = self:FindKnife()
    if not tool then
        return
    end

    if not equipped then
        local hum = self:GetHumanoid(player)
        if not hum then
            return
        end

        pcall(function()
            hum:EquipTool(tool)
        end)

        if tool.Parent ~= player.Character then
            return
        end
    end

    pcall(function()
        tool:Activate()
    end)
end

function KillAll:GetRole()
    if self.activeRole == "Main" then
        return "Main"
    end
    if self.activeRole == "Alt" then
        return "Alt"
    end
    return nil
end

function KillAll:ParseNumber(str)
    if str == nil then
        return nil
    end

    local text = tostring(str)
    return tonumber(text) or tonumber(string.match(text, "%d+") or "")
end

function KillAll:GetTeamScores()
    local playerGui = player:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("Main")
    local gameFrame = mainGui and mainGui:FindFirstChild("MainGameFrame")
    local playersFrame = gameFrame and gameFrame:FindFirstChild("PlayersFrame")

    if not playersFrame then
        return nil, nil
    end

    local blueFrame = playersFrame:FindFirstChild("TeamBlueScoreFrame")
    local redFrame = playersFrame:FindFirstChild("TeamRedScoreFrame")
    local blueText = blueFrame and blueFrame:FindFirstChild("ScoreText")
    local redText = redFrame and redFrame:FindFirstChild("ScoreText")

    if not (blueText and redText) then
        return nil, nil
    end

    local b = self:ParseNumber(blueText.Text)
    local r = self:ParseNumber(redText.Text)

    if player:GetAttribute("Team") == "Red" then
        return r, b
    end

    return b, r
end

function KillAll:GetRoundKills(targetPlayer)
    if not targetPlayer then
        return nil
    end

    local attr = tonumber(targetPlayer:GetAttribute("RoundKills"))
    if attr then
        return attr
    end

    local direct = targetPlayer:FindFirstChild("RoundKills")
    if direct and (direct:IsA("IntValue") or direct:IsA("NumberValue")) then
        return tonumber(direct.Value) or 0
    end

    local ls = targetPlayer:FindFirstChild("leaderstats")
    local lsKills = ls and ls:FindFirstChild("RoundKills")
    if lsKills and (lsKills:IsA("IntValue") or lsKills:IsA("NumberValue")) then
        return tonumber(lsKills.Value) or 0
    end

    return nil
end

function KillAll:GetStreak(targetPlayer)
    local streak = targetPlayer and targetPlayer:FindFirstChild("Streak")
    if streak and (streak:IsA("IntValue") or streak:IsA("NumberValue")) then
        return tonumber(streak.Value)
    end

    local root = targetPlayer and self:GetRoot(targetPlayer)
    local tag = root and root:FindFirstChild("HeadTag")
    local streakTag = tag and tag:FindFirstChild("Streak")
    local label = streakTag and streakTag:FindFirstChild("TextLabel")

    if not label then
        return nil
    end

    return tonumber(tostring(label.Text or ""):gsub("[^%d%-]", ""))
end

function KillAll:ReadMyLeaderboardStreak()
    local lb = workspace:FindFirstChild("Leaderboards")
    local streakLB = lb and lb:FindFirstChild("streak")
    local screenPart = streakLB and streakLB:FindFirstChild("ScreenPart")
    local surface = screenPart and screenPart:FindFirstChild("SurfaceGui")
    local frame = surface and surface:FindFirstChild("Frame")

    if not frame then
        return nil
    end

    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("Frame") and child.LayoutOrder == 50 then
            local wins = child:FindFirstChild("Wins")

            if wins then
                if wins:IsA("IntValue") or wins:IsA("NumberValue") then
                    return tonumber(wins.Value)
                elseif wins:IsA("TextLabel") or wins:IsA("TextButton") or wins:IsA("TextBox") then
                    local direct = tonumber(tostring(wins.Text or ""))
                    if direct then
                        return direct
                    end

                    local matched = string.match(tostring(wins.Text or ""), "%d+")
                    return matched and tonumber(matched) or nil
                end
            end
        end
    end

    return nil
end

function KillAll:ShouldBreakStreak()
    if not a8_breakStreakEnabled then
        return true
    end

    local target = math.floor(a8_breakStreakTarget or 0)
    if target <= 0 then
        local mine = self:ReadMyLeaderboardStreak()
        if not mine then
            return false
        end
        target = math.max(0, mine - 1)
    end

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and isEnemy(other) then
            local streak = self:GetStreak(other)
            if streak and streak >= target then
                return true
            end
        end
    end

    return false
end

function KillAll:ShouldLowerKD(role)
    if not a8_lowerKDEnabled then
        return true
    end

    local target = math.clamp(math.floor(a8_kdTargetKills or 4), 0, 4)
    local myScore, enemyScore = self:GetTeamScores()

    if role == "Alt" then
        local mine = self:GetRoundKills(player)
        return (mine or myScore or 0) < target
    end

    if enemyScore then
        return enemyScore >= target
    end

    for _, other in ipairs(Players:GetPlayers()) do
        local kills = isEnemy(other) and self:GetRoundKills(other) or nil
        if kills and kills >= target then
            return true
        end
    end

    return false
end

function KillAll:ShouldRun()
    local role = self:GetRole()
    if not role then
        return true
    end

    return self:ShouldBreakStreak() and self:ShouldLowerKD(role)
end

function KillAll:Update(dt)
    if not self:IsInMatch() then
        self:ResetState()
        return
    end

    if not self:ShouldRun() then
        self:ResetState()
        return
    end

    local myRoot = self:GetRoot(player)
    local target = myRoot and self:GetClosestEnemy()

    if not target then
        self:ResetState()
        return
    end

    self:DisableCollisions()
    self:SwingKnife(dt or 0)

    local hum = self:GetHumanoid(player)
    if hum and not hum.PlatformStand then
        pcall(function()
            hum.PlatformStand = true
        end)
    end

    local targetPos = target.Position
    local targetHum = target.Parent and target.Parent:FindFirstChildOfClass("Humanoid")
    local onGround = targetHum and targetHum.FloorMaterial ~= Enum.Material.Air

    if target ~= self.lastTarget then
        self.lastTarget = target
        self.targetFloor = nil
        self.repositioned = false
    end

    if onGround or not self.targetFloor then
        self.targetFloor = self:GetFloorY(target)
    end

    local y = self.targetFloor - KILLALL_HEIGHT_OFFSET
    local myPos = myRoot.Position
    local x = targetPos.X
    local z = targetPos.Z

    if not self.repositioned then
        if math.abs(myPos.Y - y) > 1 then
            x = myPos.X
            z = myPos.Z
        else
            self.repositioned = true
        end
    end

    pcall(function()
        myRoot.CFrame = CFrame.new(x, y, z) * CFrame.Angles(math.rad(KILLALL_PITCH_DEGREES), 0, 0)
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

function KillAll:Start()
    if self.running then
        return
    end

    self.running = true
    self.swingAccumulator = 0

    self.connections:Add(RunService.Heartbeat:Connect(function(dt)
        if not self.running then
            return
        end
        self:Update(dt)
    end))

    self.connections:Add(player.CharacterAdded:Connect(function()
        table.clear(self.savedCollisions)
    end))
end

function KillAll:Stop()
    if not self.running then
        return
    end

    self.running = false
    self.connections:Cleanup()
    self:ResetState()
end

KillAllInstance = KillAll.new()

a8_breakStreakEnabled = false
a8_breakStreakTarget = 1
a8_lowerKDEnabled = false
a8_kdTargetKills = 4

local killAllBubbleEnabled = false
local killAllBubbleGui = nil
local killAllBubbleButton = nil

local function RefreshKillAllBubble()
    if not killAllBubbleButton then
        return
    end

    killAllBubbleButton.Text = "KA"

    if KillAllInstance.running then
        killAllBubbleButton.BackgroundColor3 = Color3.fromRGB(30, 156, 88)
        killAllBubbleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        killAllBubbleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        killAllBubbleButton.TextColor3 = Color3.fromRGB(235, 235, 235)
    end
end

local function ToggleKillAllFromBubble()
    if KillAllInstance.AlwaysOn then
        return
    end

    KillAllEnabled = not KillAllEnabled

    if KillAllEnabled then
        KillAllInstance:Start()
    else
        KillAllInstance:Stop()
    end

    if UIElements.TogKillAll then
        pcall(function()
            UIElements.TogKillAll:Set(KillAllEnabled)
        end)
    end

    RefreshKillAllBubble()
end

local function BuildKillAllBubble()
    if not killAllBubbleEnabled then
        if killAllBubbleGui then
            pcall(function()
                killAllBubbleGui:Destroy()
            end)
            killAllBubbleGui = nil
            killAllBubbleButton = nil
        end
        return
    end

    local gui = player:FindFirstChildOfClass("PlayerGui")
    if not gui then
        return
    end

    local previous = gui:FindFirstChild("NexvyrKillAllBubble")
    if previous then
        pcall(function()
            previous:Destroy()
        end)
    end

    local screenGuiKA = Instance.new("ScreenGui")
    screenGuiKA.Name = "NexvyrKillAllBubble"
    screenGuiKA.ResetOnSpawn = false
    screenGuiKA.IgnoreGuiInset = true
    screenGuiKA.DisplayOrder = 2147483646
    screenGuiKA.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGuiKA.Parent = gui

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.AnchorPoint = Vector2.new(1, 1)
    button.Position = UDim2.new(1, -12, 1, -188)
    button.Size = UDim2.new(0, 48, 0, 48)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextWrapped = true
    button.Text = "KA"
    button.TextColor3 = Color3.fromRGB(235, 235, 235)
    button.Parent = screenGuiKA

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(115, 115, 115)
    stroke.Parent = button

    makeDraggable(button, button, ToggleKillAllFromBubble)

    killAllBubbleGui = screenGuiKA
    killAllBubbleButton = button

    RefreshKillAllBubble()
end

local function EnforceKillAllAlwaysOn()
    KillAllInstance.EnforceToken = (KillAllInstance.EnforceToken or 0) + 1
    local token = KillAllInstance.EnforceToken

    task.spawn(function()
        while KillAllInstance.AlwaysOn and token == KillAllInstance.EnforceToken do
            if not KillAllEnabled or not KillAllInstance.running then
                KillAllEnabled = true
                pcall(function()
                    KillAllInstance:Start()
                end)
            end
            task.wait(1)
        end
    end)
end

Tabs.Inicio:Section({ Title = "Perfil del Jugador" })

local execName = "Desconocido"
pcall(function()
    execName = identifyexecutor and identifyexecutor() or "Desconocido"
end)

Tabs.Inicio:Paragraph({
    Title = "Perfil " .. player.DisplayName,
    Desc = "Usuario: @" .. player.Name
        .. "\nID: " .. player.UserId
        .. "\nEdad de la cuenta: " .. player.AccountAge .. " días",
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=420&h=420",
    ImageSize = 48
})

Tabs.Inicio:Paragraph({
    Title = "Sistema",
    Desc = "Ejecutor actual: " .. execName
})

Tabs.Inicio:Section({ Title = "Información del Servidor" })

local gameNameStr = "Desconocido"
pcall(function()
    gameNameStr = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

Tabs.Inicio:Paragraph({
    Title = "Juego Actual",
    Desc = gameNameStr .. "\nPlace ID: " .. game.PlaceId,
    Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
    ImageSize = 48
})

Tabs.Inicio:Section({ Title = "Juegos Soportados" })

local function TPSeguro(placeId, nombreJuego)
    if game.PlaceId == placeId then
        return
    end

    pcall(function()
        if setclipboard then
            setclipboard("https://www.roblox.com/games/" .. tostring(placeId))
        end
    end)

    task.wait(0.5)

    pcall(function()
        TeleportService:Teleport(placeId, player)
    end)
end

Tabs.Inicio:Button({
    Title = "Murder Mystery 2",
    Callback = function()
        TPSeguro(142823291, "MM2")
    end
})

Tabs.Inicio:Button({
    Title = "Murderers VS Sheriffs (Duels)",
    Callback = function()
        TPSeguro(135856908115931, "Duels")
    end
})

Tabs.Inicio:Button({
    Title = "Murder Mystery V (MMV)",
    Callback = function()
        TPSeguro(117973911105557, "MMV")
    end
})

task.wait()

Tabs.Aim:Section({ Title = "Auto Shoot" })

UIElements.TogAutoShoot = Tabs.Aim:Toggle({
    Title = "Auto Shoot (Normal - Cabeza/Torso)",
    Desc = "Dispara automáticamente al torso o cabeza sin fallar.",
    Callback = function(Value)
        autoShootEnabled = Value
        if not Value and not autoShootAgresivoEnabled then
            getgenv().NexvyrTargetPart = nil
        end
    end
})

UIElements.TogAutoShootAgr = Tabs.Aim:Toggle({
    Title = "Auto Shoot (Agresivo - Hitbox Completa)",
    Desc = "Dispara a cualquier píxel visible del cuerpo del enemigo.",
    Callback = function(Value)
        autoShootAgresivoEnabled = Value
        if not Value and not autoShootEnabled then
            getgenv().NexvyrTargetPart = nil
        end
    end
})

UIElements.TogSilentAimManual = Tabs.Aim:Toggle({
    Title = "Silent Aim",
    Desc = "Redirige las balas al enemigo.",
    Callback = function(Value)
        silentAimManualEnabled = Value
        if not Value and not autoShootEnabled and not autoShootAgresivoEnabled then
            getgenv().NexvyrTargetPart = nil
        end
    end
})

UIElements.DropSilentAimPart = Tabs.Aim:Dropdown({
    Title = "Target: Parte del cuerpo",
    Values = { "Cabeza", "Torso", "Cuerpo Completo" },
    Value = "Cabeza",
    Callback = function(Value)
        silentAimTargetPart = Value
    end
})

UIElements.TogSilentAimFOV = Tabs.Aim:Toggle({
    Title = "Silent Aim (Con FOV)",
    Desc = "Igual que el Silent Aim, pero solo afecta a los enemigos dentro del círculo.",
    Callback = function(Value)
        silentAimFovEnabled = Value
        if not Value and not silentAimManualEnabled and not autoShootEnabled and not autoShootAgresivoEnabled then
            getgenv().NexvyrTargetPart = nil
        end
    end
})

UIElements.TogShowFOV = Tabs.Aim:Toggle({
    Title = "Mostrar Círculo FOV",
    Desc = "Dibuja un círculo en pantalla.",
    Callback = function(Value)
        fovVisiblePreference = Value
    end
})

UIElements.SliFOVSize = Tabs.Aim:Slider({
    Title = "Tamaño del FOV",
    Step = 1,
    Value = { Min = 10, Max = 800, Default = 120 },
    Callback = function(v)
        fovRadius = v
    end
})

getgenv().NexvyrTargetPart = nil

local oldNamecall
if hookmetamethod and getnamecallmethod and checkcaller then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()

        if not checkcaller() and getgenv().NexvyrTargetPart then
            local target = getgenv().NexvyrTargetPart

            if target and target.Parent then
                if method == "Raycast" and self == workspace then
                    local origin, direction, p3 = ...
                    if typeof(direction) == "Vector3" and direction.Magnitude > 20 then
                        local newDir = (target.Position - origin).Unit * 5000
                        return oldNamecall(self, origin, newDir, p3)
                    end
                elseif string.find(method, "FindPartOnRay") and self == workspace then
                    local ray, p2, p3, p4 = ...
                    if typeof(ray) == "Ray" and ray.Direction.Magnitude > 20 then
                        local newRay = Ray.new(ray.Origin, (target.Position - ray.Origin).Unit * 5000)
                        return oldNamecall(self, newRay, p2, p3, p4)
                    end
                end
            else
                getgenv().NexvyrTargetPart = nil
            end
        end

        return oldNamecall(self, ...)
    end)
else
    warn("Hook de raycast no disponible en este entorno.")
end

task.spawn(function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    while task.wait(0.1) do
        if autoShootEnabled or autoShootAgresivoEnabled then
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                continue
            end

            local arma = char:FindFirstChildOfClass("Tool")
            if not arma or not arma:FindFirstChild("Handle") then
                getgenv().NexvyrTargetPart = nil
                continue
            end

            local closestTargetPart = nil
            local shortestDistance = math.huge
            local myPos = char.HumanoidRootPart.Position
            local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and isEnemy(p) and p.Character then
                    local enemyHum = p.Character:FindFirstChild("Humanoid")

                    if enemyHum and enemyHum.Health > 0 then
                        params.FilterDescendantsInstances = { char, p.Character }

                        local function ProcesarParte(part)
                            local dist = (part.Position - myPos).Magnitude

                            if dist < shortestDistance then
                                local size = part.Size
                                local offsets = {
                                    Vector3.new(0, 0, 0),
                                    Vector3.new(size.X / 2.1, 0, 0),
                                    Vector3.new(-size.X / 2.1, 0, 0),
                                    Vector3.new(0, size.Y / 2.1, 0),
                                    Vector3.new(0, -size.Y / 2.1, 0)
                                }

                                local isVisible = false
                                for _, offset in ipairs(offsets) do
                                    if not workspace:Raycast(headPos, (part.CFrame * offset) - headPos, params) then
                                        isVisible = true
                                        break
                                    end
                                end

                                if isVisible then
                                    shortestDistance = dist
                                    closestTargetPart = part
                                end
                            end
                        end

                        if autoShootAgresivoEnabled then
                            for _, part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    ProcesarParte(part)
                                end
                            end
                        else
                            local partesClave = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }
                            for _, partName in ipairs(partesClave) do
                                local part = p.Character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    ProcesarParte(part)
                                end
                            end
                        end
                    end
                end
            end

            if closestTargetPart then
                getgenv().NexvyrTargetPart = closestTargetPart

                pcall(function()
                    arma:Activate()
                    task.delay(0.05, function()
                        if arma.Parent == char then
                            arma:Deactivate()
                        end
                    end)
                end)

                task.wait(0.2)
            else
                getgenv().NexvyrTargetPart = nil
            end
        end
    end
end)

task.spawn(function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    while task.wait(0.1) do
        if silentAimManualEnabled or silentAimFovEnabled then
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                continue
            end

            local closestTargetPart = nil
            local shortestDistToCenter = math.huge
            local shortestDistanceFisica = math.huge
            local myPos = char.HumanoidRootPart.Position
            local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and isEnemy(p) and p.Character then
                    local enemyHum = p.Character:FindFirstChild("Humanoid")

                    if enemyHum and enemyHum.Health > 0 then
                        local partesAEscanear = {}

                        if silentAimTargetPart == "Cabeza" then
                            local head = p.Character:FindFirstChild("Head")
                            if head then
                                table.insert(partesAEscanear, head)
                            end
                        elseif silentAimTargetPart == "Torso" then
                            local partesClave = { "UpperTorso", "Torso", "HumanoidRootPart" }
                            for _, partName in ipairs(partesClave) do
                                local part = p.Character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    table.insert(partesAEscanear, part)
                                end
                            end
                        elseif silentAimTargetPart == "Cuerpo Completo" then
                            for _, part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    table.insert(partesAEscanear, part)
                                end
                            end
                        end

                        params.FilterDescendantsInstances = { char, p.Character }

                        for _, part in ipairs(partesAEscanear) do
                            local distFisica = (part.Position - myPos).Magnitude
                            local pos2D, onScreen = camera:WorldToViewportPoint(part.Position)
                            local distToCenter = (Vector2.new(pos2D.X, pos2D.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude

                            local pasaFiltro = false

                            if silentAimFovEnabled then
                                if onScreen and distToCenter <= fovRadius and distToCenter < shortestDistToCenter then
                                    pasaFiltro = true
                                end
                            elseif silentAimManualEnabled then
                                if distFisica < shortestDistanceFisica then
                                    pasaFiltro = true
                                end
                            end

                            if pasaFiltro then
                                local raycastResult = workspace:Raycast(headPos, part.Position - headPos, params)

                                if not raycastResult then
                                    if silentAimFovEnabled then
                                        shortestDistToCenter = distToCenter
                                        closestTargetPart = part
                                    else
                                        shortestDistanceFisica = distFisica
                                        closestTargetPart = part
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if closestTargetPart then
                getgenv().NexvyrTargetPart = closestTargetPart
            else
                if not autoShootEnabled and not autoShootAgresivoEnabled then
                    getgenv().NexvyrTargetPart = nil
                end
            end
        end
    end
end)

Tabs.KillAll:Section({ Title = "Kill All" })

UIElements.TogKillAll = Tabs.KillAll:Toggle({
    Title = "Kill All Enemies",
    Desc = "Se teletransporta al piso del enemigo y ataca con cuchillo. Solo en partida.",
    Value = false,
    Callback = function(Value)
        if KillAllInstance.AlwaysOn and not Value then
            task.defer(function()
                if KillAllInstance.AlwaysOn then
                    KillAllEnabled = true
                    pcall(function()
                        KillAllInstance:Start()
                    end)
                end
            end)
            return
        end

        KillAllEnabled = Value

        if Value then
            KillAllInstance:Start()
        else
            KillAllInstance:Stop()
        end

        RefreshKillAllBubble()
    end
})

Tabs.KillAll:Toggle({
    Title = "Keep Kill All Always On",
    Desc = "Fuerza que Kill All permanezca encendido y bloquea su toggle.",
    Value = false,
    Callback = function(Value)
        KillAllInstance.AlwaysOn = Value

        if Value then
            KillAllEnabled = true
            pcall(function()
                KillAllInstance:Start()
            end)

            pcall(function()
                UIElements.TogKillAll.LockedTitle = "Locked by Always On"
            end)

            pcall(function()
                UIElements.TogKillAll:Lock()
            end)

            EnforceKillAllAlwaysOn()
        else
            pcall(function()
                UIElements.TogKillAll:Unlock()
            end)
        end

        RefreshKillAllBubble()
    end
})

Tabs.KillAll:Toggle({
    Title = "Kill All Bubble",
    Desc = "Muestra un botón flotante 'KA' en pantalla.",
    Value = false,
    Callback = function(Value)
        killAllBubbleEnabled = Value
        BuildKillAllBubble()
    end
})

Tabs.KillAll:Space()

Tabs.KillAll:Section({ Title = "Hitbox Expander" })

Tabs.KillAll:Toggle({
    Title = "Activar Hitbox",
    Desc = "Añade una hitbox rectangular a los enemigos.",
    Value = false,
    Callback = function(Value)
        hitboxEnabled = Value

        if not Value then
            limpiarHitboxes()
        end
    end
})

Tabs.KillAll:Toggle({
    Title = "Hitbox Invisible",
    Desc = "Hace la hitbox completamente transparente.",
    Value = false,
    Callback = function(Value)
        hitboxInvisible = Value
    end
})

Tabs.KillAll:Slider({
    Title = "Tamaño de la Hitbox",
    Step = 0.5,
    Value = { Min = 1.0, Max = 50.0, Default = 3.5 },
    Callback = function(v)
        hitboxSize = v
    end
})

Tabs.KillAll:Colorpicker({
    Title = "Color de la Hitbox",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c)
        hitboxColor = c
    end
})

-- ============================================================
-- PESTAÑA: AUTO TELEPORT MAIN/ALT
-- ============================================================

Tabs.RachaFarm:Section({ Title = "Auto Teleport Main/Alt" })

local autoTPMainToggle
local autoTPAltToggle

autoTPMainToggle = Tabs.RachaFarm:Toggle({
    Title = "Auto Teleport (Main)",
    Desc = "Te teletransporta a la plataforma Main. Se desactiva si activás Alt.",
    Value = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Main"
            KillAllInstance.activeRole = "Main"

            if autoTPAltToggle then
                pcall(function() autoTPAltToggle:Set(false) end)
            end

            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Main" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                KillAllInstance.activeRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end
})

autoTPAltToggle = Tabs.RachaFarm:Toggle({
    Title = "Auto Teleport (Alt)",
    Desc = "Te teletransporta a la plataforma Alt. Se desactiva si activás Main.",
    Value = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Alt"
            KillAllInstance.activeRole = "Alt"

            if autoTPMainToggle then
                pcall(function() autoTPMainToggle:Set(false) end)
            end

            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Alt" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                KillAllInstance.activeRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end
})

Tabs.RachaFarm:Dropdown({
    Title = "Tipo de Duelo",
    Values = { "1v1", "2v2", "3v3", "4v4" },
    Value = "1v1",
    Callback = function(value)
        if PadZoneConfig["Right Platforms"][value] then
            AutoTeleportMainAltInstance.DuelType = value
        else
            AutoTeleportMainAltInstance.DuelType = "1v1"
        end
        AutoTeleportMainAltInstance:Kick()
    end
})

Tabs.RachaFarm:Dropdown({
    Title = "Fila de Plataformas",
    Values = { "Right Platforms", "Left Platforms" },
    Value = "Right Platforms",
    Callback = function(value)
        if PadZoneConfig[value] then
            AutoTeleportMainAltInstance.PlatformRow = value
        else
            AutoTeleportMainAltInstance.PlatformRow = "Right Platforms"
        end
        AutoTeleportMainAltInstance:Kick()
    end
})

Tabs.RachaFarm:Space()
Tabs.RachaFarm:Divider()
Tabs.RachaFarm:Space()

Tabs.RachaFarm:Toggle({
    Title = "Break Streak",
    Desc = "Rompe la racha de jugadores que superen el objetivo.",
    Value = false,
    Callback = function(value)
        a8_breakStreakEnabled = value
    end
})

Tabs.RachaFarm:Slider({
    Title = "Break Streak Target",
    Step = 1,
    Value = { Min = 0, Max = 500, Default = 1 },
    Callback = function(value)
        a8_breakStreakTarget = value
    end
})

Tabs.RachaFarm:Space()

Tabs.RachaFarm:Toggle({
    Title = "Lower KD",
    Desc = "Baja tu KD matando jugadores que tengan pocas kills.",
    Value = false,
    Callback = function(value)
        a8_lowerKDEnabled = value
    end
})

Tabs.RachaFarm:Slider({
    Title = "KD Target Kills",
    Step = 1,
    Value = { Min = 0, Max = 4, Default = 4 },
    Callback = function(value)
        a8_kdTargetKills = value
    end
})

Tabs.Vis:Section({ Title = "Configuración de ESP" })

UIElements.TogEsp = Tabs.Vis:Toggle({
    Title = "ESP Jugadores",
    Callback = function(s)
        espEnabled = s
    end
})

UIElements.ColEsp = Tabs.Vis:Colorpicker({
    Title = "Color del ESP",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c)
        espColor = c
    end
})

Tabs.Vis:Section({ Title = "Filtros de ESP" })

UIElements.TogEspGl = Tabs.Vis:Toggle({
    Title = "Mostrar Resplandor",
    Callback = function(s)
        espSettings.Glow = s
    end
})

UIElements.TogEspLines = Tabs.Vis:Toggle({
    Title = "Mostrar Líneas",
    Callback = function(s)
        espLinesEnabled = s
    end
})

local activeESPs = {}
local MAX_ESP_DISTANCE = 1500
local tracerLines = {}

local function cleanESP(targetPlayer)
    if activeESPs[targetPlayer] then
        if activeESPs[targetPlayer].Highlight then
            activeESPs[targetPlayer].Highlight:Destroy()
        end
        activeESPs[targetPlayer] = nil
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if espEnabled then
            local myChar = player.Character
            local myHead = myChar and myChar:FindFirstChild("Head")
            local myPos = myHead and myHead.Position

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    local char = p.Character

                    if char
                        and char:FindFirstChild("Humanoid")
                        and char.Humanoid.Health > 0
                        and char:FindFirstChild("Head")
                        and isEnemy(p) then
                        local targetHead = char.Head
                        local dist = myPos and (targetHead.Position - myPos).Magnitude or 0

                        if dist <= MAX_ESP_DISTANCE then
                            if activeESPs[p] and activeESPs[p].Char ~= char then
                                cleanESP(p)
                            end

                            if not activeESPs[p] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = p.Name .. "_Glow"
                                highlight.FillTransparency = 1
                                highlight.OutlineTransparency = 0
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Adornee = char
                                highlight.Parent = espFolder

                                activeESPs[p] = { Highlight = highlight, Char = char }
                            end

                            local espObj = activeESPs[p]

                            if espObj.Highlight.Enabled ~= espSettings.Glow then
                                espObj.Highlight.Enabled = espSettings.Glow
                            end

                            if espObj.Highlight.OutlineColor ~= espColor then
                                espObj.Highlight.OutlineColor = espColor
                            end
                        else
                            cleanESP(p)
                        end
                    else
                        cleanESP(p)
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                cleanESP(p)
            end
        end
    end
end)

local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Radius = fovRadius
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1
end

RunService.RenderStepped:Connect(function()
    if fovVisiblePreference and FOVCircle then
        FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        FOVCircle.Radius = fovRadius
        FOVCircle.Visible = true

        if silentAimFovEnabled and getgenv().NexvyrTargetPart then
            FOVCircle.Color = Color3.fromRGB(0, 255, 0)
        else
            FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    elseif FOVCircle then
        FOVCircle.Visible = false
    end

    if not espEnabled or not espLinesEnabled then
        for _, tLine in pairs(tracerLines) do
            if tLine.Visible then
                tLine.Visible = false
            end
        end
        return
    end

    local myChar = player.Character
    local myPos = (myChar and myChar.PrimaryPart) and myChar.PrimaryPart.Position or camera.CFrame.Position
    local centroPantallaX = camera.ViewportSize.X / 2

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local tLine = tracerLines[p]

            if not tLine then
                if Drawing then
                    tLine = Drawing.new("Line")
                    tLine.Thickness = 1.5
                    tLine.Transparency = 1
                    tLine.Visible = false
                    tracerLines[p] = tLine
                else
                    break
                end
            end

            local char = p.Character
            local hrp = char and char.PrimaryPart

            if hrp and isEnemy(p) then
                local hum = char:FindFirstChild("Humanoid")

                if hum and hum.Health > 0 then
                    local hrpPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        local dist = (myPos - hrp.Position).Magnitude

                        if dist <= MAX_ESP_DISTANCE then
                            if tLine.From.X ~= centroPantallaX then
                                tLine.From = Vector2.new(centroPantallaX, 0)
                            end

                            tLine.To = Vector2.new(hrpPos.X, hrpPos.Y)

                            if tLine.Color ~= espColor then
                                tLine.Color = espColor
                            end

                            if not tLine.Visible then
                                tLine.Visible = true
                            end

                            continue
                        end
                    end
                end
            end

            if tLine and tLine.Visible then
                tLine.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if tracerLines[p] then
        tracerLines[p]:Remove()
        tracerLines[p] = nil
    end
    cleanESP(p)
end)

Tabs.Farm:Section({ Title = "Farmeo de Evento" })

getgenv().AutoEventFarm = false
local Networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
local RemoteFarm = Networking and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")

Tabs.Farm:Toggle({
    Title = "Auto Farmear Evento",
    Callback = function(s)
        getgenv().AutoEventFarm = s

        if s then
            task.spawn(function()
                while getgenv().AutoEventFarm do
                    pcall(function()
                        if RemoteFarm then
                            RemoteFarm:FireServer()
                        else
                            Networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
                            RemoteFarm = Networking and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")
                        end
                    end)

                    task.wait(0.05)
                end
            end)
        end
    end
})

Tabs.Graficos:Section({ Title = "Modos Visuales" })

UIElements.TogTokyowami = Tabs.Graficos:Toggle({
    Title = "Atardecer",
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")

        if Value then
            if not Lighting:GetAttribute("OrigSaved") then
                Lighting:SetAttribute("OrigBright", Lighting.Brightness)
                Lighting:SetAttribute("OrigCSB", Lighting.ColorShift_Bottom)
                Lighting:SetAttribute("OrigCST", Lighting.ColorShift_Top)
                Lighting:SetAttribute("OrigOA", Lighting.OutdoorAmbient)
                Lighting:SetAttribute("OrigTime", Lighting.ClockTime)
                Lighting:SetAttribute("OrigFogC", Lighting.FogColor)
                Lighting:SetAttribute("OrigFogE", Lighting.FogEnd)
                Lighting:SetAttribute("OrigExp", Lighting.ExposureCompensation)
                Lighting:SetAttribute("OrigShadow", Lighting.ShadowSoftness)
                Lighting:SetAttribute("OrigAmbient", Lighting.Ambient)
                Lighting:SetAttribute("OrigSaved", true)
            end

            for _, v in ipairs(tokyowamiEffects) do
                pcall(function()
                    v:Destroy()
                end)
            end
            table.clear(tokyowamiEffects)

            local Bloom = Instance.new("BloomEffect")
            Bloom.Intensity = 0.1
            Bloom.Threshold = 0
            Bloom.Size = 100
            Bloom.Parent = Lighting
            table.insert(tokyowamiEffects, Bloom)

            local Sky = Instance.new("Sky")
            Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
            Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
            Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
            Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
            Sky.CelestialBodiesShown = false
            Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
            Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
            Sky.Parent = Lighting
            table.insert(tokyowamiEffects, Sky)

            local Blur = Instance.new("BlurEffect")
            Blur.Size = 2
            Blur.Parent = Lighting
            table.insert(tokyowamiEffects, Blur)

            local Inaritaisha = Instance.new("ColorCorrectionEffect")
            Inaritaisha.Saturation = 0.05
            Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219)
            Inaritaisha.Parent = Lighting
            table.insert(tokyowamiEffects, Inaritaisha)

            local SunRays = Instance.new("SunRaysEffect")
            SunRays.Intensity = 0.05
            SunRays.Parent = Lighting
            table.insert(tokyowamiEffects, SunRays)

            Lighting.Brightness = 2.14
            Lighting.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
            Lighting.ColorShift_Top = Color3.fromRGB(240, 127, 14)
            Lighting.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
            Lighting.ClockTime = 6.7
            Lighting.FogColor = Color3.fromRGB(94, 76, 106)
            Lighting.FogEnd = 1000
            Lighting.ExposureCompensation = 0.24
            Lighting.ShadowSoftness = 0
            Lighting.Ambient = Color3.fromRGB(59, 33, 27)
        else
            for _, v in ipairs(tokyowamiEffects) do
                pcall(function()
                    v:Destroy()
                end)
            end
            table.clear(tokyowamiEffects)

            if Lighting:GetAttribute("OrigSaved") then
                Lighting.Brightness = Lighting:GetAttribute("OrigBright")
                Lighting.ColorShift_Bottom = Lighting:GetAttribute("OrigCSB")
                Lighting.ColorShift_Top = Lighting:GetAttribute("OrigCST")
                Lighting.OutdoorAmbient = Lighting:GetAttribute("OrigOA")
                Lighting.ClockTime = Lighting:GetAttribute("OrigTime")
                Lighting.FogColor = Lighting:GetAttribute("OrigFogC")
                Lighting.FogEnd = Lighting:GetAttribute("OrigFogE")
                Lighting.ExposureCompensation = Lighting:GetAttribute("OrigExp")
                Lighting.ShadowSoftness = Lighting:GetAttribute("OrigShadow")
                Lighting.Ambient = Lighting:GetAttribute("OrigAmbient")
            end
        end
    end
})

Tabs.Graficos:Section({ Title = "Rendimiento" })

local fpsBoostEnabled = false
local autoFpsConnection = nil
local origGlobalShadows = true
local origFogEnd = 100000
local origShadowSoftness = 1

UIElements.ToggleFPS = Tabs.Graficos:Toggle({
    Title = "FPS Boost (Elimina texturas)",
    Value = false,
    Callback = function(state)
        fpsBoostEnabled = state

        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        local cacheFolder = Lighting:FindFirstChild("NexvyrPBRCache")

        if not cacheFolder then
            cacheFolder = Instance.new("Folder")
            cacheFolder.Name = "NexvyrPBRCache"
            cacheFolder.Parent = Lighting
        end

        if state then
            origGlobalShadows = Lighting.GlobalShadows
            origFogEnd = Lighting.FogEnd
            origShadowSoftness = Lighting.ShadowSoftness

            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0

            if Terrain then
                pcall(function()
                    if not Terrain:GetAttribute("OrigWaveSize") then
                        Terrain:SetAttribute("OrigWaveSize", Terrain.WaterWaveSize)
                        Terrain:SetAttribute("OrigDeco", Terrain.Decoration)
                    end

                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 1
                    Terrain.Decoration = false
                end)
            end

            local function applyLowGraphics(v)
                if not v:IsA("BasePart")
                    and not v:IsA("Decal")
                    and not v:IsA("Texture")
                    and not v:IsA("SpecialMesh")
                    and not v:IsA("Light")
                    and not v:IsA("PostEffect") then
                    return
                end

                pcall(function()
                    if v:IsA("ScreenGui") then
                        return
                    end

                    if v.Parent and v.Parent:FindFirstChild("Humanoid") then
                        return
                    end

                    if v:IsA("BasePart") and not v:IsA("Terrain") then
                        if not v:GetAttribute("OrigMat") then
                            v:SetAttribute("OrigMat", v.Material.Name)
                            v:SetAttribute("OrigCast", v.CastShadow)
                        end

                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                        v.CastShadow = false

                        if v:IsA("MeshPart") then
                            if not v:GetAttribute("OrigTex") then
                                v:SetAttribute("OrigTex", v.TextureID)
                            end
                            v.TextureID = ""
                        end
                    elseif v:IsA("SpecialMesh") then
                        if not v:GetAttribute("OrigTex") then
                            v:SetAttribute("OrigTex", v.TextureId)
                        end
                        v.TextureId = ""
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        if not v:GetAttribute("OrigTrans") then
                            v:SetAttribute("OrigTrans", v.Transparency)
                        end
                        v.Transparency = 1
                    elseif v:IsA("Light") or v:IsA("PostEffect") then
                        if v:GetAttribute("OrigEnabled") == nil then
                            v:SetAttribute("OrigEnabled", v.Enabled)
                        end
                        v.Enabled = false
                    end
                end)
            end

            task.spawn(function()
                local count = 0

                for _, v in pairs(workspace:GetDescendants()) do
                    applyLowGraphics(v)
                    count = count + 1

                    if count % 300 == 0 then
                        task.wait()
                    end
                end
            end)

            if not autoFpsConnection then
                autoFpsConnection = workspace.DescendantAdded:Connect(function(v)
                    if fpsBoostEnabled then
                        applyLowGraphics(v)
                    end
                end)
            end
        else
            Lighting.GlobalShadows = origGlobalShadows
            Lighting.FogEnd = origFogEnd
            Lighting.ShadowSoftness = origShadowSoftness

            if Terrain and Terrain:GetAttribute("OrigWaveSize") then
                pcall(function()
                    Terrain.WaterWaveSize = Terrain:GetAttribute("OrigWaveSize")
                    Terrain.Decoration = Terrain:GetAttribute("OrigDeco")
                end)
            end

            task.spawn(function()
                local count = 0

                for _, v in pairs(workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("BasePart") and v:GetAttribute("OrigMat") then
                            local matName = v:GetAttribute("OrigMat")
                            if Enum.Material[matName] then
                                v.Material = Enum.Material[matName]
                            end

                            v.CastShadow = v:GetAttribute("OrigCast")

                            if v:IsA("MeshPart") and v:GetAttribute("OrigTex") then
                                v.TextureID = v:GetAttribute("OrigTex")
                            end
                        elseif v:IsA("SpecialMesh") and v:GetAttribute("OrigTex") then
                            v.TextureId = v:GetAttribute("OrigTex")
                        elseif (v:IsA("Decal") or v:IsA("Texture")) and v:GetAttribute("OrigTrans") then
                            v.Transparency = v:GetAttribute("OrigTrans")
                        elseif (v:IsA("Light") or v:IsA("PostEffect")) and v:GetAttribute("OrigEnabled") ~= nil then
                            v.Enabled = v:GetAttribute("OrigEnabled")
                        end
                    end)

                    count = count + 1

                    if count % 300 == 0 then
                        task.wait()
                    end
                end

                for _, v in pairs(cacheFolder:GetChildren()) do
                    pcall(function()
                        if v:GetAttribute("OrigParent") then
                            v.Parent = v:GetAttribute("OrigParent")
                        end
                    end)
                end
            end)

            if autoFpsConnection then
                autoFpsConnection:Disconnect()
                autoFpsConnection = nil
            end
        end
    end
})

local animationData = {
    ["Old School"] = { Walk = 10921244891, Run = 10921240218, Jump = 10921242013, Fall = 10921241244, SwimIdle = 10921244018, Swim = 10921243048, Idle = 10921230744, Idle2 = 10921232093, Climb = 10921229866 },
    ["Adidas Sports"] = { Walk = 18537392113, Run = 18537384940, Jump = 18537380791, Fall = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Idle = 18537376492, Idle2 = 18537371272, Climb = 18537363391 },
    ["Adidas Community"] = { Walk = 122150855457006, Run = 82598234841035, Jump = 75290611992385, Fall = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266208, Idle = 122257458498464, Idle2 = 102357151005774, Climb = 88763136693023 },
    ["Adidas Aura"] = { Walk = 83842218823011, Run = 118320322718866, Jump = 109996626521204, Fall = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383903, Idle = 110211186840347, Idle2 = 114191137265065, Climb = 97824616490448 },
    ["Wicked Popular"] = { Walk = 92072849924640, Run = 72301599441680, Jump = 104325245285198, Fall = 121152442762481, Idle = 118832222982049, Idle2 = 76049494037641, SwimIdle = 113199415118199, Swim = 99384245425157, Climb = 131326830509784 },
    ["Elder"] = { Walk = 10921111375, Run = 10921104374, Jump = 10921107367, Fall = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, Idle = 10921101664, Idle2 = 10921102574, Climb = 10921100400 },
    ["Zombie"] = { Walk = 10921355261, Run = 616163682, Jump = 10921351278, Fall = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Idle = 10921344533, Idle2 = 10921345304, Climb = 10921343576 },
    ["Mage"] = { Walk = 10921152678, Run = 10921148209, Jump = 10921149743, Fall = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, Idle = 10921144709, Idle2 = 10921145797, Climb = 10921143404 },
    ["Catwalk Glam"] = { Walk = 109168724482748, Run = 81024476153754, Jump = 116936326516985, Fall = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181628, Idle = 133806214992291, Idle2 = 94970088341563, Climb = 119377220967554 },
    ["Astronaut"] = { Walk = 10921046031, Run = 10921039308, Jump = 10921042494, Fall = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, Idle = 10921034824, Idle2 = 10921036806, Climb = 10921032124 },
    ['Wicked "Dancing Through Life"'] = { Walk = 73718308412641, Run = 135515454877967, Jump = 78508480717326, Fall = 78147885297412, SwimIdle = 129183123083281, Swim = 110657013921774, Idle = 92849173543269, Idle2 = 132238900951109, Climb = 129447497744818 },
    ["Werewolf"] = { Walk = 10921342074, Run = 10921336997, Fall = 10921337907, SwimIdle = 10921341319, Swim = 10921340419, Idle = 10921330408, Idle2 = 10921333667, Climb = 10921329322 },
    ["Superhero"] = { Walk = 10921298616, Run = 10921291831, Jump = 10921294559, Fall = 10921293373, SwimIdle = 10921297391, Swim = 10921295495, Idle = 10921288909, Idle2 = 10921290167, Climb = 10921286911 },
    ["Toy"] = { Walk = 10921312010, Run = 10921306285, Jump = 10921308158, Fall = 10921307241, SwimIdle = 10921310341, Swim = 10921309319, Idle = 10921301576, Climb = 10921300839 },
    ["No Boundaries"] = { Walk = 18747074203, Run = 18747070484, Jump = 18747069148, Fall = 18747062535, SwimIdle = 18747071682, Swim = 18747073181, Idle = 18747067405, Idle2 = 18747063918, Climb = 18747060903 },
    ["NFL"] = { Walk = 110358958299415, Run = 117333533048078, Jump = 119846112151352, Fall = 129773241321032, SwimIdle = 79090109939093, Swim = 132697394189921, Idle = 92080889861410, Idle2 = 74451233229259, Climb = 134630013742019 },
    ["Amazon Unboxed"] = { Walk = 90478085024465, Run = 134824450619865, Jump = 121454505477205, Fall = 94788218468396, SwimIdle = 129126268464847, Swim = 105962919001086, Idle = 98281136301627, Climb = 121145883950231 },
    ["Vampire"] = { Walk = 10921326949, Run = 10921320299, Jump = 10921322186, Fall = 10921321317, SwimIdle = 10921325443, Swim = 10921324408, Idle = 10921315373, Climb = 10921314188 },
    ["Ninja"] = { Walk = 656121766, Run = 656118852, Jump = 656117878, Fall = 656115606, SwimIdle = 656121397, Swim = 656119721, Idle = 656117400, Idle2 = 656118341, Climb = 656114359 },
    ["Robot"] = { Walk = 616095330, Run = 616091570, Jump = 616090535, Fall = 616087089, SwimIdle = 616094091, Swim = 616092998, Idle = 616088211, Idle2 = 616089559, Climb = 616086039 },
    ["Levitation"] = { Walk = 616013216, Run = 616010382, Jump = 616008936, Fall = 616005863, SwimIdle = 616012453, Swim = 616011509, Idle = 616006778, Idle2 = 616008087, Climb = 616003713 },
    ["Stylish"] = { Walk = 616146177, Run = 616140816, Jump = 616139451, Fall = 616134815, SwimIdle = 616144772, Swim = 616143378, Idle = 616136790, Idle2 = 616138447, Climb = 616133594 },
    ["Bubbly"] = { Walk = 910034870, Run = 910025107, Jump = 910016857, Fall = 910001910, SwimIdle = 910030921, Swim = 910028158, Idle = 910004836, Idle2 = 910009958, Climb = 909997997 },
    ["Cartoon"] = { Walk = 742640026, Run = 742638842, Jump = 742637942, Fall = 742637151, SwimIdle = 742639812, Swim = 742639220, Idle = 742637544, Idle2 = 742638445, Climb = 742636889 }
}

local function clearAllAnimations()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    for _, track in pairs(hum:GetPlayingAnimationTracks()) do
        track:Stop(0)
        track:Destroy()
    end
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            track:Stop(0)
            track:Destroy()
        end
    end
    task.wait(0.1)
end

local function applyCustomAnims(customData)
    if not customData then return end
    local char = player.Character
    if not char then return end
    clearAllAnimations()

    local animate = char:FindFirstChild("Animate")
    if not animate then return end

    if not misAnimacionesOriginales then
        local function getAnim(folderName, animName)
            local folder = animate:FindFirstChild(folderName)
            if folder then
                local anim = folder:FindFirstChild(animName)
                if anim and anim:IsA("Animation") then
                    local idStr = anim.AnimationId:match("%d+")
                    if idStr then return tonumber(idStr) end
                end
            end
            return nil
        end

        misAnimacionesOriginales = {
            Idle = getAnim("idle", "Animation1") or 507766666,
            Idle2 = getAnim("idle", "Animation2") or 507766951,
            Walk = getAnim("walk", "WalkAnim") or 507777826,
            Run = getAnim("run", "RunAnim") or 507767714,
            Jump = getAnim("jump", "JumpAnim") or 507765000,
            Climb = getAnim("climb", "ClimbAnim") or 507765644,
            Fall = getAnim("fall", "FallAnim") or 507767968,
            Swim = getAnim("swim", "Swim") or 507784897,
            SwimIdle = getAnim("swimidle", "SwimIdle") or 507785072
        }
    end

    animate.Disabled = true
    task.wait(0.1)

    local function updateAnimation(folderName, animName, animId)
        if not animId then return end
        local folder = animate:FindFirstChild(folderName)
        if folder then
            local anim = folder:FindFirstChild(animName)
            if anim and anim:IsA("Animation") then
                anim.AnimationId = "rbxassetid://" .. tostring(animId)
            end
        end
    end

    updateAnimation("idle", "Animation1", customData.Idle)
    updateAnimation("idle", "Animation2", customData.Idle2 or customData.Idle)
    updateAnimation("walk", "WalkAnim", customData.Walk)
    updateAnimation("run", "RunAnim", customData.Run)
    updateAnimation("jump", "JumpAnim", customData.Jump)
    updateAnimation("climb", "ClimbAnim", customData.Climb)
    updateAnimation("fall", "FallAnim", customData.Fall)
    updateAnimation("swim", "Swim", customData.Swim)
    updateAnimation("swimidle", "SwimIdle", customData.SwimIdle or customData.Swim)

    task.wait(0.1)
    animate.Disabled = false

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Landed)
        task.wait(0.05)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

task.spawn(function()
    while task.wait(1) do
        if animacionActualActiva then
            local char = player.Character
            if char then
                local animate = char:FindFirstChild("Animate")
                if animate then
                    local idleFolder = animate:FindFirstChild("idle")
                    if idleFolder then
                        local anim1 = idleFolder:FindFirstChild("Animation1")
                        if anim1 then
                            local currentId = anim1.AnimationId:match("%d+")
                            if currentId ~= tostring(animacionActualActiva.Idle) then
                                applyCustomAnims(animacionActualActiva)
                            end
                        end
                    end
                end
            end
        end
    end
end)

local animList = {"Ninguno"}
for name, _ in pairs(animationData) do
    table.insert(animList, name)
end
table.sort(animList)

Tabs.Animaciones:Section({Title = "Paquetes Completos"})

local selectedBundleCompleto = "Ninguno"
Tabs.Animaciones:Dropdown({
    Title = "Elegir Paquete",
    Values = animList,
    Value = "Ninguno",
    Callback = function(Value)
        selectedBundleCompleto = Value
    end
})

Tabs.Animaciones:Button({
    Title = "Aplicar Paquete Completo",
    Callback = function()
        if selectedBundleCompleto == "Ninguno" then return end
        task.spawn(function()
            animacionActualActiva = animationData[selectedBundleCompleto]
            applyCustomAnims(animacionActualActiva)
        end)
    end
})

Tabs.Animaciones:Button({
    Title = "Restaurar Default",
    Callback = function()
        task.spawn(function()
            local defaultAnims = misAnimacionesOriginales or {
                Idle = 507766666, Idle2 = 507766951, Walk = 507777826, Run = 507767714,
                Jump = 507765000, Climb = 507765644, Fall = 507767968, Swim = 507784897, SwimIdle = 507785072
            }
            animacionActualActiva = nil
            applyCustomAnims(defaultAnims)
        end)
    end
})

Tabs.Animaciones:Section({Title = "Mezclador de Animaciones"})

local mixParts = {
    Idle = "Ninguno", Walk = "Ninguno", Run = "Ninguno",
    Jump = "Ninguno", Fall = "Ninguno", Climb = "Ninguno"
}

Tabs.Animaciones:Dropdown({Title = "Reposo", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Idle = Value end})
Tabs.Animaciones:Dropdown({Title = "Caminar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Walk = Value end})
Tabs.Animaciones:Dropdown({Title = "Correr", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Run = Value end})
Tabs.Animaciones:Dropdown({Title = "Saltar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Jump = Value end})
Tabs.Animaciones:Dropdown({Title = "Caer", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Fall = Value end})
Tabs.Animaciones:Dropdown({Title = "Escalar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Climb = Value end})

Tabs.Animaciones:Button({
    Title = "Combinar y Aplicar",
    Callback = function()
        task.spawn(function()
            local customMix = {}

            if mixParts.Idle ~= "Ninguno" then
                customMix.Idle = animationData[mixParts.Idle].Idle
                customMix.Idle2 = animationData[mixParts.Idle].Idle2
            end
            if mixParts.Walk ~= "Ninguno" then customMix.Walk = animationData[mixParts.Walk].Walk end
            if mixParts.Run ~= "Ninguno" then customMix.Run = animationData[mixParts.Run].Run end
            if mixParts.Jump ~= "Ninguno" then customMix.Jump = animationData[mixParts.Jump].Jump end
            if mixParts.Fall ~= "Ninguno" then customMix.Fall = animationData[mixParts.Fall].Fall end
            if mixParts.Climb ~= "Ninguno" then customMix.Climb = animationData[mixParts.Climb].Climb end

            local hasValues = false
            for _, v in pairs(customMix) do
                if v then
                    hasValues = true
                    break
                end
            end

            if hasValues then
                animacionActualActiva = customMix
                applyCustomAnims(animacionActualActiva)
            end
        end)
    end
})

Tabs.Com:Section({ Title = "Comunidad" })

Tabs.Com:Button({
    Title = "Grupo de WhatsApp",
    Callback = function()
        pcall(function()
            if setclipboard then
                setclipboard("https://chat.whatsapp.com/CZsrpvaCrCO5oOzeBX5wCM?s=cl&p=a&mlu=4&ilr=4")

                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Link Copiado!",
                    Text = "Abre WhatsApp y pega el enlace para unirte al grupo.",
                    Duration = 4
                })
            end
        end)
    end
})

Tabs.Avisos:Section({ Title = "Aviso" })

Tabs.Avisos:Paragraph({
    Title = "El staff de NexvyrHub no se hace responsable si resultas baneado del juego.",
    Desc = "Actualizaciones cada semana"
})

Tabs.Owners:Section({ Title = "Equipo Nexvyr's" })

Tabs.Owners:Paragraph({
    Title = "<font color='#FFD700'><b>NEXVYR</b></font>",
    Desc = "<font color='#FFD700'>[Owner]</font> <b>7.dui</b>\n\n<font color='#FFD700'>Creador del proyecto</font>\n<font color='#FFD700'>Diseñador principal</font>",
    Image = "rbxassetid://88304008295495",
    ImageSize = 32
})

Tabs.Owners:Paragraph({
    Title = "<font color='#4FC3F7'>SAMXHQQ</font>",
    Desc = "<font color='#4FC3F7'>[Admin]</font> samxh\n\n<font color='#4FC3F7'>Administrador del sistema</font>\n<font color='#4FC3F7'>Moderador</font>",
    Image = "rbxassetid://88304008295495",
    ImageSize = 32
})

Tabs.Owners:Paragraph({
    Title = "<font color='#81C784'>XIN</font>",
    Desc = "<font color='#81C784'>[Helper]</font> AminVega\n\n<font color='#81C784'>Soporte al usuario</font>\n<font color='#81C784'>Documentación</font>",
    Image = "rbxassetid://88304008295495",
    ImageSize = 32
})

Tabs.Owners:Paragraph({
    Title = "Gracias por usar Nexvyr-Hub",
    Desc = "Tu apoyo nos motiva a seguir mejorando.\n\n<font color='#FFD700'>Síguenos para más actualizaciones!</font>"
})
