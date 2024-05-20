local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('qb-vehicleshop:server:GetMyVehicles', function(source) 
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    local MyVeh = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
    if MyVeh[1] then return MyVeh else return false end   
end)

lib.callback.register('qb-vehicleshop:server:GetPlayerInfo', function(source, tsrc) 
    local tPlayer = QBCore.Functions.GetPlayer(tsrc)
    if not tPlayer then return false end
    local Target = {
        FullName = tPlayer.PlayerData.charinfo.firstname..' '..tPlayer.PlayerData.charinfo.lastname,
        CitizenId = tPlayer.PlayerData.citizenid
    }  
    return Target
end)

RegisterNetEvent('qb-vehicleshop:server:Confirmation:TransferVeh', function(buyerId, price, VehFullName, plate, model)
    local src = source   
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local SellerFullName = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
    TriggerClientEvent('qb-vehicleshop:client:Confirmation:TransferVeh', buyerId, src, SellerFullName, price, VehFullName, plate, model)
end)

RegisterNetEvent('qb-vehicleshop:server:VehicleTransfered', function(plate, sellerId, price, model)
    local src = source   
    local Player = QBCore.Functions.GetPlayer(src)
    local sPlayer = QBCore.Functions.GetPlayer(sellerId)
    if not Player or not sPlayer then return end
    if Player.PlayerData.money[Config.Payment] >= price then
        Player.Functions.RemoveMoney(Config.Payment, price, 'Transfer Vehicle')
        sPlayer.Functions.AddMoney(Config.Payment, price, 'Transfer Vehicle')
        MySQL.update.await('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', {Player.PlayerData.citizenid, plate})
        TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
        QBCore.Functions.Notify(sellerId, 'Vehicle Transferred Successfully', 'success', 5000)
        QBCore.Functions.Notify(src, 'The Vehicle Now Is Your', 'success', 5000)
    else
        QBCore.Functions.Notify(sellerId, 'He not have enough money', 'error', 5000)
        QBCore.Functions.Notify(src, 'Not have enough money in '..Config.Payment, 'error', 5000)
    end  
end)

RegisterNetEvent('qb-vehicleshop:server:SendNotify', function(src, text, type, timer)
    QBCore.Functions.Notify(src, text, type, timer)
end)

QBCore.Commands.Add(Config.Command, "To Transfer Your Vehicle To Another Citizen", {}, false, function(source)
    TriggerClientEvent('qb-vehicleshop:client:TransferVeh', source)
end)
