-- **********************************************************************
-- GnomTEC Gnomcorder2
-- Version: 6.2.3.1
-- Author: Peter Jack
-- URL: http://www.gnomtec.de/
-- **********************************************************************
-- Copyright © 2015 by Peter Jack
--
-- Licensed under the EUPL, Version 1.1 only (the "Licence");
-- You may not use this work except in compliance with the Licence.
-- You may obtain a copy of the Licence at:
--
-- http://ec.europa.eu/idabc/eupl5
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the Licence is distributed on an "AS IS" basis,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Licence for the specific language governing permissions and
-- limitations under the Licence.
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Gnomcorder2")

-- ----------------------------------------------------------------------
-- Addon Info Constants (local)
-- ----------------------------------------------------------------------
-- addonInfo for addon registration to GnomTEC API
local addonInfo = {
	["Name"] = "GnomTEC Gnomcorder2",
	["Description"] = "GnomTEC Gnomcorder Series II.",	
	["Version"] = "6.2.3.1",
	["Date"] = "2015-11-20",
	["Author"] = "Peter Jack",
	["Email"] = "info@gnomtec.de",
	["Website"] = "http://www.gnomtec.de/",
	["Copyright"] = "© 2015 by Peter Jack",
	["License"] = "European Union Public Licence (EUPL v.1.1)",	
	["FrameworkRevision"] = 3
}

-- ----------------------------------------------------------------------
-- Addon Global Constants (local)
-- ----------------------------------------------------------------------
-- Class levels
local CLASS_BASE		= 0
local CLASS_CLASS		= 1
local CLASS_WIDGET	= 2
local CLASS_ADDON		= 3

-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Addon Static Variables (local)
-- ----------------------------------------------------------------------
local addonDataObject =	{
	type = "data source",
	text = "0 warnings",
	value = "0",
	suffix = "warning(s)",
	label = "GnomTEC Gnomcorder2",
	icon = [[Interface\Icons\Inv_Misc_Tournaments_banner_Gnome]],
	OnClick = function(self, button)
		GnomTEC_Gnomcorder2.SwitchMainWindow()
	end,
	OnTooltipShow = function(tooltip)
		GnomTEC_Gnomcorder2.ShowAddonTooltip(tooltip)
	end,
}

-- ----------------------------------------------------------------------
-- Addon Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------
-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

local function fullunitname(unitName)
	if (nil ~= emptynil(unitName)) then
		local player, realm = strsplit( "-", unitName, 2 )
		if (not realm) then
			_,realm = UnitFullName("player")
		end
		unitName = player.."-"..realm
	end
	return unitName
end

local function getCustomChannelName(channelNumber)
	for i=1,GetNumDisplayChannels() do
   	name, header, collapsed, number, count, active, category, voiceEnabled, voiceActive = GetChannelDisplayInfo(i)
		if ((channelNumber == number) and (category == "CHANNEL_CATEGORY_CUSTOM")) then
      	return name
    	end
  	end
   return nil
end

local function getCustomChannelNumber(channelName)
	for i=1,GetNumDisplayChannels() do
		name, header, collapsed, number, count, active, category, voiceEnabled, voiceActive = GetChannelDisplayInfo(i)
    	if ((strupper(name) == strupper(channelName)) and (category == "CHANNEL_CATEGORY_CUSTOM")) then
      	return number
    	end
  	end
	return nil
end

-- ----------------------------------------------------------------------
-- Addon Class
-- ----------------------------------------------------------------------

local function GnomTECGnomcorder2()
	-- call base class
	local self, protected = GnomTECAddon("GnomTEC_Gnomcorder2", addonInfo)
	
	-- when we got nil from base class there is a major issue and we will stop here.
	-- GnomTEC framework will inform the user by itself about the issue.
	if (nil == self) then
		return self
	end
	
	-- public fields go in the instance table
	-- self.field = value
	
	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local mainWindowWidgets = nil
	local isOn = false

	local chat = GnomTECClassChat();
	
	-- private methods
	-- local function f()
	local function OnClickmainWindowSwitchOnOff(widget, button)
		isOn = mainWindowWidgets.mainWindowSwitchOnOff.IsOn()
		if isOn then
			mainWindowWidgets.mainWindowLEDOnOff.On()
			mainWindowWidgets.mainWindowFrequence.On()

			local channelNumber, code
			local channelName

			channelNumber = 0			
			code = 0
		
			for t=1, 4 do
				if mainWindowWidgets.mainWindowSwitchFrequence[tostring(t)].IsOn() then
					mainWindowWidgets.mainWindowLEDFrequence[tostring(t)].On()
					channelNumber = channelNumber + 2^(4-t)
				else
					mainWindowWidgets.mainWindowLEDFrequence[tostring(t)].Off()
				end
			end		

			if (channelNumber <= 10) then
				channelName = getCustomChannelName(channelNumber)
			else
				 local groups = {"<<GUILD>>", "<<OFFICER>>" , "<<PARTY>>", "<<RAID>>", "<<INSTANCE_CHAT>>"}
				 channelName = groups[channelNumber-10]
			end

			for t=5, 10 do
				if mainWindowWidgets.mainWindowSwitchFrequence[tostring(t)].IsOn() then
					mainWindowWidgets.mainWindowLEDFrequence[tostring(t)].On()
					code = code + 2^(10-t)
				else
					mainWindowWidgets.mainWindowLEDFrequence[tostring(t)].Off()
				end
			end		
			mainWindowWidgets.mainWindowFrequence.SetText((channelName or "<<INVALID>>").."-"..code)
			
			if mainWindowWidgets.mainWindowSwitchMic.IsOn() then
				mainWindowWidgets.mainWindowLEDMic.On()
				isMicOn = true
			else
				mainWindowWidgets.mainWindowLEDMic.Off()
				isMicOn = false
			end
			
		else
			mainWindowWidgets.mainWindowLEDOnOff.Off()
			mainWindowWidgets.mainWindowFrequence.Off()
			for t=1, 10 do
				mainWindowWidgets.mainWindowLEDFrequence[tostring(t)].Off()
			end
			mainWindowWidgets.mainWindowLEDMic.Off()
		end
	end

	local function OnClickmainWindowSwitchFrequence(widget, button)
		if (isOn) then
			label = widget.GetLabel()
			if (label) then
				if mainWindowWidgets.mainWindowSwitchFrequence[label].IsOn() then
					mainWindowWidgets.mainWindowLEDFrequence[label].On()
				else
					mainWindowWidgets.mainWindowLEDFrequence[label].Off()
				end
			end
			
			local channelNumber, code
			local channelName

			channelNumber = 0			
			code = 0
		
			for t=1, 4 do
				if mainWindowWidgets.mainWindowSwitchFrequence[tostring(t)].IsOn() then
					channelNumber = channelNumber + 2^(4-t)
				end
			end		
			if (channelNumber <= 10) then
				channelName = getCustomChannelName(channelNumber)
			else
				 local groups = {"<<GUILD>>", "<<OFFICER>>" , "<<PARTY>>", "<<RAID>>", "<<INSTANCE_CHAT>>"}
				 channelName = groups[channelNumber-10]
			end

			for t=5, 10 do
				if mainWindowWidgets.mainWindowSwitchFrequence[tostring(t)].IsOn() then
					code = code + 2^(10-t)
				end
			end		

			mainWindowWidgets.mainWindowFrequence.SetText((channelName or "<<INVALID>>").."-"..code)
		end
	end

	local function OnClickmainWindowSwitchMic(widget, button)
		if (isOn) then
			if mainWindowWidgets.mainWindowSwitchMic.IsOn() then
				mainWindowWidgets.mainWindowLEDMic.On()
				isMicOn = true
			else
				mainWindowWidgets.mainWindowLEDMic.Off()
				isMicOn = false
			end
		end
	end
	
	local function Broadcast(message)
		if (not isOn) or (not isMicOn) then
			return
		end
		
		local player = UnitName("player")
		local character = GnomTECClassCharacter(player);	
		local	posX, posY, posZ, terrainMapID = character.GetPosition()
		local data = {}
		local channelName, code = strsplit("-", mainWindowWidgets.mainWindowFrequence.GetText())
		local ChannelNumber = getCustomChannelNumber(channelName)	
		data.frequence = mainWindowWidgets.mainWindowFrequence.GetText()
		data.message = message
			
		data.maxDistance = "1000"
		if (posX) then
			data.position = {
				posX = posX,
				posY = posY,
				posZ = posZ,
				terrainMapID = terrainMapID
			}
		end

		if (ChannelNumber) then
			self.Broadcast(data, "CHANNEL", tostring(ChannelNumber));
		else
			local channel = string.match(channelName,"<<[%a_]+>>")
			if (channel and (channel ~= "<<INVALID>>")) then
				local distribution = string.match(channel,"[%a_]+")
				self.Broadcast(data, distribution, nil)
			end 
		end
	end
	
	-- protected methods
	-- function protected.f()
	function protected.OnInitialize()
	 	-- Code that you want to run when the addon is first loaded goes here.
	end

	function protected.OnEnable()
  	  -- Called when the addon is enabled
				
		addonDataObject = self.NewDataObject("", addonDataObject)
		
		self.ShowMinimapIcon(addonDataObject)
	end

	function protected.OnDisable()
		-- Called when the addon is disabled
	end
	
	-- public methods
	-- function self.f()
	function self.OnBroadcast(data, sender)
		if (not isOn) then
			return
		end

		local character = GnomTECClassCharacter(sender);
		local distance
		
		if (data.position) then
			character.SetPosition(data.position.posX, data.position.posY, data.position.posZ, data.position.terrainMapID)
		end		
		distance = character.GetDistance()
		
		if (strupper(data.frequence or "") == strupper(mainWindowWidgets.mainWindowFrequence.GetText())) then
			chat.LocalMonsterWhisper(string.format("[Gnomcorder] [%s]:(%i GDE): %s", sender, distance or -1, data.message or "..."), sender)
		end
	end
	
	function chat.OnSay(message, sender)
		sender = fullunitname(sender)
		if (sender == fullunitname(UnitName("player"))) then
			Broadcast(message)
		end
	end

	function chat.OnWhisper(message, sender)
		sender = fullunitname(sender)
		if (sender == fullunitname(UnitName("player"))) then
			Broadcast(message)
		end
	end

	function self.SwitchMainWindow(show)
		if (not mainWindowWidgets) then
			mainWindowWidgets = {}
			mainWindowWidgets.mainWindow = GnomTECWidgetContainerDevice({title="GnomTEC Gnomcorder2", name="Main", db=self.db})
			mainWindowWidgets.mainWindowLayout = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindow})

			mainWindowWidgets.mainWindowLayoutTop = GnomTECWidgetContainerLayoutHorizontal({parent=mainWindowWidgets.mainWindowLayout})

			mainWindowWidgets.mainWindowLayoutOnOff = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayoutTop, width="1%"})
			mainWindowWidgets.mainWindowPlaqueOnOff = GnomTECWidgetDevicePlaque({parent=mainWindowWidgets.mainWindowLayoutOnOff, text="On"})
			mainWindowWidgets.mainWindowLayoutSwitchFieldOnOff = GnomTECWidgetContainerLayoutHorizontal({parent=mainWindowWidgets.mainWindowLayoutOnOff})
			mainWindowWidgets.mainWindowSwitchesSpacer1 = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayoutSwitchFieldOnOff, width="50%"})	
			mainWindowWidgets.mainWindowLayoutSwitchOnOff = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayoutSwitchFieldOnOff})
			mainWindowWidgets.mainWindowSwitchOnOff= GnomTECWidgetDeviceSwitch({parent=mainWindowWidgets.mainWindowLayoutSwitchOnOff, on=false})
			mainWindowWidgets.mainWindowSwitchOnOff.OnClick = OnClickmainWindowSwitchOnOff
			mainWindowWidgets.mainWindowLEDOnOff= GnomTECWidgetDeviceLED({parent=mainWindowWidgets.mainWindowLayoutSwitchOnOff, on=false})
			mainWindowWidgets.mainWindowSwitchesSpacer2 = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayoutSwitchFieldOnOff, width="50%"})	

			mainWindowWidgets.mainWindowLayoutFrequence = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayoutTop})
			mainWindowWidgets.mainWindowMessagePlaqueFrequence = GnomTECWidgetDevicePlaque({parent=mainWindowWidgets.mainWindowLayoutFrequence, text="Frequence settings"})
			mainWindowWidgets.mainWindowLayoutSwitches = GnomTECWidgetContainerLayoutHorizontal({parent=mainWindowWidgets.mainWindowLayoutFrequence})
			mainWindowWidgets.mainWindowSwitchesSpacer3 = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayoutSwitches, width="50%"})	
			mainWindowWidgets.mainWindowLayoutSwitchFrequence = {}
			mainWindowWidgets.mainWindowSwitchFrequence = {}
			mainWindowWidgets.mainWindowLEDFrequence = {}			
			for t=1, 10 do
				mainWindowWidgets.mainWindowLayoutSwitchFrequence[tostring(t)] = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayoutSwitches})
				mainWindowWidgets.mainWindowSwitchFrequence[tostring(t)] = GnomTECWidgetDeviceSwitch({parent=mainWindowWidgets.mainWindowLayoutSwitchFrequence[tostring(t)], label=tostring(t), on=false})
				mainWindowWidgets.mainWindowSwitchFrequence[tostring(t)].OnClick = OnClickmainWindowSwitchFrequence
				mainWindowWidgets.mainWindowLEDFrequence[tostring(t)]= GnomTECWidgetDeviceLED({parent=mainWindowWidgets.mainWindowLayoutSwitchFrequence[tostring(t)], on=false})
			end		
			mainWindowWidgets.mainWindowSwitchesSpacer4 = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayoutSwitches, width="50%"})	

			mainWindowWidgets.mainWindowFrequence = GnomTECWidgetDeviceNixie({parent=mainWindowWidgets.mainWindowLayout, text="-----", length="25", on=false})			

			mainWindowWidgets.mainWindowLayoutBottom = GnomTECWidgetContainerLayoutHorizontal({parent=mainWindowWidgets.mainWindowLayout})
			mainWindowWidgets.mainWindowLayoutMic = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayoutBottom, width="1%"})
			mainWindowWidgets.mainWindowPlaqueMic = GnomTECWidgetDevicePlaque({parent=mainWindowWidgets.mainWindowLayoutMic, text="Microfone"})
			mainWindowWidgets.mainWindowLayoutSwitchFieldMic = GnomTECWidgetContainerLayoutHorizontal({parent=mainWindowWidgets.mainWindowLayoutMic})
			mainWindowWidgets.mainWindowSwitchesSpacer5 = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayoutSwitchFieldMic, width="50%"})	
			mainWindowWidgets.mainWindowLayoutSwitchMic = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayoutSwitchFieldMic})
			mainWindowWidgets.mainWindowSwitchMic = GnomTECWidgetDeviceSwitch({parent=mainWindowWidgets.mainWindowLayoutSwitchMic, on=false})
			mainWindowWidgets.mainWindowSwitchMic.OnClick = OnClickmainWindowSwitchMic
			mainWindowWidgets.mainWindowLEDMic = GnomTECWidgetDeviceLED({parent=mainWindowWidgets.mainWindowLayoutSwitchMic, on=false})
			mainWindowWidgets.mainWindowSwitchesSpacer6 = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayoutSwitchFieldMic, width="50%"})	

		end
		
		if (nil == show) then
			if mainWindowWidgets.mainWindow.IsShown() then
				mainWindowWidgets.mainWindow.Hide()
			else
				mainWindowWidgets.mainWindow.Show()
			end
		else
			if show then
				mainWindowWidgets.mainWindow.Show()
			else
				mainWindowWidgets.mainWindow.Hide()
			end
		end
	end
	
		
	function	self.ShowAddonTooltip(tooltip)
		tooltip:AddLine("GnomTEC Gnomcorder2 Informationen",1.0,1.0,1.0)
		tooltip:AddLine(" ")
		tooltip:AddLine("Goldkraftkern fast leer",1.0,1.0,1.0)
	end
	
	-- constructor
	do
		self.SwitchMainWindow(false)
		self.LogMessage(LOG_INFO, "Willkommen bei GnomTEC Gnomcorder2")
	end
	
	-- return the instance table
	return self
end

-- ----------------------------------------------------------------------
-- Addon Instantiation
-- ----------------------------------------------------------------------

GnomTEC_Gnomcorder2 = GnomTECGnomcorder2()
