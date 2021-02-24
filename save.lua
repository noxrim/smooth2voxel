--options--

saveRegion = Region3.new( --region3 to save
	Vector3.new(556.365, -49.25, -549.184),
	Vector3.new(-585.811, 572.358, 579.458)
)

--code--

terrain = workspace:WaitForChild("Terrain")
maxAxisSize = 48

function snapRegionToCells(region)
	local regPos = region.CFrame.Position
	local regSize = region.Size
	local cornerA = regPos - regSize*0.5
	local cornerB = regPos + regSize*0.5
	return Region3.new(terrain:WorldToCell(cornerA)*4,terrain:WorldToCell(cornerB)*4)
end


function renderRegionAsPart(region)
	local part = Instance.new("Part",workspace)
	part.Size = Vector3.new(1,1,1)
	part.CFrame = region.CFrame
	part.Color = Color3.new(math.random(0,255)/255,math.random(0,255)/255,math.random(0,255)/255)
	local mesh = Instance.new("BlockMesh",part)
	mesh.Scale = region.Size
	
	spawn(function()
		wait(1)
		part:Remove()
	end)
	
end

function makeRegionPositive(region)
	local regPos = region.CFrame.Position
	local regSize = region.Size
	local cornerA = regPos - regSize*0.5
	local cornerB = regPos + regSize*0.5
	local newRegion = Region3.new(cornerA, cornerB)
	if newRegion.Size.X < 0 then
		local bufferA = cornerA.X
		local bufferB = cornerB.X
		cornerA = Vector3.new(bufferB, cornerA.Y, cornerA.Z)
		cornerB = Vector3.new(bufferA, cornerB.Y, cornerB.Z)
	end
	if newRegion.Size.Y < 0 then
		local bufferA = cornerA.Y
		local bufferB = cornerB.Y
		cornerA = Vector3.new(cornerA.X, bufferB, cornerA.Z)
		cornerB = Vector3.new(cornerB.X, bufferA, cornerB.Z)
	end
	if newRegion.Size.Z < 0 then
		local bufferA = cornerA.Z
		local bufferB = cornerB.Z
		cornerA = Vector3.new(cornerA.X, cornerA.Y, bufferB)
		cornerB = Vector3.new(cornerB.X, cornerB.Y, bufferA)
	end
	local newRegion = Region3.new(cornerA, cornerB)
	return newRegion
end


function splitX(region,maxSize)
	local splits = {}
	local regPos = region.CFrame.Position
	local regSize = region.Size
	local cornerA = regPos - regSize*0.5
	local cornerB = regPos + regSize*0.5
	for j = 1, math.ceil(regSize.X / maxSize) do
		local asdf = regSize.X - (maxSize*j)
		if regSize.X > maxSize then
			local a = nil
			local b = nil
			if asdf < 0 then
				a = Vector3.new(cornerA.X+(maxSize*(j-1)),cornerA.Y,cornerA.Z)
				b = Vector3.new(cornerA.X+(maxSize*j)+asdf,cornerB.Y,cornerB.Z)
			else
				a = Vector3.new(cornerA.X+(maxSize*(j-1)),cornerA.Y,cornerA.Z)
				b = Vector3.new(cornerA.X+(maxSize*j),cornerB.Y,cornerB.Z)
			end
			local funnyRegion = Region3.new(a,b)
			table.insert(splits,funnyRegion)
		end
	end
	return splits
end

function splitY(region,maxSize)
	local splits = {}
	local regPos = region.CFrame.Position
	local regSize = region.Size
	local cornerA = regPos - regSize*0.5
	local cornerB = regPos + regSize*0.5
	for j = 1, math.ceil(regSize.Y / maxSize) do
		local asdf = regSize.Y - (maxSize*j)
		if regSize.Y > maxSize then
			local a = nil
			local b = nil
			if asdf < 0 then
				a = Vector3.new(cornerA.X,cornerA.Y+(maxSize*(j-1)),cornerA.Z)
				b = Vector3.new(cornerB.X,cornerA.Y+(maxSize*j)+asdf,cornerB.Z)
			else
				a = Vector3.new(cornerA.X,cornerA.Y+(maxSize*(j-1)),cornerA.Z)
				b = Vector3.new(cornerB.X,cornerA.Y+(maxSize*j),cornerB.Z)
			end
			local funnyRegion = Region3.new(a,b)
			table.insert(splits,funnyRegion)
		end
	end
	return splits
end

function splitZ(region,maxSize)
	local splits = {}
	local regPos = region.CFrame.Position
	local regSize = region.Size
	local cornerA = regPos - regSize*0.5
	local cornerB = regPos + regSize*0.5
	for j = 1, math.ceil(regSize.Z / maxSize) do
		local asdf = regSize.Z - (maxSize*j)
		if regSize.Z > maxSize then
			local a = nil
			local b = nil
			if asdf < 0 then
				a = Vector3.new(cornerA.X,cornerA.Y,cornerA.Z+(maxSize*(j-1)))
				b = Vector3.new(cornerB.X,cornerB.Y,cornerA.Z+(maxSize*j)+asdf)
			else
				a = Vector3.new(cornerA.X,cornerA.Y,cornerA.Z+(maxSize*(j-1)))
				b = Vector3.new(cornerB.X,cornerB.Y,cornerA.Z+(maxSize*j))
			end
			local funnyRegion = Region3.new(a,b)
			table.insert(splits,funnyRegion)
		end
	end
	return splits
end

function splitRegion(region,maxSize)
	-- im sorry i had to split this into 3 different functions my brain literally could not understand it any other way
	local a = {}
	local b = {}
	local c = {}
	a = splitX(region,maxSize)
	for i = 1, #a do
		local ba = splitY(a[i],maxSize)
		for j = 1, #ba do
			table.insert(b,ba[j])
		end
	end
	for i = 1, #b do
		local ca = splitZ(b[i],maxSize)
		for j = 1, #ca do
			table.insert(c,ca[j])
		end
	end
	return c
end

game:GetService("ChangeHistoryService"):SetWaypoint("terrain save")

saveRegion = snapRegionToCells(saveRegion)

saveRegion = makeRegionPositive(saveRegion)

print("estimated regions: "..math.ceil((saveRegion.Size.X*saveRegion.Size.Y*saveRegion.Size.Z)/(maxAxisSize^3)))

regionSections = {}

print("splitting regions...")
wait(1)

regionSections = splitRegion(saveRegion, maxAxisSize)

for i = 1, #regionSections do
	renderRegionAsPart(regionSections[i])
end
	
print("done splitting, saving data...")
wait(1)
local tData = Instance.new("BoolValue",workspace)
tData.Name = "Terrain Data"

for i = 1, #regionSections do
	print("saving region "..tostring(i).."/"..tostring(#regionSections))
	local size = regionSections[i].Size
	local pos = regionSections[i].CFrame.Position
	local cornerA = pos - size*0.5
	local cornerB = pos + size*0.5
	local materials, occupancies = terrain:ReadVoxels(regionSections[i],4)
	local chunkData = Instance.new("StringValue",tData)
	chunkData.Name = tostring(i)
	local rDataStr = ""
	for x = 1, size.X, 1 do
        for y = 1, size.Y, 1 do
            for z = 1, size.Z, 1 do
				if occupancies[x] and occupancies[x][y] and occupancies[x][y][z] and materials[x] and materials[x][y] and materials[x][y][z] then
					rDataStr = rDataStr .. "|" .. x+(pos.X/4) .. "," .. y+(pos.Y/4) .. "," .. z+(pos.Z/4) .. "," .. tostring(materials[x][y][z]) .. "," .. tostring(occupancies[x][y][z])
				end
            end
        end
    end
	chunkData.Value = rDataStr
end

print("done saving!")
game:GetService("Selection"):Set({tData})