-------\\ Variables //-------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerDropdown, MultiTargetDropdown

--[[
    You may swap these three links back to the original ones, it will not break my dropdown refresh fix, I'm only using them because I slightly modified them for my script.

    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
]]
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/R3THdev/R3TH-PRIV/refs/heads/main/Fluent/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/R3THdev/R3TH-PRIV/refs/heads/main/Fluent/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/R3THdev/R3TH-PRIV/refs/heads/main/Fluent/Addons/InterfaceManager.lua"))()

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

local function refreshDropdowns()
    local newList = GetPlayerNames()
    PlayerDropdown:SetValues(newList)
    MultiTargetDropdown:SetValues(newList)
end

-------\\ Connections //-------
Players.PlayerAdded:Connect(refreshDropdowns)
Players.PlayerRemoving:Connect(refreshDropdowns)

-------\\ Main //-------
PlayerDropdown = Tabs.Main:AddDropdown("PlayerDropdown", {
    Title = "Teleport to Player",
    Values = GetPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(Value)
        print("Selected:", Value)
    end
})

MultiTargetDropdown = Tabs.Main:AddDropdown("TargetPlayersDropdown", {
    Title = "Target Players",
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

refreshDropdowns()
Notify("Script loaded successfully.")
