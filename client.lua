local QBCore = exports['qb-core']:GetCoreObject()

local function TranferVeh()
    local MyVeh = lib.callback.await('qb-vehicleshop:server:GetMyVehicles', false)
    if MyVeh then 
        local Menu = {}

        for i in pairs(MyVeh) do
            if QBCore.Shared.Vehicles[MyVeh[i].vehicle] then
                local VehShar = QBCore.Shared.Vehicles[MyVeh[i].vehicle]
                local VehFullName = VehShar.brand..' '..VehShar.name
                Menu[#Menu +1] = {
                    title = VehFullName,
                    icon = 'car-side',
                    onSelect = function()
                        local Veh, Distance = QBCore.Functions.GetClosestVehicle() 
                        if Veh ~= 0 and Distance < 5.0 then
                            local Plate = QBCore.Functions.GetPlate(Veh)
                            if Plate ~= MyVeh[i].plate then 
                                QBCore.Functions.Notify('Near vehicle not your or not same car you select', 'error', 6000)
                                return
                            end
                            local VehInput = lib.inputDialog('Contract Transfer', {
                                {type = 'number', label = 'Player ID', icon = 'address-card', required = true, min = 1, max = 20000},
                                {type = 'number', label = 'Price Sell', icon = 'tag', required = true},
                                {type = 'checkbox', label = 'Confirmation', required = true},
                            })

                            
                            if VehInput then   
                                if Config.LimitPrice.MaxPrice < tonumber(VehInput[2]) then
                                    QBCore.Functions.Notify('Max price for sell is '..Config.LimitPrice.MaxPrice, 'error')
                                    TranferVeh()
                                    return
                                elseif Config.LimitPrice.MinPrice > tonumber(VehInput[2]) then
                                    QBCore.Functions.Notify('Min price for sell is '..Config.LimitPrice.MinPrice, 'error')
                                    TranferVeh()
                                    return
                                end

                                local player = GetPlayerFromServerId(VehInput[1])   
                                local myId = GetPlayerServerId(PlayerId())  

                                if not Config.EnableTransferSelf then
                                    if myId == VehInput[1] then QBCore.Functions.Notify("Can't Transfer Vehicle To Yourself", 'error') return end  
                                end
                                                 
                                if player and player ~= -1 then
                                    local ped = PlayerPedId()
                                    local tPed = GetPlayerPed(player)
                                    local dist = #(GetEntityCoords(ped) - GetEntityCoords(tPed)) <= 5
                                    if dist then
                                        local tInfo = lib.callback.await('qb-vehicleshop:server:GetPlayerInfo', false, VehInput[1])
                                        if not tInfo then QBCore.Functions.Notify('This Citizen Offline', 'error') return end
                                        
                                        local alert = lib.alertDialog({
                                            header = '-> Are You Sure You Want Transfer This Vehicle: \n- Vehicle: '..VehFullName..
                                            ' \n- Plate: '..MyVeh[i].plate..'  \n- Receiver Citizen: '..tInfo.FullName..'  \n- Price Sell: '..VehInput[2]..'$',
                                            centered = true,
                                            cancel = true
                                        })

                                        if alert == 'confirm' then
                                            TriggerServerEvent('qb-vehicleshop:server:Confirmation:TransferVeh', tonumber(VehInput[1]), tonumber(VehInput[2]), VehFullName, MyVeh[i].plate, MyVeh[i].vehicle)
                                        elseif alert == 'cancel' then
                                            lib.showContext('transfer_vehicle_menu')
                                        end         
                                    else
                                        QBCore.Functions.Notify('This Citizen Not Near You', 'error')
                                    end
                                else
                                    QBCore.Functions.Notify('This Citizen Offline', 'error')
                                end
                            end                           
                        else
                            QBCore.Functions.Notify('The Vehicle Need To Be Near You', 'error')
                        end                    
                    end
                }
            end        
        end

        lib.registerContext({
            id = 'transfer_vehicle_menu',
            title = 'Transfer Vehicle Menu',
            options = Menu
        })
        lib.showContext('transfer_vehicle_menu')
    else
        QBCore.Functions.Notify('You not have any vehicle to transfer', 'error', 4000)
    end
end

RegisterNetEvent('qb-vehicleshop:client:TransferVeh', TranferVeh)

RegisterNetEvent('qb-vehicleshop:client:Confirmation:TransferVeh', function(idSeller, fullNameSeller, price, vehFullname, plate, model)
    local alert = lib.alertDialog({
        header = '-> You Receive A Request To Buy Vehicle: \n- Vehicle: '..vehFullname..
        ' \n- Plate: '..plate..'  \n- Seller Citizen: '..fullNameSeller..'  \n- Buy Price: '..price..'$',
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        TriggerServerEvent('qb-vehicleshop:server:VehicleTransfered', plate, idSeller, price, model)
    elseif alert == 'cancel' then
        QBCore.Functions.Notify('Contract Refused', 'error', 6000)
        TriggerServerEvent('qb-vehicleshop:server:SendNotify', idSeller, 'Contract Refused', 'error', 6000)
    end  
end)
