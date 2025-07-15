local HttpService = game:GetService("HttpService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "R3TH PRIV"
    InterfaceManager.Settings = {
        Theme = "Darker",
        Acrylic = false,
        Transparency = false,
        MenuKeybind = "LeftControl"
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library
	end

    function InterfaceManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split("/")
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end

		table.insert(paths, self.Folder)
		table.insert(paths, self.Folder .. "/settings")

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function InterfaceManager:SaveSettings()
        writefile(self.Folder .. "/options.json", HttpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library.")
		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

		tab:AddParagraph({
            Title = "Credits",
            Content = "Scripting: R3THdev\nInterface: dawid"
        })

		local section = tab:AddSection("Interface")

		local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
			Title = "Theme",
			Description = "Changes the interface's theme.",
			Values = Library.Themes,
			Default = Settings.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
			end
		})

        InterfaceTheme:SetValue(Settings.Theme)
	
		if Library.UseAcrylic then
			section:AddToggle("AcrylicToggle", {
				Title = "Acrylic",
				Description = "Acrylic requires graphic quality 8+.",
				Default = Settings.Acrylic,
				Callback = function(Value)
					Library:ToggleAcrylic(Value)
                    Settings.Acrylic = Value
                    InterfaceManager:SaveSettings()
				end
			})
		end
	
		section:AddToggle("TransparentToggle", {
			Title = "Transparency",
			Description = "Makes the interface semi-transparent.",
			Default = Settings.Transparency,
			Callback = function(Value)
				Library:ToggleTransparency(Value)
				Settings.Transparency = Value
                InterfaceManager:SaveSettings()
			end
		})

		local ButtonToggle
        local ToggleButtonGui
        
        local function createToggleButton()
        	if ToggleButtonGui then return end
        
        	ToggleButtonGui = Instance.new("ScreenGui")
        	ToggleButtonGui.Name = "ScreenGui"
        	ToggleButtonGui.ResetOnSpawn = false
        	ToggleButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        	local button = Instance.new("TextButton")
        	button.Name = "TextButton"
        	button.Size = UDim2.new(0, 80, 0, 30)
        	button.Position = UDim2.new(0, 10, 0, 10)
        	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        	button.TextColor3 = Color3.fromRGB(255, 255, 255)
        	button.Text = "Toggle UI"
        	button.Parent = ToggleButtonGui
        
        	button.Active = true
        	button.Draggable = true
        
        	button.MouseButton1Click:Connect(function()
        		Library:Toggle()
        	end)
        
        	ToggleButtonGui.Parent = game:GetService("CoreGui")
        end
        
        local function removeToggleButton()
        	if ToggleButtonGui then
        		ToggleButtonGui:Destroy()
        		ToggleButtonGui = nil
        	end
        end
        
        ButtonToggle = section:AddToggle("ButtonToggle", {
        	Title = "UI Button Toggle",
        	Description = "Adds a mobile-friendly button to toggle UI",
        	Default = Settings.ButtonToggle or false,
        	Callback = function(Value)
        		Settings.ButtonToggle = Value
        		InterfaceManager:SaveSettings()
        		if Value then
        			createToggleButton()
        		else
        			removeToggleButton()
        		end
        	end
        })
        
        if Settings.ButtonToggle then
        	createToggleButton()
        end
	
		local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
		MenuKeybind:OnChanged(function()
			Settings.MenuKeybind = MenuKeybind.Value
            InterfaceManager:SaveSettings()
		end)
		Library.MinimizeKeybind = MenuKeybind
    end
end

return InterfaceManager
