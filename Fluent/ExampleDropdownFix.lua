-------\\ Variables //-------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Dropdown1, Dropdown2

--[[
    The SaveManager and InterfaceManager links can be switched back to the original versions if preferred.
    I’ve made custom modifications to both for use in my own script, but those changes may not suit everyone.

    I recommend keeping the Fluent link to my modified version.
    It includes an improvement to SetValues for dropdowns: instead of rebuilding the entire list,
    it will only add or remove values that differ from the previous list—greatly improving performance.

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

local function playerList()
    local List = {}
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            table.insert(List, Player.Name)
        end
    end
    return List
end

local function refreshDropdowns()
    local newList = playerList()
    Dropdown1:SetValues(newList)
    Dropdown2:SetValues(newList)
end

-------\\ Connections //-------
Players.PlayerAdded:Connect(refreshDropdowns)
Players.PlayerRemoving:Connect(refreshDropdowns)

-------\\ Main //-------
Dropdown1 = Tabs.Main:AddDropdown("Dropdown1", {
    Title = "Select Player",
    Values = playerList(),
    Multi = false,
    Default = nil,
    Callback = function(Value)
        print("Selected:", Value)
    end
})

Dropdown2 = Tabs.Main:AddDropdown("Dropdown2", {
    Title = "Select Players",
    Values = playerList(),
    Multi = true,
    Default = {},
    Callback = function(Value)
        local Values = {}
        for Name, Selected in pairs(Value) do
            if Selected then
                table.insert(Values, Name)
            end
        end

        print("Selected:", table.concat(Values, ", "))
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
