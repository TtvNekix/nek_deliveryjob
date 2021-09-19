Delivery = {}
Delivery.Functions = {}

ESX = exports['es_extended']:getSharedObject()
local inJob = false
local PlayerData = nil
local inAnim = false
local entity = nil
local haveBox = false
local vehicle = nil

CreateThread(function()
    Wait(5000)
    while PlayerData == nil do
        PlayerData = ESX.GetPlayerData()
        print("Getting PlayerData...")
        Wait(0)
    end 
    Wait(5000)
    Delivery.Functions.StartThread()
end)

RegisterNetEvent('esx:setJob', function()
    PlayerData = ESX.GetPlayerData()
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

	if thisFrame then
		DisplayHelpTextThisFrame('HelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('HelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

Delivery.Functions.GetBox = function()
    CreateThread(function()
        while not haveBox do
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
        while haveBox do

            local dist = Vdist(GetEntityCoords(vehicle), GetEntityCoords(PlayerPedId())) 
                if dist < 4 then
                    Delivery.Functions.floatingText("Press ~y~E ~w~to ~g~put the box ~w~in the trunk of the ~g~vehicle", GetEntityCoords(PlayerPedId()))  
                    if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then
                        DeleteObject(entity)
                        SetVehicleDoorsShut(vehicle, false)
                        ClearPedTasksImmediately(PlayerPedId())
                        haveBox = false
                    end
                end
            Wait(0)
        end
    end)
end

RegisterNetEvent('nek_deliveryjob:clothes', function(option)
    if option == 'ped' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
        print("Default Ped")
    elseif option == 'clothes' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            local data = nil
            if skin.sex == 1 then
                data = Config['Delivery']['Uniforms']['Male']
            else 
                data = Config['Delivery']['Uniforms']['Female']
            end
            TriggerEvent('skinchanger:loadClothes', skin, data)
            print("Job Clothes")
        end)
    end
end)

RegisterNetEvent('nek_deliveryjob:startJob', function()
    --local random = math.random(1, #Config['Delivery']['Houses'])
    local random2 = math.random(1, #Config['Delivery']['Vehicles']['Cars'])
    local box = GetHashKey('v_ind_meatboxsml')
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
        local vehicles = ESX.Game.GetVehiclesInArea(v, 2)

        if #vehicles == 0 then
            ESX.Game.SpawnVehicle(Config['Delivery']['Vehicles']['Cars'][random2], v, Config['Delivery']['Vehicles']['Spawner']['rotation'], function(veh)
                vehicle = veh
                SetVehicleNumberPlateText(veh, Config['Delivery']['Vehicles']['Plate'])
                SetVehicleDoorOpen(veh, 3, false, false)
                SetVehicleDoorOpen(veh, 2, false, false)
            end)
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

Delivery.Functions.StartThread = function()
    CreateThread(function()
        Wait(2000)
        while not inJob do
            local msec = 3000
            local playerPed = PlayerPedId()
            local pedCoords = GetEntityCoords(playerPed)
            local isInVeh = GetVehiclePedIsIn(playerPed, false)
            local inVeh = IsPedInAnyVehicle(playerPed)
            local dist = nil
                if PlayerData.job.name == Config['Delivery']['JobName'] then
                    msec = 1000
                    for k, v in pairs(Config['Delivery']['Base']) do
                        dist = Vdist(pedCoords, v['coords'])
                        if dist < 20 then
                            msec = 0
                            DrawMarker(1, vector3(v['coords']['x'], v['coords']['y'], v['coords']['z'] - 1.0), 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.1, 255,0,0, 200, 0, 0, 0, 0)
                            if dist < 1 then
                                Delivery.Functions.floatingText(v['text'], v['coords'])
                                if IsControlJustPressed(0, Config['Delivery']['ActionKey']) then
                                    local data = Config['Delivery']['Menu']
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