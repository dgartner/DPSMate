-- Global Variables
DPSMate.Modules.AurasLost = {}
DPSMate.Modules.AurasLost.Hist = "Auras"
DPSMate.Options.Options[1]["args"]["auraslost"] = {
	order = 240,
	type = 'toggle',
	name = 'Auras lost',
	desc = 'TO BE ADDED!',
	get = function() return DPSMateSettings["windows"][DPSMate.Options.Dewdrop:GetOpenedParent().Key]["options"][1]["auraslost"] end,
	set = function() DPSMate.Options:ToggleDrewDrop(1, "auraslost", DPSMate.Options.Dewdrop:GetOpenedParent()) end,
}

-- Register the moodule
DPSMate:Register("auraslost", DPSMate.Modules.AurasLost)


function DPSMate.Modules.AurasLost:GetSortedTable(arr)
	local b, a, total = {}, {}, 0
	for cat, val in pairs(arr) do -- 2 Target
		local CV = 0
		for ca, va in pairs(val) do -- 3 ability
			for c, v in pairs(va) do -- 1 Ability
				if c==2 then
					for ce, ve in pairs(v) do
						CV=CV+1
					end
				end
			end
		end
		local i = 1
		while true do
			if (not b[i]) then
				table.insert(b, i, CV)
				table.insert(a, i, cat)
				break
			else
				if b[i] < CV then
					table.insert(b, i, CV)
					table.insert(a, i, cat)
					break
				end
			end
			i=i+1
		end
		total = total + CV
	end
	return b, total, a
end

function DPSMate.Modules.AurasLost:EvalTable(user, k)
	local a, b, temp, total = {}, {}, {}, 0
	local arr = DPSMate:GetMode(k)
	for cat, val in pairs(arr[user[1]]) do -- 3 Ability
		local CV = 0
		for ca, va in pairs(val) do -- each one
			if ca==2 then
				for ce, ve in pairs(va) do
					CV=CV+1
				end
			end
		end
		if temp[cat] then temp[cat]=temp[cat]+CV else temp[cat]=CV end
	end
	for cat, val in pairs(temp) do
		local i = 1
		while true do
			if (not b[i]) then
				table.insert(b, i, val)
				table.insert(a, i, cat)
				break
			else
				if b[i] < val then
					table.insert(b, i, val)
					table.insert(a, i, cat)
					break
				end
			end
			i=i+1
		end
	end
	return a, total, b
end

function DPSMate.Modules.AurasLost:GetSettingValues(arr, cbt, k)
	local name, value, perc, sortedTable, total, a, p, strt = {}, {}, {}, {}, 0, 0, "", {[1]="",[2]=""}
	if DPSMateSettings["windows"][k]["numberformat"] == 2 then p = "K" end
	sortedTable, total, a = DPSMate.Modules.AurasLost:GetSortedTable(arr)
	for cat, val in pairs(sortedTable) do
		local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
		if dmg==0 then break end
		local str = {[1]="",[2]="",[3]=""}
		if DPSMateSettings["columnsauraslost"][1] then str[1] = " "..dmg..p; strt[2] = tot..p end
		if DPSMateSettings["columnsauraslost"][2] then str[3] = " ("..string.format("%.1f", 100*dmg/tot).."%)" end
		table.insert(name, DPSMate:GetUserById(a[cat]))
		table.insert(value, str[1]..str[3])
		table.insert(perc, 100*(dmg/sort))
	end
	return name, value, perc, strt
end

function DPSMate.Modules.AurasLost:ShowTooltip(user,k)
	local a,b,c = DPSMate.Modules.AurasLost:EvalTable(DPSMateUser[user], k)
	if DPSMateSettings["informativetooltips"] then
		for i=1, DPSMateSettings["subviewrows"] do
			if not a[i] then break end
			GameTooltip:AddDoubleLine(i..". "..DPSMate:GetAbilityById(a[i]),c[i],1,1,1,1,1,1)
		end
	end
end

