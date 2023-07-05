Delivery = {}
Delivery.Functions = {}

QBCore = exports['qb-core']:GetCoreObject()

local inJob = false
local haveClothes = false
local PlayerData = nil
local inAnim = false
local entity = nil
local haveBox = false
local getBox = false
local vehicle, vehicle2 = nil, nil
local gotoPoint = false
local comeBack = false
local dest_blip, blipStatus
local data = {}

CreateThread(function()
    Wait(3000)

    while PlayerData == nil do
        PlayerData = QBCore.Functions.GetPlayerData()
        print("Getting PlayerData...")
        Wait(0)
    end

    Wait(2000)

    for k, v in pairs(Config['Delivery']['Blips']) do
        local blip = AddBlipForCoord(v['x'], v['y'], v['z'])
        SetBlipSprite(blip, v['sprite'])
        SetBlipScale(blip, v['scale'])
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v['label'])
        EndTextCommandSetBlipName(blip)
    end

    Delivery.Functions.StartThread()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('nek_deliveryjob:stopJob', function()
    TriggerServerEvent('nek_delivery:wb', "The player with Name **"..GetPlayerName(PlayerId()).."** has stopped working")
    inJob = false
    haveBox = false
    blipStatus = 'delete'
    inAnim = false
    ClearPedTasksImmediately(PlayerPedId())
    DeleteObject(entity)
    DeleteVehicle(vehicle)
end)

Delivery.Functions.floatingText = function(msg, coords)
	AddTextEntry('FloatingHelpNotification', msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('FloatingHelpNotification')
	EndTextCommandDisplayHelp(2, false, false, -1)
end

Delivery.Functions.ShowNotification = function(msg, thisFrame, beep, duration)
    AddTextEntry('HelpNotification', msg)
    BeginTextCommandDisplayHelp('HelpNotification')
    EndTextCommandDisplayHelp(0, false, true, 3500)
end

Delivery.Functions.SetBlipRoutes = function(x, y, z, sprite, colour)
    dest_blip, blipStatus = AddBlipForCoord(x, y, z), nil
    SetBlipSprite(dest_blip, sprite)
    SetBlipDisplay(dest_blip, 4)
    SetBlipScale(dest_blip, 0.70)
    SetBlipColour(dest_blip, colour)
    SetBlipRoute(dest_blip, true)
    SetBlipAsShortRange(garbageHQBlip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Destination")
    EndTextCommandSetBlipName(dest_blip)

    blipStatus = true

    CreateThread(function()
        while true do
            local distance = Vdist(x, y, z, GetEntityCoords(PlayerPedId()))
            if blipStatus == 'delete' then
                RemoveBlip(dest_blip)
                break
            end
            Wait(1000)
        end
    end)
end

Delivery.Functions.GetBox = function()
    CreateThread(function()
        while not haveBox and inJob do
            Delivery.Functions.floatingText("Press ~y~E ~w~to ~g~take the box", vec3(Config['Delivery']['Prop']['x'], Config['Delivery']['Prop']['y'], Config['Delivery']['Prop']['z'] + 1.0))
            if Vdist(GetEntityCoords(PlayerPedId()), GetEntityCoords(entity)) < 2 then
                if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then
                    ClearPedTasksImmediately(PlayerPedId())
                    TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
                    AttachEntityToEntity(entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
                    haveBox = true
                    Wait(200)
                    Delivery.Functions.PutBoxInVehicle()
                end
            end
            Wait(0)
        end
    end)
end

Delivery.Functions.PutBoxInVehicle = function()
    Delivery.Functions.ShowNotification("Put the box in the trunk of the vehicle")
    CreateThread(function()
        while haveBox and inJob do
            local dist = Vdist(GetEntityCoords(vehicle), GetEntityCoords(PlayerPedId()))
                if dist < 4 then
                    Delivery.Functions.floatingText("Press ~y~E ~w~to ~g~put the box ~w~in the trunk of the ~g~vehicle", GetEntityCoords(PlayerPedId()))
                    if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then
                        DeleteObject(entity)
                        SetVehicleDoorsShut(vehicle, false)
                        ClearPedTasksImmediately(PlayerPedId())
                        
                        haveBox = false
                        gotoPoint = true
                        Delivery.Functions.GoToPointAndDelivery()
                    end
                end
            Wait(0)
        end
    end)
end

Delivery.Functions.GetClosestVehicle = function()
    CreateThread(function()
        Wait(1000)
        while gotoPoint and inJob and not getBox do
            local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
            vehicle2 = QBCore.Functions.GetClosestVehicle(vec3(px, py, pz))
            Wait(2000)
        end
    end)
end

Delivery.Functions.GoToPointAndDelivery = function()

    if not HasAnimDictLoaded("anim@heists@box_carry@") then
		RequestAnimDict("anim@heists@box_carry@") 
		while not HasAnimDictLoaded("anim@heists@box_carry@") do 
			Citizen.Wait(0)
		end
	end

    if not HasModelLoaded(Config['Delivery']['Prop']['Model']) then
        RequestModel(Config['Delivery']['Prop']['Model'])
        while not HasModelLoaded(Config['Delivery']['Prop']['Model']) do
            Citizen.Wait(0)
        end
    end

    local dest = math.random(1, #Config['Delivery']['Destinations'])
    Delivery.Functions.SetBlipRoutes(Config['Delivery']['Destinations'][dest]['x'], Config['Delivery']['Destinations'][dest]['y'], Config['Delivery']['Destinations'][dest]['z'], 1, 27)
    Delivery.Functions.ShowNotification("Go to the ~g~point ~w~marked in the ~y~GPS")
    Delivery.Functions.GetClosestVehicle()
    getBox = false
    CreateThread(function()
        Wait(5000)
        while gotoPoint and inJob do
            local msec = 1000
            local dist = Vdist(vec3(Config['Delivery']['Destinations'][dest]['x'], Config['Delivery']['Destinations'][dest]['y'], Config['Delivery']['Destinations'][dest]['z']), GetEntityCoords(PlayerPedId()))
            local isInVeh = IsPedInVehicle(PlayerPedId(), vehicle2)

            if not getBox then
                msec = 500
                local door = GetEntryPositionOfDoor(vehicle2, 3)
                local dist2 = Vdist(door, GetEntityCoords(PlayerPedId()))
                if dist2 < 1 and not getBox then
                    msec = 0
                    Delivery.Functions.floatingText("Press ~y~E ~w~to get the ~g~package", GetEntityCoords(PlayerPedId()))
                    if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then
                        TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                        SetVehicleDoorOpen(vehicle2, 3, false, true)
                        Wait(250)
                        SetVehicleDoorOpen(vehicle2, 2, false, true)
                        Wait(5000)
                        ClearPedTasks(PlayerPedId())
                        Wait(2500)
                        entity = CreateObject(Config['Delivery']['Prop']['Model'], GetEntityCoords(PlayerPedId()), true, false, false)
                        Wait(150)
                        SetVehicleDoorsShut(vehicle2, false)
                        ClearPedTasksImmediately(PlayerPedId())
                        Wait(750)
                        TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
                        AttachEntityToEntity(entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
                        getBox = true
                    end
                end
            else
                if dist < 8 then
                    msec = 0
                    DrawMarker(1, vec3(Config['Delivery']['Destinations'][dest]['x'], Config['Delivery']['Destinations'][dest]['y'], Config['Delivery']['Destinations'][dest]['z'] - 1.0), 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.1, 255,0,0, 200, 0, 0, 0, 0)
                    if dist < 1.25 then
                        Delivery.Functions.floatingText("Press ~y~E ~w~to put the ~g~package ~w~on the floor", vec3(Config['Delivery']['Destinations'][dest]['x'], Config['Delivery']['Destinations'][dest]['y'], Config['Delivery']['Destinations'][dest]['z']))
                        if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then
                            ClearPedTasksImmediately(PlayerPedId())
                            DeleteObject(entity)
                            Wait(500)
                            blipStatus = 'delete'
                            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                            Wait(5000)
                            ClearPedTasks(PlayerPedId())
                            Wait(2500)
                            entity = CreateObject(Config['Delivery']['Prop']['Model'], vec3(Config['Delivery']['Destinations'][dest]['x'], Config['Delivery']['Destinations'][dest]['y'], Config['Delivery']['Destinations'][dest]['z'] - 1.0), true, false, false)
                            gotoPoint = false
                            comeBack = true
                            Delivery.Functions.ShowNotification("Come ~r~back ~w~to the ~g~restaurant")
                            Delivery.Functions.ComeBack()
                        end
                    end
                end
            end
            Wait(msec)
        end
    end)
end

Delivery.Functions.ComeBack = function()
    Delivery.Functions.SetBlipRoutes(Config['Delivery']['Vehicles']['Deleter']['x'], Config['Delivery']['Vehicles']['Deleter']['y'], Config['Delivery']['Vehicles']['Deleter']['z'], 1, 27)
    CreateThread(function()
        while comeBack do
            local msec = 1000
            local dist = Vdist(GetEntityCoords(PlayerPedId()), Config['Delivery']['Vehicles']['Deleter'])

            if dist > 60 and dist < 80 then
                DeleteObject(entity)
            end

            if dist < 3 then
                msec = 0
                Delivery.Functions.floatingText("Press ~y~E ~w~to ~g~park ~w~the ~r~vehicle", GetEntityCoords(GetVehiclePedIsIn(PlayerPedId())))
                if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then
                    local v = GetVehiclePedIsIn(PlayerPedId())
                    TaskLeaveVehicle(PlayerPedId(), v)
                    Wait(2500)
                    NetworkFadeOutEntity(v, true, false)
                    Wait(2000)
                    DeleteVehicle(v)
                    DeleteObject(entity)
                    Delivery.Functions.Pay()
                    blipStatus = 'delete'
                    comeBack = false
                    inJob = false
                end
            end
            Wait(msec)
        end
    end)
end

Delivery.Functions.Pay = function()
    local random = math.random(Config['Delivery']['FinalPayout']['Min'], Config['Delivery']['FinalPayout']['Max'])

    TriggerServerEvent('nek_delivery:pay', tonumber(random))
end

RegisterNetEvent('nek_deliveryjob:clothes', function(option)
    if option == 'ped' then
        TriggerServerEvent('qb-clothes:loadPlayerSkin')
        haveClothes = false
        print("Default Ped")
    elseif option == 'clothes' then
        local ped = PlayerPedId()
        local gender = QBCore.Functions.GetPlayerData().charinfo.gender
        if gender == 0 then
            TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.male)
        else
            TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.female)
        end
        haveClothes = true
        print("Job Clothes")
    end
end)

RegisterNetEvent('nek_deliveryjob:startJob', function()
    TriggerServerEvent('nek_delivery:wb', "The player with Name **"..GetPlayerName(PlayerId()).."** has started to work")
    local random = math.random(1, #Config['Delivery']['Vehicles']['Cars'])
    local bone = 4089

    if not HasAnimDictLoaded("anim@heists@box_carry@") then
		RequestAnimDict("anim@heists@box_carry@") 
		while not HasAnimDictLoaded("anim@heists@box_carry@") do 
			Citizen.Wait(0)
		end
	end

    if not HasModelLoaded(Config['Delivery']['Prop']['Model']) then
        RequestModel(Config['Delivery']['Prop']['Model'])
        while not HasModelLoaded(Config['Delivery']['Prop']['Model']) do
            Citizen.Wait(0)
        end
    end

    for k, v in pairs(Config['Delivery']['Vehicles']['Spawner']['coords']) do
        local vehicles = GetVehiclesInArea()

        if #vehicles == 0 then
            QBCore.Functions.SpawnVehicle(Config['Delivery']['Vehicles']['Cars'][random], function(veh)
                vehicle = veh
                SetVehicleNumberPlateText(veh, Config['Delivery']['Vehicles']['Plate'])

                SetVehicleDoorOpen(veh, 3, false, false)
                SetVehicleDoorOpen(veh, 2, false, false)
                TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                SetEntityHeading(veh, Config['Delivery']['Vehicles']['Spawner']['rotation'])
            end, v, true)   

            inJob = true
            inAnim = true
        else
            inAnim = false
            Delivery.Functions.ShowNotification("There is no free place to park your vehicle")
        end

        if inAnim then
            entity = CreateObject(Config['Delivery']['Prop']['Model'], Config['Delivery']['Prop']['x'], Config['Delivery']['Prop']['y'], Config['Delivery']['Prop']['z'], true, false, false)
            Delivery.Functions.GetBox()
            haveBox = false
        else
            Delivery.Functions.ShowNotification("Could not start delivery")
        end
    end
end)

RegisterCommand('stopanim', function()
    inAnim = false
    DeleteObject(entity)
    ClearPedTasksImmediately(PlayerPedId())
end)

function GetVehiclesInArea()
    local vehicles = {}

    for k, v in pairs(QBCore.Functions.GetVehicles()) do
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(v)) < 2.0 then
            table.insert(vehicles, v)
        end
    end
    return vehicles
end


Delivery.Functions.StartThread = function()
    CreateThread(function()
        Wait(2000)
        while true do
            local msec = 3000
            local playerPed = PlayerPedId()
            local pedCoords = GetEntityCoords(playerPed)
            local isInVeh = GetVehiclePedIsIn(playerPed, false)
            local inVeh = IsPedInAnyVehicle(playerPed)
            local dist = nil
                if PlayerData.job.name== Config['Delivery']['JobName'] then
                    msec = 1000
                    for k, v in pairs(Config['Delivery']['Base']) do
                        local dist = Vdist(pedCoords, v['coords'])
                        if dist < 20 then
                            msec = 0
                            DrawMarker(1, vector3(v['coords']['x'], v['coords']['y'], v['coords']['z'] - 1.0), 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.1, 255,0,0, 200, 0, 0, 0, 0)
                            if dist < 1 then
                                Delivery.Functions.floatingText("Press ~y~E ~w~to access to ~g~job options", v['coords'])
                                if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then         
                                    data = {}
                                    if haveClothes and not inJob then
                                        table.insert(data, {text = "Default Ped", toDo = [[TriggerEvent('nek_deliveryjob:clothes', 'ped')]], icon = "fas fa-tshirt"})
                                    elseif not haveClothes and not inJob then
                                        table.insert(data, {text = "Put Clothes", toDo = [[TriggerEvent('nek_deliveryjob:clothes', 'clothes')]], icon = "fas fa-user-tie"})
                                    end

                                    if inJob then
                                        table.insert(data, {text = "Stop Job", toDo = [[TriggerEvent('nek_deliveryjob:stopJob')]], icon = "fas fa-truck-loading"})
                                    elseif not inJob and haveClothes then
                                        table.insert(data, {text = "Start Job", toDo = [[TriggerEvent('nek_deliveryjob:startJob')]], icon = "fas fa-truck-loading"})
                                    end
                                    TriggerEvent("guille_cont:client:open", "Delivery Menu", data)
                                end
                            end
                        end
                    end
                else
                    msec = 3000
                end
            Wait(msec)
        end
    end)
end
