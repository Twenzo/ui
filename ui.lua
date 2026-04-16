local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local function getContainer()
    local ok, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    return ok and result or PlayerGui
end
local Container = getContainer()

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local ScreenSize = workspace.CurrentCamera.ViewportSize
local ScreenH    = ScreenSize.Y
local ScreenW    = ScreenSize.X

local TopInset   = game:GetService("GuiService"):GetGuiInset().Y
local SafeTop    = IsMobile and math.max(TopInset, 30) or 0

local CONFIG = {
    Title      = "vibecoded.xyz",
    SubTitle   = "v4.0",
    ToggleKey  = Enum.KeyCode.RightShift,
    Accent     = Color3.fromRGB(200, 200, 200), -- Main Grey
    Accent2    = Color3.fromRGB(120, 120, 120), -- Darker Grey
    Warn       = Color3.fromRGB(255, 185, 0),
    Danger     = Color3.fromRGB(255, 60, 90),
    BgMain     = Color3.fromRGB(12, 12, 12),
    BgPanel    = Color3.fromRGB(18, 18, 18),
    BgSidebar  = Color3.fromRGB(15, 15, 15),
    BgCard     = Color3.fromRGB(22, 22, 22),
    Text       = Color3.fromRGB(230, 230, 230),
    TextDim    = Color3.fromRGB(120, 120, 120),
    Width      = IsMobile and math.min(ScreenW - 20, 380) or 700,
    Height     = IsMobile and math.min(ScreenH - SafeTop - 20, 480) or 460,
    SidebarW   = IsMobile and 0    or 155,
    RowH       = IsMobile and 50   or 40,
    FontSize   = IsMobile and 14   or 12,
}

local function tw(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p; return c
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Accent
    s.Thickness = thick or 1
    s.Transparency = trans or 0.7
    s.Parent = p; return s
end

local function pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 10)
    u.PaddingRight  = UDim.new(0, r or 10)
    u.Parent = p; return u
end

local function vlist(p, spacing)
    local ul = Instance.new("UIListLayout")
    ul.FillDirection       = Enum.FillDirection.Vertical
    ul.Padding             = UDim.new(0, spacing or 6)
    ul.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ul.VerticalAlignment   = Enum.VerticalAlignment.Top
    ul.SortOrder           = Enum.SortOrder.LayoutOrder
    ul.Parent = p; return ul
end

local function hlist(p, spacing)
    local ul = Instance.new("UIListLayout")
    ul.FillDirection       = Enum.FillDirection.Horizontal
    ul.Padding             = UDim.new(0, spacing or 6)
    ul.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ul.VerticalAlignment   = Enum.VerticalAlignment.Center
    ul.SortOrder           = Enum.SortOrder.LayoutOrder
    ul.Parent = p; return ul
end

local function ripple(parent, x, y, color)
    color = color or CONFIG.Accent
    local rip = Instance.new("Frame")
    rip.Size                   = UDim2.new(0,0,0,0)
    rip.Position               = UDim2.new(0,x,0,y)
    rip.AnchorPoint            = Vector2.new(0.5,0.5)
    rip.BackgroundColor3       = color
    rip.BackgroundTransparency = 0.55
    rip.ZIndex                 = parent.ZIndex + 5
    rip.Parent                 = parent
    corner(rip, 999)
    local maxS = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    tw(rip,{Size=UDim2.new(0,maxS,0,maxS),BackgroundTransparency=1},0.5,Enum.EasingStyle.Quad)
    game:GetService("Debris"):AddItem(rip, 0.55)
end

local function startGlitch(lbl, original)
    local chars = {"@","#","$","%","&","!","?","X","0","1"}
    task.spawn(function()
        while lbl.Parent do
            task.wait(math.random(3,6))
            for i = 1,6 do
                local g = ""
                for j = 1,#original do
                    g = g..(math.random()<0.3 and chars[math.random(#chars)] or original:sub(j,j))
                end
                lbl.Text = g; task.wait(0.05)
            end
            lbl.Text = original
        end
    end)
end

local function createParticles(parent, count)
    count = count or 14
    for i = 1,count do
        local p = Instance.new("Frame")
        local sz = math.random(1,3)
        p.Size = UDim2.new(0,sz,0,sz)
        p.Position = UDim2.new(math.random(),0,math.random(),0)
        p.BackgroundColor3 = CONFIG.Accent
        p.BackgroundTransparency = math.random(55,85)/100
        p.ZIndex = parent.ZIndex+1; p.Parent = parent; corner(p,99)
        task.spawn(function()
            while p.Parent do
                local dur = math.random(4,9)
                tw(p,{Position=UDim2.new(math.random(),0,math.random(),0),
                    BackgroundTransparency=math.random(60,90)/100},dur,Enum.EasingStyle.Sine)
                task.wait(dur)
            end
        end)
    end
end

local function createRunningLine(parent, horizontal, color, speed)
    color = color or CONFIG.Accent; speed = speed or 2.5
    local line = Instance.new("Frame")
    line.Size = horizontal and UDim2.new(0,50,0,1) or UDim2.new(0,1,0,35)
    line.Position = UDim2.new(0,0,0,0)
    line.BackgroundColor3 = color; line.BackgroundTransparency = 0.25
    line.ZIndex = parent.ZIndex+2; line.Parent = parent; corner(line,2)
    local grad = Instance.new("UIGradient")
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.5,0),
        NumberSequenceKeypoint.new(1,1),
    })
    grad.Rotation = horizontal and 0 or 90; grad.Parent = line
    task.spawn(function()
        while line.Parent do
            if horizontal then
                line.Position = UDim2.new(-0.12,0,0,0)
                tw(line,{Position=UDim2.new(1.12,0,0,0)},speed,Enum.EasingStyle.Sine)
            else
                line.Position = UDim2.new(0,0,-0.12,0)
                tw(line,{Position=UDim2.new(0,0,1.12,0)},speed,Enum.EasingStyle.Sine)
            end
            task.wait(speed+0.1)
        end
    end)
    return line
end

local function breathingStroke(s, min, max, speed)
    min = min or 0.4; max = max or 0.85; speed = speed or 1.2
    task.spawn(function()
        while s.Parent do
            tw(s,{Transparency=min},speed); task.wait(speed)
            tw(s,{Transparency=max},speed); task.wait(speed)
        end
    end)
end

-- Rainbow stroke logic removed as requested. Standard breathing grey used instead.

if Container:FindFirstChild("VibeCodedGui") then
    Container.VibeCodedGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "VibeCodedGui"; Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true; Gui.DisplayOrder = 999
Gui.Parent = Container

local Dim = Instance.new("Frame")
Dim.Size = UDim2.new(1,0,1,0); Dim.BackgroundColor3 = Color3.new(0,0,0)
Dim.BackgroundTransparency = 1; Dim.ZIndex = 1; Dim.Parent = Gui

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0,IsMobile and 50 or 34,0,IsMobile and 50 or 34)
OpenBtn.Position = UDim2.new(0,10,0.5,-(IsMobile and 25 or 17))
OpenBtn.Text = "V"; OpenBtn.TextSize = IsMobile and 20 or 15
OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextColor3 = CONFIG.Accent
OpenBtn.BackgroundColor3 = CONFIG.BgPanel; OpenBtn.BackgroundTransparency = 0.08
OpenBtn.ZIndex = 10; OpenBtn.Visible = false; OpenBtn.Parent = Gui
corner(OpenBtn, IsMobile and 14 or 8)
local OpenStroke = stroke(OpenBtn,CONFIG.Accent,1,0.45)
breathingStroke(OpenStroke, 0.3, 0.7, 1.5)

task.spawn(function()
    while OpenBtn.Parent do
        if OpenBtn.Visible then
            tw(OpenBtn,{BackgroundTransparency=0.3},0.8); task.wait(0.8)
            tw(OpenBtn,{BackgroundTransparency=0.08},0.8); task.wait(0.8)
        else task.wait(0.5) end
    end
end)

local HEADER_H = IsMobile and 52 or 44
local TABBAR_H = IsMobile and 42 or 0

local Win = Instance.new("Frame")
Win.Name = "Window"
Win.Size = UDim2.new(0,CONFIG.Width,0,CONFIG.Height)
Win.Position = UDim2.new(0.5,-CONFIG.Width/2,0.5,-CONFIG.Height/2)
Win.BackgroundColor3 = CONFIG.BgPanel; Win.ClipsDescendants = true
Win.ZIndex = 2; Win.Parent = Gui; corner(Win,8)
local WinStroke = stroke(Win,CONFIG.Accent,1,0.72)
createParticles(Win,20)

local ScanLine = Instance.new("Frame")
ScanLine.Size = UDim2.new(1,0,0,2); ScanLine.BackgroundColor3 = CONFIG.Accent
ScanLine.BackgroundTransparency = 0.82; ScanLine.ZIndex = 20; ScanLine.Parent = Win

RunService.Heartbeat:Connect(function()
    if not Win.Visible then return end
    local t = tick()%3/3
    ScanLine.Position = UDim2.new(0,0,t,0)
    ScanLine.BackgroundTransparency = 0.75+math.sin(tick()*6)*0.1
end)

local Header = Instance.new("Frame")
Header.Name = "Header"; Header.Size = UDim2.new(1,0,0,HEADER_H)
Header.BackgroundColor3 = CONFIG.BgSidebar; Header.BorderSizePixel = 0
Header.ZIndex = 3; Header.Parent = Win

createRunningLine(Header,true,CONFIG.Accent,2.2)
createRunningLine(Header,true,CONFIG.Accent2,3.8)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1,0,0,1); HeaderLine.Position = UDim2.new(0,0,1,-1)
HeaderLine.BackgroundColor3 = CONFIG.Accent; HeaderLine.BackgroundTransparency = 0.75
HeaderLine.ZIndex = 4; HeaderLine.Parent = Header

task.spawn(function()
    local dir,trans = 1,0.75
    while Header.Parent do
        trans = trans+dir*0.015
        if trans>=0.9 then dir=-1 end
        if trans<=0.55 then dir=1 end
        HeaderLine.BackgroundTransparency = trans
        task.wait(0.03)
    end
end)

local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0,28,0,28); LogoBox.Position = UDim2.new(0,12,0.5,-14)
LogoBox.BackgroundColor3 = CONFIG.Accent; LogoBox.BackgroundTransparency = 0.82
LogoBox.ZIndex = 4; LogoBox.Parent = Header; corner(LogoBox,5)
local LogoStroke = stroke(LogoBox,CONFIG.Accent,1,0.35)
breathingStroke(LogoStroke,0.1,0.6,0.7)

local LogoLbl = Instance.new("TextLabel")
LogoLbl.Size = UDim2.new(1,0,1,0); LogoLbl.Text = "V"; LogoLbl.TextSize = 15
LogoLbl.Font = Enum.Font.GothamBold; LogoLbl.TextColor3 = CONFIG.Accent
LogoLbl.BackgroundTransparency = 1; LogoLbl.TextXAlignment = Enum.TextXAlignment.Center
LogoLbl.ZIndex = 5; LogoLbl.Parent = LogoBox

task.spawn(function()
    while LogoBox.Parent do
        tw(LogoBox,{BackgroundTransparency=0.55},0.85)
        tw(LogoLbl,{TextColor3=Color3.fromRGB(220,220,220)},0.85); task.wait(0.85)
        tw(LogoBox,{BackgroundTransparency=0.88},0.85)
        tw(LogoLbl,{TextColor3=CONFIG.Accent},0.85); task.wait(0.85)
    end
end)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0,160,0,20); TitleLbl.Position = UDim2.new(0,48,0,7)
TitleLbl.Text = CONFIG.Title; TitleLbl.TextSize = 16; TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextColor3 = CONFIG.Accent; TitleLbl.BackgroundTransparency = 1
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 4; TitleLbl.Parent = Header
startGlitch(TitleLbl,CONFIG.Title)

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(0,240,0,14); SubLbl.Position = UDim2.new(0,49,0,27)
SubLbl.Text = CONFIG.SubTitle.." // "..(IsMobile and "📱 Mobile" or "🖥 PC")
SubLbl.TextSize = 9; SubLbl.Font = Enum.Font.Code; SubLbl.TextColor3 = CONFIG.TextDim
SubLbl.BackgroundTransparency = 1; SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.ZIndex = 4; SubLbl.Parent = Header

local function makeHeaderBtn(offsetX,icon,col)
    local sz = IsMobile and 32 or 24
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,sz,0,sz); b.Position = UDim2.new(1,offsetX,0.5,-sz/2)
    b.Text = icon; b.TextSize = IsMobile and 13 or 11; b.Font = Enum.Font.GothamBold
    b.TextColor3 = col; b.BackgroundColor3 = col; b.BackgroundTransparency = 0.88
    b.ZIndex = 5; b.Parent = Header; corner(b,5)
    local bs = stroke(b,col,1,0.55); breathingStroke(bs,0.3,0.7,1)
    b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.65,TextColor3=Color3.new(1,1,1)},0.15) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0.88,TextColor3=col},0.15) end)
    b.MouseButton1Down:Connect(function() tw(b,{BackgroundTransparency=0.45},0.08) end)
    b.MouseButton1Up:Connect(function()   tw(b,{BackgroundTransparency=0.65},0.1)  end)
    return b
end

local step     = IsMobile and -38 or -30
local BtnClose = makeHeaderBtn(step,     "✕",CONFIG.Danger)
local BtnMini  = makeHeaderBtn(step*2+4, "−",CONFIG.Warn)

if not IsMobile then
    local dragging,dragStart,startPos
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=i.Position; startPos=Win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d = i.Position-dragStart
            Win.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

local SidebarScroll,MobileTabScroll,SidebarFrame

if not IsMobile then
    SidebarFrame = Instance.new("Frame")
    SidebarFrame.Name = "Sidebar"
    SidebarFrame.Size = UDim2.new(0,CONFIG.SidebarW,1,-HEADER_H)
    SidebarFrame.Position = UDim2.new(0,0,0,HEADER_H)
    SidebarFrame.BackgroundColor3 = CONFIG.BgSidebar; SidebarFrame.BorderSizePixel = 0
    SidebarFrame.ClipsDescendants = true; SidebarFrame.ZIndex = 3; SidebarFrame.Parent = Win
    createParticles(SidebarFrame,8)
    createRunningLine(SidebarFrame,false,CONFIG.Accent,3)
    createRunningLine(SidebarFrame,false,CONFIG.Accent2,5)
    local SideRight = Instance.new("Frame")
    SideRight.Size = UDim2.new(0,1,1,0); SideRight.Position = UDim2.new(1,-1,0,0)
    SideRight.BackgroundColor3 = CONFIG.Accent; SideRight.BackgroundTransparency = 0.8
    SideRight.ZIndex = 4; SideRight.Parent = SidebarFrame
    local SideGrad = Instance.new("UIGradient")
    SideGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0),
        NumberSequenceKeypoint.new(0.85,0),
        NumberSequenceKeypoint.new(1,1),
    })
    SideGrad.Rotation = 90; SideGrad.Parent = SidebarFrame
    SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Size = UDim2.new(1,0,1,-30); SidebarScroll.Position = UDim2.new(0,0,0,8)
    SidebarScroll.BackgroundTransparency = 1; SidebarScroll.ScrollBarThickness = 0
    SidebarScroll.CanvasSize = UDim2.new(0,0,0,0); SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidebarScroll.ZIndex = 4; SidebarScroll.Parent = SidebarFrame
    vlist(SidebarScroll,2); pad(SidebarScroll,6,6,6,6)
    local SideVer = Instance.new("TextLabel")
    SideVer.Size = UDim2.new(1,0,0,26); SideVer.Position = UDim2.new(0,0,1,-26)
    SideVer.Text = "vibecoded.xyz"; SideVer.TextSize = 9; SideVer.Font = Enum.Font.Code
    SideVer.TextColor3 = CONFIG.TextDim; SideVer.BackgroundTransparency = 1
    SideVer.TextXAlignment = Enum.TextXAlignment.Center; SideVer.ZIndex = 4; SideVer.Parent = SidebarFrame
    startGlitch(SideVer,"vibecoded.xyz")
else
    local MobileTabBar = Instance.new("Frame")
    MobileTabBar.Name = "MobileTabBar"; MobileTabBar.Size = UDim2.new(1,0,0,TABBAR_H)
    MobileTabBar.Position = UDim2.new(0,0,0,HEADER_H); MobileTabBar.BackgroundColor3 = CONFIG.BgSidebar
    MobileTabBar.BorderSizePixel = 0; MobileTabBar.ZIndex = 3; MobileTabBar.Parent = Win
    createRunningLine(MobileTabBar,true,CONFIG.Accent,2.8)
    local MBLine = Instance.new("Frame")
    MBLine.Size = UDim2.new(1,0,0,1); MBLine.Position = UDim2.new(0,0,1,-1)
    MBLine.BackgroundColor3 = CONFIG.Accent; MBLine.BackgroundTransparency = 0.78; MBLine.Parent = MobileTabBar
    MobileTabScroll = Instance.new("ScrollingFrame")
    MobileTabScroll.Size = UDim2.new(1,0,1,0); MobileTabScroll.BackgroundTransparency = 1
    MobileTabScroll.ScrollBarThickness = 0; MobileTabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    MobileTabScroll.CanvasSize = UDim2.new(0,0,1,0); MobileTabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    MobileTabScroll.ZIndex = 4; MobileTabScroll.Parent = MobileTabBar
    local mtl = hlist(MobileTabScroll,0); mtl.VerticalAlignment = Enum.VerticalAlignment.Center
end

local CONTENT_TOP  = HEADER_H+TABBAR_H
local CONTENT_LEFT = IsMobile and 0 or CONFIG.SidebarW

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1,-CONTENT_LEFT,1,-CONTENT_TOP)
ContentArea.Position = UDim2.new(0,CONTENT_LEFT,0,CONTENT_TOP)
ContentArea.BackgroundColor3 = CONFIG.BgMain; ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true; ContentArea.ZIndex = 2; ContentArea.Parent = Win
createParticles(ContentArea,12)
createRunningLine(ContentArea,true,CONFIG.Accent,4)
createRunningLine(ContentArea,true,CONFIG.Accent2,6.5)

local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0,270,1,0); NotifHolder.Position = UDim2.new(1,-280,0,0)
NotifHolder.BackgroundTransparency = 1; NotifHolder.ZIndex = 30; NotifHolder.Parent = Gui
vlist(NotifHolder,6); pad(NotifHolder,14,14,0,0)

local function notify(title,msg,ntype)
    ntype = ntype or "info"
    local color = ntype=="success" and CONFIG.Accent or ntype=="warn" and CONFIG.Warn
               or ntype=="error" and CONFIG.Danger or CONFIG.Accent2
    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(1,0,0,0); nf.AutomaticSize = Enum.AutomaticSize.Y
    nf.BackgroundColor3 = CONFIG.BgCard; nf.BackgroundTransparency = 1
    nf.ClipsDescendants = true; nf.ZIndex = 30
    nf.Position = UDim2.new(1,20,0,0); nf.Parent = NotifHolder; corner(nf,6)
    local nfStroke = stroke(nf,color,1,0.4); breathingStroke(nfStroke,0.2,0.6,0.8)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,0); bar.BackgroundColor3 = color
    bar.BackgroundTransparency = 0.1; bar.ZIndex = 31; bar.Parent = nf
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1,-3,1,0); inner.Position = UDim2.new(0,3,0,0)
    inner.BackgroundTransparency = 1; inner.ZIndex = 31; inner.Parent = nf
    pad(inner,7,7,10,10); vlist(inner,2)
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,0,0,15); tl.Text = title; tl.TextSize = 12
    tl.Font = Enum.Font.GothamBold; tl.TextColor3 = color; tl.BackgroundTransparency = 1
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 32; tl.Parent = inner
    local ml = Instance.new("TextLabel")
    ml.Size = UDim2.new(1,0,0,0); ml.AutomaticSize = Enum.AutomaticSize.Y
    ml.Text = msg; ml.TextSize = 11; ml.Font = Enum.Font.Gotham
    ml.TextColor3 = CONFIG.TextDim; ml.BackgroundTransparency = 1
    ml.TextXAlignment = Enum.TextXAlignment.Left; ml.TextWrapped = true
    ml.ZIndex = 32; ml.Parent = inner
    local prog = Instance.new("Frame")
    prog.Size = UDim2.new(1,0,0,2); prog.Position = UDim2.new(0,0,1,-2)
    prog.BackgroundColor3 = color; prog.BackgroundTransparency = 0.3
    prog.ZIndex = 32; prog.Parent = nf
    tw(nf,{BackgroundTransparency=0.05,Position=UDim2.new(0,0,0,0)},0.35,Enum.EasingStyle.Back)
    tw(nfStroke,{Transparency=0.4},0.35); tw(prog,{Size=UDim2.new(0,0,0,2)},3.2)
    if ntype=="error" then
        task.spawn(function()
            for i=1,4 do
                tw(nf,{Position=UDim2.new(0,6,0,0)},0.05); task.wait(0.05)
                tw(nf,{Position=UDim2.new(0,-6,0,0)},0.05); task.wait(0.05)
            end
            tw(nf,{Position=UDim2.new(0,0,0,0)},0.05)
        end)
    end
    task.delay(3.2,function()
        if not nf.Parent then return end
        tw(nf,{BackgroundTransparency=1,Position=UDim2.new(1,20,0,0)},0.3)
        task.wait(0.32); if nf.Parent then nf:Destroy() end
    end)
end

local VibeLibrary = {}
local tabList   = {}
local activeTab = nil

function VibeLibrary:Tab(name,icon)
    icon = icon or "◈"
    local btn       = Instance.new("TextButton")
    local indicator = Instance.new("Frame")
    btn.BackgroundColor3 = CONFIG.Accent; btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 5

    if not IsMobile then
        btn.Size = UDim2.new(1,0,0,36); btn.Parent = SidebarScroll; corner(btn,6)
        indicator.Size = UDim2.new(0,3,0.55,0); indicator.Position = UDim2.new(0,0,0.225,0)
        indicator.BackgroundColor3 = CONFIG.Accent; indicator.BackgroundTransparency = 1
        indicator.ZIndex = 6; indicator.Parent = btn; corner(indicator,2)
        local iconL = Instance.new("TextLabel")
        iconL.Size = UDim2.new(0,24,1,0); iconL.Position = UDim2.new(0,10,0,0)
        iconL.Text = icon; iconL.TextSize = 14; iconL.Font = Enum.Font.GothamBold
        iconL.TextColor3 = CONFIG.TextDim; iconL.BackgroundTransparency = 1
        iconL.TextXAlignment = Enum.TextXAlignment.Center
        iconL.ZIndex = 6; iconL.Name = "IconL"; iconL.Parent = btn
        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1,-38,1,0); nameL.Position = UDim2.new(0,38,0,0)
        nameL.Text = name; nameL.TextSize = 12; nameL.Font = Enum.Font.GothamSemibold
        nameL.TextColor3 = CONFIG.TextDim; nameL.BackgroundTransparency = 1
        nameL.TextXAlignment = Enum.TextXAlignment.Left
        nameL.ZIndex = 6; nameL.Name = "NameL"; nameL.Parent = btn
        btn.MouseEnter:Connect(function()
            if activeTab and activeTab.btn~=btn then
                tw(btn,{BackgroundTransparency=0.92},0.15)
                tw(nameL,{TextColor3=CONFIG.Text},0.15)
                tw(iconL,{TextColor3=Color3.fromRGB(200,200,200)},0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab and activeTab.btn~=btn then
                tw(btn,{BackgroundTransparency=1},0.15)
                tw(nameL,{TextColor3=CONFIG.TextDim},0.15)
                tw(iconL,{TextColor3=CONFIG.TextDim},0.15)
            end
        end)
    else
        btn.Size = UDim2.new(0,88,1,-6); btn.Parent = MobileTabScroll; corner(btn,6)
        indicator.Size = UDim2.new(0.65,0,0,2); indicator.Position = UDim2.new(0.175,0,1,-3)
        indicator.BackgroundColor3 = CONFIG.Accent; indicator.BackgroundTransparency = 1
        indicator.ZIndex = 6; indicator.Parent = btn; corner(indicator,1)
        local iconL = Instance.new("TextLabel")
        iconL.Size = UDim2.new(0,20,1,0); iconL.Position = UDim2.new(0,6,0,0)
        iconL.Text = icon; iconL.TextSize = 15; iconL.Font = Enum.Font.GothamBold
        iconL.TextColor3 = CONFIG.TextDim; iconL.BackgroundTransparency = 1
        iconL.TextXAlignment = Enum.TextXAlignment.Center
        iconL.ZIndex = 6; iconL.Name = "IconL"; iconL.Parent = btn
        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1,-28,1,0); nameL.Position = UDim2.new(0,26,0,0)
        nameL.Text = name; nameL.TextSize = 11; nameL.Font = Enum.Font.GothamSemibold
        nameL.TextColor3 = CONFIG.TextDim; nameL.BackgroundTransparency = 1
        nameL.TextXAlignment = Enum.TextXAlignment.Left
        nameL.ZIndex = 6; nameL.Name = "NameL"; nameL.Parent = btn
    end

    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_"..name; page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1; page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = CONFIG.Accent; page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.Visible = false
    page.ZIndex = 3; page.Parent = ContentArea
    vlist(page,6); pad(page,10,10,10,10)

    local tabData = {btn=btn,page=page,indicator=indicator}
    table.insert(tabList,tabData)

    local function activate(fromOpen)
        for _,td in ipairs(tabList) do
            if td~=tabData then
                td.page.Visible = false
                tw(td.btn,{BackgroundTransparency=1},0.2)
                tw(td.indicator,{BackgroundTransparency=1},0.2)
                local iL = td.btn:FindFirstChild("IconL")
                local nL = td.btn:FindFirstChild("NameL")
                if iL then tw(iL,{TextColor3=CONFIG.TextDim},0.2) end
                if nL then tw(nL,{TextColor3=CONFIG.TextDim},0.2) end
            end
        end
        activeTab = tabData; page.Visible = true
        if not fromOpen then
            page.Position = UDim2.new(0,12,0,0)
            tw(page,{Position=UDim2.new(0,0,0,0)},0.28,Enum.EasingStyle.Quart)
        end
        tw(btn,{BackgroundTransparency=0.87},0.2)
        tw(indicator,{BackgroundTransparency=0},0.2)
        local iL = btn:FindFirstChild("IconL"); local nL = btn:FindFirstChild("NameL")
        if iL then tw(iL,{TextColor3=CONFIG.Accent},0.2) end
        if nL then tw(nL,{TextColor3=CONFIG.Text},  0.2) end
    end

    btn.MouseButton1Click:Connect(function()
        if activeTab==tabData then return end
        local mp = UserInputService:GetMouseLocation()
        ripple(btn,mp.X-btn.AbsolutePosition.X,mp.Y-btn.AbsolutePosition.Y,CONFIG.Accent)
        activate(false)
    end)
    if #tabList==1 then task.defer(function() activate(true) end) end

    local Tab = {}

    function Tab:Section(title)
        local sec = Instance.new("Frame")
        sec.Size = UDim2.new(1,0,0,0); sec.AutomaticSize = Enum.AutomaticSize.Y
        sec.BackgroundColor3 = CONFIG.BgCard; sec.BackgroundTransparency = 1
        sec.ZIndex = 4; sec.Parent = page; corner(sec,6)
        local secStroke = stroke(sec,CONFIG.Accent,1,0.9)
        breathingStroke(secStroke,0.6,0.92,1.8)
        task.defer(function()
            tw(sec,{BackgroundTransparency=0.3},0.4)
            tw(secStroke,{Transparency=0.82},0.4)
        end)
        local sh = Instance.new("Frame")
        sh.Size = UDim2.new(1,0,0,28); sh.BackgroundColor3 = CONFIG.Accent
        sh.BackgroundTransparency = 0.93; sh.ZIndex = 5; sh.Parent = sec; corner(sh,6)
        local shLine = Instance.new("Frame")
        shLine.Size = UDim2.new(1,0,0,1); shLine.Position = UDim2.new(0,0,1,-1)
        shLine.BackgroundColor3 = CONFIG.Accent; shLine.BackgroundTransparency = 0.78
        shLine.ZIndex = 5; shLine.Parent = sh
        createRunningLine(sh,true,CONFIG.Accent,3)
        local shDot = Instance.new("Frame")
        shDot.Size = UDim2.new(0,4,0,4); shDot.Position = UDim2.new(0,10,0.5,-2)
        shDot.BackgroundColor3 = CONFIG.Accent; shDot.ZIndex = 6; shDot.Parent = sh; corner(shDot,2)
        task.spawn(function()
            while shDot.Parent do
                tw(shDot,{BackgroundTransparency=0.1},0.5); task.wait(0.5)
                tw(shDot,{BackgroundTransparency=0.8},0.5); task.wait(0.5)
            end
        end)
        local shLbl = Instance.new("TextLabel")
        shLbl.Size = UDim2.new(1,-22,1,0); shLbl.Position = UDim2.new(0,18,0,0)
        shLbl.Text = title; shLbl.TextSize = 11; shLbl.Font = Enum.Font.GothamBold
        shLbl.TextColor3 = CONFIG.Accent; shLbl.BackgroundTransparency = 1
        shLbl.TextXAlignment = Enum.TextXAlignment.Left; shLbl.ZIndex = 6; shLbl.Parent = sh
        local items = Instance.new("Frame")
        items.Size = UDim2.new(1,0,0,0); items.AutomaticSize = Enum.AutomaticSize.Y
        items.Position = UDim2.new(0,0,0,28); items.BackgroundTransparency = 1
        items.ZIndex = 4; items.Parent = sec; vlist(items,1); pad(items,4,6,0,0)
        
        local Section = {}
        local RH = CONFIG.RowH
        local rowIndex = 0
        local function makeRow(h)
            rowIndex = rowIndex+1; local idx = rowIndex
            local r = Instance.new("Frame")
            r.Size = UDim2.new(1,0,0,h or RH+4); r.BackgroundTransparency = 1
            r.ZIndex = 4; r.Position = UDim2.new(0,-15,0,0); r.Parent = items
            task.delay(idx*0.04,function()
                if r.Parent then tw(r,{Position=UDim2.new(0,0,0,0)},0.3,Enum.EasingStyle.Quart) end
            end)
            return r
        end

        function Section:Button(opts)
            opts = opts or {}; local col = opts.Color or CONFIG.Accent
            local row = makeRow(RH+10)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,-16,0,RH); b.Position = UDim2.new(0,8,0.5,-RH/2)
            b.BackgroundColor3 = col; b.BackgroundTransparency = 0.87
            b.Text = ""; b.ZIndex = 5; b.ClipsDescendants = true; b.Parent = row; corner(b,5)
            local bs = stroke(b,col,1,0.65); breathingStroke(bs,0.4,0.75,1.5)
            local iL = Instance.new("TextLabel")
            iL.Size = UDim2.new(0,20,1,0); iL.Position = UDim2.new(0,10,0,0)
            iL.Text = "▶"; iL.TextSize = 9; iL.Font = Enum.Font.GothamBold
            iL.TextColor3 = col; iL.BackgroundTransparency = 1
            iL.TextXAlignment = Enum.TextXAlignment.Center; iL.ZIndex = 5; iL.Parent = b
            local nL = Instance.new("TextLabel")
            nL.Size = UDim2.new(1,-36,0,opts.Desc and 16 or RH)
            nL.Position = UDim2.new(0,30,0,opts.Desc and math.floor(RH/2)-14 or 0)
            nL.Text = opts.Label or "Button"; nL.TextSize = CONFIG.FontSize
            nL.Font = Enum.Font.GothamSemibold; nL.TextColor3 = CONFIG.Text
            nL.BackgroundTransparency = 1; nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.ZIndex = 5; nL.Parent = b
            if opts.Desc then
                local dL = Instance.new("TextLabel")
                dL.Size = UDim2.new(1,-36,0,13); dL.Position = UDim2.new(0,30,0,math.floor(RH/2)+1)
                dL.Text = opts.Desc; dL.TextSize = 10; dL.Font = Enum.Font.Gotham
                dL.TextColor3 = CONFIG.TextDim; dL.BackgroundTransparency = 1
                dL.TextXAlignment = Enum.TextXAlignment.Left; dL.ZIndex = 5; dL.Parent = b
            end
            b.MouseEnter:Connect(function()
                tw(b,{BackgroundTransparency=0.73},0.15); tw(iL,{TextColor3=Color3.new(1,1,1)},0.15)
            end)
            b.MouseLeave:Connect(function()
                tw(b,{BackgroundTransparency=0.87},0.15); tw(iL,{TextColor3=col},0.15)
            end)
            b.MouseButton1Down:Connect(function() tw(b,{BackgroundTransparency=0.55},0.07) end)
            b.MouseButton1Click:Connect(function()
                local mp = UserInputService:GetMouseLocation()
                ripple(b,mp.X-b.AbsolutePosition.X,mp.Y-b.AbsolutePosition.Y,col)
                tw(b,{BackgroundTransparency=0.87},0.15)
                if opts.Callback then task.spawn(opts.Callback) end
            end)
        end

        function Section:Toggle(opts)
            opts = opts or {}; local val = opts.Default==true
            local row = makeRow(RH+10)
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1,-16,0,RH); bg.Position = UDim2.new(0,8,0.5,-RH/2)
            bg.BackgroundColor3 = CONFIG.BgPanel; bg.BackgroundTransparency = 0.3
            bg.ZIndex = 5; bg.Parent = row; corner(bg,5)
            local bgs = stroke(bg,CONFIG.Accent,1,0.88); breathingStroke(bgs,0.6,0.92,2)
            local nL = Instance.new("TextLabel")
            nL.Size = UDim2.new(1,-70,0,opts.Desc and 16 or RH)
            nL.Position = UDim2.new(0,12,0,opts.Desc and math.floor(RH/2)-14 or 0)
            nL.Text = opts.Label or "Toggle"; nL.TextSize = CONFIG.FontSize
            nL.Font = Enum.Font.GothamSemibold; nL.TextColor3 = CONFIG.Text
            nL.BackgroundTransparency = 1; nL.TextXAlignment = Enum.TextXAlignment.Left; nL.ZIndex = 6; nL.Parent = bg
            if opts.Desc then
                local dL = Instance.new("TextLabel")
                dL.Size = UDim2.new(1,-70,0,13); dL.Position = UDim2.new(0,12,0,math.floor(RH/2)+1)
                dL.Text = opts.Desc; dL.TextSize = 10; dL.Font = Enum.Font.Gotham
                dL.TextColor3 = CONFIG.TextDim; dL.BackgroundTransparency = 1; dL.TextXAlignment = Enum.TextXAlignment.Left; dL.ZIndex = 6; dL.Parent = bg
            end
            local tgl = Instance.new("Frame")
            tgl.Size = UDim2.new(0,36,0,18); tgl.Position = UDim2.new(1,-46,0.5,-9)
            tgl.BackgroundColor3 = val and CONFIG.Accent or CONFIG.BgCard
            tgl.ZIndex = 6; tgl.Parent = bg; corner(tgl,9)
            local ball = Instance.new("Frame")
            ball.Size = UDim2.new(0,12,0,12); ball.Position = UDim2.new(0,val and 21 or 3,0.5,-6)
            ball.BackgroundColor3 = val and CONFIG.BgMain or CONFIG.TextDim
            ball.ZIndex = 7; ball.Parent = tgl; corner(ball,6)
            local function update()
                tw(tgl,{BackgroundColor3=val and CONFIG.Accent or CONFIG.BgCard},0.2)
                tw(ball,{Position=UDim2.new(0,val and 21 or 3,0.5,-6),BackgroundColor3=val and CONFIG.BgMain or CONFIG.TextDim},0.2)
                if opts.Callback then task.spawn(opts.Callback,val) end
            end
            local click = Instance.new("TextButton")
            click.Size = UDim2.new(1,0,1,0); click.BackgroundTransparency = 1; click.Text = ""; click.ZIndex = 8; click.Parent = bg
            click.MouseButton1Click:Connect(function()
                val = not val; update()
            end)
        end
        
        return Section
    end
    return Tab
end

-- Toggle visibility logic
local IsOpen = true
local function toggleGui()
    IsOpen = not IsOpen
    if IsOpen then
        Win.Visible = true
        tw(Win,{Size=UDim2.new(0,CONFIG.Width,0,CONFIG.Height),BackgroundTransparency=0},0.3)
        tw(Dim,{BackgroundTransparency=0.7},0.3)
        OpenBtn.Visible = false
    else
        tw(Win,{Size=UDim2.new(0,CONFIG.Width,0,0),BackgroundTransparency=1},0.3)
        tw(Dim,{BackgroundTransparency=1},0.3)
        task.delay(0.3,function() if not IsOpen then Win.Visible = false; OpenBtn.Visible = true end end)
    end
end

UserInputService.InputBegan:Connect(function(i,g)
    if not g and i.KeyCode == CONFIG.ToggleKey then toggleGui() end
end)

BtnClose.MouseButton1Click:Connect(function() Gui:Destroy() end)
BtnMini.MouseButton1Click:Connect(toggleGui)
OpenBtn.MouseButton1Click:Connect(toggleGui)

return VibeLibrary