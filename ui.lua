--[[
    XU Advanced UI Library
    Color Palette: Cyberpunk Dark Purple & Charcoal
    Features: Scrollable Sidebar, Smooth Animations, Mobile Draggable Float Button, Draggable Header
--]]

local XU = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 销毁旧的 UI 防止重复加载
if CoreGui:FindFirstChild("XU_UiBase") then
    CoreGui["XU_UiBase"]:Destroy()
end

-- 简易拖拽函数 (完美兼容PC与手机触摸)
local function MakeDraggable(gui, handle)
    handle = handle or gui
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function XU:CreateWindow(titleText)
    titleText = titleText or "XU UI"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XU_UiBase"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- 1. 缩小后的悬浮按钮 (初始隐藏)
    local FloatBtn = Instance.new("ImageButton")
    FloatBtn.Name = "FloatBtn"
    FloatBtn.Size = UDim2.new(0, 55, 0, 55)
    FloatBtn.Position = UDim2.new(0.5, -27, 0.4, -27)
    FloatBtn.Image = "rbxassetid://106649176674330" -- 你提供的图片ID
    FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 18, 24)
    FloatBtn.BorderSizePixel = 0
    FloatBtn.Visible = false
    FloatBtn.ClipsDescendants = true
    FloatBtn.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(0, 12) -- 带圆角的正方形
    FloatCorner.Parent = FloatBtn

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = Color3.fromRGB(115, 60, 195)
    FloatStroke.Thickness = 1.5
    FloatStroke.Parent = FloatBtn

    MakeDraggable(FloatBtn) -- 悬浮球也支持自由拖拽

    -- 2. 主框架 (调整宽高度以完美适配侧边栏 + 内容区)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 480, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -240, 0.4, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 13, 18) -- 深暗底色
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(115, 60, 195) -- 经典霓虹紫
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- 顶部栏
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar

    local FixFrame = Instance.new("Frame")
    FixFrame.Size = UDim2.new(1, 0, 0, 10)
    FixFrame.Position = UDim2.new(0, 0, 1, -10)
    FixFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
    FixFrame.BorderSizePixel = 0
    FixFrame.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TitleBar

    MakeDraggable(MainFrame, TitleBar) -- 只能拖拽顶部栏移动

    -- 按钮区域容器 (存放关闭和缩小)
    local ButtonHolder = Instance.new("Frame")
    ButtonHolder.Size = UDim2.new(0, 70, 1, 0)
    ButtonHolder.Position = UDim2.new(1, -75, 0, 0)
    ButtonHolder.BackgroundTransparency = 1
    ButtonHolder.Parent = TitleBar

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.Parent = ButtonHolder

    -- 关闭按钮 (×)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = ButtonHolder

    -- 缩小按钮 (-)
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeBtn.TextSize = 12
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Parent = ButtonHolder

    -- 3. 动画逻辑
    local isAnimating = false
    local originalSize = MainFrame.Size

    -- 缩小动画
    MinimizeBtn.MouseButton1Click:Connect(function()
        if isAnimating then return end
        isAnimating = true
        
        -- 记录当前坐标，使悬浮球出现在正中心
        FloatBtn.Position = UDim2.new(
            MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + (MainFrame.Size.X.Offset/2) - 27,
            MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (MainFrame.Size.Y.Offset/2) - 27
        )

        -- 缩小主窗口
        local shrink = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + (MainFrame.Size.X.Offset/2), MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (MainFrame.Size.Y.Offset/2))
        })
        shrink:Play()
        
        shrink.Completed:Connect(function()
            MainFrame.Visible = false
            FloatBtn.Visible = true
            FloatBtn.Size = UDim2.new(0, 0, 0, 0)
            
            -- 弹出悬浮球
            local pop = TweenService:Create(FloatBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 55, 0, 55)
            })
            pop:Play()
            pop.Completed:Connect(function()
                isAnimating = false
            end)
        end)
    end)

    -- 恢复动画
    FloatBtn.MouseButton1Click:Connect(function()
        if isAnimating then return end
        isAnimating = true

        -- 缩小悬浮球
        local shrinkFloat = TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        shrinkFloat:Play()

        shrinkFloat.Completed:Connect(function()
            FloatBtn.Visible = false
            MainFrame.Visible = true
            
            -- 恢复主界面大小与位置
            local targetPos = UDim2.new(
                FloatBtn.Position.X.Scale, FloatBtn.Position.X.Offset - (originalSize.X.Offset/2) + 27,
                FloatBtn.Position.Y.Scale, FloatBtn.Position.Y.Offset - (originalSize.Y.Offset/2) + 27
            )
            
            local restore = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = originalSize,
                Position = targetPos
            })
            restore:Play()
            restore.Completed:Connect(function()
                isAnimating = false
            end)
        end)
    end)

    -- 关闭动画
    CloseBtn.MouseButton1Click:Connect(function()
        if isAnimating then return end
        isAnimating = true
        
        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + (MainFrame.Size.X.Offset/2), MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (MainFrame.Size.Y.Offset/2))
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)

    -- 4. 侧边栏结构 (Sidebar)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, -35)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 16, 25) -- 略带紫色的偏暗深灰
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = Color3.fromRGB(115, 60, 195)
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 6)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingLeft = UDim.new(0, 6)
    SidebarPadding.PaddingRight = UDim.new(0, 6)
    SidebarPadding.Parent = Sidebar

    -- 自动调整侧边栏滑动高度
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 16)
    end)

    -- 5. 右侧内容区域载体
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -120, 1, -35)
    ContentHolder.Position = UDim2.new(0, 120, 0, 35)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- 核心模块对象
    local Elements = {}
    local tabs = {}
    local pages = {}
    local currentTab = nil

    -- 创建 Tab 页面方法
    function Elements:CreateTab(tabName)
        local pageId = #tabs + 1

        -- 侧边栏 Tab 切换按钮
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName.."_Btn"
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 24, 38)
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn

        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, 0, 1, 0)
        TabText.Text = tabName
        TabText.TextColor3 = Color3.fromRGB(160, 150, 175) -- 默认未选中灰色
        TabText.Font = Enum.Font.GothamMedium
        TabText.TextSize = 12
        TabText.BackgroundTransparency = 1
        TabText.Parent = TabBtn

        -- 对应的右侧可滑动页面 (ScrollingFrame)
        local PageFrame = Instance.new("ScrollingFrame")
        PageFrame.Name = tabName.."_Page"
        PageFrame.Size = UDim2.new(1, -16, 1, -10)
        PageFrame.Position = UDim2.new(0, 8, 0, 5)
        PageFrame.BackgroundTransparency = 1
        PageFrame.BorderSizePixel = 0
        PageFrame.ScrollBarThickness = 3
        PageFrame.ScrollBarImageColor3 = Color3.fromRGB(115, 60, 195)
        PageFrame.Visible = false
        PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageFrame.Parent = ContentHolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = PageFrame

        -- 页面高度自动调节
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        -- 切换 Tab 的高亮与显示逻辑
        local function selectTab()
            if currentTab == pageId then return end
            
            -- 重置之前选中的 Tab 样式
            if currentTab and tabs[currentTab] then
                TweenService:Create(tabs[currentTab].Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 24, 38)}):Play()
                TweenService:Create(tabs[currentTab].Text, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(160, 150, 175)}):Play()
                pages[currentTab].Visible = false
            end

            -- 高亮当前 Tab 样式
            currentTab = pageId
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(115, 60, 195)}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            PageFrame.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(selectTab)

        -- 缓存对象
        tabs[pageId] = {Btn = TabBtn, Text = TabText}
        pages[pageId] = PageFrame

        -- 默认自动选中第一个 Tab
        if pageId == 1 then
            task.spawn(selectTab)
        end

        -- 单个页面下的具体控件生成器
        local PageControls = {}

        -- 1. 创建按钮
        function PageControls:CreateButton(text, callback)
            callback = callback or function() end

            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 35)
            BtnFrame.BackgroundColor3 = Color3.fromRGB(32, 26, 40)
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = PageFrame

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = BtnFrame

            local BtnText = Instance.new("TextLabel")
            BtnText.Size = UDim2.new(1, 0, 1, 0)
            BtnText.Text = text
            BtnText.TextColor3 = Color3.fromRGB(220, 210, 235)
            BtnText.Font = Enum.Font.GothamMedium
            BtnText.TextSize = 13
            BtnText.BackgroundTransparency = 1
            BtnText.Parent = BtnFrame

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(115, 60, 195)}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 26, 40)}):Play()
                pcall(callback)
            end)
        end

        -- 2. 创建开关
        function PageControls:CreateToggle(text, default, callback)
            default = default or false
            callback = callback or function() end
            local toggled = default

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(26, 21, 32)
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = PageFrame

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame

            local ToggleText = Instance.new("TextLabel")
            ToggleText.Size = UDim2.new(1, -60, 1, 0)
            ToggleText.Position = UDim2.new(0, 12, 0, 0)
            ToggleText.Text = text
            ToggleText.TextColor3 = Color3.fromRGB(220, 210, 235)
            ToggleText.Font = Enum.Font.GothamMedium
            ToggleText.TextSize = 13
            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
            ToggleText.BackgroundTransparency = 1
            ToggleText.Parent = ToggleFrame

            local SwitchBox = Instance.new("Frame")
            SwitchBox.Size = UDim2.new(0, 36, 0, 18)
            SwitchBox.Position = UDim2.new(1, -46, 0.5, -9)
            SwitchBox.BackgroundColor3 = toggled and Color3.fromRGB(115, 60, 195) or Color3.fromRGB(55, 50, 65)
            SwitchBox.BorderSizePixel = 0
            SwitchBox.Parent = ToggleFrame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(1, 0)
            BoxCorner.Parent = SwitchBox

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 12, 0, 12)
            Dot.Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Dot.BorderSizePixel = 0
            Dot.Parent = SwitchBox

            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = Dot

            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                local targetPos = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                local targetColor = toggled and Color3.fromRGB(115, 60, 195) or Color3.fromRGB(55, 50, 65)
                
                TweenService:Create(Dot, TweenInfo.new(0.12), {Position = targetPos}):Play()
                TweenService:Create(SwitchBox, TweenInfo.new(0.12), {BackgroundColor3 = targetColor}):Play()
                
                pcall(callback, toggled)
            end)
        end

        return PageControls
    end

    return Elements
end

return XU