--[[

 Copyright (c) 2009, Adrian L Lange
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met: 

 · Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 · Redistributions in binary form must reproduce the above copyright notice, this
   list of conditions and the following disclaimer in the documentation and/or
   other materials provided with the distribution.

 · Neither the name of the add-on nor the names of its contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--]]

local L = {}
if(GetLocale() == 'deDE') then
	L.TOOLTIP = 'Klicke hier um das set zu wechsein'
	L.NOSET = 'Kein set'
elseif(GetLocale() == 'frFR') then
	L.TOOLTIP = 'Cliquez ici pour changer de set'
	L.NOSET = 'Pas de set'
elseif(GetLocale() == 'zhCN') then
	L.TOOLTIP = '点击选择套装'
	L.NOSET = '无套装'
elseif(GetLocale() == 'zhTW') then
	L.TOOLTIP = '點擊選擇套裝'
	L.NOSET = '無套裝'
else
	L.TOOLTIP = 'Click here to change your set'
	L.NOSET = 'No set'
end

local menuList = {}
local pendingName = nil
local pendingUpdate = true

local addonName = 'Broker_Equipment'

local addon = CreateFrame('Frame', addonName..'DropDown', UIParent, 'UIDropDownMenuTemplate')
local broker = LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
	type = 'data source',
	text = L.NOSET,
	icon = [=[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]=],
	iconCoords = {0.065, 0.935, 0.065, 0.935}
})


local function equipSet(name, icon)
	EquipmentManager_EquipSet(name)

	if(InCombatLockdown()) then
		pendingName = name
		broker.text = '|cffff0000'..name
	else
		broker.text = name
	end

	broker.icon = icon
	EquipmentDB.text = name
	EquipmentDB.icon = icon
end

local function initDropDown()
	for k, v in next, menuList do
		UIDropDownMenu_AddButton(v, level or 1)
	end
end	

local function createDropDown()
	wipe(menuList)

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		local info = {}
		info.index = index
		info.text = name
		info.icon = icon
		info.func = function() equipSet(name, icon) end

		menuList[index] = info
	end

	table.sort(menuList, function(a, b) return a.index < b.index end)
	UIDropDownMenu_Initialize(addon, initDropDown, 'MENU')
	pendingUpdate = nil
end

local function onEvent(self, event, arg1)
	if(event == 'PLAYER_REGEN_ENABLED') then
		if(pendingName) then
			broker.text = pendingName
			pendingName = nil
		end
	elseif(event == 'EQUIPMENT_SETS_CHANGED') then
		pendingUpdate = true
	else
		if(arg1 ~= addonName) then return end

		Broker_EquipmentDB = Broker_EquipmentDB or {text = L.NOSET, icon = broker.icon}
		broker.text = Broker_EquipmentDB.text
		broker.icon = Broker_EquipmentDB.icon

		self:UnregisterEvent(event)
	end
end

function broker:OnClick()
	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end

	if(pendingUpdate) then
		createDropDown()
	end

	ToggleDropDownMenu(1, nil, addon, self, 0, 0)
end

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(L.TOOLTIP)
end


addon:RegisterEvent('ADDON_LOADED')
addon:RegisterEvent('PLAYER_REGEN_ENABLED')
addon:RegisterEvent('EQUIPMENT_SETS_CHANGED')
addon:SetScript('OnEvent', onEvent)