local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 清理旧 UI
if CoreGui:FindFirstChild("XU_Framework") then CoreGui.XU_Framework:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XU_Framework"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local XU_Lib = {}

-- 初始化主窗口
function XU_Lib:Init()
    -- 1. 主框架
    local Main = Instance.new("Frame")
    Main.Name = "XU_Main"
    Main.Size = UDim2.new(0, 540, 0, 360)
    Main.Position = UDim2.new(0.5, -270, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

    -- 🔥 核心流光边框 (Rainbow Stroke)
    local XU_Stroke = Instance.new("UIStroke", Main)
    XU_Stroke.Thickness = 2.5
    XU_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local XU_Gradient = Instance.new("UIGradient", XU_Stroke)
    XU_Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
    })

    task.spawn(function()
        while true do
            TweenService:Create(XU_Gradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            task.wait(2)
            XU_Gradient.Rotation = 0
        end
    end)

    -- 2. 布局系统
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 18, 0, 0)
    Title.Text = "XU FRAMEWORK"
    Title.TextColor3 = Color3.fromRGB(0, 170, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 130, 1, -70)
    Sidebar.Position = UDim2.new(0, 12, 0, 55)
    Sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 8)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -165, 1, -70)
    Container.Position = UDim2.new(0, 150, 0, 55)
    Container.BackgroundTransparency = 1

    -- 3. 悬浮窗 (高度缩小)
    local FloatBtn = Instance.new("ImageButton", ScreenGui)
    FloatBtn.Name = "XU_Float"
    FloatBtn.Size = UDim2.new(0, 45, 0, 32) -- 扁平化设计
    FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    FloatBtn.Visible = false
    FloatBtn.ZIndex = 200
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 6)
    local FloatStroke = Instance.new("UIStroke", FloatBtn)
    FloatStroke.Color = Color3.fromRGB(0, 170, 255)
    FloatStroke.Thickness = 2

    -- 4. 窗口控制
    local function CreateControl(txt, pos, callback)
        local btn = Instance.new("TextButton", TopBar)
        btn.Size = UDim2.new(0, 35, 0, 35)
        btn.Position = pos
        btn.BackgroundTransparency = 1
        btn.Text = txt
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 24
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    CreateControl("×", UDim2.new(1, -45, 0, 5), function() ScreenGui:Destroy() end)
    CreateControl("-", UDim2.new(1, -85, 0, 5), function()
        Main.Visible = false
        FloatBtn.Position = UDim2.new(0, Main.AbsolutePosition.X + 250, 0, Main.AbsolutePosition.Y)
        FloatBtn.Visible = true
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        FloatBtn.Visible = false
    end)

    -- 通用防误触
    self.SafeClick = function(func)
        local debounce = false
        return function(...)
            if not debounce then
                debounce = true
                func(...)
                task.wait(0.3)
                debounce = false
            end
        end
    end

    self.Main = Main
    self.Container = Container
    self.Sidebar = Sidebar
    return self
end

-- [栏目管理]
function XU_Lib:AddTab(name, isHome)
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = isHome or false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0,0,0,0)
    
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 6)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0, Layout.AbsoluteContentSize.Y + 10)
    end)

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.BackgroundColor3 = isHome and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(15, 15, 20)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.new(0.9,0.9,0.9)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.Sidebar:GetChildren()) do 
            if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(15, 15, 20) end 
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    end)
    return Page
end

-- [1] XU 巨大按钮
function XU_Lib:AddBigButton(parent, text, img, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -5, 0, 90)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 20
    Btn.TextXAlignment = Enum.TextXAlignment.Right
    Instance.new("UICorner", Btn)
    Instance.new("UIPadding", Btn).PaddingRight = UDim.new(0, 20)

    if img and img ~= "" then
        local I = Instance.new("ImageLabel", Btn)
        I.Size = UDim2.new(0, 70, 0, 70)
        I.Position = UDim2.new(0, 10, 0.5, -35)
        I.Image = img
        I.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Instance.new("UICorner", I)
    end
    Btn.MouseButton1Click:Connect(self.SafeClick(callback))
end

-- [2] XU 网格按钮 (自动适配1-3列)
function XU_Lib:AddButtonRow(parent, buttons)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, -5, 0, 35)
    Row.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Row)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 5)

    for _, info in pairs(buttons) do
        local B = Instance.new("TextButton", Row)
        B.Size = UDim2.new(1/#buttons, -(((#buttons-1)*5)/#buttons), 1, 0)
        B.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        B.Text = info.Text
        B.TextColor3 = Color3.new(0.9,0.9,0.9)
        B.Font = Enum.Font.Gotham
        B.TextSize = 12
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
        B.MouseButton1Click:Connect(self.SafeClick(info.Callback))
    end
end

-- [3] XU 文件夹 (深度嵌套支持)
function XU_Lib:AddFolder(parent, name)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, -5, 0, 35)
    F.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    F.ClipsDescendants = true
    Instance.new("UICorner", F)
    
    local T = Instance.new("TextButton", F)
    T.Size = UDim2.new(1, 0, 0, 35)
    T.BackgroundTransparency = 1
    T.Text = "  [+] " .. name
    T.TextColor3 = Color3.fromRGB(0, 170, 255)
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Font = Enum.Font.GothamBold

    local Content = Instance.new("Frame", F)
    Content.Position = UDim2.new(0, 5, 0, 40)
    Content.Size = UDim2.new(1, -10, 0, 0)
    Content.BackgroundTransparency = 1
    local L = Instance.new("UIListLayout", Content); L.Padding = UDim.new(0, 5)

    local open = false
    T.MouseButton1Click:Connect(function()
        open = not open
        T.Text = open and "  [-] " .. name or "  [+] " .. name
        TweenService:Create(F, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, open and (L.AbsoluteContentSize.Y + 45) or 35)}):Play()
    end)
    return Content
end

-- [4] XU 开关 (全域触发)
function XU_Lib:AddToggle(parent, text, callback)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, -5, 0, 35)
    B.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    B.Text = "  " .. text
    B.TextColor3 = Color3.new(0.9,0.9,0.9)
    B.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", B)

    local Switch = Instance.new("Frame", B)
    Switch.Size = UDim2.new(0, 35, 0, 18)
    Switch.Position = UDim2.new(1, -45, 0.5, -9)
    Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame", Switch)
    Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local state = false
    B.MouseButton1Click:Connect(self.SafeClick(function()
        state = not state
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 60)}):Play()
        callback(state)
    end))
end

-- [5] XU 列表选择执行
function XU_Lib:AddDropdown(parent, text, list, callback)
    local D = Instance.new("Frame", parent)
    D.Size = UDim2.new(1, -5, 0, 35); D.BackgroundColor3 = Color3.fromRGB(20, 20, 30); D.ClipsDescendants = true
    Instance.new("UICorner", D)

    local sel = list[1] or "None"
    local M = Instance.new("TextButton", D)
    M.Size = UDim2.new(1, 0, 0, 35); M.BackgroundTransparency = 1
    M.Text = "  " .. text .. " > " .. sel; M.TextColor3 = Color3.new(0.8,0.8,0.8); M.TextXAlignment = Enum.TextXAlignment.Left
    
    local Run = Instance.new("TextButton", M)
    Run.Size = UDim2.new(0, 50, 0, 24); Run.Position = UDim2.new(1, -55, 0.5, -12)
    Run.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Run.Text = "RUN"; Instance.new("UICorner", Run)

    local open = false
    M.MouseButton1Click:Connect(function()
        open = not open
        TweenService:Create(D, TweenInfo.new(0.3), {Size = UDim2.new(1,-5, 0, open and 140 or 35)}):Play()
    end)

    local S = Instance.new("ScrollingFrame", D)
    S.Position = UDim2.new(0,5,0,35); S.Size = UDim2.new(1,-10,0,100); S.BackgroundTransparency = 1; S.ScrollBarThickness = 2

    local SL = Instance.new("UIListLayout", S)
    for _, v in pairs(list) do
        local o = Instance.new("TextButton", S)
        o.Size = UDim2.new(1,0,0,25); o.BackgroundTransparency = 1; o.Text = v; o.TextColor3 = Color3.new(0.6,0.6,0.6)
        o.MouseButton1Click:Connect(function()
            sel = v; M.Text = "  " .. text .. " > " .. sel; open = false
            TweenService:Create(D, TweenInfo.new(0.3), {Size = UDim2.new(1,-5, 0, 35)}):Play()
        end)
    end
    Run.MouseButton1Click:Connect(self.SafeClick(function() callback(sel) end))
end

-- [6] XU 字体标签 (纯文本)
function XU_Lib:AddLabel(parent, text)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, -5, 0, 30); L.BackgroundTransparency = 1
    L.Text = "  " .. text; L.TextColor3 = Color3.new(0.5,0.5,0.5); L.TextXAlignment = Enum.TextXAlignment.Left; L.Font = Enum.Font.Gotham
end

-- 拖拽支持 (全平台)
local function Drag(obj, target)
    local dragStart, startPos, dragging
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function() dragging = false end)
end

function XU_Lib:Finalize()
    Drag(self.Main:FindFirstChild("Frame", true) or self.Main, self.Main) -- 简单拖拽
    return self
end

return XU_Lib