First: 
Add this to your qb-core/shared.lua
	["delivery"] = {
		label = "Amazon",
		defaultDuty = true,
		grades = {
            ['0'] = {
                name = "Delivery man",
                payment = 50
            },
        },
	},
Picture Example:https://prnt.sc/1th4uuu

Add this to your qb-cityhall/client/main.lua:
https://prnt.sc/1th4yg9
And qb-cityhall/html/index.html: 
https://prnt.sc/1th50lo
 <div class="job-page-block" data-job="delivery"><p>Delivery</p></div>

