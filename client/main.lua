-- Main thread
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end
end)

-- 
-- Script section
-- 

-- Base UI
RegisterNetEvent('minecop_banking:bankUI')
AddEventHandler('minecop_banking:bankUI', function()
	SetNuiFocus(true, true)
	SendNUIMessage({action = 'openBank'})
end)

RegisterNetEvent('minecop_banking:atmUI')
AddEventHandler('minecop_banking:atmUI', function()
	ESX.TriggerServerCallback('minecop_banking:getDebitCards', function(cards)
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'openATM',
			cards = cards
		})
	end)
end)

RegisterNetEvent('minecop_banking:payUI')
AddEventHandler('minecop_banking:payUI', function(price)
	ESX.TriggerServerCallback('minecop_banking:getDebitCards', function(cards)
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'openPay',
			cards = cards,
			price = price
		})
	end)
end)

RegisterNetEvent('minecop_banking:closeUI')
AddEventHandler('minecop_banking:closeUI', function()
	SetNuiFocus(false, false)
	SendNUIMessage({action = 'closeAll'})
	TriggerServerEvent('minecop_banking:changeOrderStatus', 2)
end)

RegisterNUICallback('closeUI', function(data, cb)
    TriggerEvent('minecop_banking:closeUI')
    cb(true)
end)

RegisterNetEvent('minecop_banking:updateAccount')
AddEventHandler('minecop_banking:updateAccount', function(action, success, message, account)
	SendNUIMessage({
		action = action,
		messageType = success,
		message = message,
		account = account
	})
end)

-- Bank Events UI

RegisterNUICallback('openAccount', function(data, cb)
	TriggerServerEvent('minecop_banking:openAccount', data)
	cb(true)
end)

RegisterNUICallback('loginAccount', function(data, cb)
	TriggerServerEvent('minecop_banking:loginAccount', data)
	cb(true)
end)

RegisterNUICallback('logoutAccount', function(data, cb)
	TriggerServerEvent('minecop_banking:logoutAccount', data)
	cb(true)
end)

RegisterNUICallback('recoverAccount', function(data, cb)
	TriggerServerEvent('minecop_banking:recoverAccount', data)
	cb(true)
end)

RegisterNUICallback('newPasswordAccount', function(data, cb)
	TriggerServerEvent('minecop_banking:newPasswordAccount', data)
	cb(true)
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('minecop_banking:depositAccount', data)
	cb(true)
end)

RegisterNUICallback('withdraw', function(data, cb)
	TriggerServerEvent('minecop_banking:withdrawAccount', data)
	cb(true)
end)

RegisterNUICallback('addTransferContact', function(data, cb)
	TriggerServerEvent('minecop_banking:addTransferContact', data)
	cb(true)
end)

RegisterNUICallback('removeTransferContact', function(data, cb)
	TriggerServerEvent('minecop_banking:removeTransferContact', data)
	cb(true)
end)

RegisterNUICallback('transfer', function(data, cb)
	TriggerServerEvent('minecop_banking:transferAccount', data)
	cb(true)
end)

RegisterNUICallback('saveCardSettings', function(data, cb)
	TriggerServerEvent('minecop_banking:saveCardSettings', data)
	cb(true)
end)

RegisterNUICallback('getDuplicateCard', function(data, cb)
	TriggerServerEvent('minecop_banking:getDuplicateCard', data)
	cb(true)
end)

RegisterNUICallback('getNewCard', function(data, cb)
	TriggerServerEvent('minecop_banking:getNewCard', data)
	cb(true)
end)

RegisterNUICallback('lockCard', function(data, cb)
	TriggerServerEvent('minecop_banking:lockCard', data)
	cb(true)
end)

RegisterNUICallback('setMainAccount', function(data, cb)
	TriggerServerEvent('minecop_banking:setMainAccount', data)
	cb(true)
end)

RegisterNUICallback('closeAccount', function(data, cb)
	TriggerServerEvent('minecop_banking:closeAccount', data)
	cb(true)
end)

-- ATM Events UI

RegisterNUICallback('putCardATM', function(data, cb)
	TriggerServerEvent('minecop_banking:putCardATM', data)
	cb(true)
end)

-- Pay Events UI

RegisterNUICallback('payPayPass', function(data, cb)
	TriggerServerEvent('minecop_banking:payPayPass', data)
	cb(true)
end)

RegisterNUICallback('payTraditional', function(data, cb)
	TriggerServerEvent('minecop_banking:payTraditional', data)
	cb(true)
end)

-- Show blips
Citizen.CreateThread(function()
	local atmSet = Config.Blips.ATM
	if atmSet.blip then
		for i=1, #atmSet.positions, 1 do
			local pos = atmSet.positions[i]
			local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
			SetBlipAsShortRange(blip, true)
			SetBlipSprite(blip, atmSet.blipSprite)
			SetBlipScale(blip, atmSet.blipScale)
			SetBlipColour(blip, atmSet.blipColour)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('ATM'))
			EndTextCommandSetBlipName(blip)
		end
	end
	local bankSet = Config.Blips.Bank
	if bankSet.blip then
		for i=1, #bankSet.positions, 1 do
			local pos = bankSet.positions[i]
			local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
			SetBlipAsShortRange(blip, true)
			SetBlipSprite(blip, bankSet.blipSprite)
			SetBlipScale(blip, bankSet.blipScale)
			SetBlipColour(blip, bankSet.blipColour)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('bank'))
			EndTextCommandSetBlipName(blip)
		end
	end
end)

local isNearBank = false
local isNearATM = false

-- Key control
Citizen.CreateThread(function()
	while true do
		Wait(1)
		if isNearBank then
			SetTextComponentFormat("STRING")
			AddTextComponentString(_U('useBank'))
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			if IsControlJustPressed(0, 38) then
				TriggerEvent('minecop_banking:bankUI')
			end
		elseif isNearATM then
			SetTextComponentFormat("STRING")
			AddTextComponentString(_U('useATM'))
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			if IsControlJustPressed(0, 38) then
				TriggerEvent('minecop_banking:atmUI')
			end
		end
		if IsControlJustPressed(0, 202) then
			TriggerEvent('minecop_banking:closeUI')
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		if nearBank() then
			isNearBank = true
		elseif nearATM() then
			isNearATM = true
		else
			isNearBank = false
			isNearATM = false
		end
	end
end)

-- Functions
function nearBank()
	local bankSet = Config.Blips.Bank
	local location = GetEntityCoords(PlayerPedId())
	for i=1, #bankSet.positions, 1 do
		local pos = bankSet.positions[i]
		local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, location['x'], location['y'], location['z'], true)
		if distance <= 2 then return true end
	end
end

function nearATM()
	local atmSet = Config.Blips.ATM
	local location = GetEntityCoords(PlayerPedId())
	if atmSet.byProps then
		for i = 1, #atmSet.props do
			local entity = GetClosestObjectOfType(location, 1.0, GetHashKey(atmSet.props[i]), false, false, false)
			local entityCoords = GetEntityCoords(entity)
			if DoesEntityExist(entity) then
				return true
			end
		end
	else
		for i=1, #atmSet.positions, 1 do
			local pos = atmSet.positions[i]
			local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, location['x'], location['y'], location['z'], true)
			if distance <= 2 then return true end
		end
	end
end