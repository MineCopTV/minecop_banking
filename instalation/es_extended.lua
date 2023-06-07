-- /es_extended/server/common.lua
-- Replace this code
MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
    for k,v in ipairs(result) do
        ESX.Items[v.name] = {
            label = v.label,
            weight = v.weight,
            rare = v.rare,
            canRemove = v.can_remove
        }
    end
end)
-- To this
MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
    for k,v in ipairs(result) do
        ESX.Items[v.name] = {
            label = v.label,
            weight = v.weight,
            rare = v.rare,
            canRemove = v.can_remove
        }
        if v.name == "card" then
            MySQL.Async.fetchAll('SELECT * FROM minecop_banking_cards', {}, function(result2)
                for k2,v2 in ipairs(result2) do
                    local name = v.name..v2.id
                    local label = v.label.." "..v2.number
                    ESX.Items[name] = {
                        label = label,
                        weight = v.weight,
                        rare = v.rare,
                        canRemove = v.can_remove
                    }
                end
            end)
        end
    end
end)

-- /es_extended/client/main.lua
-- Add this code
RegisterNetEvent('esx:updatePlayerData')
AddEventHandler('esx:updatePlayerData', function(playerData)
	ESX.PlayerData = playerData
end)

-- /es_extended/server/classes/player.lua
-- Add this code
self.forceAddInventoryItem = function(name, itemData)
    table.insert(self.inventory, {
        name = name,
        count = 0,
        label = itemData.label,
        weight = itemData.weight,
        usable = ESX.UsableItemsCallbacks[name] ~= nil,
        rare = itemData.rare,
        canRemove = itemData.canRemove
    })
    table.sort(self.inventory, function(a, b)
        return a.label < b.label
    end)
    TriggerEvent('esx:onUpdatePlayerData', self.source, self)
    self.triggerEvent('esx:updatePlayerData', self)
end

-- /es_extended/server/functions.lua
-- Add this code
ESX.IsItemExist = function(name)
	if ESX.Items[name] then return ESX.Items[name] end
end

ESX.DynamicAddItem = function(name, data)
	if ESX.Items[name] then
		print(('[es_extended] [^3WARNING^7] An item "%s" is already exist, overriding them'):format(name))
	end
	ESX.Items[name] = {
		label = data.label,
		weight = data.weight,
		rare = data.rare,
		canRemove = data.canRemove
	}
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		xPlayer.forceAddInventoryItem(name, ESX.Items[name])
	end
end

-- /es_extended/server/paycheck.lua
-- Replace all code
ESX.StartPayCheck = function()
	function payCheck()
		local xPlayers = ESX.GetPlayers()

		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			local job     = xPlayer.job.grade_name
			local salary  = xPlayer.job.grade_salary
			if salary > 0 then
				if job == 'unemployed' then -- unemployed
					TriggerEvent('minecop_banking:addMoneyMain', xPlayer, salary)
					TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_help', salary), 'CHAR_BANK_FLEECA', 9)
				elseif Config.EnableSocietyPayouts then
					TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
						if society ~= nil then
							TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
								if account.money >= salary then
									TriggerEvent('minecop_banking:addMoneyMain', xPlayer, salary)
									account.removeMoney(salary)

									TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
								else
									TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_FLEECA', 1)
								end
							end)
						else -- not a society
							TriggerEvent('minecop_banking:addMoneyMain', xPlayer, salary)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
						end
					end)
				else -- generic job
					TriggerEvent('minecop_banking:addMoneyMain', xPlayer, salary)
					TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
				end
			end
		end
		SetTimeout(Config.PaycheckInterval, payCheck)
	end
	SetTimeout(Config.PaycheckInterval, payCheck)
end