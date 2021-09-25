# guille_contextmenu (IF YOU RENAME THE SCRIPT WILL NOT WORK) https://discord.gg/eBpmkW6e5j 


Add in the cfg of your server -> ensure guille_contextmenu


## How to implement it

You can insert the data in many ways, this is an example:
```
RegisterCommand("testmenu", function()
    local data = {}
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola")]]})
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola1")]]})
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola2")]]})
    table.insert(data, {text = "Juanjo", toDo = [[TriggerServerEvent("hola3")]]})
    TriggerEvent("guille_cont:client:open", "Hola", data, false)
end)
    
    INSIDE [[]] THE CODE THAT THE BUTTON WILL EXECUTE
    
```
Use this event if you are using coords:
```
TriggerEvent("guille_cont:client:open", "Interaction menu" --[[Title of the menu]], data --[[Data of the script]], true, --[[Use coords = true, not using coords = false]] coords --[[The coords of the entity or place]])
```
If you are not using coords use this:
```
TriggerEvent("guille_cont:client:open", "Interaction menu" --[[Title of the menu]], data --[[Data of the script]], false, --[[Use coords = true, not using coords = false]])
```
You can set custom icons from https://fontawesome.com/v5.15/icons?d=gallery&p=1


## PREVIEW
https://streamable.com/57ww5q
