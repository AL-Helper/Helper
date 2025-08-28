local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = require(ReplicatedStorage.Shared.Inventory.Client)
local Replion = require(ReplicatedStorage.Packages.Replion)
local RAPData = Replion.Client:WaitReplion("ItemRAP")

local RemoveListing = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.1.0")
	:WaitForChild("net")
	:WaitForChild("RF/RemoveBoothListing")

local CreateListing = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.1.0")
	:WaitForChild("net")
	:WaitForChild("RF/CreatingBoothListing")

local categories = { "Sword", "Explosion", "Emote" }
local RAP_THRESHOLD = 50
local LOOP_DELAY = 3600 --1 jam hehe

local function RefreshBooth()
	for _, category in ipairs(categories) do
		local items = Client:Get(category)
		if items then
			for _, data in pairs(items) do
				local name = data.Name or "Unknown"

				local itemKey
				if data.Finisher == true then
					itemKey = string.format('[[\"Finisher\",true],[\"Name\",\"%s\"]]', name)
				else
					itemKey = string.format('[[\"Name\",\"%s\"]]', name)
				end

				local rap = RAPData:Get({ "Items", category, itemKey }) or 0

				if rap < RAP_THRESHOLD and data.TradeLock and data.TradeLock.Type == "Listing" then
					local tradeLockValue = data.TradeLock.Value
					if tradeLockValue then
						pcall(function()
							RemoveListing:InvokeServer(tradeLockValue)
							print("❌ Removed:", name, "| RAP:", rap, "| Finisher:", tostring(data.Finisher == true))
						end)
						task.wait(0.5)
					end
				end

				if rap >= RAP_THRESHOLD and (not data.TradeLock or data.TradeLock.Type ~= "Listing") then
					pcall(function()
						local args = {{
							ItemKey = itemKey,
							Type = category,
							Price = rap,
							Amount = 1
						}}
						CreateListing:InvokeServer(unpack(args))
						print("✅ Listed:", name, "| RAP:", rap, "| Finisher:", tostring(data.Finisher == true))
					end)

					task.wait(0.5) 
				end
			end
		end
	end
	print("🔁 Refresh selesai, tunggu " .. LOOP_DELAY .. " detik...")
end

while true do
	RefreshBooth()
	task.wait(LOOP_DELAY)
end
