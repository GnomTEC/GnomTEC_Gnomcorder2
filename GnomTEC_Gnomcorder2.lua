-- **********************************************************************
-- GnomTEC Gnomcorder2
-- Version: 7.2.0.1
-- Author: Peter Jack
-- URL: http://www.gnomtec.de/
-- **********************************************************************
-- Copyright © 2015-2017 by Peter Jack
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
	["Version"] = "7.2.0.1",
	["Date"] = "2017-04-01",
	["Author"] = "Peter Jack",
	["Email"] = "info@gnomtec.de",
	["Website"] = "http://www.gnomtec.de/",
	["Copyright"] = "© 2015-2017 by Peter Jack",
	["License"] = "European Union Public Licence (EUPL v.1.1)",	
	["FrameworkRevision"] = 9
}

-- ----------------------------------------------------------------------
-- Addon Global Constants (local)
-- ----------------------------------------------------------------------
-- Class levels
local CLASS_BASE	= 0
local CLASS_CLASS	= 1
local CLASS_WIDGET	= 2
local CLASS_ADDON	= 3

-- Log levels
local LOG_FATAL = 0
local LOG_ERROR	= 1
local LOG_WARN	= 2
local LOG_INFO 	= 3
local LOG_DEBUG = 4

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
	local radio = GnomTECGnomcorder2Radio(self, "Radio channel 1")
	
	-- private methods
	-- local function f()

	-- protected methods
	-- function protected.f()
	function protected.OnInitialize()
	 	-- Code that you want to run when the addon is first loaded goes here.
	 	radio.OnInitialize()
	end

	function protected.OnEnable()
  	  -- Called when the addon is enabled
				
		addonDataObject = self.NewDataObject("", addonDataObject)

	 	radio.OnEnable()

		self.ShowMinimapIcon(addonDataObject)
	end

	function protected.OnDisable()
		-- Called when the addon is disabled
	 	radio.OnDisable()
	end
	
	-- public methods
	-- function self.f()
	function self.SwitchMainWindow(show)
		radio.SwitchMainWindow(show)
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
