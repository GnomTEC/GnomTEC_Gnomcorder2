-- **********************************************************************
-- GnomTEC Gnomcorder2 - Radio
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
-- Module Global Constants (local)
-- ----------------------------------------------------------------------
-- Class levels
local CLASS_BASE			= 0
local CLASS_CLASS			= 1
local CLASS_WIDGET		= 2
local CLASS_ADDON			= 3
local CLASS_ADDONMODULE	= 4


-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Module Static Variables (local)
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Module Startup Initialization
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
-- Module Class
-- ----------------------------------------------------------------------

function GnomTECGnomcorder2Radio(addon, moduleIdentifier)
	-- call base class
	local self = GnomTECAddonModule(addon, moduleIdentifier)
		
	-- public fields go in the instance table
	-- self.field = value
	
	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local addon = addon
	local modulTitle = modulTitle
	local widgets = nil
	local isOn = false
	local amplifierMic = nil
	local amplifierRec = nil
	

	local chat = GnomTECClassChat();
	
	-- private methods
	-- local function f()
	local function timer()
		local n

		if (amplifierMic) then
			n = 0
			if (#amplifierMic > 0) then
				n = table.remove(amplifierMic, 1)
			else
				amplifierMic = nil
			end
			
			for t=1, 10 do
				if (t <= n) then
					widgets.amplifierMicLED[tostring(t)].On()
				else
					widgets.amplifierMicLED[tostring(t)].Off()
				end
			end		
		end
		
		if (amplifierRec) then
			n = 0
			if (#amplifierRec > 0) then
				n = table.remove(amplifierRec, 1)
			else
				amplifierRec = nil
			end	
			for t=1, 10 do
				if (t <= n) then
					widgets.amplifierRecLED[tostring(t)].On()
				else
					widgets.amplifierRecLED[tostring(t)].Off()
				end		
			end
		end
	end
	
	local function OnClickOnOffSwitch(widget, button)
		isOn = widgets.onOffSwitch.IsOn()
		if isOn then
			widgets.onOffLED.On()
			widgets.nixie.On()

			local channelNumber, code
			local channelName

			channelNumber = 0			
			code = 0
		
			for t=1, 4 do
				if widgets.frequenceSwitch[tostring(t)].IsOn() then
					widgets.frequenceLED[tostring(t)].On()
					channelNumber = channelNumber + 2^(4-t)
				else
					widgets.frequenceLED[tostring(t)].Off()
				end
			end		

			if (channelNumber <= 10) then
				channelName = getCustomChannelName(channelNumber)
			else
				 local groups = {"<<GUILD>>", "<<OFFICER>>" , "<<PARTY>>", "<<RAID>>", "<<INSTANCE_CHAT>>"}
				 channelName = groups[channelNumber-10]
			end

			for t=5, 10 do
				if widgets.frequenceSwitch[tostring(t)].IsOn() then
					widgets.frequenceLED[tostring(t)].On()
					code = code + 2^(10-t)
				else
					widgets.frequenceLED[tostring(t)].Off()
				end
			end		
			widgets.nixie.SetText((channelName or "<<INVALID>>").."-"..code, 0, 5)
			
			if widgets.micSwitch.IsOn() then
				widgets.micLED.On()
				isMicOn = true
			else
				widgets.micLED.Off()
				isMicOn = false
			end
			
		else
			widgets.onOffLED.Off()
			widgets.nixie.Off()
			for t=1, 10 do
				widgets.frequenceLED[tostring(t)].Off()
				widgets.amplifierMicLED[tostring(t)].Off()
				widgets.amplifierRecLED[tostring(t)].Off()
			end
			widgets.micLED.Off()
		end
	end

	local function OnClickFrequenceSwitch(widget, button)
		if (isOn) then
			label = widget.GetLabel()
			if (label) then
				if widgets.frequenceSwitch[label].IsOn() then
					widgets.frequenceLED[label].On()
				else
					widgets.frequenceLED[label].Off()
				end
			end
			
			local channelNumber, code
			local channelName

			channelNumber = 0			
			code = 0
		
			for t=1, 4 do
				if widgets.frequenceSwitch[tostring(t)].IsOn() then
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
				if widgets.frequenceSwitch[tostring(t)].IsOn() then
					code = code + 2^(10-t)
				end
			end		

			widgets.nixie.SetText((channelName or "<<INVALID>>").."-"..code, 0, 5)
		end
	end

	local function OnClickMicSwitch(widget, button)
		if (isOn) then
			if widgets.micSwitch.IsOn() then
				widgets.micLED.On()
				isMicOn = true
			else
				widgets.micLED.Off()
				for t=1, 10 do
					widgets.amplifierMicLED[tostring(t)].Off()
				end
				isMicOn = false
			end
		end
	end
	
	local function Broadcast(message)
		if (not isOn) or (not isMicOn) then
			return
		end

		amplifierMic = amplifierMic or {}
		for w in string.gmatch(message,"%w+") do
			local n = min(string.len(w), 10)
			for i=0, n, 2 do
				table.insert(amplifierMic, i)
			end
			for i=0, n, 2 do
				table.insert(amplifierMic, n-i)
			end
		end		
		
		local player = UnitName("player")
		local character = GnomTECClassCharacter(player);	
		local	posX, posY, posZ, terrainMapID = character.GetPosition()
		local data = {}
		local channelName, code = strsplit("-", widgets.nixie.GetText())
		local channelNumber = getCustomChannelNumber(channelName)	

		code = tonumber(code)
		data.frequence = widgets.nixie.GetText()
		if (code ~= 0) then
			-- we send the message itself only when code ~= 0 within hidden addonmessage
			data.message = message;
		end
		
		if (posX) then
			data.position = {
				posX = posX,
				posY = posY,
				posZ = posZ,
				terrainMapID = terrainMapID
			}
		end

		if (channelNumber) then
			addon.Broadcast(data, "CHANNEL", tostring(channelNumber));
			if (code == 0) then
				-- we send the message itself as normal chat message if code == 0
				-- this is also a legacy GnomCorder compatibility mode
				message = "!0 "..message
				chat.SendMessage(message, "CHANNEL", tostring(channelNumber))
			end
		else
			local channel = string.match(channelName,"<<[%a_]+>>")
			if (channel and (channel ~= "<<INVALID>>")) then
				local distribution = string.match(channel,"[%a_]+")
				addon.Broadcast(data, distribution, nil)
				if (code == 0) then
					-- we send the message itself as normal chat message if code == 0
					-- this is also a legacy GnomCorder compatibility mode
					message = "!0 "..message
					chat.SendMessage(message, distribution)
				end
			end 
		end
	end
	
	function chat.OnInstance(message, sender)
		if (strfind(message,"^!%d ")) then
			-- Gnomcorder normal chat message (or legacy message)
			local data = {}
			data.frequence = "<<INSTANCE_CHAT>>-0"
			data.message = string.gsub(message,"^!%d ","")	
			self.OnBroadcastEventHandler(nil, "GNOMTEC_COMM_BROADCAST", data, sender)
		end
	end

	function chat.OnChannel(message, sender, channelNumber)
		local channelName = getCustomChannelName(channelNumber)
		if ((channelName) and (strfind(message,"^!%d "))) then
			-- Gnomcorder normal chat message (or legacy message)
			local data = {}
			data.frequence = channelName.."-0"
			data.message = string.gsub(message,"^!%d ","")	
			self.OnBroadcastEventHandler(nil, "GNOMTEC_COMM_BROADCAST", data, sender)
		end
	end

	function chat.OnGuild(message, sender)
		if (strfind(message,"^!%d ")) then
			-- Gnomcorder normal chat message (or legacy message)
			local data = {}
			data.frequence = "<<GUILD>>-0"
			data.message = string.gsub(message,"^!%d ","")	
			self.OnBroadcastEventHandler(nil, "GNOMTEC_COMM_BROADCAST", data, sender)
		end
	end

	function chat.OnOfficer(message, sender)
		if (strfind(message,"^!%d ")) then
			-- Gnomcorder normal chat message (or legacy message)
			local data = {}
			data.frequence = "<<OFFICER>>-0"
			data.message = string.gsub(message,"^!%d ","")	
			self.OnBroadcastEventHandler(nil, "GNOMTEC_COMM_BROADCAST", data, sender)
		end
	end

	function chat.OnParty(message, sender)
		if (strfind(message,"^!%d ")) then
			-- Gnomcorder normal chat message (or legacy message)
			local data = {}
			data.frequence = "<<PARTY>>-0"
			data.message = string.gsub(message,"^!%d ","")	
			self.OnBroadcastEventHandler(nil, "GNOMTEC_COMM_BROADCAST", data, sender)
		end
	end

	function chat.OnRaid(message, sender)
		if (strfind(message,"^!%d ")) then
			-- Gnomcorder normal chat message (or legacy message)
			local data = {}
			data.frequence = "<<RAID>>-0"
			data.message = string.gsub(message,"^!%d ","")	
			self.OnBroadcastEventHandler(nil, "GNOMTEC_COMM_BROADCAST", data, sender)
		end
	end
	
	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.OnBroadcastEventHandler(object, event, data, sender)
		if (not isOn) then
			return
		end

		local character = GnomTECClassCharacter(sender);
		local distance
		
		if (data.position) then
			character.SetPosition(data.position.posX, data.position.posY, data.position.posZ, data.position.terrainMapID)
		end		
		distance = character.GetDistance()
		
		if (data.message) then
			if (strupper(data.frequence or "") == strupper(widgets.nixie.GetText())) then
				amplifierRec = amplifierRec or {}
				for w in string.gmatch(data.message,"%w+") do
					local n = min(string.len(w), 10)
					for i=0, n, 2 do
						table.insert(amplifierRec, i)
					end
					for i=0, n, 2 do
						table.insert(amplifierRec, n-i)
					end
				end		
				chat.LocalMonsterWhisper(string.format("[Gnomcorder] [%s]:(%i GDE): %s", sender, distance or -1, data.message or "..."), sender)
			end
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
		if (not widgets) then
			widgets = {}
			widgets.device = GnomTECWidgetContainerDevice({title=moduleTitle, name=moduleTitle, db=addon.db})
			widgets.layout_1_V = GnomTECWidgetContainerLayoutVertical({parent=widgets.device})

			--
			-- On/Off and frequence settings
			--
			widgets.layout_1_1_H = GnomTECWidgetContainerLayoutHorizontal({parent=widgets.layout_1_V})
			-- On/Off
			widgets.layout_1_1_1_V = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_1_H, width="1%"})
			widgets.plaque_1_1_1_1 = GnomTECWidgetDevicePlaque({parent=widgets.layout_1_1_1_V, text="On"})
			widgets.layout_1_1_1_2_H = GnomTECWidgetContainerLayoutHorizontal({parent=widgets.layout_1_1_1_V})
			widgets.spacer_1_1_1_2_1 = GnomTECWidgetSpacer({parent=widgets.layout_1_1_1_2_H, width="50%"})	
			widgets.layout_1_1_1_2_2_V = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_1_1_2_H})
			widgets.onOffSwitch = GnomTECWidgetDeviceSwitch({parent=widgets.layout_1_1_1_2_2_V, on=false})
			widgets.onOffSwitch.OnClick = OnClickOnOffSwitch
			widgets.onOffLED= GnomTECWidgetDeviceLED({parent=widgets.layout_1_1_1_2_2_V, on=false})
			widgets.spacer_1_1_1_2_3 = GnomTECWidgetSpacer({parent=widgets.layout_1_1_1_2_H, width="50%"})	
			-- frequence settings
			widgets.layout_1_1_2_V = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_1_H})
			widgets.plaque_1_1_2_1 = GnomTECWidgetDevicePlaque({parent=widgets.layout_1_1_2_V, text="Frequence settings"})
			widgets.layout_1_1_2_2_H = GnomTECWidgetContainerLayoutHorizontal({parent=widgets.layout_1_1_2_V})
			widgets.spacer_1_1_2_2_1 = GnomTECWidgetSpacer({parent=widgets.layout_1_1_2_2_H, width="50%"})	
			widgets.layout_1_1_2_2_2_V = {}
			widgets.frequenceSwitch = {}
			widgets.frequenceLED = {}			
			for t=1, 10 do
				widgets.layout_1_1_2_2_2_V[tostring(t)] = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_1_2_2_H})
				widgets.frequenceSwitch[tostring(t)] = GnomTECWidgetDeviceSwitch({parent=widgets.layout_1_1_2_2_2_V[tostring(t)], label=tostring(t), on=false})
				widgets.frequenceSwitch[tostring(t)].OnClick = OnClickFrequenceSwitch
				widgets.frequenceLED[tostring(t)]= GnomTECWidgetDeviceLED({parent=widgets.layout_1_1_2_2_2_V[tostring(t)], on=false})
			end		
			widgets.spacer_1_1_2_2_3 = GnomTECWidgetSpacer({parent=widgets.layout_1_1_2_2_H, width="50%"})	
			
		
			--
			-- Nixie display
			--
			widgets.nixie = GnomTECWidgetDeviceNixie({parent=widgets.layout_1_V, text="-----", length="25", on=false})			

			--
			-- Mic. and amplifiers (Microfone/Receiver)
			--
			widgets.layout_1_2_H = GnomTECWidgetContainerLayoutHorizontal({parent=widgets.layout_1_V})
			-- Mic
			widgets.layout_1_2_1_V = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_2_H, width="1%"})
			widgets.plaque_1_2_1_1 = GnomTECWidgetDevicePlaque({parent=widgets.layout_1_2_1_V, text="Mic"})
			widgets.layout_1_2_1_2_H = GnomTECWidgetContainerLayoutHorizontal({parent=widgets.layout_1_2_1_V})
			widgets.spacer_1_2_1_2_1 = GnomTECWidgetSpacer({parent=widgets.layout_1_2_1_2_H, width="50%"})	
			widgets.layout_1_2_1_2_2_V = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_2_1_2_H})
			widgets.micSwitch = GnomTECWidgetDeviceSwitch({parent=widgets.layout_1_2_1_2_2_V, on=false})
			widgets.micSwitch.OnClick = OnClickMicSwitch
			widgets.micLED= GnomTECWidgetDeviceLED({parent=widgets.layout_1_2_1_2_2_V, on=false})
			widgets.spacer_1_2_1_2_3 = GnomTECWidgetSpacer({parent=widgets.layout_1_2_1_2_H, width="50%"})	
			-- Amplifiers
			widgets.layout_1_2_2_V = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_2_H})
			widgets.plaque_1_2_2_1 = GnomTECWidgetDevicePlaque({parent=widgets.layout_1_2_2_V, text="Amplifiers (Mic/Rec)"})
			widgets.layout_1_2_2_2_H = GnomTECWidgetContainerLayoutHorizontal({parent=widgets.layout_1_2_2_V})
			widgets.spacer_1_2_2_2_1 = GnomTECWidgetSpacer({parent=widgets.layout_1_2_2_2_H, width="50%"})	
			widgets.layout_1_2_2_2_2_V = {}
			widgets.amplifierMicLED = {}
			widgets.amplifierRecLED = {}			
			for t=1, 10 do
				widgets.layout_1_2_2_2_2_V[tostring(t)] = GnomTECWidgetContainerLayoutVertical({parent=widgets.layout_1_2_2_2_H})
				widgets.amplifierMicLED[tostring(t)]= GnomTECWidgetDeviceLED({parent=widgets.layout_1_2_2_2_2_V[tostring(t)], on=false})
				widgets.amplifierRecLED[tostring(t)]= GnomTECWidgetDeviceLED({parent=widgets.layout_1_2_2_2_2_V[tostring(t)], on=false})
			end		
			widgets.spacer_1_2_2_2_3 = GnomTECWidgetSpacer({parent=widgets.layout_1_2_2_2_H, width="50%"})	
		end
	
		if (nil == show) then
			if widgets.device.IsShown() then
				widgets.device.Hide()
			else
				widgets.device.Show()
			end
		else
			if show then
				widgets.device.Show()
			else
				widgets.device.Hide()
			end
		end		
	end
	
	-- constructor
	do
		self.SwitchMainWindow(false)
		self.ScheduleRepeatingTimer(timer, 0.1)
		
		addon.RegisterEvent("GNOMTEC_COMM_BROADCAST", self.OnBroadcastEventHandler)

	end
	
	-- return the instance table
	return self
end
