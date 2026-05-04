local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 彻底清理
if CoreGui:FindFirstChild("XU_Framework") then CoreGui.XU_Framework:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XU_Framework"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local XU_Lib = {}
local UIConfig = {
    MainColor = Color3.fromRGB(5, 5, 7),
    AccentColor = Color3.fromRGB(160, 60, 255), -- 还原原始紫
    SecondaryColor = Color3.fromRGB(15, 15, 20),
    Font = Enum.Font.GothamBold
}

function XU_Lib:Init()
    -- 1. 主框架 (硬核深色)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 540, 0, 360)
    Main.Position = UDim2.new(0.5, -270, 0.5, -180)
    Main.BackgroundColor3 = UIConfig.MainColor
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

    -- 🔥 还原流光灯带 (逻辑增强：永不闪烁)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Thickness = 2.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local MainGradient = Instance.new("UIGradient", MainStroke)
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, UIConfig.AccentColor),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 10, 60)),
        ColorSequenceKeypoint.new(1, UIConfig.AccentColor)
    })

    task.spawn(function()
        while true do
            TweenService:Create(MainGradient, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            task.wait(1.5)
            MainGradient.Rotation = 0
        end
    end)

    -- 2. 顶部标题栏
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 18, 0, 0)
    Title.Text = "XU PREMIUM"
    Title.TextColor3 = UIConfig.AccentColor
    Title.Font = UIConfig.Font
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- 3. 栏目与容器
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 130, 1, -70)
    Sidebar.Position = UDim2.new(0, 12, 0, 55)
    Sidebar.BackgroundTransparency = 1
    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 8)
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder -- 强制排序

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -165, 1, -70)
    Container.Position = UDim2.new(0, 150, 0, 55)
    Container.BackgroundTransparency = 1

    -- 4. 悬浮窗 (缩小高度版)
    local FloatIcon = Instance.new("ImageButton", ScreenGui)
    FloatIcon.Size = UDim2.new(0, 45, 0, 32)
    FloatIcon.BackgroundColor3 = UIConfig.SecondaryColor
    FloatIcon.Visible = false
    FloatIcon.ZIndex = 200
    Instance.new("UICorner", FloatIcon).CornerRadius = UDim.new(0, 6)
    local FloatStroke = Instance.new("UIStroke", FloatIcon)
    FloatStroke.Color = UIConfig.AccentColor
    FloatStroke.Thickness = 2

    -- 点击反馈与防误触
    self.SafeExec = function(func)
        local db = false
        return function(...)
            if db then return end
            db = true
            -- 点击爆发特效
            MainStroke.Thickness = 5
            TweenService:Create(MainStroke, TweenInfo.new(0.4), {Thickness = 2.5}):Play()
            func(...)
            task.wait(0.3)
            db = false
        end
    end

    -- 按钮控制逻辑
    local function CreateCtrl(txt, pos, cb)
        local b = Instance.new("TextButton", TopBar)
        b.Size = UDim2.new(0, 35, 0, 35); b.Position = pos; b.BackgroundTransparency = 1
        b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 26; b.Font = UIConfig.Font
        b.MouseButton1Click:Connect(cb)
    end

    CreateCtrl("×", UDim2.new(1, -45, 0, 5), function() ScreenGui:Destroy() end)
    CreateCtrl("-", UDim2.new(1, -85, 0, 5), function()
        Main.Visible = false
        FloatIcon.Position = UDim2.new(0, Main.AbsolutePosition.X + 250, 0, Main.AbsolutePosition.Y)
        FloatIcon.Visible = true
    end)
    FloatIcon.MouseButton1Click:Connect(function() Main.Visible = true; FloatIcon.Visible = false end)

    self.Main = Main
    self.Container = Container
    self.Sidebar = Sidebar
    self.CurrentOrder = 0 -- 排序计数器
    return self
end

function XU_Lib:AddTab(name, isHome)
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = isHome or false
    Page.ScrollBarThickness = 0; Page.CanvasSize = UDim2.new(0,0,0,0)
    
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8); Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0, Layout.AbsoluteContentSize.Y + 15)
    end)

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(1, 0, 0, 42); TabBtn.BackgroundColor3 = isHome and Color3.fromRGB(40, 20, 80) or UIConfig.SecondaryColor
    TabBtn.Text = name; TabBtn.TextColor3 = Color3.new(0.9,0.9,0.9); TabBtn.Font = UIConfig.Font; TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = UIConfig.SecondaryColor end end
        Page.Visible = true; TabBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 80)
    end)
    return Page
end

-- [1] 巨大按钮 (强制排序)
function XU_Lib:AddBigButton(parent, text, imgId, callback)
    self.CurrentOrder = self.CurrentOrder + 1
    local Btn = Instance.new("TextButton", parent)
    Btn.LayoutOrder = self.CurrentOrder
    Btn.Size = UDim2.new(1, -5, 0, 90); Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    Btn.Text = text; Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = UIConfig.Font; Btn.TextSize = 22; Btn.TextXAlignment = Enum.TextXAlignment.Right
    Instance.new("UICorner", Btn); Instance.new("UIPadding", Btn).PaddingRight = UDim.new(0, 30)

    if imgId and imgId ~= "" then
        local Icon = Instance.new("ImageLabel", Btn)
        Icon.Size = UDim2.new(0, 80, 0, 80); Icon.Position = UDim2.new(0, 10, 0.5, -40); Icon.Image = imgId
        Icon.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Instance.new("UICorner", Icon)
    end
    Btn.MouseButton1Click:Connect(self.SafeExec(callback))
end

-- [2] 网格多按钮 (自动缩放)
function XU_Lib:AddButtonRow(parent, buttons)
    self.CurrentOrder = self.CurrentOrder + 1
    local Row = Instance.new("Frame", parent)
    Row.LayoutOrder = self.CurrentOrder
    Row.Size = UDim2.new(1, -5, 0, 38); Row.BackgroundTransparency = 1
    local L = Instance.new("UIListLayout", Row); L.FillDirection = Enum.FillDirection.Horizontal; L.Padding = UDim.new(0, 6)

    for _, info in pairs(buttons) do
        local B = Instance.new("TextButton", Row)
        B.Size = UDim2.new(1/#buttons, -(((#buttons-1)*6)/#buttons), 1, 0)
        B.BackgroundColor3 = UIConfig.SecondaryColor; B.Text = info.Text; B.TextColor3 = Color3.new(0.9,0.9,0.9)
        B.Font = UIConfig.Font; B.TextSize = 13; Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
        B.MouseButton1Click:Connect(self.SafeExec(info.Callback))
    end
end

-- [3] 文件夹系统
function XU_Lib:AddFolder(parent, name)
    self.CurrentOrder = self.CurrentOrder + 1
    local F = Instance.new("Frame", parent)
    F.LayoutOrder = self.CurrentOrder
    F.Size = UDim2.new(1, -5, 0, 35); F.BackgroundColor3 = Color3.fromRGB(12, 12, 18); F.ClipsDescendants = true
    Instance.new("UICorner", F)
    
    local T = Instance.new("TextButton", F)
    T.Size = UDim2.new(1, 0, 0, 35); T.BackgroundTransparency = 1; T.Text = "  📁 " .. name
    T.TextColor3 = UIConfig.AccentColor; T.Font = UIConfig.Font; T.TextXAlignment = Enum.TextXAlignment.Left

    local Content = Instance.new("Frame", F)
    Content.Position = UDim2.new(0, 5, 0, 40); Content.Size = UDim2.new(1, -10, 0, 0); Content.BackgroundTransparency = 1
    local L = Instance.new("UIListLayout", Content); L.Padding = UDim.new(0, 6); L.SortOrder = Enum.SortOrder.LayoutOrder

    local open = false
    T.MouseButton1Click:Connect(function()
        open = not open
        TweenService:Create(F, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, open and (L.AbsoluteContentSize.Y + 45) or 35)}):Play()
    end)
    return Content
end

-- [4] 开关 (全域触发)
function XU_Lib:AddToggle(parent, text, callback)
    self.CurrentOrder = self.CurrentOrder + 1
    local B = Instance.new("TextButton", parent)
    B.LayoutOrder = self.CurrentOrder
    B.Size = UDim2.new(1, -5, 0, 35); B.BackgroundColor3 = UIConfig.SecondaryColor
    B.Text = "  " .. text; B.TextColor3 = Color3.new(0.9,0.9,0.9); B.Font = UIConfig.Font
    B.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", B)

    local Sw = Instance.new("Frame", B)
    Sw.Size = UDim2.new(0, 35, 0, 18); Sw.Position = UDim2.new(1, -45, 0.5, -9); Sw.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)

    local D = Instance.new("Frame", Sw)
    D.Size = UDim2.new(0, 14, 0, 14); D.Position = UDim2.new(0, 2, 0.5, -7); D.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", D)

    local s = false
    B.MouseButton1Click:Connect(self.SafeExec(function()
        s = not s
        TweenService:Create(D, TweenInfo.new(0.2), {Position = s and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = s and UIConfig.AccentColor or Color3.fromRGB(45, 45, 55)}):Play()
        callback(s)
    end))
end

-- [5] 列表触发器
function XU_Lib:AddDropdown(parent, text, list, callback)
    self.CurrentOrder = self.CurrentOrder + 1
    local D = Instance.new("Frame", parent)
    D.LayoutOrder = self.CurrentOrder
    D.Size = UDim2.new(1, -5, 0, 35); D.BackgroundColor3 = UIConfig.SecondaryColor; D.ClipsDescendants = true
    Instance.new("UICorner", D)

    local sel = list[1] or "..."
    local M = Instance.new("TextButton", D)
    M.Size = UDim2.new(1, 0, 0, 35); M.BackgroundTransparency = 1; M.Text = "  " .. text .. ": " .. sel
    M.TextColor3 = Color3.new(0.8,0.8,0.8); M.TextXAlignment = Enum.TextXAlignment.Left; M.Font = UIConfig.Font
    
    local Exec = Instance.new("TextButton", M)
    Exec.Size = UDim2.new(0, 55, 0, 24); Exec.Position = UDim2.new(1, -60, 0.5, -12)
    Exec.BackgroundColor3 = UIConfig.AccentColor; Exec.Text = "执行"; Instance.new("UICorner", Exec)

    local open = false
    M.MouseButton1Click:Connect(function()
        open = not open
        TweenService:Create(D, TweenInfo.new(0.3), {Size = UDim2.new(1,-5, 0, open and 140 or 35)}):Play()
    end)

    local S = Instance.new("ScrollingFrame", D)
    S.Position = UDim2.new(0,5,0,38); S.Size = UDim2.new(1,-10,0,95); S.BackgroundTransparency = 1; S.ScrollBarThickness = 2
    local L = Instance.new("UIListLayout", S)

    for _, v in pairs(list) do
        local opt = Instance.new("TextButton", S)
        opt.Size = UDim2.new(1, 0, 0, 25); opt.BackgroundTransparency = 1; opt.Text = v
        opt.TextColor3 = Color3.new(0.6,0.6,0.6); opt.Font = UIConfig.Font
        opt.MouseButton1Click:Connect(function()
            sel = v; M.Text = "  " .. text .. ": " .. sel; open = false
            TweenService:Create(D, TweenInfo.new(0.3), {Size = UDim2.new(1,-5, 0, 35)}):Play()
        end)
    end
    Exec.MouseButton1Click:Connect(self.SafeExec(function() callback(sel) end))
end

-- [6] 文本显示
function XU_Lib:AddLabel(parent, text)
    self.CurrentOrder = self.CurrentOrder + 1
    local L = Instance.new("TextLabel", parent)
    L.LayoutOrder = self.CurrentOrder
    L.Size = UDim2.new(1, -5, 0, 30); L.BackgroundTransparency = 1
    L.Text = "  " .. text; L.TextColor3 = Color3.new(0.5,0.5,0.5); L.TextXAlignment = Enum.TextXAlignment.Left; L.Font = Enum.Font.Gotham
end

-- 拖拽支持
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

function XU_Lib:Final()
    Drag(self.Main, self.Main)
    return self
end

return XU_Lib