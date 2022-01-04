Config = {}
Config['Version'] = 3.2 -- DON'T TOUCH THIS
Config['Locale'] = 'en' -- es // en

Config['EnableWebhook'] = false
Config['Webhook'] = "" -- Change me compulsory
Config['CommunityName'] = "Nekix Vehicle Shop Logs" -- Change me if you want
Config['CommunityLogo'] = 'https://cdn.discordapp.com/icons/838115320597446677/a96dc72395659c8d3921bece0ac2039d?size=256' -- Change me if you want
Config['Avatar'] = 'https://cdn.discordapp.com/icons/838115320597446677/a96dc72395659c8d3921bece0ac2039d?size=256' -- Change me if you want

Config['VS'] = {
    ['PressKey'] = 38, -- E
    ['NeedLicense'] = false, -- Need license? Dependency --> esx_license
    ['LicenseRequired'] = 'drive', -- Only if ['NeedLicense'] is true
    ['PersonalizedPlate'] = true,
    ['RandomPlate'] = false, -- Random letters and numbers
    ['TestTime'] = 1, -- IN MINUTES! Minutes, not ms
    ['BackToVSAfterTest'] = true, -- Back to the Vehicle Shop after the drive test finished
    ['Menu'] = {
        {label = "Test de conduccion del coche", value = 'test'}, -- Only if ['DriveTest'] is true ^^
        {label = "Inserta Matricula Personalizada", value = 'plate'}, -- Only if ['PersonalizedPlate'] is true ^^
        {label = "Pagar con Dinero en Mano", value = 'money'},
        {label = "Pgar con Dinero del Banco", value = 'bank'}
    },
    ['Blips'] = {
        {
            ['x'] = 222.1689,
            ['y'] = -852.3805,
            ['z'] = 30.06906,
            ['sprite'] = 523,
            ['color'] = 47,
            ['scale'] = 0.75,
            ['label'] = "Concesionario VIP",
        },
        {
            ['x'] = -53.45557,
            ['y'] = -1116.232,
            ['z'] = 26.435,
            ['sprite'] = 523,
            ['color'] = 47,
            ['scale'] = 0.75,
            ['label'] = "Vehicle Shop 2",
        }
    },
    ['Cars'] = {
        {
            ['model'] = 'blista',
            ['label'] = "Blista",
            ['price'] = 4,
            ['x'] = 227.5898,
            ['y'] = -873.8725,
            ['z'] = 30.4921,
            ['r'] = -12.9241,
            ['spawner'] = 'Test1'
        },
        {
            ['model'] = 'bati',
            ['label'] = "Bati",
            ['price'] = 1,
            ['x'] = -53.45557,
            ['y'] = -1116.232,
            ['z'] = 26.435,
            ['r'] = 7.3242,
            ['spawner'] = 'Test2'
        },
    },
    ['Spawners'] = {
        ['Test1'] = {
            ['x'] = 222.1689,
            ['y'] = -852.3805,
            ['z'] = 31.06906,
            ['r'] = -110.8709
        },
        ['Test2'] = {
            ['x'] = -30.98,
            ['y'] = -1089.839,
            ['z'] = 27.0,
            ['r'] = 334.4646
        },
    },
    ['Sellers'] = {
        ['Percentage'] = 50, -- 50%, you can change it.
        ['Locations'] = {
            {
                ['x'] = -45.24,
                ['y'] = -1083.221,
                ['z'] = 26.721,
            },
        }
    }
}
