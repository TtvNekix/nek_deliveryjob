Delivery = {}
Delivery.Functions = {}

Delivery.Functions.SendWB = function(msg)
	if Config['EnableWebhook'] then
		PerformHttpRequest(Config['Webhook'], function(err, text, headers) end, 'POST', json.encode({
			username = Config['Username'],
			embeds = {{
				["color"] = color,
				["author"] = {
					["name"] = Config['CommunityName'],
					["icon_url"] = Config['CommunityLogo']
				},
				["description"] = "".. msg .."",
				["footer"] = {
					["text"] = "• "..os.date("%x %X %p"),
				},
			}}, 
			avatar_url = Config['Avatar']
		}),
		{
			['Content-Type'] = 'application/json'
		})
	end
end

RegisterNetEvent('nek_delivery:wb', function(msg)
	Delivery.Functions.SendWB(msg)
end)

RegisterNetEvent('nek_delivery:pay', function(quantity)
	local xPlayer = ESX.GetPlayerFromId(source)

	if quantity > Config['Delivery']['FinalPayout']['Max'] then
		Delivery.Functions.SendWB("The player with Identifier " ..xPlayer.identifier.. " have tried to get more money than the maximum indicated in the config.lua")
	else
		xPlayer.addMoney(quantity)
		TriggerClientEvent('esx:showNotification', source, 'You received ~g~$' ..tonumber(quantity))
		Delivery.Functions.SendWB("The player with Identifier " ..xPlayer.identifier.. " received **$" ..quantity.. "**")
	end
end)


-- VERSION CHECKER DON'T DELETE THIS IF YOU WANT TO RECEIVE NEW UPDATES
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        function checkVersion(error, latestVersion, headers)
			local currentVersion = Config['Version']    
            local name = "[^4nek_delivery^7]"
            Citizen.Wait(2000)
            
			if tonumber(currentVersion) < tonumber(latestVersion) then
				print(name .. " ^1is outdated.\nCurrent version: ^8" .. currentVersion .. "\nNewest version: ^2" .. latestVersion .. "\n^3Update^7: https://github.com/TtvNekix/nekix_deliverychecker")
			else
				print(name .. " is updated.")
			end
		end

		function checkUpdates(error2, update, headers2)
			local updates = update
			local name = "[^4nek_delivery^7]"
            Citizen.Wait(2000)
            
			print(name .." Last Updates \n [\n".. tostring(updates) .."\n]")
		end
	
		PerformHttpRequest("https://raw.githubusercontent.com/TtvNekix/deliverychecker/main/version", checkVersion, "GET")
		PerformHttpRequest("https://raw.githubusercontent.com/TtvNekix/deliverychecker/main/last-updates", checkUpdates, "GET")
    end
end)
-----------------------------------
