-- // PRIVATE SCRIPT - NO LEAK //
-- // Optimization for Mobile Executor (Delta/Fluxus) //

local Lib = {}

function Lib:Init()
    local UIS = game:GetService("UserInputService")
    local CG = game:GetService("CoreGui")
    local TS = game:GetService("TweenService")

    if CG:FindFirstChild("TianLi_V13") then CG.TianLi_V13:Destroy() end

    local Screen = Instance.new("ScreenGui", CG)
    Screen.Name = "TianLi_V13"
    Screen.IgnoreGuiInset = true -- 手机端必须开这个，防止顶部偏移

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 540, 0, 360)
    Main.Position = UDim2.new(0.5, -270, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false -- 关键点：不能裁剪，否则边框灯带会被切掉
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

    -- [ 核心灯带逻辑 - 强制置顶修复 ]
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Name = "GlowBorder"
    MainStroke.Thickness = 3 -- 稍微加粗一点
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.LineJoinMode = Enum.LineJoinMode.Round
    MainStroke.Transparency = 0 -- 确保不透明
    MainStroke.Enabled = true

    local MainGradient = Instance.new("UIGradient", MainStroke)
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 60, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 10, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 60, 255))
    })

    -- 既然 Tween 不行，直接用循环步进，这个最稳，手机端不会卡动画
    task.spawn(function()
        local r = 0
        while task.wait() do
            r = r + 2
            if r >= 360 then r = 0 end
            MainGradient.Rotation = r
        end
    end)

    -- 剩下的 UI 结构保持 V13 原样
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1, 0, 0, 45); Top.BackgroundTransparency = 1
    
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -165, 1, -70); Content.Position = UDim2.new(0, 150, 0, 55); Content.BackgroundTransparency = 1
    
    local Side = Instance.new("Frame", Main)
    Side.Size = UDim2.new(0, 130, 1, -70); Side.Position = UDim2.new(0, 12, 0, 55); Side.BackgroundTransparency = 1
    Instance.new("UIListLayout", Side).Padding = UDim.new(0, 8)

    local API = {}
    function API:AddTab(name)
        local P = Instance.new("ScrollingFrame", Content)
        P.Size = UDim2.new(1, 0, 1, 0); P.Visible = false; P.BackgroundTransparency = 1; P.ScrollBarThickness = 0
        Instance.new("UIListLayout", P).Padding = UDim.new(0, 8)

        local B = Instance.new("TextButton", Side)
        B.Size = UDim2.new(1, 0, 0, 42); B.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        B.Text = name; B.TextColor3 = Color3.fromRGB(230, 230, 230); B.Font = "GothamBold"; B.TextSize = 14
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)

        B.MouseButton1Click:Connect(function()
            for _,v in pairs(Content:GetChildren()) do v.Visible = false end
            P.Visible = true
        end)
        
        local Page = {}
        function Page:Button(t, cb)
            local btn = Instance.new("TextButton", P)
            btn.Size = UDim2.new(0.98, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            btn.Text = t; btn.TextColor3 = Color3.fromRGB(220, 220, 220); btn.Font = "Gotham"
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(cb)
        end
        return Page
    end

    -- 简单的拖拽 (去掉啰嗦的封装)
    local d, sI, sP
    Top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; sI = i.Position; sP = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = i.Position - sI
            Main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function() d = false end)

    return API
end

return Lib