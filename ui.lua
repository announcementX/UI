local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("TianLi_V13") then CoreGui.TianLi_V13:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TianLi_V13"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 颜色配置
local Theme = {
    Main = Color3.fromRGB(5, 5, 7),
    Accent = Color3.fromRGB(160, 60, 255),
    Dark = Color3.fromRGB(15, 15, 20),
    Text = Color3.fromRGB(230, 230, 230),
    Button = Color3.fromRGB(25, 25, 35)
}

-- 1. 主框架
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 540, 0, 360)
Main.Position = UDim2.new(0.5, -270, 0.5, -180)
Main.BackgroundColor3 = Theme.Main
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 2.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local MainGradient = Instance.new("UIGradient", MainStroke)
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 10, 60)),
    ColorSequenceKeypoint.new(1, Theme.Accent)
})

task.spawn(function()
    while true do
        TweenService:Create(MainGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
        task.wait(2)
        MainGradient.Rotation = 0
    end
end)

-- 2. 顶部与基础布局
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.Text = "TIANLI PREMIUM"
Title.TextColor3 = Theme.Accent
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

-- 3. 悬浮窗 (高度缩小处理)
local FloatIcon = Instance.new("ImageButton", ScreenGui)
FloatIcon.Size = UDim2.new(0, 45, 0, 38) -- 缩小并扁平化
FloatIcon.BackgroundColor3 = Theme.Dark
FloatIcon.Visible = false
FloatIcon.ZIndex = 200
Instance.new("UICorner", FloatIcon).CornerRadius = UDim.new(0, 8)
local FloatStroke = Instance.new("UIStroke", FloatIcon)
FloatStroke.Color = Theme.Accent
FloatStroke.Thickness = 2

-- 工具：防误触点击
local function Debounce(func)
    local IsClicked = false
    return function(...)
        if IsClicked then return end
        IsClicked = true
        func(...)
        task.wait(0.3)
        IsClicked = false
    end
end

-- 4. 核心UI构建库
local TL_Lib = {}

function TL_Lib:CreateTab(name, isHome)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = isHome or false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, 0, 0, 42)
    TabBtn.BackgroundColor3 = isHome and Color3.fromRGB(40, 20, 80) or Theme.Dark
    TabBtn.Text = name
    TabBtn.TextColor3 = Theme.Text
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(Container:GetChildren()) do v.Visible = false end
        for _, v in pairs(Sidebar:GetChildren()) do 
            if v:IsA("TextButton") then v.BackgroundColor3 = Theme.Dark end 
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 80)
    end)
    return Page
end

-- [1] 巨大按钮 (支持可选图片)
function TL_Lib:AddBigButton(parent, text, imgId, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -5, 0, 90)
    Btn.BackgroundColor3 = Theme.Button
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 22
    Btn.TextXAlignment = Enum.TextXAlignment.Right
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", Btn).PaddingRight = UDim.new(0, 25)

    if imgId and imgId ~= "" then
        local Icon = Instance.new("ImageLabel", Btn)
        Icon.Size = UDim2.new(0, 70, 0, 70)
        Icon.Position = UDim2.new(0, 10, 0.5, -35)
        Icon.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Icon.Image = imgId
        Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 6)
    end

    Btn.MouseButton1Click:Connect(Debounce(callback))
end

-- [2] 网格按钮系统 (支持1-3个)
function TL_Lib:AddButtonRow(parent, buttons)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, -5, 0, 35)
    Row.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Row)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 5)

    for _, info in pairs(buttons) do
        local B = Instance.new("TextButton", Row)
        B.Size = UDim2.new(1/#buttons, -(((#buttons-1)*5)/#buttons), 1, 0)
        B.BackgroundColor3 = Theme.Dark
        B.Text = info.Text
        B.TextColor3 = Theme.Text
        B.Font = Enum.Font.Gotham
        B.TextSize = 12
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", B).Color = Theme.Accent
        
        B.MouseButton1Click:Connect(Debounce(info.Callback))
    end
end

-- [3] 文件夹系统
function TL_Lib:AddFolder(parent, name)
    local FolderFrame = Instance.new("Frame", parent)
    FolderFrame.Size = UDim2.new(1, -5, 0, 35)
    FolderFrame.BackgroundColor3 = Theme.Dark
    FolderFrame.ClipsDescendants = true
    Instance.new("UICorner", FolderFrame)
    
    local TitleBtn = Instance.new("TextButton", FolderFrame)
    TitleBtn.Size = UDim2.new(1, 0, 0, 35)
    TitleBtn.BackgroundTransparency = 1
    TitleBtn.Text = "  📁  " .. name
    TitleBtn.TextColor3 = Theme.Accent
    TitleBtn.Font = Enum.Font.GothamBold
    TitleBtn.TextSize = 14
    TitleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local Content = Instance.new("Frame", FolderFrame)
    Content.Position = UDim2.new(0, 5, 0, 40)
    Content.Size = UDim2.new(1, -10, 0, 0)
    Content.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Content)
    Layout.Padding = UDim.new(0, 5)

    local open = false
    TitleBtn.MouseButton1Click:Connect(function()
        open = not open
        local targetSize = open and (Layout.AbsoluteContentSize.Y + 45) or 35
        TweenService:Create(FolderFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, targetSize)}):Play()
    end)
    return Content
end

-- [4] 开关
function TL_Lib:AddToggle(parent, text, callback)
    local TFrame = Instance.new("TextButton", parent)
    TFrame.Size = UDim2.new(1, -5, 0, 35)
    TFrame.BackgroundColor3 = Theme.Dark
    TFrame.Text = "  " .. text
    TFrame.TextColor3 = Theme.Text
    TFrame.Font = Enum.Font.Gotham
    TFrame.TextSize = 14
    TFrame.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TFrame)

    local Box = Instance.new("Frame", TFrame)
    Box.Size = UDim2.new(0, 34, 0, 18)
    Box.Position = UDim2.new(1, -45, 0.5, -9)
    Box.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame", Box)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local state = false
    TFrame.MouseButton1Click:Connect(Debounce(function()
        state = not state
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 60)}):Play()
        callback(state)
    end))
end

-- [5] 列表选择触发
function TL_Lib:AddDropdown(parent, text, options, callback)
    local DropFrame = Instance.new("Frame", parent)
    DropFrame.Size = UDim2.new(1, -5, 0, 35)
    DropFrame.BackgroundColor3 = Theme.Dark
    DropFrame.ClipsDescendants = true
    Instance.new("UICorner", DropFrame)

    local Selected = "未选择"
    local MainBtn = Instance.new("TextButton", DropFrame)
    MainBtn.Size = UDim2.new(1, 0, 0, 35)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = "  " .. text .. " : [" .. Selected .. "]"
    MainBtn.TextColor3 = Theme.Text
    MainBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local Trigger = Instance.new("TextButton", MainBtn)
    Trigger.Size = UDim2.new(0, 60, 0, 25)
    Trigger.Position = UDim2.new(1, -65, 0.5, -12)
    Trigger.Text = "执行"
    Trigger.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", Trigger)

    local open = false
    MainBtn.MouseButton1Click:Connect(function()
        open = not open
        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, open and 150 or 35)}):Play()
    end)

    local List = Instance.new("ScrollingFrame", DropFrame)
    List.Position = UDim2.new(0, 0, 0, 35)
    List.Size = UDim2.new(1, 0, 0, 110)
    List.BackgroundTransparency = 1
    local LL = Instance.new("UIListLayout", List)
    
    for _, opt in pairs(options) do
        local o = Instance.new("TextButton", List)
        o.Size = UDim2.new(1, 0, 0, 25)
        o.BackgroundTransparency = 1
        o.Text = opt
        o.TextColor3 = Color3.fromRGB(150, 150, 150)
        o.MouseButton1Click:Connect(function()
            Selected = opt
            MainBtn.Text = "  " .. text .. " : [" .. Selected .. "]"
            open = false
            TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 35)}):Play()
        end)
    end

    Trigger.MouseButton1Click:Connect(Debounce(function()
        callback(Selected)
    end))
end

-- [6] 文本显示
function TL_Lib:AddLabel(parent, text)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, -5, 0, 30)
    L.BackgroundTransparency = 1
    L.Text = "  " .. text
    L.TextColor3 = Color3.fromRGB(150, 150, 150)
    L.Font = Enum.Font.GothamItalic
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
end