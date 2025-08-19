--[[
    RobloxUILibrary.lua
    A lightweight, modular, and performant UI library for Roblox Studio
    Author: fluxScript82
]]

local RobloxUILibrary = {}
RobloxUILibrary.__index = RobloxUILibrary

-- Theme definitions
local Themes = {
    Light = {
        Background = Color3.fromRGB(240,240,240),
        Accent = Color3.fromRGB(0, 170, 255),
        Foreground = Color3.fromRGB(35,35,35),
        Button = Color3.fromRGB(200,200,200),
        ButtonText = Color3.fromRGB(60,60,60),
        Slider = Color3.fromRGB(0,170,255),
        ToggleOn = Color3.fromRGB(0,170,255),
        ToggleOff = Color3.fromRGB(180,180,180),
    },
    Dark = {
        Background = Color3.fromRGB(30,30,32),
        Accent = Color3.fromRGB(0, 170, 255),
        Foreground = Color3.fromRGB(230,230,230),
        Button = Color3.fromRGB(45,45,48),
        ButtonText = Color3.fromRGB(220,220,220),
        Slider = Color3.fromRGB(0,170,255),
        ToggleOn = Color3.fromRGB(0,170,255),
        ToggleOff = Color3.fromRGB(60,60,60),
    }
}

-- Utility: Tween
local function Tween(obj, prop, val, duration, easing)
    local TweenService = game:GetService("TweenService")
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.25, easing or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = val})
    tween:Play()
    return tween
end

-- Utility: Make draggable
local function MakeDraggable(frame)
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Utility: Auto scale
local function UIScaleFor(obj)
    local scale = Instance.new("UIScale")
    scale.Parent = obj
    return scale
end

-- Create a new library instance
function RobloxUILibrary.new(theme)
    local self = setmetatable({}, RobloxUILibrary)
    self.Theme = Themes[theme or "Dark"]
    self.CustomThemes = {}
    return self
end

-- Add a custom theme
function RobloxUILibrary:AddTheme(name, themeTable)
    self.CustomThemes[name] = themeTable
end

-- Set current theme
function RobloxUILibrary:SetTheme(name)
    self.Theme = self.CustomThemes[name] or Themes[name] or self.Theme
end

-- Create a new window
function RobloxUILibrary:CreateWindow(title)
    -- Main holder
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Name = "RobloxUILib_" .. tostring(title or "Window")
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    ScreenGui.Parent = (game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui"))

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(0, 400, 0, 350)
    Holder.Position = UDim2.new(0.5, -200, 0.5, -175)
    Holder.BackgroundColor3 = self.Theme.Background
    Holder.BorderSizePixel = 0
    Holder.Name = "MainWindow"
    Holder.Parent = ScreenGui
    UIScaleFor(Holder)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    TopBar.BackgroundColor3 = self.Theme.Accent
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Holder

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "  " .. (title or "Window")
    Title.Font = Enum.Font.GothamSemibold
    Title.TextColor3 = self.Theme.Foreground
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- Tab holder
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(1, 0, 1, -36)
    TabHolder.Position = UDim2.new(0, 0, 0, 36)
    TabHolder.BackgroundColor3 = self.Theme.Background
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = Holder

    -- Tabs UIListLayout
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabHolder

    -- Draggable window
    MakeDraggable(TopBar)

    local window = {
        _library = self,
        _gui = ScreenGui,
        _holder = Holder,
        _tabHolder = TabHolder,
        _tabLayout = TabLayout,
        _tabs = {},
        _theme = self.Theme,
    }

    setmetatable(window, {
        __index = function(t, k) return RobloxUILibrary.WindowFunctions[k] end
    })

    return window
end

-- Window functions
RobloxUILibrary.WindowFunctions = {}

-- Create a new tab in the window
function RobloxUILibrary.WindowFunctions:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 36)
    TabButton.BackgroundColor3 = self._theme.Button
    TabButton.TextColor3 = self._theme.ButtonText
    TabButton.Text = name or "Tab"
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 16
    TabButton.Parent = self._tabHolder

    local TabFrame = Instance.new("Frame")
    TabFrame.BackgroundTransparency = 1
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.Visible = false
    TabFrame.Parent = self._holder

    TabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, t in ipairs(self._tabs) do
            t.Frame.Visible = false
            Tween(t.Button, "BackgroundColor3", self._theme.Button, 0.2)
        end
        -- Show this
        TabFrame.Visible = true
        Tween(TabButton, "BackgroundColor3", self._theme.Accent, 0.2)
    end)

    table.insert(self._tabs, {Button = TabButton, Frame = TabFrame})
    -- Show first tab by default
    if #self._tabs == 1 then
        TabFrame.Visible = true
        TabButton.BackgroundColor3 = self._theme.Accent
    end

    local tab = {
        _window = self,
        _frame = TabFrame,
        _theme = self._theme,
    }
    setmetatable(tab, {
        __index = function(t, k) return RobloxUILibrary.TabFunctions[k] end
    })
    return tab
end

-- Tab functions
RobloxUILibrary.TabFunctions = {}

-- Add a label
function RobloxUILibrary.TabFunctions:CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 28)
    Label.Position = UDim2.new(0, 10, 0, 10 + (#self._frame:GetChildren()-1)*38)
    Label.BackgroundTransparency = 1
    Label.Text = text or "Label"
    Label.TextColor3 = self._theme.Foreground
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = self._frame
    return Label
end

-- Add a button
function RobloxUILibrary.TabFunctions:CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Position = UDim2.new(0, 10, 0, 10 + (#self._frame:GetChildren()-1)*38)
    Button.BackgroundColor3 = self._theme.Button
    Button.TextColor3 = self._theme.ButtonText
    Button.Text = text or "Button"
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 16
    Button.AutoButtonColor = false
    Button.Parent = self._frame

    Button.MouseEnter:Connect(function()
        Tween(Button, "BackgroundColor3", self._theme.Accent, 0.15)
    end)
    Button.MouseLeave:Connect(function()
        Tween(Button, "BackgroundColor3", self._theme.Button, 0.15)
    end)
    Button.MouseButton1Click:Connect(function()
        if typeof(callback) == "function" then callback() end
    end)

    return Button
end

-- Add a toggle
function RobloxUILibrary.TabFunctions:CreateToggle(text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 30)
    Frame.Position = UDim2.new(0, 10, 0, 10 + (#self._frame:GetChildren()-1)*38)
    Frame.BackgroundTransparency = 1
    Frame.Parent = self._frame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text or "Toggle"
    ToggleLabel.TextColor3 = self._theme.Foreground
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 16
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -34, 0.5, -12)
    ToggleBtn.BackgroundColor3 = default and self._theme.ToggleOn or self._theme.ToggleOff
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Frame

    local value = default and true or false
    ToggleBtn.MouseButton1Click:Connect(function()
        value = not value
        Tween(ToggleBtn, "BackgroundColor3", value and self._theme.ToggleOn or self._theme.ToggleOff, 0.15)
        if typeof(callback) == "function" then callback(value) end
    end)

    return {
        Set = function(_, v)
            value = v
            Tween(ToggleBtn, "BackgroundColor3", value and self._theme.ToggleOn or self._theme.ToggleOff, 0.15)
        end,
        Get = function() return value end
    }
end

-- Add a slider
function RobloxUILibrary.TabFunctions:CreateSlider(text, min, max, default, callback)
    min, max, default = min or 0, max or 100, default or 0
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 36)
    Frame.Position = UDim2.new(0, 10, 0, 10 + (#self._frame:GetChildren()-1)*38)
    Frame.BackgroundTransparency = 1
    Frame.Parent = self._frame

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(0.8, 0, 1, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text or "Slider"
    SliderLabel.TextColor3 = self._theme.Foreground
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 16
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = Frame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(0.4, 0, 0, 6)
    SliderBar.Position = UDim2.new(0.8, 10, 0.5, -3)
    SliderBar.BackgroundColor3 = self._theme.Button
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Frame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = self._theme.Slider
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar

    local Drag = Instance.new("ImageButton")
    Drag.Size = UDim2.new(0, 16, 0, 16)
    Drag.BackgroundTransparency = 1
    Drag.Image = "rbxassetid://3570695787"
    Drag.ImageColor3 = self._theme.Accent
    Drag.Position = UDim2.new(0, -8, 0.5, -8)
    Drag.Parent = Fill
    Drag.ZIndex = 2

    local value = default
    local dragging = false

    local function UpdateSlider(x)
        local barAbsPos = SliderBar.AbsolutePosition
        local barAbsSize = SliderBar.AbsoluteSize
        local rel = math.clamp((x - barAbsPos.X) / barAbsSize.X, 0, 1)
        value = math.floor((min + (max-min)*rel) * 100) / 100
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Drag.Position = UDim2.new(1, -8, 0.5, -8)
        SliderLabel.Text = ("%s (%s)"):format(text, tostring(value))
        if typeof(callback) == "function" then callback(value) end
    end

    Drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    Drag.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input.Position.X)
        end
    end)
    UpdateSlider(SliderBar.AbsolutePosition.X + (default-min)/(max-min)*SliderBar.AbsoluteSize.X)

    return {
        Set = function(_, v) UpdateSlider(SliderBar.AbsolutePosition.X + (v-min)/(max-min)*SliderBar.AbsoluteSize.X) end,
        Get = function() return value end
    }
end

-- Add a dropdown
function RobloxUILibrary.TabFunctions:CreateDropdown(text, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 38)
    Frame.Position = UDim2.new(0, 10, 0, 10 + (#self._frame:GetChildren()-1)*38)
    Frame.BackgroundTransparency = 1
    Frame.Parent = self._frame

    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(1, 0, 1, 0)
    DropdownBtn.BackgroundColor3 = self._theme.Button
    DropdownBtn.TextColor3 = self._theme.ButtonText
    DropdownBtn.Text = ("%s: %s ▼"):format(text, default or options[1])
    DropdownBtn.Font = Enum.Font.GothamBold
    DropdownBtn.TextSize = 16
    DropdownBtn.AutoButtonColor = false
    DropdownBtn.Parent = Frame

    local Open = false
    local value = default or options[1]

    local function SetDropdown(val)
        value = val
        DropdownBtn.Text = ("%s: %s ▼"):format(text, value)
        if typeof(callback) == "function" then callback(value) end
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        if Open then return end
        Open = true
        for i, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.Position = UDim2.new(0, 0, 0, i*28)
            OptBtn.BackgroundColor3 = self._theme.Button
            OptBtn.TextColor3 = self._theme.ButtonText
            OptBtn.Text = opt
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 15
            OptBtn.Parent = Frame

            OptBtn.MouseButton1Click:Connect(function()
                SetDropdown(opt)
                for _, v in ipairs(Frame:GetChildren()) do
                    if v:IsA("TextButton") and v ~= DropdownBtn then v:Destroy() end
                end
                Open = false
            end)
        end
    end)
    return {
        Set = function(_, v) SetDropdown(v) end,
        Get = function() return value end
    }
end

-- Add a textbox
function RobloxUILibrary.TabFunctions:CreateTextbox(text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 32)
    Frame.Position = UDim2.new(0, 10, 0, 10 + (#self._frame:GetChildren()-1)*38)
    Frame.BackgroundTransparency = 1
    Frame.Parent = self._frame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.3, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text or "Textbox"
    TextLabel.TextColor3 = self._theme.Foreground
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = Frame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.7, -10, 1, 0)
    TextBox.Position = UDim2.new(0.3, 10, 0, 0)
    TextBox.BackgroundColor3 = self._theme.Button
    TextBox.TextColor3 = self._theme.ButtonText
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 16
    TextBox.Text = default or ""
    TextBox.PlaceholderText = text or "Textbox"
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = Frame

    TextBox.FocusLost:Connect(function(enter)
        if enter then
            if typeof(callback) == "function" then callback(TextBox.Text) end
        end
    end)

    return TextBox
end

-- Return library
return RobloxUILibrary
