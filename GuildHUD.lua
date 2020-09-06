
GuildHUDOptions = {};

local guildHUDFrame = CreateFrame("Frame", "GuildHUDFrame", UIParent);

guildHUDFrame:SetMovable(true)
guildHUDFrame:EnableMouse(true)
guildHUDFrame:RegisterForDrag("LeftButton")
guildHUDFrame:SetSize(160, 20)
guildHUDFrame:SetPoint("TOPLEFT", UIParent)

local function guildHudStartMoving()
  if not guildHUDFrame:IsMovable() then
    return
  end
  guildHUDFrame:StartMoving()
end

guildHUDFrame:SetScript("OnDragStart", guildHudStartMoving)
guildHUDFrame:SetScript("OnDragStop", guildHUDFrame.StopMovingOrSizing)

local showExtra = false
local myFont = GameFontNormal:GetFont();
local guildHudConfiguration = nil
local line = guildHUDFrame:CreateTexture()
local textStrings = {}
textStrings[1] = guildHUDFrame:CreateFontString("tableString" .. 1, "OVERLAY");


local function updateGuild()
  if not IsInGuild() then
    return
  end

	GuildRoster()
  local guildName = GetGuildInfo("player")
  if guildName then
    textStrings[1]:SetFont(myFont, SavedFontSize + 2, "NONE");
    textStrings[1]:SetJustifyH("LEFT")
    textStrings[1]:SetPoint("TOPLEFT", guildHUDFrame, "TOPLEFT", 0, 0);
    textStrings[1]:SetTextColor(.24, .88, .24, .85);
    textStrings[1]:SetFormattedText(guildName); 
    guildHUDFrame:SetSize(textStrings[1]:GetStringWidth(), textStrings[1]:GetStringHeight())
    
    line:SetColorTexture(.24, .88, .24, .5)
    line:SetSize(textStrings[1]:GetStringWidth(), 1)
    line:SetPoint("TOPLEFT", guildHUDFrame, "TOPLEFT", 0, 2-textStrings[1]:GetStringHeight())      
  end

	local j = 2;
	local totalMembers = GetNumGuildMembers()
	for i = 1, totalMembers do
		local name, rank, rankIndex, level, _, zone, note, officernote, connected, memberstatus, class, _, _, isMobile = GetGuildRosterInfo(i)
		if name and zone then
			if connected then
        if not textStrings[j] then
          textStrings[j] = guildHUDFrame:CreateFontString("tableString" .. i, "OVERLAY")
          textStrings[j]:SetFont(myFont, SavedFontSize, "NONE");
          textStrings[j]:SetJustifyH("LEFT")
        end
				local a,b = string.find(name, "-")
				local name = string.sub(name, 1, a-1)
				textStrings[j]:SetPoint("TOPLEFT", guildHUDFrame, "TOPLEFT", 1, -4-(j-1)*(SavedFontSize+2));

				local classColor = RAID_CLASS_COLORS[class]
				textStrings[j]:SetTextColor(classColor.r, classColor.g, classColor.b, .95);

				if (string.len(SavedIgnoreText) > 0 and string.match(note, SavedIgnoreText)) or string.len(note) == 0 then
					note = ""
				else 
					note = " (" .. note .. ")"
				end
        
        if showExtra then
          name = name .. note .. " - " .. zone
        else
          if SavedNotesSwitch then
            name = name .. note
          end
          if SavedLocationSwitch then
            name = name .. " - " .. zone
          end
        end

				textStrings[j]:SetText(name);

				j=j+1;
			end
		end
	end

	-- clear the rest of the list
	for k = j, #textStrings do
		textStrings[k]:SetText("")
	end
end

local function heartbeat()
	updateGuild()
	C_Timer.After(2, heartbeat)
end
C_Timer.After(2, heartbeat)


local function guildHudCreateConfiguration(frame, level, menuList, topLevel)
  local info = UIDropDownMenu_CreateInfo()
  info.owner = frame
  info.isNotRadio = true
    
  if level == 1 then
    info.text = "HUD Locked"
    info.checked = SavedLockSwitch
    info.func = function(info) 
      SavedLockSwitch = not SavedLockSwitch 
      guildHUDFrame:SetMovable(not SavedLockSwitch)
      --guildHUDFrame:EnableMouse(not SavedLockSwitch)
    end
    UIDropDownMenu_AddButton(info, level)	
    
    info.text = "Guild notes shown"
    info.checked = SavedNotesSwitch
    info.func = function(info) 
      SavedNotesSwitch = not SavedNotesSwitch
      updateGuild() 
    end
    UIDropDownMenu_AddButton(info, level)	
    
    info.text = "Location shown"
    info.checked = SavedLocationSwitch
    info.func = function(info) 
      SavedLocationSwitch = not SavedLocationSwitch
      updateGuild() 
    end
    UIDropDownMenu_AddButton(info, level)	    
    
    info.text = "Ignore text..."
    info.notCheckable = true
    info.func = function(info) StaticPopup_Show("GUILDHUDIGNORETEXT") end
    UIDropDownMenu_AddButton(info, level)	
  
    info.notCheckable = true
    info.text = "Font size"
    info.hasArrow = true
    info.menuList = "font"
    UIDropDownMenu_AddButton(info)
    
  elseif menuList == "font" then
    info.notCheckable = false
    info.isNotRadio = false
    
    info.text = "Tiny"
    info.checked = SavedFontSize == 8
    info.func = function(info) SavedFontSize = 8; updateGuild() end
    UIDropDownMenu_AddButton(info, level)
    info.text = "Small"
    info.checked = SavedFontSize == 11
    info.func = function(info) SavedFontSize = 11; updateGuild() end
    UIDropDownMenu_AddButton(info, level)
    info.text = "Medium"
    info.checked = SavedFontSize == 14
    info.func = function(info) SavedFontSize = 14; updateGuild() end
    UIDropDownMenu_AddButton(info, level)
    info.text = "Large"
    info.checked = SavedFontSize == 17
    info.func = function(info) SavedFontSize = 17; updateGuild() end
    UIDropDownMenu_AddButton(info, level)
    info.text = "Huge"
    info.checked = SavedFontSize == 20
    info.func = function(info) SavedFontSize = 20; updateGuild() end
    UIDropDownMenu_AddButton(info, level)
  end
end

local function guildHudConfigurationMenu()
	if not guildHudConfiguration then
		guildHudConfiguration = CreateFrame("Frame", "GuildHudOptionsMenu", button, "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(guildHudConfiguration, guildHudCreateConfiguration, "MENU")
	end
  guildHudConfiguration:SetParent(guildHUDFrame)
	ToggleDropDownMenu(1, nil, guildHudConfiguration, "cursor", 3, -3)
end


function initialize()
  StaticPopupDialogs["GUILDHUDIGNORETEXT"] = {
    text = "Ignore notes with the following text:",
    button1 = "OK",
    button2 = "Cancel",
    OnShow = function (self, data)
      self.editBox:SetText(SavedIgnoreText)
    end,
    OnAccept = function (self, data, data2)
        SavedIgnoreText = self.editBox:GetText()
        updateGuild()
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }
  
  guildHUDFrame:SetMovable(not SavedLockSwitch)
  guildHUDFrame:SetScript("OnMouseUp", function (self, button)
    if button=='RightButton' then 
        guildHudConfigurationMenu()
    end
  end)
end


function guildHUDFrame:OnEvent(event, arg1)
	if event == "PLAYER_LOGIN" then
		--print ("loaded")
		if SavedFontSize == nil then
			SavedFontSize = 11
		end
		if SavedNotesSwitch == nil then
			SavedNotesSwitch = true
		end
		if SavedNotesSwitch == nil then
			SavedLockSwitch = false
		end    
		if SavedIgnoreText == nil then
			SavedIgnoreText = ""
		end   
    
		initialize()
		updateGuild()
    guildHUDFrame:UnregisterEvent("PLAYER_LOGIN");
	end
  
  if event == "PLAYER_LOGOUT" then
    guildHUDFrame:SetMovable(true)
  end

	if event == "GUILD_ROSTER_UPDATE" then
		updateGuild()
	end
end

guildHUDFrame:RegisterEvent("PLAYER_LOGIN");
guildHUDFrame:RegisterEvent("PLAYER_LOGOUT");
guildHUDFrame:RegisterEvent("GUILD_ROSTER_UPDATE");

guildHUDFrame:SetScript("OnEnter", function() showExtra = true; updateGuild() end )
guildHUDFrame:SetScript("OnLeave", function() showExtra = false; updateGuild() end )
guildHUDFrame:SetScript("OnEvent", guildHUDFrame.OnEvent);

