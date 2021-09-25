Config = {}
Config['Version'] = 1.1 -- DON'T TOUCH THIS

Config['EnableWebhook'] = false
Config['Webhook'] = "" -- Change me compulsory
Config['CommunityName'] = "Nekix Delivery Job Logs" -- Change me if you want
Config['CommunityLogo'] = 'https://cdn.discordapp.com/icons/838115320597446677/a96dc72395659c8d3921bece0ac2039d?size=256' -- Change me if you want
Config['Avatar'] = 'https://cdn.discordapp.com/icons/838115320597446677/a96dc72395659c8d3921bece0ac2039d?size=256' -- Change me if you want

Config['Delivery'] = {
    ['JobName'] = 'delivery',
    ['ActionKey'] = 38, -- E
    ['FinalPayout'] = {
        ['Min'] = 500,
        ['Max'] = 1000
    },
    ['Blips'] = {
        {
            ['x'] = -1177.998,
            ['y'] = -892.051,
            ['z'] = 13.757,
            ['sprite'] = 616,
            ['color'] = 47,
            ['scale'] = 0.75,
            ['label'] = "Delivery Center",
        }
    },
    ['Uniforms'] = { 
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
        ['Female'] = { -- Edit female clothes, i can't find good clothes for females peds
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
            ['coords'] = vector3(-1177.998, -892.051, 13.757),
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
                vector3(-1168.39, -882.855, 14.137),
            },
            ['rotation'] = 302.2133,
        },
        ['Deleter'] = vector3(-1173.832, -900.722, 15.0),
        ['Plate'] = "DELIVERY",
        ['Cars'] = {
            'rumpo',
        },
    },
    ['Destinations'] = { -- Add more Destinations writing more vector3(x, y, z)
        vector3(-284.3353, -601.2335, 33.5532),
        vector3(-292.3353, -601.2335, 33.5532),
    },
}


Config.Uniforms = {
	['male'] = {
		outfitData = {
			['t-shirt'] = {item = 15, texture = 0},
			['torso2']  = {item = 56, texture = 0},
			['arms']    = {item = 85, texture = 0},
			['pants']   = {item = 45, texture = 4},
			['shoes']   = {item = 42, texture = 2},
		}
	},
	['female'] = {
	 	outfitData = {
			['t-shirt'] = {item = 14, texture = 0},
			['torso2']  = {item = 22, texture = 0},
			['arms']    = {item = 85, texture = 0},
			['pants']   = {item = 47, texture = 4},
			['shoes']   = {item = 98, texture = 1},
	 	}
	},
}
