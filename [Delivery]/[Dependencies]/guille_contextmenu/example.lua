RegisterCommand("testmenu", function()
    local data = {}
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola")]]})
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola1")]]})
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola2")]]})
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola3")]]})
    TriggerEvent("guille_cont:client:open", "Hola", data)
end)
