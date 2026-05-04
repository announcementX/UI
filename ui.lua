local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local XU = {}
XU.__index = XU

-- 这个是主要配色，你们想改就在这里改呗，反正你们随便改
local XU_Theme = {
    Main = Color3.fromRGB(5, 5, 7),
    Accent = Color3.fromRGB(160, 60, 255),
    Secondary = Color3.fromRGB(20, 20, 28),
    Text = Color3.fromRGB(230, 230, 230),
    Sidebar = Color3.fromRGB(15, 15, 20),
    ButtonHover = Color3.fromRGB(40, 20, 80)
}

-- 流光边框特效,这个的话我推荐你们不要改啊，因为这个你们乱改，小心到时候废了
local function applyGlowEffect(stroke)
    local gradient = Instance.new("UIGradient", stroke)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, XU_Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 10, 60)),
        ColorSequenceKeypoint.new(1, XU_Theme.Accent)
    })
    
    task.spawn(function()
        while stroke.Parent do
            TweenService:Create(gradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            task.wait(2)
            gradient.Rotation = 0
        end
    end)
end

function XU.new(projectName)
    local self = setmetatable({}, XU)
    
    -- 基础容器
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "XU_Framework"
    self.Gui.Parent = CoreGui
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 主框架
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 540, 0, 360)
    self.Main.Position = UDim2.new(0.5, -270, 0.5, -180)
    self.Main.BackgroundColor3 = XU_Theme.Main
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 6)

    -- 流光描边
    local stroke = Instance.new("UIStroke", self.Main)
    stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    applyGlowEffect(stroke)
    self.MainStroke = stroke

    -- 顶部栏 
    local topBar = Instance.new("Frame", self.Main)
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundTransparency = 1
    self:EnableDrag(topBar, self.Main)

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 18, 0, 0)
    title.Text = projectName or "XU EXCLUSIVE"
    title.TextColor3 = XU_Theme.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- 侧边栏
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 130, 1, -70)
    self.Sidebar.Position = UDim2.new(0, 12, 0, 55)
    self.Sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", self.Sidebar).Padding = UDim.new(0, 8)

    -- 内容展示区
    self.Content = Instance.new("Frame", self.Main)
    self.Content.Size = UDim2.new(1, -165, 1, -70)
    self.Content.Position = UDim2.new(0, 150, 0, 55)
    self.Content.BackgroundTransparency = 1

    -- 关闭按钮
    local close = Instance.new("TextButton", topBar)
    close.Size = UDim2.new(0, 35, 0, 35)
    close.Position = UDim2.new(1, -40, 0, 5)
    close.Text = "×"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.BackgroundTransparency = 1
    close.TextSize = 24
    close.MouseButton1Click:Connect(function() self.Gui:Destroy() end)

    return self
end

-- 创建页面 
function XU:CreateTab(name)
    local page = Instance.new("ScrollingFrame", self.Content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 0
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)

    local btn = Instance.new("TextButton", self.Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = XU_Theme.Sidebar
    btn.Text = name
    btn.TextColor3 = XU_Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Content:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.Sidebar:GetChildren()) do
            if v:IsA("TextButton") then v.BackgroundColor3 = XU_Theme.Sidebar end
        end
        page.Visible = true
        btn.BackgroundColor3 = XU_Theme.ButtonHover
        
        -- 点击时边框爆发特效
        local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        self.MainStroke.Thickness = 5
        TweenService:Create(self.MainStroke, info, {Thickness = 2.5}):Play()
    end)

    -- 默认激活首个页面
    if #self.Sidebar:GetChildren() == 2 then 
        page.Visible = true
        btn.BackgroundColor3 = XU_Theme.ButtonHover
    end

    -- 返回页面对象以便添加组件
    local TabMethods = {}
    function TabMethods:AddButton(text, callback)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(0.98, 0, 0, 38)
        b.BackgroundColor3 = XU_Theme.Secondary
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(callback)
    end
    
    return TabMethods
end

-- 拖拽
function XU:EnableDrag(bar, frame)
    local drag, startPos, mouseStart
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            mouseStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mouseStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function() drag = false end)
end

return XU