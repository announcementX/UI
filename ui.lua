--[[
    XU Premium UI Library
    Color Palette: Dark Purple & Charcoal
    Optimization: Mobile Touch and Scrolling Friendly
--]]

local XU = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 销毁旧的 UI 防止重复加载
if CoreGui:FindFirstChild("XU_UiBase") then
    CoreGui["XU_UiBase"]:Destroy()
end

function XU:CreateWindow(titleText)
    titleText = titleText or "XU"
    
    -- 主屏幕载体
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XU_UiBase"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- 主框架
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 360, 0, 240)
    MainFrame.Position = UDim2.new(0.5, -180, 0.4, -120)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 18, 24) -- 深暗黑紫背景
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- 基础拖拽支持
    MainFrame.Parent = ScreenGui

    -- 圆角和描边
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(115, 60, 195) -- 霓虹紫边框
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- 顶部标题栏
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 25, 38)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar

    -- 修复底部圆角被遮挡的细节
    local FixFrame = Instance.new("Frame")
    FixFrame.Size = UDim2.new(1, 0, 0, 10)
    FixFrame.Position = UDim2.new(0, 0, 1, -10)
    FixFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 38)
    FixFrame.BorderSizePixel = 0
    FixFrame.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TitleBar

    -- 关闭按钮
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 22
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TitleBar

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- 内容滚动区域（完美适配手机端滑动，不易误触）
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 3
    Container.ScrollBarImageColor3 = Color3.fromRGB(115, 60, 195)
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Container

    -- 自动调整滚动高度
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    -- 内部元素生成器
    local Elements = {}

    -- 1. 添加按钮方法
    function Elements:CreateButton(text, callback)
        callback = callback or function() end
        
        local BtnFrame = Instance.new("TextButton")
        BtnFrame.Size = UDim2.new(1, 0, 0, 35)
        BtnFrame.BackgroundColor3 = Color3.fromRGB(38, 32, 48)
        BtnFrame.Text = ""
        BtnFrame.AutoButtonColor = false
        BtnFrame.Parent = Container

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = BtnFrame

        local BtnText = Instance.new("TextLabel")
        BtnText.Size = UDim2.new(1, 0, 1, 0)
        BtnText.Text = text
        BtnText.TextColor3 = Color3.fromRGB(220, 210, 235)
        BtnText.Font = Enum.Font.GothamMedium
        BtnText.TextSize = 14
        BtnText.BackgroundTransparency = 1
        BtnText.Parent = BtnFrame

        -- 点击反馈动画
        BtnFrame.MouseButton1Click:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(115, 60, 195)}):Play()
            task.wait(0.1)
            TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(38, 32, 48)}):Play()
            pcall(callback)
        end)
    end

    -- 2. 添加开关(Toggle)方法
    function Elements:CreateToggle(text, default, callback)
        default = default or false
        callback = callback or function() end
        local toggled = default

        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 28, 40)
        ToggleFrame.Text = ""
        ToggleFrame.AutoButtonColor = false
        ToggleFrame.Parent = Container

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = ToggleFrame

        local ToggleText = Instance.new("TextLabel")
        ToggleText.Size = UDim2.new(1, -60, 1, 0)
        ToggleText.Position = UDim2.new(0, 12, 0, 0)
        ToggleText.Text = text
        ToggleText.TextColor3 = Color3.fromRGB(220, 210, 235)
        ToggleText.Font = Enum.Font.GothamMedium
        ToggleText.TextSize = 14
        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
        ToggleText.BackgroundTransparency = 1
        ToggleText.Parent = ToggleFrame

        -- 开关外框
        local SwitchBox = Instance.new("Frame")
        SwitchBox.Size = UDim2.new(0, 36, 0, 20)
        SwitchBox.Position = UDim2.new(1, -46, 0.5, -10)
        SwitchBox.BackgroundColor3 = toggled and Color3.fromRGB(115, 60, 195) or Color3.fromRGB(55, 50, 65)
        SwitchBox.BorderSizePixel = 0
        SwitchBox.Parent = ToggleFrame

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(1, 0)
        BoxCorner.Parent = SwitchBox

        -- 开关圆点
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 14, 0, 14)
        Dot.Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dot.BorderSizePixel = 0
        Dot.Parent = SwitchBox

        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(1, 0)
        DotCorner.Parent = Dot

        -- 触发逻辑
        ToggleFrame.MouseButton1Click:Connect(function()
            toggled = not toggled
            local targetPos = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            local targetColor = toggled and Color3.fromRGB(115, 60, 195) or Color3.fromRGB(55, 50, 65)
            
            TweenService:Create(Dot, TweenInfo.new(0.15), {Position = targetPos}):Play()
            TweenService:Create(SwitchBox, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
            
            pcall(callback, toggled)
        end)
    end

    return Elements
end

return XU