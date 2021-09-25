function log(ty, t)
    if ty == "error" then
        print("^3["..GetCurrentResourceName().."] ^1[ERROR] "..t)
    else
        print("^2["..GetCurrentResourceName().."] ^2[INFO]^8 "..t)
    end
end

local GUI = {}
GUI.Time = 0


local isThis = {}
isThis['selected'] = 1
isThis['data'] = {}

RegisterNetEvent("guille_cont:client:open")
AddEventHandler("guille_cont:client:open", function(title, data)
    if not isThis.menuOpened then
        local datas = -1
        if title == nil then
            log("error", "Title does not exist")
            return
        end
        for k,v in pairs(data) do
            datas = datas + 1
            if v.toDo == nil then
                log("error", "The data toDo does not exist in table data, read the guille_contextmenu docs")
                return
            end
            v.toDo = v.toDo:gsub('"', "'")
        end
        local toSend = {}
        for k, v in pairs(data) do
            isThis['data'][k] = v['toDo']
            table.insert(toSend, {text = v['text'], icon = v['icon']})
        end
        log("Menu created", '')
        isThis['data'] = data
        SendNUIMessage({
            title = title;
            data = toSend;
        })
        isThis.menuOpened = true
        TriggerEvent("openMenu", datas)
    end
end)

RegisterNUICallback("close", function(cb)
    PlaySoundFrontend(-1, 'Highlight_Cancel','DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    isThis.menuOpened = false
end)

RegisterNetEvent("openMenu")
AddEventHandler("openMenu", function(num)
    local selected = 0
    Citizen.CreateThread(function()
        Citizen.Wait(500)
        while isThis.menuOpened do
            if IsControlJustPressed(0, 18) and (GetGameTimer() - GUI.Time) > 500 then
                SendNUIMessage({
                    toExecute = tostring(selected);
                })
                assert(load(isThis['data'][isThis['selected']]['toDo']))()
                isThis['selected'] = 1
                isThis['data'] = {}
            end

            if IsControlJustPressed(0, 177) and (GetGameTimer() - GUI.Time) > 150 then
                SendNUIMessage({
                    move = "no"
                })
                isThis['selected'] = 1
                isThis['data'] = {}
            end

            if IsControlJustPressed(0, 27) and (GetGameTimer() - GUI.Time) > 150 then
                -- SUBIR
                if selected == 0 then
                    selected = num
                    SendNUIMessage({
                        selected = tostring(num);
                    })
                    
                elseif selected ~= 0 then
                    selected = selected - 1
                    SendNUIMessage({
                        selected = tostring(selected);
                    })
                end

                if isThis['selected'] == 1 then
                    isThis['selected'] = num + 1
                else
                    isThis['selected'] = isThis['selected'] - 1
                end
                
            end

            if IsControlJustPressed(0, 173) and (GetGameTimer() - GUI.Time) > 150 then
                -- BAJAR
                if selected == num then
                    selected = 0
                    SendNUIMessage({
                        selected = tostring(0);
                    })
                elseif selected ~= num then
                    selected = selected + 1
                    SendNUIMessage({
                        selected = tostring(selected);
                    })
                end

                if isThis['selected'] == (num + 1) then
                    isThis['selected'] = 1
                else
                    isThis['selected'] = isThis['selected'] + 1
                end
                
            end
            Citizen.Wait(0)
        end
    end)
end)
