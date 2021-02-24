--options--

clearTerrain = true --clear terrain before importing
autowedge = true --automatically rotate wedges based on surrounding cells when importing
useNewerMaterialMap = true --use the newer material mappings from may 2016 when some new smooth terrain materials were added, if not use older mappings from before these existed

--code--

terrain = workspace:WaitForChild("Terrain")
sel = game:GetService("Selection"):Get()

materialMapOld = {}
materialMapOld["Enum.Material.Air"] = Enum.CellMaterial.Empty
materialMapOld["Enum.Material.Grass"] = Enum.CellMaterial.Grass
materialMapOld["Enum.Material.Sand"] = Enum.CellMaterial.Sand
materialMapOld["Enum.Material.Slate"] = Enum.CellMaterial.Granite
materialMapOld["Enum.Material.Concrete"] = Enum.CellMaterial.Asphalt
materialMapOld["Enum.Material.WoodPlanks"] = Enum.CellMaterial.WoodPlank
materialMapOld["Enum.Material.Water"] = Enum.CellMaterial.Water

materialMapNew = {}
materialMapNew["Enum.Material.Air"] = Enum.CellMaterial.Empty
materialMapNew["Enum.Material.Grass"] = Enum.CellMaterial.Grass
materialMapNew["Enum.Material.Sand"] = Enum.CellMaterial.Sand
materialMapNew["Enum.Material.Slate"] = Enum.CellMaterial.Granite
materialMapNew["Enum.Material.Concrete"] = Enum.CellMaterial.Iron
materialMapOld["Enum.Material.WoodPlanks"] = Enum.CellMaterial.WoodPlank
materialMapNew["Enum.Material.Asphalt"] = Enum.CellMaterial.Asphalt
materialMapNew["Enum.Material.Pavement"] = Enum.CellMaterial.MossyStone
materialMapNew["Enum.Material.Sandstone"] = Enum.CellMaterial.RedPlastic
materialMapNew["Enum.Material.Ice"] = Enum.CellMaterial.BluePlastic
materialMapNew["Enum.Material.Water"] = Enum.CellMaterial.Water

occupancyMap = {}
occupancyMap[0] = Enum.CellBlock.Solid
occupancyMap[1] = Enum.CellBlock.Solid
occupancyMap[0.5] = Enum.CellBlock.VerticalWedge
occupancyMap[0.3359375] = Enum.CellBlock.CornerWedge
occupancyMap[0.66796875] = Enum.CellBlock.InverseCornerWedge

function split(inputstr, sep) 
	sep=sep or '%s' 
	local t={}
	for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do 
		table.insert(t,field)  
		if s=="" then 
			return t 
		end
	end 
end

if useNewerMaterialMap then
	workingMatMap = materialMapNew
else
	workingMatMap = materialMapOld
end

if clearTerrain then
	terrain:Clear()
end

cellsToAutowedge = {}

if #sel == 1 then
	local tData = sel[1]
	if tData:IsA("BoolValue") and tData.Name == "Terrain Data" then
		chunkData = tData:GetChildren()
		for i = 1, #chunkData do
			local bruh = split(chunkData[i].Value,"|")
			for j = 2, #bruh do
				local bruhh = split(bruh[j],",")
				local cellShape = occupancyMap[tonumber(bruhh[5])] or Enum.CellBlock.Solid
				terrain:SetCell(
					math.floor(tonumber(bruhh[1]))-7,
					math.floor(tonumber(bruhh[2]))-7,
					math.floor(tonumber(bruhh[3]))-7,
					workingMatMap[bruhh[4]] or Enum.CellMaterial.Grass,
					cellShape,
					0
				)
				if cellShape ~= Enum.CellBlock.Solid then
					table.insert(cellsToAutowedge,Vector3.new(tonumber(bruhh[1]),tonumber(bruhh[2]),tonumber(bruhh[3])))
				end
			end
			print("chunk "..i.." of "..#chunkData)
		end
		for i = 1, #cellsToAutowedge do
			local pos = cellsToAutowedge[i]
			terrain:AutowedgeCell(pos.X-7,pos.Y-7,pos.Z-7)
		end
	else
		print("thats not terrain data")
	end
else
	print("select the terrain data u want to import")
end