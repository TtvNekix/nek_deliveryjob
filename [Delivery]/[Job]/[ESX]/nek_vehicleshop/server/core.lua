ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj Wait(5000) print("Nekix Vehicle Shop ^2initialized^0") end)

local plate = nil
local created = false

ESX.RegisterServerCallback('nek_vs:checkLicense', function(src, cb, type)
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll("SELECT * FROM user_licenses WHERE owner = @owner AND type = @type",
    {
        ['@owner'] = xPlayer.identifier,
        ['@type'] = type
    }, 
    function(results)
        if results[1] then
            cb(true)
        else
            xPlayer.showNotification(_('notHaveLicense'))
        end
    end)
end)

RegisterNetEvent('print', function(msg)
    print(msg)
end)

generatePlate = function(hash)
    local xPlayer = ESX.GetPlayerFromId(source)

    plate = nil
    local letters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
    local random = math.random(1, #letters)
    local random2 = math.random(1, #letters)
    local random3 = math.random(1, #letters)
    local letter1 = letters[random]
    local letter2 = letters[random2]
    local letter3 = letters[random3]

    if Config['VS']['RandomPlate'] then
        plate = letter1 .."".. letter2 .."".. letter3 .." ".. math.random(1000, 9999)
    else
        plate = "NEK " ..math.random(1000, 9999)
    end

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate",
    {
        ['@plate'] = tostring(plate)
    },
    function(results)
        if results[1] then
            generatePlate()
        else
            print("Ya generada")
        end
        created = false
    end)
end

RegisterNetEvent('nek_vs:carInDb', function(vehicleData)
    local xPlayer = ESX.GetPlayerFromId(source)

    print(xPlayer.identifier.. " ".. _('getCarPlate') .." ".. json.encode(plate))

    MySQL.Sync.execute("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",
    {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = tostring(plate),
        ['@vehicle'] = tostring(json.encode(vehicleData))
    })

end)

sendWB = function(message)
	PerformHttpRequest(Config['Webhook'], function(err, text, headers) end, 'POST', json.encode({
		username = Config['Username'],
		embeds = {{
			["color"] = color,
			["author"] = {
				["name"] = Config['CommunityName'],
				["icon_url"] = Config['CommunityLogo']
			},
			["description"] = "".. message .."",
			["footer"] = {
				["text"] = "• "..os.date("%x %X %p"),
			},
		}}, 
		avatar_url = Config['Avatar']
	}),
	{
		['Content-Type'] = 'application/json'
	})

	print("Webhook Enviado")
end

ESX.RegisterServerCallback('nek_vs:existPlate', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate",
    {
        ['@plate'] = tostring(plate)
    },
    function(results)
        if results[1] then
            cb(false)
        else
            cb(true)
        end
        created = false
    end)
end)

ESX.RegisterServerCallback('nek_vs:isYourCar', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate AND owner = @owner",
    {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = tostring(plate)
    },
    function(results)
        if results[1] then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterNetEvent('nek_vs:sellVehicle', function(finalprice, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Sync.execute("DELETE FROM owned_vehicles WHERE plate = @plate AND owner = @owner",
    {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = tostring(plate)
    })
    
    xPlayer.addMoney(finalprice)
end)

RegisterNetEvent('nek_vs:buyCar', function(model, model2, price, hash, mode, matricula, spawner)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if model and price then
        if mode == 'bank' then
            if xPlayer.getAccount('bank').money >= tonumber(price) then
                xPlayer.removeAccountMoney('bank', tonumber(price))
                if matricula == nil then
                    generatePlate(hash)
                else
                    plate = matricula
                end
                Citizen.Wait(1000)
                TriggerClientEvent('nek_vs:giveCar', src, model2, plate, spawner)
                xPlayer.showNotification("Has recibido un vehiculo -- Matricula: " .. plate .. " / Modelo: " .. model)
                if Config['EnableWebhook'] then
                	sendWB("**".. identifier .."** buy a vehicle\n\n**Price:** $".. price .."\n**Model:** ".. model .."\n**Plate:** ".. plate .."\n**Account Used:** ".. mode)
            	end
            else
                if Config['EnableWebhook'] then
                	sendWB("**".. identifier .."** try to buy with account **".. mode .."** with a price of **$".. price .."** but doesn't have money.")
                end
                xPlayer.showNotification("No tienes dinero suficiente")
            end
        elseif mode == 'money' then
            if xPlayer.getMoney() >= tonumber(price) then
                xPlayer.removeMoney(tonumber(price))
                if matricula == nil then
                    generatePlate(hash)
                else
                    plate = matricula
                end
                Citizen.Wait(1000)
                TriggerClientEvent('nek_vs:giveCar', src, model2, plate, spawner)
                xPlayer.showNotification(_('getVehicle_1') .."".. plate .. "".. _('getVehicle_2') .."".. model)
                if Config['EnableWebhook'] then
                	sendWB("**".. identifier .."** buy a vehicle\n\n**Price:** $".. price .."\n**Model:** ".. model .."\n**Plate:** ".. plate .."\n**Account Used:** ".. mode)
            	end
            else
                if Config['EnableWebhook'] then
                	sendWB("**".. identifier .."** try to buy with account **".. mode .."** with a price of **$".. price .."** but doesn't have money.")
                end
                xPlayer.showNotification("No tienes dinero suficiente")
            end
        end
    end
end)


-- VERSION CHECKER DON'T DELETE THIS IF YOU WANT TO RECEIVE NEW UPDATES
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        function checkVersion(error, latestVersion, headers)
			local currentVersion = Config['Version']    
            local name = "[^4nek_vehicleshop^7]"
            Citizen.Wait(2000)
            
			if tonumber(currentVersion) < tonumber(latestVersion) then
				print(name .. " ^1is outdated.\nCurrent version: ^8" .. currentVersion .. "\nNewest version: ^2" .. latestVersion .. "\n^3Update^7: https://github.com/TtvNekix/nekix_vehicleshop")
			else
				print(name .. " is updated.")
			end
		end
	
		PerformHttpRequest("https://raw.githubusercontent.com/TtvNekix/vschecker/main/version", checkVersion, "GET")
    end
end)
-----------------------------------
