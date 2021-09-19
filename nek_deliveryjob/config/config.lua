Config = {}
Config['Version'] = 1.0 -- DON'T TOUCH THIS
Config['EsxVersion'] = 1.2 -- Available Version -> 1.1 / 1.2

Config['Delivery'] = {
    ['JobName'] = 'delivery',
    ['ActionKey'] = 38, -- E
    ['Menu'] = {
        {text = "Put Clothes", toDo = [[TriggerEvent('nek_deliveryjob:clothes', 'clothes')]], icon = "fas fa-user-tie"},
        {text = "Default Ped", toDo = [[TriggerEvent('nek_deliveryjob:clothes', 'ped')]], icon = "fas fa-tshirt"},
        {text = "Start Job", toDo = [[TriggerEvent('nek_deliveryjob:startJob')]], icon = "fas fa-truck-loading"},
    },
    ['Uniforms'] = { -- Edit female clothes, i can't find good clothes for females peds
        ['Male'] = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1'] = 13,   ['torso_2'] = 3,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 11,
            ['pants_1'] = 96,   ['pants_2'] = 0,
            ['shoes_1'] = 10,    ['shoes_2'] = 0,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['helmet_1'] = -1,    ['helmet_2'] = 0
        },
        ['Female'] = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1'] = 13,   ['torso_2'] = 3,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 11,
            ['pants_1'] = 96,   ['pants_2'] = 0,
            ['shoes_1'] = 10,    ['shoes_2'] = 0,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['helmet_1'] = -1,    ['helmet_2'] = 0
        }
    },
    ['Base'] = {
        {
            ['coords'] = vec3(-1177.998, -892.051, 13.757),
            ['text'] = "Press ~y~E ~w~to access to ~g~job options",
        }
    },
    ['Prop'] = {
        ['Model'] = 'prop_cs_cardbox_01',
        ['x'] = -1178.628,
        ['y'] = -887.744,
        ['z'] = 12.807, 
    },
    ['Vehicles'] = {
        ['Spawner'] = {
            ['coords'] = {
                vec3(-1168.39, -882.855, 14.137),
            },
            ['rotation'] = 302.2133,
        },
        ['Plate'] = "DELIVERY",
        ['Cars'] = {
            'rumpo',
            'rumpo2'
        },
    },
    ['Houses'] = {

    },
}