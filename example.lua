--[[ ExampleUsage.lua
    Example script to use RobloxUILibrary in a real Roblox project.
    Place both RobloxUILibrary.lua and this script in your Roblox game's ReplicatedStorage or as a ModuleScript.
]]

local RobloxUILibrary = loadstring(https://raw.githubusercontent.com/fluxScript82/nixam/refs/heads/main/ui.library.lua)

-- Create library and window
local Library = RobloxUILibrary.new("Dark") -- or "Light"
local Window = Library:CreateWindow("Nixam Hub")

-- Create a tab
local MainTab = Window:CreateTab("Main")

-- Add UI elements
MainTab:CreateLabel("Welcome to Nixam Hub!")

MainTab:CreateButton("Say Hello", function()
    print("Hello from Nixam Hub!")
end)

local toggle = MainTab:CreateToggle("Enable Feature", false, function(state)
    print("Feature enabled?", state)
end)

local slider = MainTab:CreateSlider("Speed", 1, 100, 50, function(val)
    print("Slider value:", val)
end)

local dropdown = MainTab:CreateDropdown("Select Mode", {"Easy", "Medium", "Hard"}, "Medium", function(choice)
    print("Selected:", choice)
end)

local textbox = MainTab:CreateTextbox("Username", "", function(txt)
    print("Your username is:", txt)
end)

-- You can programmatically set or get values:
toggle:Set(true)         -- Set toggle to enabled
print(toggle:Get())      -- Get toggle state
slider:Set(75)           -- Set slider to 75
print(slider:Get())      -- Get slider value
dropdown:Set("Hard")     -- Select "Hard"
print(dropdown:Get())    -- Get current dropdown value

-- To add more tabs:
local SettingsTab = Window:CreateTab("Settings")
SettingsTab:CreateLabel("Settings coming soon...")

-- To change themes at runtime:
-- Library:SetTheme("Light") or Library:SetTheme("Dark") or Library:SetTheme("YourCustomTheme")
