-------\\ Variables //-------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-------\\ UI Variables //-------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-------\\ Functions //-------
local function Notify(Message, Time)
    Fluent:Notify({
        Title = "Fluent",
        Content = Message,
        Duration = Time or 7
    })
end

local function GetPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function RefreshPlayerDropdowns()
    local newList = GetPlayerNames()
    PlayerDropdown:SetValues(newList)
    MultiTargetDropdown:SetValues(newList)
end
RefreshPlayerDropdowns()

-------\\ Connections //-------
Players.PlayerAdded:Connect(RefreshPlayerDropdowns)
Players.PlayerRemoving:Connect(RefreshPlayerDropdowns)

-------\\ Main //-------
local PlayerDropdown = Tabs.Main:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Values = GetPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(Value)
        print("Selected:", Value)
    end
})

local MultiTargetDropdown = Tabs.Main:AddDropdown("TargetPlayersDropdown", {
    Title = "Select Players",
    Values = GetPlayerNames(),
    Multi = true,
    Default = {},
    Callback = function(Value)
        local values = {}
        for name, selected in pairs(Value) do
            if selected then
                table.insert(values, name)
            end
        end
        print("Selected:", table.concat(values, ", "))
    end
})

-------\\ Components //-------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Notify("Script has been loaded.")
