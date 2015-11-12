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
		
		data.message = "Dies ist ein Test"
		data.maxDistance = "1000"
		if (posX) then
			data.position = {
				posX = posX,
				posY = posY,
				posZ = posZ,
				terrainMapID = terrainMapID
			}
		end
		
		self.Broadcast(data, "WHISPER", player);
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
		
		mainWindowWidgets.mainWindowReceive.AddMessage(string.format("[%s](%i GDE): %s", sender, distance or -1, data.message or "..."))
	end
	
	function self.SwitchMainWindow(show)
		if (not mainWindowWidgets) then
			mainWindowWidgets = {}
			mainWindowWidgets.mainWindow = GnomTECWidgetContainerWindow({title="GnomTEC Gnomcorder2", name="Main", db=self.db})
			mainWindowWidgets.mainWindowLayout = mainWindowWidgets.mainWindow
			
			mainWindowWidgets.mainWindowLayoutFunctions = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayout})
			mainWindowWidgets.mainWindowTopSpacer = GnomTECWidgetSpacer({parent=mainWindowWidgets.mainWindowLayoutFunctions, minHeight=34, minWidth=50})
			mainWindowWidgets.mainWindowSend = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutFunctions, label="Send Broadcast"})
			mainWindowWidgets.mainWindowSend.OnClick = OnClickMainWindowSend
			mainWindowWidgets.mainWindowReceive = GnomTECWidgetScrollingMessage({parent=mainWindowWidgets.mainWindowLayoutFunctions})			
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
