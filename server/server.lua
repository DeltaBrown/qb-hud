local ResetStress = false

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

BJCore.Commands.Add("cash", "Check your cash balance", {}, false, function(source, args)
	local src = source
	local xPlayer = BJCore.Functions.GetPlayer(src)
	TriggerClientEvent('hud:client:ShowMoney', src, "cash")
end)

BJCore.Commands.Add("bank", "Check your bank balance", {}, false, function(source, args)
	local src = source
	local xPlayer = BJCore.Functions.GetPlayer(src)
	TriggerClientEvent('hud:client:ShowMoney', src, "bank")
end)

RegisterServerEvent('bj-hud:Server:UpdateStress')
AddEventHandler('bj-hud:Server:UpdateStress', function(StressGain)
	local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + StressGain
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
		TriggerClientEvent("bj-hud:client:UpdateStress", src, newStress)
	end
end)

RegisterServerEvent('bj-hud:Server:GainStress')
AddEventHandler('bj-hud:Server:GainStress', function(amount)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
        TriggerClientEvent('bj-hud:client:UpdateStress', src, newStress)
        TriggerClientEvent('DoShortHudText', src, 'Stress gained')
	end
end)

RegisterServerEvent('bj-hud:Server:RelieveStress')
AddEventHandler('bj-hud:Server:RelieveStress', function(amount)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] - amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
        TriggerClientEvent("bj-hud:client:UpdateStress", src, newStress)
        TriggerClientEvent('DoShortHudText', src, 'Stress relieved')
	end
end)

BJCore.Functions.RegisterServerCallback('BJCore:HasMoney', function(source, cb, costs)
    local retval = false
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then 
        if Player.Functions.RemoveMoney("cash", costs) then
            TriggerClientEvent('bj-phone:client:RemoveCashMoney', src, costs)
			retval = true
		end
	end
	cb(retval)
end)

BJCore.Functions.CreateUseableItem('watch', function(source)
    local src = source
    TriggerClientEvent('hud:toggleWatch', src)
end)

BJCore.Functions.CreateUseableItem("harness", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('bj-hud:client:useHarness', source, item)
end)

RegisterServerEvent('bj-hud:server:equipHarness')
AddEventHandler('bj-hud:server:equipHarness', function(item)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player.PlayerData.items[item.slot].info.uses - 1 == 0 then
        TriggerClientEvent("inventory:client:ItemBox", source, BJCore.Shared.Items['harness'], "remove")
        Player.Functions.RemoveItem('harness', 1)
    else
        Player.PlayerData.items[item.slot].info.uses = Player.PlayerData.items[item.slot].info.uses - 1
        Player.Functions.SetInventory(Player.PlayerData.items)
    end
end)

RegisterServerEvent('bj-hud:server:DoHarnessDamage')
AddEventHandler('bj-hud:server:DoHarnessDamage', function(hp, data)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    if hp == 0 then
        Player.Functions.RemoveItem('harness', 1, data.slot)
    else
        Player.PlayerData.items[data.slot].info.uses = Player.PlayerData.items[data.slot].info.uses - 1
        Player.Functions.SetInventory(Player.PlayerData.items)
    end
end)

RegisterServerEvent('bj-hud:server:ejection')
AddEventHandler('bj-hud:server:ejection', function(plyID, veloc)
    TriggerClientEvent("bj-hud:client:ejection", plyID, veloc)
end)

BJCore.Commands.Add("setfuel", "Set vehicle fuel amount", {{name="amount", help="Amount of fuel to give (max 100)"}}, true, function(source, args)
	local Amount = BJCore.Functions.GetPlayer(tonumber(args[1]))
    local veh = GetVehiclePedIsIn(source,false)
    
    if veh ~= nil then
        exports['bj-hud']:SetFuel(veh, Amount)
    else
        TriggerClientEvent('DoShortHudText', src, 'Player is not in a vehicle')
    end

end, "god")