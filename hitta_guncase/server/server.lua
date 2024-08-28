ESX = exports["es_extended"]:getSharedObject()


ESX.RegisterUsableItem(Config.Item, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('hitta_guncase:openMenu', source)
end)

RegisterNetEvent('hitta_gunCase:giveCase')
AddEventHandler('hitta_gunCase:giveCase', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(Config.Item, 1)
end)

RegisterNetEvent('hitta_gunCase:removeCase')
AddEventHandler('hitta_gunCase:removeCase', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(Config.Item, 1)
end)

local gunCase = {
    id = 'guncase',
    label = 'Gun Case',
    slots = 1,
    weight = 100000,
    owner = false
}
 
AddEventHandler('onServerResourceStart', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    exports.ox_inventory:RegisterStash(gunCase.id, gunCase.label, Config.Inventory.slots, Config.Inventory.weight, gunCase.owner)
end)