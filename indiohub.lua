-- ========================================================
-- ÍNDIO HUB - Universal (Funciona em qualquer executor)
-- ========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local bars, evt, antiAFK, lowGFX = false, false, false, false
local vel, dist_max = 16, 1000
local backup = {}

local function som(a)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = a and "rbxassetid://6042053626" or "rbxassetid://6895084424"
        s.Volume = 1.5; s.PlaybackSpeed = a and 1.5 or .6
        s.Parent = SoundService; s:Play()
        game:GetService("Debris"):AddItem(s, 3)
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "IndioHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if syn and syn.protect_gui then
    pcall(function() syn.protect_gui(gui) end)
end
gui.Parent = LP:WaitForChild("PlayerGui")

local function C(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do pcall(function() o[k] = v end) end
    o.Parent = parent
    return o
end
local function cr(p, r) C("UICorner", {CornerRadius = UDim.new(0, r or 3)}, p) end

-- Botão flutuante com emoji
local btn = C("TextButton", {Size = UDim2.new(0,55,0,55), Position = UDim2.new(0,20,0,150),
    BackgroundColor3 = Color3.fromRGB(25,25,30), Text = "🤑", TextSize = 28,
    Font = Enum.Font.GothamBold, Active = true, Draggable = true}, gui)
cr(btn, 12)

-- Janela principal (menor)
local pf = C("Frame", {Size = UDim2.new(0,240,0,410), Position = UDim2.new(.5,-120,.5,-205),
    BackgroundColor3 = Color3.fromRGB(22,22,28), Visible = false, Active = true, Draggable = true}, gui)
cr(pf)

local bd = C("UIStroke", {Thickness = 1.5, Color = Color3.fromRGB(60,60,70), ZIndex = 5}, pf)
local h = 0
RunService.RenderStepped:Connect(function() h = (h+.005)%1; bd.Color = Color3.fromHSV(h,.6,.9) end)

-- Título
local tt = C("TextLabel", {Size = UDim2.new(1,0,0,35), BackgroundColor3 = Color3.fromRGB(30,30,38),
    BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(240,240,240), Text = "🤑 ÍNDIO HUB",
    Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 6}, pf)
cr(tt)
C("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10),
    BackgroundColor3 = Color3.fromRGB(30,30,38), BackgroundTransparency = 0.3, ZIndex = 6}, tt)
local x = C("TextButton", {Size = UDim2.new(0,28,1,0), Position = UDim2.new(1,-28,0,0),
    BackgroundColor3 = Color3.fromRGB(180,50,50), TextColor3 = Color3.new(1,1,1), Text = "X",
    Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 7}, tt)
cr(x)

-- Próximo evento
local tf = C("Frame", {Size = UDim2.new(1,-16,0,45), Position = UDim2.new(0,8,0,42),
    BackgroundColor3 = Color3.fromRGB(30,30,38), BackgroundTransparency = 0.2, ZIndex = 4}, pf)
cr(tf)
C("TextLabel", {Size = UDim2.new(1,0,0,16), Position = UDim2.new(0,0,0,4), BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(220,220,220), Text = "PRÓXIMO EVENTO", Font = Enum.Font.GothamBold,
    TextSize = 10, ZIndex = 5}, tf)
local tV = C("TextLabel", {Size = UDim2.new(1,0,0,22), Position = UDim2.new(0,0,0,18),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,200,50), Text = "--:--",
    Font = Enum.Font.GothamBlack, TextSize = 17, ZIndex = 5}, tf)

-- Rodapé
local stl = C("TextLabel", {Size = UDim2.new(1,-16,0,22), Position = UDim2.new(0,8,1,-30),
    BackgroundColor3 = Color3.fromRGB(28,28,35), BackgroundTransparency = 0.2,
    TextColor3 = Color3.fromRGB(180,180,180), Text = "Aguardando...",
    Font = Enum.Font.GothamMedium, TextSize = 10, ZIndex = 4}, pf)
cr(stl)

-- Popup
local function popup(t, c)
    pcall(function()
        local p = C("TextLabel", {Size = UDim2.new(0,200,0,32), Position = UDim2.new(.5,-100,.2,-15),
            BackgroundColor3 = Color3.fromRGB(22,22,28), TextColor3 = c, Text = t,
            Font = Enum.Font.GothamMedium, TextSize = 13, BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 100}, gui)
        cr(p)
        local s = C("UIStroke", {Color = c, Transparency = 1}, p)
        TweenService:Create(p, TweenInfo.new(.25), {Position = UDim2.new(.5,-100,.2,0), BackgroundTransparency = 0, TextTransparency = 0}):Play()
        TweenService:Create(s, TweenInfo.new(.25), {Transparency = .5}):Play()
        task.wait(1.2)
        TweenService:Create(p, TweenInfo.new(.3), {Position = UDim2.new(.5,-100,.2,-15), BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(s, TweenInfo.new(.3), {Transparency = 1}):Play()
        task.wait(.35); p:Destroy()
    end)
end

-- Toggle (menor)
local of = C("Frame", {Size = UDim2.new(1,-16,0,190), Position = UDim2.new(0,8,0,94),
    BackgroundTransparency = 1, ZIndex = 4}, pf)
local function tog(nome, y, cb)
    local r = C("Frame", {Size = UDim2.new(1,0,0,42), Position = UDim2.new(0,0,0,y),
        BackgroundColor3 = Color3.fromRGB(30,30,38), BackgroundTransparency = 0.2, ZIndex = 4}, of)
    cr(r)
    C("TextLabel", {Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(220,220,220), Text = nome, Font = Enum.Font.GothamMedium,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, r)
    local st = C("TextLabel", {Size = UDim2.new(0,44,0,18), Position = UDim2.new(1,-84,.5,-9),
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(130,130,130), Text = "OFF",
        Font = Enum.Font.GothamBold, TextSize = 9, ZIndex = 5}, r)
    local bg = C("Frame", {Size = UDim2.new(0,34,0,17), Position = UDim2.new(1,-42,.5,-8.5),
        BackgroundColor3 = Color3.fromRGB(60,60,70), ZIndex = 5}, r)
    cr(bg, 99)
    local kn = C("Frame", {Size = UDim2.new(0,13,0,13), Position = UDim2.new(0,2,.5,-6.5),
        BackgroundColor3 = Color3.fromRGB(240,240,240), ZIndex = 6}, bg)
    cr(kn, 99)
    local c = C("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", ZIndex = 10}, r)
    local s = false
    c.MouseButton1Click:Connect(function()
        s = not s
        TweenService:Create(bg, TweenInfo.new(.2), {BackgroundColor3 = s and Color3.fromRGB(60,180,60) or Color3.fromRGB(60,60,70)}):Play()
        TweenService:Create(kn, TweenInfo.new(.2), {Position = s and UDim2.new(1,-15,.5,-6.5) or UDim2.new(0,2,.5,-6.5)}):Play()
        st.Text = s and "ON" or "OFF"
        st.TextColor3 = s and Color3.fromRGB(80,200,80) or Color3.fromRGB(130,130,130)
        som(s)
        popup((s and "ATIVADO: " or "DESATIVADO: ")..nome, s and Color3.fromRGB(80,220,80) or Color3.fromRGB(220,80,80))
        cb(s)
    end)
end

-- Low GFX
local function aplicarLowGFX(ativar)
    pcall(function()
        if ativar then
            backup.Lighting = {GlobalShadows = Lighting.GlobalShadows, Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
                FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart}
            Lighting.GlobalShadows = false; Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(180,180,180); Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
            Lighting.FogEnd = 100000; Lighting.FogStart = 0

            backup.Effects = {}
            for _, o in pairs(Lighting:GetChildren()) do
                if o:IsA("BlurEffect") or o:IsA("SunRaysEffect") or o:IsA("ColorCorrectionEffect") or
                   o:IsA("BloomEffect") or o:IsA("DepthOfFieldEffect") or o:IsA("Atmosphere") or o:IsA("Sky") then
                    table.insert(backup.Effects, {obj = o, enabled = o.Enabled, parent = o.Parent})
                    if o:IsA("Sky") then o.Parent = nil else o.Enabled = false end
                end
            end

            backup.Workspace = {}
            for _, o in pairs(workspace:GetDescendants()) do
                if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
                    table.insert(backup.Workspace, {obj = o, enabled = o.Enabled}); o.Enabled = false
                elseif o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
                    table.insert(backup.Workspace, {obj = o, enabled = o.Enabled}); o.Enabled = false
                elseif o:IsA("Decal") or o:IsA("Texture") then
                    table.insert(backup.Workspace, {obj = o, trans = o.Transparency}); o.Transparency = 1
                elseif o:IsA("Beam") then
                    table.insert(backup.Workspace, {obj = o, enabled = o.Enabled}); o.Enabled = false
                end
            end

            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                backup.Terrain = {WaterWaveSize = terrain.WaterWaveSize, WaterWaveSpeed = terrain.WaterWaveSpeed,
                    WaterReflectance = terrain.WaterReflectance, WaterTransparency = terrain.WaterTransparency}
                terrain.WaterWaveSize = 0; terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0; terrain.WaterTransparency = 1; terrain.Decoration = false
            end
        else
            if backup.Lighting then for k, v in pairs(backup.Lighting) do pcall(function() Lighting[k] = v end) end end
            if backup.Effects then
                for _, d in ipairs(backup.Effects) do
                    pcall(function()
                        if d.parent and not d.obj.Parent then d.obj.Parent = d.parent end
                        d.obj.Enabled = d.enabled
                    end)
                end
            end
            if backup.Workspace then
                for _, d in ipairs(backup.Workspace) do
                    pcall(function()
                        if d.enabled ~= nil then d.obj.Enabled = d.enabled end
                        if d.trans ~= nil then d.obj.Transparency = d.trans end
                    end)
                end
            end
            if backup.Terrain then
                local terrain = workspace:FindFirstChildOfClass("Terrain")
                if terrain then
                    terrain.WaterWaveSize = backup.Terrain.WaterWaveSize
                    terrain.WaterWaveSpeed = backup.Terrain.WaterWaveSpeed
                    terrain.WaterReflectance = backup.Terrain.WaterReflectance
                    terrain.WaterTransparency = backup.Terrain.WaterTransparency
                    terrain.Decoration = true
                end
            end
            backup = {}
        end
    end)
end

tog("Coletar Evento", 0, function(s) evt = s end)
tog("Coletar Barris", 45, function(s) bars = s end)
tog("Anti-AFK", 90, function(s)
    antiAFK = s
    if s then
        task.spawn(function()
            while antiAFK do
                task.wait(50)
                pcall(function()
                    local VU = game:GetService("VirtualUser")
                    VU:CaptureController(); VU:ClickButton2(Vector2.new(0, 0))
                end)
                pcall(function()
                    local h2 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                    if h2 then h2.Jump = true end
                end)
            end
        end)
    end
end)
tog("Modo Leve", 135, aplicarLowGFX)

-- Slider (menor)
local vf = C("Frame", {Size = UDim2.new(1,-16,0,55), Position = UDim2.new(0,8,0,295),
    BackgroundColor3 = Color3.fromRGB(30,30,38), BackgroundTransparency = 0.2, ZIndex = 4}, pf)
cr(vf)
C("TextLabel", {Size = UDim2.new(.6,0,0,18), Position = UDim2.new(0,10,0,5), BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(220,220,220), Text = "Velocidade", Font = Enum.Font.GothamMedium,
    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, vf)
local vV = C("TextLabel", {Size = UDim2.new(.3,0,0,18), Position = UDim2.new(.65,0,0,5), BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(255,200,50), Text = "16", Font = Enum.Font.GothamBold, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 5}, vf)
local bgB = C("Frame", {Size = UDim2.new(1,-20,0,8), Position = UDim2.new(0,10,0,32),
    BackgroundColor3 = Color3.fromRGB(50,50,60), ZIndex = 5}, vf)
cr(bgB, 99)
local fil = C("Frame", {Size = UDim2.new(.16,0,1,0), BackgroundColor3 = Color3.fromRGB(255,140,0), ZIndex = 6}, bgB)
cr(fil, 99)
local kn2 = C("Frame", {Size = UDim2.new(0,17,0,17), Position = UDim2.new(.16,-8.5,.5,-8.5),
    BackgroundColor3 = Color3.new(1,1,1), ZIndex = 7}, bgB)
cr(kn2, 99)
C("UIStroke", {Color = Color3.fromRGB(255,140,0), Thickness = 2}, kn2)
local sb = C("TextButton", {Size = UDim2.new(1,0,3,0), Position = UDim2.new(0,0,-1,0),
    BackgroundTransparency = 1, Text = "", ZIndex = 10}, bgB)
local dragging = false
local function setV(x2)
    local p = math.clamp((x2 - bgB.AbsolutePosition.X) / bgB.AbsoluteSize.X, 0, 1)
    local v = math.floor(p * 100)
    vel = v
    fil.Size = UDim2.new(p,0,1,0)
    kn2.Position = UDim2.new(p,-8.5,.5,-8.5)
    vV.Text = tostring(v)
    local h3 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h3 then h3.WalkSpeed = v end
end
sb.MouseButton1Down:Connect(function() dragging = true; setV(UIS:GetMouseLocation().X) end)
UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then setV(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; popup("Velocidade: "..vel, Color3.fromRGB(255,200,50)) end end)

btn.MouseButton1Click:Connect(function() pf.Visible = not pf.Visible end)
x.MouseButton1Click:Connect(function() pf.Visible = false end)

-- FPS (menor)
local ff = C("Frame", {Size = UDim2.new(0,95,0,26), Position = UDim2.new(0,20,0,100),
    BackgroundColor3 = Color3.fromRGB(22,22,28), Active = true, Draggable = true}, gui)
cr(ff)
local sf = C("UIStroke", {Color = Color3.fromRGB(0,255,100), Thickness = 1}, ff)
C("TextLabel", {Size = UDim2.new(0,36,1,0), Position = UDim2.new(0,5,0,0), BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(150,150,150), Text = "FPS:", Font = Enum.Font.GothamBold,
    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, ff)
local fV = C("TextLabel", {Size = UDim2.new(0,50,1,0), Position = UDim2.new(0,40,0,0), BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(0,255,100), Text = "0", Font = Enum.Font.GothamBlack,
    TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right}, ff)
local fc, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local a = tick()
    if a - lt >= 1 then
        local fp = math.floor(fc / (a - lt))
        fc, lt = 0, a
        fV.Text = tostring(fp)
        local c = fp >= 50 and Color3.fromRGB(0,255,100) or (fp >= 30 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,80,80))
        fV.TextColor3 = c; sf.Color = c
    end
end)

-- Buscas
local function pegarPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        for _, c in ipairs(obj:GetChildren()) do if c:IsA("BasePart") then return c.Position end end
    end
    return nil
end

local function pecaAlta(obj)
    local alta, maiorY = nil, -9999
    for _, p in ipairs(obj:GetDescendants()) do
        if p:IsA("BasePart") and p.Position.Y > maiorY then
            maiorY = p.Position.Y; alta = p
        end
    end
    return alta
end

local function acharMeuTerreno()
    local nome = string.lower(LP.Name)
    local display = string.lower(LP.DisplayName or "")
    local id = tostring(LP.UserId)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent then
            local n = string.lower(obj.Name)
            if string.find(n, nome) or string.find(n, id) or (display ~= "" and string.find(n, display)) then
                return obj
            end
        end
    end
    return nil
end

local function getEvt()
    local t = {}
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not r then return t end
    for _, o in pairs(workspace:GetDescendants()) do
        local nome = string.lower(o.Name)
        if string.find(nome, "super honey") or string.find(nome, "superhoney") or
           string.find(nome, "super_honey") or string.find(nome, "super-honey") then
            local pos = pegarPos(o)
            if pos then
                local dist = (r.Position - pos).Magnitude
                if dist < dist_max then
                    local jaTem = false
                    for _, v in ipairs(t) do
                        if (v.pos - pos).Magnitude < 3 then jaTem = true break end
                    end
                    if not jaTem then table.insert(t, {obj = o, pos = pos}) end
                end
            end
        end
    end
    table.sort(t, function(a, b) return (r.Position - a.pos).Magnitude < (r.Position - b.pos).Magnitude end)
    return t
end

-- Loops
task.spawn(function()
    while true do
        pcall(function()
            if evt then
                local c = LP.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then
                    for _, f in ipairs(getEvt()) do
                        local obj = f.obj
                        if obj and obj.Parent then
                            local p = nil
                            if obj:IsA("Model") then p = pecaAlta(obj)
                            elseif obj:IsA("BasePart") then p = obj end
                            if p then
                                local pA = h.CFrame
                                h.CFrame = CFrame.new(p.Position + Vector3.new(0,3,0))
                                task.wait(0.2)
                                h.CFrame = pA
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if bars then
                local c = LP.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then
                    local t = acharMeuTerreno()
                    if t then
                        for _, obj in ipairs(t:GetDescendants()) do
                            if obj:IsA("Model") and obj.Parent then
                                local n = string.lower(obj.Name)
                                local bate = false
                                if string.find(n, "apiary") then bate = true
                                elseif string.find(n, "beehive") then bate = true
                                elseif string.find(n, "honey barrel") then bate = true
                                elseif string.find(n, "barrel") then bate = true
                                end
                                if bate and not string.find(n, "loja") then
                                    local p = pecaAlta(obj)
                                    if p then
                                        local pA = h.CFrame
                                        h.CFrame = CFrame.new(p.Position + Vector3.new(0,3,0))
                                        task.wait(0.15)
                                        h.CFrame = pA
                                        task.wait(0.02)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end
