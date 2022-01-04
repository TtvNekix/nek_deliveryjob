ESX = nil
local matricula = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    for k, v in pairs(Config['VS']['Blips']) do
        local blip = AddBlipForCoord(v['x'], v['y'], v['z'])
        SetBlipSprite(blip, v['sprite'])
        SetBlipScale(blip, v['scale'])
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v['label'])
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, false)
    end
end)

Citizen.CreateThread(function()
    deleteNearbyVehicles(1)
    Wait(1000)
    deleteNearbyVehicles(1)
    Wait(5000)
    spawnVehicles()
    spawnDeleters()
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        deleteNearbyVehicles(1)
    end
end)

spawnDeleters = function()
    while true do
        local msec = 750
        local entity = PlayerPedId()
        local car = GetVehiclePedIsIn(entity)
        local pos = GetEntityCoords(entity)
        local isIn = IsPedInAnyVehicle(entity)
        for k, v in pairs(Config['VS']['Sellers']['Locations']) do
            local dist = #(pos - vector3(v['x'], v['y'], v['z']))
            if dist < 15 then
                msec = 0
                DrawMarker(1, vector3(v['x'], v['y'], v['z'] - 1.0), 0, 0, 0, 0, 0, 0, 4.0, 4.0, 0.1, 255,0,0, 200, 0, 0, 0, 0)
            end
            if dist < 3 and isIn then
                msec = 0
                floatingText(_U('tosell'), vec3(v['x'], v['y'], v['z'] + 1.0))
                if IsControlJustPressed(0, 38) then
                    local plate = ESX.Game.GetVehicleProperties(car).plate
                    ESX.TriggerServerCallback('nek_vs:isYourCar', function(cb)
                        if cb then
                            local carname = string.lower(GetDisplayNameFromVehicleModel(ESX.Game.GetVehicleProperties(car).model))
                            for i, e in pairs(Config['VS']['Cars']) do
                                local car2 = nil
                                if e.model == carname then
                                    car2 = e
                                    local finalprice = car2.price * Config['VS']['Sellers']['Percentage'] / 100
                                    TaskLeaveVehicle(entity, car)
                                    Wait(500)
                                    TriggerServerEvent('nek_vs:sellVehicle', finalprice, plate)
                                    Wait(500)
                                    NetworkFadeOutEntity(car, true, true)
                                    Wait(1000)
                                    ESX.Game.DeleteVehicle(car)
                                    SendNUIMessage({
                                        show = true;
                                        text = finalprice.. "💲 ➡️ 💰";
                                    })
                                    Wait(3000)
                                    SendNUIMessage({
                                        show = false;
                                    })
                                end
                            end
                        else
                            -- If you want to code, do it here
                        end
                    end, plate)
                end
            end
        end
        Wait(msec)
    end
end

deleteNearbyVehicles = function(radius)
    local playerPed = PlayerPedId()

	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
        for k, v in pairs(Config['VS']['Cars']) do
		    local vehicles = ESX.Game.GetVehiclesInArea(vector3(v['x'], v['y'], v['z']), radius)

            for k,entity in ipairs(vehicles) do
                local attempt = 0

                while not NetworkHasControlOfEntity(entity) and attempt < 1000 and DoesEntityExist(entity) do
                    Citizen.Wait(10)
                    NetworkRequestControlOfEntity(entity)
                    attempt = attempt + 1
                end

                if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
                    NetworkFadeOutEntity(entity, true, true)
                    Wait(1000)
                    ESX.Game.DeleteVehicle(entity)
                end
            end
        end
	else
		local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(playerPed, true) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Citizen.Wait(10)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
            NetworkFadeOutEntity(vehicle, true, true)
            Wait(1000)
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end

spawnVehicles = function()
    for k, v in pairs(Config['VS']['Cars']) do
        local z = v['z'] - 1.00
        ESX.Game.SpawnLocalVehicle(v['model'], vector3(v['x'], v['y'], z), v['r'], function(veh)
            SetEntityLocallyInvisible(veh)
            SetVehicleNumberPlateText(veh, "NEKIX VS")
            SetVehicleDoorsLocked(veh, 3)
            SetVehicleUndriveable(veh, true)
            FreezeEntityPosition(veh, true)
            SetEntityInvincible(veh, true)
        end)
    end
end

DrawText3D = function(x,y,z, text, scale1, scale2)

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
	local scale1 = scale1 or 0.65
	local scale2 = scale2 or 0.65

    SetTextScale(scale1, scale2)
    SetTextFont(1)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370 
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 0)

end

floatingText = function(msg, coords)
	AddTextEntry('FloatingHelpNotification', msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('FloatingHelpNotification')
	EndTextCommandDisplayHelp(2, false, false, -1)
end

local inTest = false
local testCar = nil
driveTest = function(model, spawner)
    if inTest then
        ESX.ShowNotification(_('alreadyTesting'))
    else
        inTest = true
        local coords = GetEntityCoords(PlayerPedId())
        ESX.Game.SpawnVehicle(model, vector3(Config['VS']['Spawners'][spawner]['x'], Config['VS']['Spawners'][spawner]['y'], Config['VS']['Spawners'][spawner]['z']), Config['VS']['Spawners'][spawner]['r'], function(veh)
            testCar = veh
            SetVehicleUndriveable(veh, false)
            SetPedIntoVehicle(PlayerPedId(), veh, -1)
            SetVehicleNumberPlateText(veh, "DRIVE VS")
        end)

        local sec = Config['VS']['TestTime'] * 60

        while inTest do
            if sec > 0 then
                sec = sec - 1
                SendNUIMessage({
                    show = true;
                    text = _('notification_1').. "" ..tostring(sec).. "" .._('notification_2');
                })
            elseif sec <= 0 then
                print("Se acabo")
                inTest = false
                TaskLeaveVehicle(PlayerPedId(), testCar)
                Wait(2500)
                NetworkFadeOutEntity(testCar, true, false)
                SendNUIMessage({
                    show = false;
                })
                Wait(1500)
		        DeleteVehicle(testCar)
                if Config['VS']['BackToVSAfterTest'] then
                    SetEntityCoords(PlayerPedId(), coords)
                end
            end
            Wait(1000)
        end
    end
end

ConceMenu = function(model, model2, price, hash, spawner)
    local elements = Config['VS']['Menu']

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu', 
    {
            title    = _('payMethod'),
            align    = 'right',
            elements = elements
    }, 
    function(data, menu)
    local data = data.current.value

    if data == 'money' or data == 'bank' then
        TriggerServerEvent('nek_vs:buyCar', model, model2, price, hash, data, matricula, spawner)
        ESX.UI.Menu.CloseAll()
    elseif data == 'test' then
        ESX.UI.Menu.CloseAll()
        driveTest(model2, spawner)
    elseif data == 'plate' then
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'menu2',
        {
                title    = _('insertPlate'),
        }, 
        function(data2, menu2)
        local data2 = data2.value

            if Config['VS']['PersonalizedPlate'] then
                
                ESX.TriggerServerCallback('nek_vs:existPlate', function(cb)
                    if cb then
                        matricula = data2
                        ESX.ShowNotification(_('insertedPlate').. "" ..matricula)
                    else
                        ESX.ShowNotification(_('plateAlreadyExists'))
                    end
                end, tostring(data2))
                
            else
                ESX.ShowNotification(_('notPersPlate'))
                matricula = nil
            end
            
            ESX.UI.Menu.CloseAll()
        end, function(data2, menu2)
            menu2.close()
        end)
    end

    end, function(data, menu)
        menu.close()
    end)
end

local vehicle = nil
RegisterNetEvent('nek_vs:giveCar', function(model, plate, spawner)
    ESX.Game.SpawnVehicle(model, vector3(Config['VS']['Spawners'][spawner]['x'], Config['VS']['Spawners'][spawner]['y'], Config['VS']['Spawners'][spawner]['z']), Config['VS']['Spawners'][spawner]['r'], function(veh)
        vehicle = veh
        SetPedIntoVehicle(PlayerPedId(), veh, -1)
        FreezeEntityPosition(veh, false)
        SetVehicleNumberPlateText(veh, tostring(plate))
    end)
    Wait(2500)
    TriggerServerEvent('nek_vs:carInDb', {model = GetHashKey(model), plate = plate})
    ESX.ShowNotification(_('vehReceived'))
    matricula = nil
end)

Citizen.CreateThread(function()
    while true do
        local msec = 750
        local playerPed = PlayerPedId()
        local pedCoords = GetEntityCoords(playerPed)
            for k, v in pairs(Config['VS']['Cars']) do
                local dist = Vdist(pedCoords, vector3(v['x'], v['y'], v['z']))

                if dist <= 2.5 then
                    msec = 0
                    local z = v['z'] + 1.30
                    floatingText("Model: ~g~" ..v['label'].. "~w~\nPrice: ~g~$" ..v['price'].. "~w~\nPress ~y~E ~w~to ~g~interact", vector3(v['x'], v['y'], z))
                    if IsControlJustPressed(0, Config['VS']['PressKey']) then
                        if Config['VS']['NeedLicense'] then
                            ESX.ShowNotification(_('verLicense'))
                            Wait(3500)
                            ESX.TriggerServerCallback('nek_vs:checkLicense', function(cb) 
                                if cb then
                                    ConceMenu(v['label'], v['model'], v['price'], GetHashKey(v['model']), v['spawner'])
                                end
                            end, Config['VS']['LicenseRequired'])
                        else
                            ConceMenu(v['label'], v['model'], v['price'], GetHashKey(v['model']), v['spawner'])
                        end
                    end
                end
            end
        Citizen.Wait(msec)
    end
end)
