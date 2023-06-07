ESX = nil
local orders = {}

while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

-- -- -- -- -- --
-- BANK EVENTS -- 
-- -- -- -- -- --
RegisterServerEvent('minecop_banking:openAccount')
AddEventHandler('minecop_banking:openAccount', function(data)
	local _source = source
    local login = data.login
    if not login or login == "" or string.len(login) < 4 or isLoginExist(login) then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('registerErrorLogin'), {})
        return
    end
    local password = data.password
    if not password or password == "" or string.len(password) < 4 then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('registerErrorPassword'), {})
        return
    end
    local backupCode = data.backupCode
    if not backupCode or string.match(backupCode, '%d%d%d%d') == nil then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('registerErrorBackupCode'), {})
        return
    end
    local type = data.type
    if not type then 
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('registerError'), {})
        return
    end
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() < Config.Prices.newAccount then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('errorPrice', Config.Prices.newAccount), {})
        return
    end
    local number = "69 "..math.random(1000,9999).." "..math.random(1000,9999).." "..math.random(1000,9999).." "..math.random(1000,9999)
    while isAccountNumberExist(number) do
        number = "69 "..math.random(1000,9999).." "..math.random(1000,9999).." "..math.random(1000,9999).." "..math.random(1000,9999)
    end
    local isMain = 0
    if not hasMainAccount(xPlayer.identifier) then isMain = 1 end
    local account = {
        owner = xPlayer.identifier,
        name = getCharacterName(xPlayer.identifier),
        number = number,
        type = type,
        login = login,
        password = password,
        backupCode = backupCode,
        balance = 0,
        percent = 0,
        contacts = {},
        isLogged = 0,
        lastLogged = nil,
        isMain = isMain
    }
    saveAccountData(account)
    xPlayer.removeMoney(Config.Prices.newAccount)
    TriggerClientEvent('minecop_banking:updateAccount', _source, "bankRegister", true, _U('registerSuccess'), {})
    xPlayer.showNotification(_U('price', Config.Prices.newAccount))
end)

RegisterServerEvent('minecop_banking:loginAccount')
AddEventHandler('minecop_banking:loginAccount', function(data)
	local _source = source
    local login = data.login
    local password = data.password
    if not login or login == "" or not password or password == "" or not checkAccountLogin(login, password) then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('loginError'), {})
        return
    end
    local account = getAccountData(login)
    if account.isLogged == 1 then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('loginErrorBusy'), {})
        return
    end
    local xPlayer = ESX.GetPlayerFromId(_source)
    account.isLogged = 1
    account.lastLogged = xPlayer.identifier
    saveAccountData(account)
    TriggerClientEvent('minecop_banking:updateAccount', _source, "bankLogin", true, _U('loginSuccess'), account)
end)

RegisterServerEvent('minecop_banking:logoutAccount')
AddEventHandler('minecop_banking:logoutAccount', function(data)
	local _source = source
    local login = data.login
    local account = getAccountData(login)
    account.isLogged = 0
    saveAccountData(account)
end)

RegisterServerEvent('minecop_banking:recoverAccount')
AddEventHandler('minecop_banking:recoverAccount', function(data)
	local _source = source
    local login = data.login
    local backupCode = data.backupCode
    if not login or login == "" or not backupCode or string.match(backupCode, '%d%d%d%d') == nil or not checkAccountRecover(login, backupCode) then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('recoverError'), {})
        return
    end
    account = getAccountData(login)
    TriggerClientEvent('minecop_banking:updateAccount', _source , "bankRecover", true, _U('recoverSuccess'), account)
end)

RegisterServerEvent('minecop_banking:newPasswordAccount')
AddEventHandler('minecop_banking:newPasswordAccount', function(data)
	local _source = source
    local login = data.login
    local password = data.password
    local passwordRepeat = data.passwordRepeat
    if not password or password == "" or not passwordRepeat or passwordRepeat == "" then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('newPasswordError'), {})
        return
    end
    if password ~= passwordRepeat then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('newPasswordErrorPassword'), {})
        return
    end
    local account = getAccountData(login)
    account.password = password
    saveAccountData(account)
    TriggerClientEvent('minecop_banking:updateAccount', _source, "bankNewPassword", true, _U('newPasswordSuccess'), {})
end)

RegisterServerEvent('minecop_banking:transferAccount')
AddEventHandler('minecop_banking:transferAccount', function(data)
	local _source = source
    local login = data.login
    local money = data.money
    if not money or money == "" or string.match(money, '%d+') == nil then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('transferError'), {})
        return
    end
    local account = getAccountData(login)
    if account.balance < tonumber(money) then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('transferErrorPrice'), {})
        return
    end
    local target = data.target
    if target and target ~= "" and isLoginExist(target) then
        if login == target then
            TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('transferErrorYourAcc'), {})
            return
        end
        local targetAccount = getAccountData(target)
        account.balance = account.balance - tonumber(money)
        saveAccountData(account)
        targetAccount.balance = targetAccount.balance + tonumber(money)
        saveAccountData(targetAccount)
        TriggerClientEvent('minecop_banking:updateAccount', _source, "bankTransfer", true, _U('transferSuccess', money), account)
    elseif target and target ~= "" and isAccountNumberExist(target) then
        if account.number == target then
            TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('transferErrorYourAcc'), {})
            return
        end
        local targetAccount = getAccountDataByNumber(target)
        account.balance = account.balance - tonumber(money)
        saveAccountData(account)
        targetAccount.balance = targetAccount.balance + tonumber(money)
        saveAccountData(targetAccount)
        TriggerClientEvent('minecop_banking:updateAccount', _source, "bankTransfer", true, _U('transferSuccess', money), account)
    else
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('transferError'), {})
    end
end)

RegisterServerEvent('minecop_banking:addTransferContact')
AddEventHandler('minecop_banking:addTransferContact', function(data)
	local _source = source
    local login = data.login
    local name = data.name
    if not name or name == "" then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('addContactError'), {})
        return
    end
    local account = getAccountData(login)
    local target = data.target
    if target and target ~= "" and isLoginExist(target) then
        local targetAccount = getAccountData(target)
        table.insert(account.contacts, {number = targetAccount.number, name = name})
        saveAccountData(account)
        TriggerClientEvent('minecop_banking:updateAccount', _source, "bankTransferAddContact", true, _U('addContactSuccess'), account)
    elseif target and target ~= "" and isAccountNumberExist(target) then
        table.insert(account.contacts, {number = target, name = name})
        saveAccountData(account)
        TriggerClientEvent('minecop_banking:updateAccount', _source, "bankTransferAddContact", true, _U('addContactSuccess'), account)
    else
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('addContactErrorTarget'), {})
    end
end)

RegisterServerEvent('minecop_banking:removeTransferContact')
AddEventHandler('minecop_banking:removeTransferContact', function(data)
	local _source = source
    local login = data.login
    local target = data.target
    if not target or target == "" then return end
    local account = getAccountData(login)
    for i=1, #account.contacts, 1 do
        local contact = account.contacts[i]
        if contact.number == target then
            table.remove(account.contacts, i)
            saveAccountData(account)
            TriggerClientEvent('minecop_banking:updateAccount', _source, "", true, _U('removeContactSuccess'), account)
            break
        end
    end
end)

RegisterServerEvent('minecop_banking:saveCardSettings')
AddEventHandler('minecop_banking:saveCardSettings', function(data)
	local _source = source
    local login = data.login
    local card = data.card
    if card == nil then return end
    local color = data.color
    local newPin = data.newPin
    if not newPin or newPin == "" or string.match(newPin, '%d%d%d%d') == nil then
        newPin = card.pin
    end
    local paypass = data.paypass
    local paypassLimit = data.paypassLimit
    if not paypassLimit or paypassLimit == "" or string.match(paypassLimit, '%d+') == nil then
        paypassLimit = card.paypassLimit
    end
    MySQL.Async.execute('UPDATE minecop_banking_cards SET color = @color, pin = @pin, paypass = @paypass, paypassLimit = @paypassLimit WHERE id = @id', {
        ['@color'] = color,
        ['@pin'] = newPin,
        ['@paypass'] = paypass,
        ['@paypassLimit'] = paypassLimit,
        ['@id'] = card.id
    }, function(result)
        local account = getAccountData(login)
        if result > 0 then
            TriggerClientEvent('minecop_banking:updateAccount', _source, "bankSaveCard", true, _U('saveCardSuccess'), account)
        end
    end)
end)

RegisterServerEvent('minecop_banking:getDuplicateCard')
AddEventHandler('minecop_banking:getDuplicateCard', function(data)
	local _source = source
    local login = data.login
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() < Config.Prices.cardDuplicate then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('errorPrice', Config.Prices.cardDuplicate), {})
        return
    end
    local account = getAccountData(login)
    if account.card == nil then return end
    xPlayer.removeMoney(Config.Prices.cardDuplicate)
    TriggerEvent('minecop_banking:addDebitCardItem', xPlayer, account.card.number)
    TriggerClientEvent('minecop_banking:updateAccount', _source, "", true, _U('getDuplicateSuccess'), {})
    xPlayer.showNotification(_U('price', Config.Prices.cardDuplicate))
end)

RegisterServerEvent('minecop_banking:getNewCard')
AddEventHandler('minecop_banking:getNewCard', function(data)
	local _source = source
    local login = data.login
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() < Config.Prices.newCard then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('errorPrice', Config.Prices.newCard), {})
        return
    end
    local account = getAccountData(login)
    local number = math.random(1000,9999).." "..math.random(1000,9999).." "..math.random(1000,9999)
    while isCardNumberExist(number) do
        number = math.random(1000,9999).." "..math.random(1000,9999).." "..math.random(1000,9999)
    end
    local pin = math.random(1000,9999)
    if account.card == nil then
        MySQL.Async.execute('INSERT INTO minecop_banking_cards (account, number, pin) VALUES (@account, @number, @pin)', {
            ['@account'] = account.id,
            ['@number'] = number,
            ['@pin'] = pin
        }, function(result)
            account = getAccountData(login)
            if result > 0 then
                xPlayer.removeMoney(Config.Prices.newCard)
                TriggerEvent('minecop_banking:addDebitCardItem', xPlayer, number)
                TriggerClientEvent('minecop_banking:updateAccount', _source, "", true, _U('getNewCardSuccess'), account)
                xPlayer.showNotification(_U('price', Config.Prices.newCard))
            end
        end)
    else
        MySQL.Async.execute('UPDATE minecop_banking_cards SET removed = @removed WHERE account = @account', {
            ['@removed'] = 1,
            ['@account'] = account.id
        })
        MySQL.Async.execute('INSERT INTO minecop_banking_cards (account, number, pin) VALUES (@account, @number, @pin)', {
            ['@account'] = account.id,
            ['@number'] = number,
            ['@pin'] = pin
        }, function(result)
            account = getAccountData(login)
            if result > 0 then
                xPlayer.removeMoney(Config.Prices.newCard)
                TriggerEvent('minecop_banking:addDebitCardItem', xPlayer, number)
                TriggerClientEvent('minecop_banking:updateAccount', _source, "", true, _U('getNewCardSuccess'), account)
                xPlayer.showNotification(_U('price', Config.Prices.newCard))
            end
        end)
    end
end)

RegisterServerEvent('minecop_banking:lockCard')
AddEventHandler('minecop_banking:lockCard', function(data)
	local _source = source
    local login = data.login
    local card = data.card
    if card == nil then return end
    if card.locked == 0 then
        MySQL.Async.execute('UPDATE minecop_banking_cards SET locked = @locked WHERE id = @id', {
            ['@locked'] = 1,
            ['@id'] = card.id
        }, function(result)
            local account = getAccountData(login)
            if result > 0 then
                TriggerClientEvent('minecop_banking:updateAccount', _source, "", true, _U('lockCardSuccess'), account)
            end
        end)
    else
        MySQL.Async.execute('UPDATE minecop_banking_cards SET locked = @locked WHERE id = @id', {
            ['@locked'] = 0,
            ['@id'] = card.id
        }, function(result)
            local account = getAccountData(login)
            if result > 0 then
                TriggerClientEvent('minecop_banking:updateAccount', _source, "", true, _U('unlockCardSuccess'), account)
            end
        end)
    end
end)

RegisterServerEvent('minecop_banking:setMainAccount')
AddEventHandler('minecop_banking:setMainAccount', function(data)
	local _source = source
    local owner = data.owner
    local login = data.login
    local isMain = data.isMain
    if isMain == 1 then return end
    MySQL.Async.execute('UPDATE minecop_banking_accounts SET isMain = @isMain WHERE owner = @owner', {
        ['@isMain'] = 0,
        ['@owner'] = owner
    })
    local account = getAccountData(login)
    account.isMain = 1
    saveAccountData(account)
    TriggerClientEvent('minecop_banking:updateAccount', _source, "", true, _U('setMainSuccess'), account)
end)

RegisterServerEvent('minecop_banking:closeAccount')
AddEventHandler('minecop_banking:closeAccount', function(data)
	local _source = source
    local login = data.login
    local backupCode = data.backupCode
    if not backupCode or string.match(backupCode, '%d%d%d%d') == nil then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('closeError'), {})
        return
    end
    local account = getAccountData(login)
    MySQL.Async.execute('UPDATE minecop_banking_cards SET account = null, removed = @removed WHERE account = @account', {
        ['@removed'] = 1,
        ['@account'] = account.id
    })
    MySQL.Async.execute('DELETE FROM minecop_banking_accounts WHERE login = @login AND backupCode = @backupCode', {
        ['@login'] = login,
        ['@backupCode'] = backupCode
    }, function(result)
        if result > 0 then
            TriggerClientEvent('minecop_banking:updateAccount', _source, "bankClose", true, _U('closeSuccess'), {})
        end
    end)
end)

RegisterServerEvent('minecop_banking:addDebitCardItem')
AddEventHandler('minecop_banking:addDebitCardItem', function(xOwner, number)
    local id = getDebitCardId(number)
    local cardItem = ESX.IsItemExist("card")
    if cardItem == nil then return end
    local newName = "card"..id
    if ESX.IsItemExist(newName) then
        xOwner.addInventoryItem(newName, 1)
    else
        local data = {
            label = cardItem.label.." "..number,
            weight = cardItem.weight,
            rare = cardItem.rare,
            canRemove = cardItem.canRemove
        }
        ESX.DynamicAddItem(newName, data)
        xOwner.addInventoryItem(newName, 1)
    end
end)

-- -- -- -- -- --
-- ATM EVENTS  --
-- -- -- -- -- --
RegisterServerEvent('minecop_banking:putCardATM')
AddEventHandler('minecop_banking:putCardATM', function(data)
	local _source = source
    local locked = data.cardLocked
    if locked == 1 then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "atmPutCardLocked", false, "", {})
        return
    end
    local removed = data.cardRemoved
    if removed == 1 then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "atmPutCardLocked", false, "", {})
        return
    end
    local account = getAccountDataByDebitCard(data.cardNumber)
    TriggerClientEvent('minecop_banking:updateAccount', _source, "atmPutCard", true, "", account)
end)

-- -- -- -- -- --
-- PAY EVENTS  --
-- -- -- -- -- --
RegisterServerEvent('minecop_banking:payPayPass')
AddEventHandler('minecop_banking:payPayPass', function(data)
	local _source = source
    local locked = data.cardLocked
    if locked == 1 then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "payLocked", false, "", {})
        return
    end
    local removed = data.cardRemoved
    if removed == 1 then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "payLocked", false, "", {})
        return
    end
    local price = data.price
    local account = getAccountDataByDebitCard(data.cardNumber)
    if account.balance < price then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "payLocked", false, "", {})
        return
    end
    if account.card.paypassLimit < price then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "payAcceptPin", true, "", account)
        return
    end
    account.balance = account.balance - price
    account.card.paypassLimit = account.card.paypassLimit - price
    saveAccountData(account)
    TriggerClientEvent('minecop_banking:updateAccount', _source, "payAccept", true, "", {})
    TriggerEvent('minecop_banking:changeOrderStatus', 1)
end)

ESX.RegisterServerCallback('minecop_banking:payCard', function(source, cb, price)
    local _source = source
    orders[_source] = 0
    TriggerClientEvent('minecop_banking:payUI', _source, price)
    while orders[_source] == 0 do Wait(1000) end
    local payed = orders[_source]
    orders[_source] = nil
    cb(payed)
end)

RegisterServerEvent('minecop_banking:changeOrderStatus')
AddEventHandler('minecop_banking:changeOrderStatus', function(status)
	local _source = source
    if not orders[_source] then return end
    orders[_source] = status
end)

-- -- -- -- -- --
-- API EVENTS  --
-- -- -- -- -- --
RegisterServerEvent('minecop_banking:depositAccount')
AddEventHandler('minecop_banking:depositAccount', function(data)
	local _source = source
    local login = data.login
    local money = data.money
    if not money or money == "" or string.match(money, '%d+') == nil then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('depositError'), {})
        return
    end
    local account = getAccountData(login)
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() < tonumber(money) then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('depositErrorPrice'), {})
        return
    end
    local newBalance = account.balance + tonumber(money)
    account.balance = newBalance
    saveAccountData(account)
    xPlayer.removeMoney(tonumber(money))
    TriggerClientEvent('minecop_banking:updateAccount', _source, "bankDeposit", true, _U('depositSuccess', money), account)
end)

RegisterServerEvent('minecop_banking:withdrawAccount')
AddEventHandler('minecop_banking:withdrawAccount', function(data)
	local _source = source
    local login = data.login
    local money = data.money
    if not money or money == "" or string.match(money, '%d+') == nil then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('withdrawError'), {})
        return
    end
    local account = getAccountData(login)
    local xPlayer = ESX.GetPlayerFromId(_source)
    if account.balance < tonumber(money) then
        TriggerClientEvent('minecop_banking:updateAccount', _source, "", false, _U('withdrawErrorPrice'), {})
        return
    end
    local newBalance = account.balance - tonumber(money)
    account.balance = newBalance
    saveAccountData(account)
    xPlayer.addMoney(tonumber(money))
    TriggerClientEvent('minecop_banking:updateAccount', _source, "bankWithdraw", true, _U('withdrawSuccess', money), account)
end)

RegisterServerEvent('minecop_banking:addMoneyMain')
AddEventHandler('minecop_banking:addMoneyMain', function(player, how)
    local xPlayer = player
    if hasMainAccount(xPlayer.identifier) then
        local account = getMainAccount(xPlayer.identifier)
        account.balance = account.balance + how
        saveAccountData(account)
    else
        xPlayer.addMoney(how)
    end
end)

RegisterServerEvent('minecop_banking:addMoney')
AddEventHandler('minecop_banking:addMoney', function(login, how)
    local account = getAccountData(login)
    account.balance = account.balance + how
    saveAccountData(account)
end)

ESX.RegisterServerCallback('minecop_banking:hasMoney', function(source, cb, login, how)
    local account = getAccountData(login)
    if account.balance >= how then cb(true) end
    cb(false)
end)

RegisterServerEvent('minecop_banking:removeMoney')
AddEventHandler('minecop_banking:removeMoney', function(login, how)
    local account = getAccountData(login)
    account.balance = account.balance - how
    saveAccountData(account)
end)

ESX.RegisterServerCallback('minecop_banking:getDebitCards', function(source, cb)
    local _source = source
    local cards = {}
    local xPlayer = ESX.GetPlayerFromId(_source)
    local inventory = xPlayer.getInventory(true)
    for k,v in pairs(inventory) do
        local cardItem = xPlayer.getInventoryItem("card")
        local item = xPlayer.getInventoryItem(k)
        if string.find(item.name, "card") and string.find(item.label, "%d+") then
            local cardNumber = string.gsub(item.label, cardItem.label.." ", "")
            local account = getAccountDataByDebitCard(cardNumber)
            table.insert(cards, {
                account = account,
                cardNumber = cardNumber,
                cardColor = account.card.color,
                cardPaypass = account.card.paypass,
                cardLocked = account.card.locked,
                cardRemoved = account.card.removed
            })
        end
    end
    cb(cards)
end)

-- -- -- -- -- --
--  UTILITIES  --
-- -- -- -- -- --
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    MySQL.Async.execute('UPDATE minecop_banking_accounts SET isLogged = @isLogged', {
        ['@isLogged'] = 0
    })
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not orders[xPlayer.identifier] then return end
    
end)

function getDebitCardId(number)
    local result = MySQL.Sync.fetchAll('SELECT id FROM minecop_banking_cards WHERE number = @number', { 
        ['@number'] = number 
    })
    return result[1].id
end

function isCardNumberExist(number)
    local result = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_cards WHERE number = @number', { 
        ['@number'] = number 
    })
    if #result > 0 then return true end
    return false
end

function getAccountData(login)
    local account = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE login = @login', { 
        ['@login'] = login 
    })
    local card = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_cards WHERE account = @account AND removed = 0', { 
        ['@account'] = account[1].id
    })
    local result = account[1]
    table.insert(result, card)
    result.card = card[1]
    result.contacts = json.decode(result.contacts)
    return result
end

function getAccountDataByNumber(number)
    local account = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE number = @number', { 
        ['@number'] = number 
    })
    local card = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_cards WHERE account = @account AND removed = 0', { 
        ['@account'] = account[1].id
    })
    local result = account[1]
    table.insert(result, card)
    result.card = card[1]
    result.contacts = json.decode(result.contacts)
    return result
end

function getAccountDataByDebitCard(cardNumber)
    local card = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_cards WHERE number = @number', { 
        ['@number'] = cardNumber
    })
    local account = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE id = @id', { 
        ['@id'] = card[1].account 
    })
    local result = account[1]
    table.insert(result, card)
    result.card = card[1]
    result.contacts = json.decode(result.contacts)
    return result
end

function saveAccountData(account)
    local exist = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE login = @login', { 
        ['@login'] = account.login
    })
    if exist[1] ~= nil then
        MySQL.Async.execute('UPDATE minecop_banking_accounts SET password = @password, balance = @balance, percent = @percent, contacts = @contacts, isMain = @isMain, isLogged = @isLogged, lastLogged = @lastLogged WHERE login = @login', {
            ['@password'] = account.password,
            ['@balance'] = account.balance,
            ['@percent'] = account.percent,
            ['@contacts'] = json.encode(account.contacts),
            ['@isMain'] = account.isMain,
            ['@isLogged'] = account.isLogged,
            ['@lastLogged'] = account.lastLogged,
            ['@login'] = account.login
        })
    else
        MySQL.Async.execute('INSERT INTO minecop_banking_accounts (owner, name, number, type, login, password, backupCode, balance, percent, contacts, isLogged, lastLogged, isMain) VALUES (@owner, @name, @number, @type, @login, @password, @backupCode, @balance, @percent, @contacts, @isLogged, @lastLogged, @isMain)', {
            ['@owner'] = account.owner,
            ['@name'] = account.name,
            ['@number'] = account.number,
            ['@type'] = account.type,
            ['@login'] = account.login,
            ['@password'] = account.password,
            ['@backupCode'] = account.backupCode,
            ['@balance'] = account.balance,
            ['@percent'] = account.percent,
            ['@contacts'] = json.encode(account.contacts),
            ['@isLogged'] = account.isLogged,
            ['@lastLogged'] = account.lastLogged,
            ['@isMain'] = account.isMain
        })
    end
end

function checkAccountRecover(login, backupCode)
    local result = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE login = @login AND backupCode = @backupCode', { 
        ['@login'] = login,
        ['@backupCode'] = backupCode
    })
    if #result > 0 then return true end
    return false
end

function checkAccountLogin(login, password)
    local result = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE login = @login AND password = @password', { 
        ['@login'] = login,
        ['@password'] = password
    })
    if #result > 0 then return true end
    return false
end

function getCharacterName(identifier)
    local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', { 
        ['@identifier'] = identifier 
    })
    return result[1].firstname.." "..result[1].lastname
end

function hasMainAccount(identifier)
    local result = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE owner = @owner AND isMain = 1', { 
        ['@owner'] = identifier
    })
    if #result > 0 then return true end
    return false
end

function getMainAccount(identifier)
    local account = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE owner = @owner AND isMain = 1', { 
        ['@owner'] = identifier
    })
    local card = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_cards WHERE account = @account AND removed = 0', { 
        ['@account'] = account[1].id
    })
    local result = account[1]
    table.insert(result, card)
    result.card = card[1]
    result.contacts = json.decode(result.contacts)
    return result
end

function isAccountNumberExist(number)
    local result = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE number = @number', { 
        ['@number'] = number 
    })
    if #result > 0 then return true end
    return false
end

function isLoginExist(login)
    local result = MySQL.Sync.fetchAll('SELECT * FROM minecop_banking_accounts WHERE login = @login', { 
        ['@login'] = login 
    })
    if #result > 0 then return true end
    return false
end