-- **********************************************************************
-- GnomTEC Gnomcorder2
-- Version: 6.2.2.1
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
	["Version"] = "6.2.2.1",
	["Date"] = "2015-11-07",
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
local function getChannelId(channel,...)

   for i = 1, select("#", ...), 2 do
     local id, name = select(i, ...)
		if (strupper(name) == strupper(channel)) then
			return id
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

	-- private methods
	-- local function f()
	local function OnClickMainWindowSend(widget, button)
		local player = UnitName("player")
		local character = GnomTECClassCharacter(player);	
		local	posX, posY, posZ, terrainMapID = character.GetPosition()
		local data = {}
		local channelName, code = strsplit("-", mainWindowWidgets.mainWindowFrequence.GetText())
		local channelId = getChannelId(channelName,GetChannelList())
		
		self.LogMessage(LOG_DEBUG,"%i %s %s", channelId or -1, channelName or "?", code or "?")
		if (channelId) then
			data.frequence = mainWindowWidgets.mainWindowFrequence.GetText()
			data.message = mainWindowWidgets.mainWindowMessage.GetText()
			mainWindowWidgets.mainWindowMessage.SetText("")
			
			data.maxDistance = "1000"
			if (posX) then
				data.position = {
					posX = posX,
					posY = posY,
					posZ = posZ,
					terrainMapID = terrainMapID
				}
			end
		
			self.Broadcast(data, "CHANNEL", tostring(channelId));
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
		local character = GnomTECClassCharacter(sender);
		local distance
		
		if (data.position) then
			character.SetPosition(data.position.posX, data.position.posY, data.position.posZ, data.position.terrainMapID)
		end		
		distance = character.GetDistance()
		
		if (strupper(data.frequence or "") == strupper(mainWindowWidgets.mainWindowFrequence.GetText())) then
			mainWindowWidgets.mainWindowReceive.AddMessage(string.format("[%s](%i GDE): %s", sender, distance or -1, data.message or "..."))
		end
	end
	
	function self.SwitchMainWindow(show)
		if (not mainWindowWidgets) then
			mainWindowWidgets = {}
			mainWindowWidgets.mainWindow = GnomTECWidgetContainerWindow({title="GnomTEC Gnomcorder2", name="Main", db=self.db})
			mainWindowWidgets.mainWindowLayout = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindow})
			mainWindowWidgets.mainWindowTopSpacer = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayout, minHeight=34, minWidth=50})
			mainWindowWidgets.mainWindowFrequenceLabel = GnomTECWidgetText({parent=mainWindowWidgets.mainWindowLayout, text="Frequence:", height="0%"})
			mainWindowWidgets.mainWindowFrequence = GnomTECWidgetEditBox({parent=mainWindowWidgets.mainWindowLayout, text="gvgg-0815", multiLine=false})			
			mainWindowWidgets.mainWindowMessageLabel = GnomTECWidgetText({parent=mainWindowWidgets.mainWindowLayout, text="Message:", height="0%"})
			mainWindowWidgets.mainWindowMessage = GnomTECWidgetEditBox({parent=mainWindowWidgets.mainWindowLayout, multiLine=false})			
			mainWindowWidgets.mainWindowSend = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayout, label="Send Broadcast"})
			mainWindowWidgets.mainWindowSend.OnClick = OnClickMainWindowSend
			mainWindowWidgets.mainWindowReceive = GnomTECWidgetScrollingMessage({parent=mainWindowWidgets.mainWindowLayout, height="100%"})			
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
