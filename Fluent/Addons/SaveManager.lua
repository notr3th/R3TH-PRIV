local HttpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "R3TH PRIV"
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if (not name) then
			return false, "No configuration file is specified."
		end

		local fullPath = self.Folder .. "/settings/" .. name .. ".json"

		local data = {
			objects = {}
		}

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
		if not success then
			return false, "Failed to encode data."
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if (not name) then
			return false, "No configuration file is specified."
		end
		
		local file = self.Folder .. "/settings/" .. name .. ".json"
		if not isfile(file) then return false, "Invalid file." end

		local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
		if not success then return false, "Failed to decode data." end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind"
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. "/settings"
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. "/settings")

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == ".json" then
				local pos = file:find(".json", 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= "/" and char ~= "\\" and char ~= "" do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == "/" or char == "\\" then
					local name = file:sub(pos + 1, start - 1)
					if name ~= "options" then
						table.insert(out, name)
					end
				end
			end
		end
		
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
        self.Options = library.Options
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder .. "/settings/autoload.txt") then
			local name = readfile(self.Folder .. "/settings/autoload.txt")

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify({
					Title = "R3TH PRIV",
					Content = "Configuration Loader",
					SubContent = "Failed to load the autoload configuration: " .. err,
					Duration = 7
				})
			end

			self.Library:Notify({
				Title = "R3TH PRIV",
				Content = "Configuration Loader",
				SubContent = string.format("Successfully auto-loaded: %q", name),
				Duration = 7
			})
		end
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("Configuration")

		section:AddInput("SaveManager_ConfigName",    { Title = "Configuration name" })
		section:AddDropdown("SaveManager_ConfigList", { Title = "Configuration list", Values = self:RefreshConfigList(), AllowNull = true })

		section:AddButton({
            Title = "Create configuration",
            Callback = function()
                local name = SaveManager.Options.SaveManager_ConfigName.Value

                if name:gsub(" ", "") == "" then 
                    return self.Library:Notify({
						Title = "R3TH PRIV",
						Content = "Configuration Loader",
						SubContent = "The configuration cannot have an empty name.",
						Duration = 7
					})
                end

                local success, err = self:Save(name)
                if not success then
                    return self.Library:Notify({
						Title = "R3TH PRIV",
						Content = "Configuration Loader",
						SubContent = "Failed to save configuration: " .. err,
						Duration = 7
					})
                end

				self.Library:Notify({
					Title = "R3TH PRIV",
					Content = "Configuration Loader",
					SubContent = string.format("Successfully created: %q", name),
					Duration = 7
				})

                SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
                SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
            end
        })

        section:AddButton({Title = "Load configuration", Callback = function()
			local name = SaveManager.Options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify({
					Title = "R3TH PRIV",
					Content = "Configuration Loader",
					SubContent = "Failed to load configuration: " .. err,
					Duration = 7
				})
			end

			self.Library:Notify({
				Title = "R3TH PRIV",
				Content = "Configuration Loader",
				SubContent = string.format("Successfully loaded: %q", name),
				Duration = 7
			})
		end})

		section:AddButton({Title = "Overwrite configuration", Callback = function()
			local name = SaveManager.Options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify({
					Title = "R3TH PRIV",
					Content = "Configuration Loader",
					SubContent = "Failed to overwrite configuration: " .. err,
					Duration = 7
				})
			end

			self.Library:Notify({
				Title = "R3TH PRIV",
				Content = "Configuration Loader",
				SubContent = string.format("Successfully overwrote: %q", name),
				Duration = 7
			})
		end})

		section:AddButton({Title = "Delete configuration", Callback = function()
        	local name = SaveManager.Options.SaveManager_ConfigList.Value
        	if not name then
        		return self.Library:Notify({
        			Title = "R3TH PRIV",
        			Content = "Configuration Loader",
        			SubContent = "No configuration selected to delete.",
        			Duration = 7
        		})
        	end
        
        	local file = self.Folder .. "/settings/" .. name .. ".json"
        	if isfile(file) then
        		delfile(file)
        
        		self.Library:Notify({
        			Title = "R3TH PRIV",
        			Content = "Configuration Loader",
        			SubContent = string.format("Successfully deleted: %q", name),
        			Duration = 7
        		})
        
        		SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
        		SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
        
        		if isfile(self.Folder .. "/settings/autoload.txt") and readfile(self.Folder .. "/settings/autoload.txt") == name then
        			delfile(self.Folder .. "/settings/autoload.txt")
        		end
        	else
        		self.Library:Notify({
        			Title = "R3TH PRIV",
        			Content = "Configuration Loader",
        			SubContent = "Configuration file not found.",
        			Duration = 7
        		})
        	end
        end})

		section:AddButton({Title = "Refresh configuration list", Callback = function()
			SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
		end})

		local AutoloadButton
		AutoloadButton = section:AddButton({Title = "Auto-load the specified configuration.", Description = "Current autoload configuration: none", Callback = function()
			local name = SaveManager.Options.SaveManager_ConfigList.Value
			writefile(self.Folder .. "/settings/autoload.txt", name)
			AutoloadButton:SetDesc("Current autoload configuration: " .. name)
			self.Library:Notify({
				Title = "R3TH PRIV",
				Content = "Configuration Loader",
				SubContent = string.format("Set %q to automatically load.", name),
				Duration = 7
			})
		end})

		if isfile(self.Folder .. "/settings/autoload.txt") then
			local name = readfile(self.Folder .. "/settings/autoload.txt")
			AutoloadButton:SetDesc("Current autoload configuration: " .. name)
		end

		SaveManager:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
