-- Mutant Islands V14: recolor EXISTING Blender meshes, including unnamed props.
-- Run once in Roblox Studio Command Bar in EDIT mode. Save a backup first.
-- Never creates or deletes an island. Does not change geometry, position or size.
local root=workspace:FindFirstChild("v14")
if not root then warn("Workspace.v14 not found"); return end
local History=game:GetService("ChangeHistoryService")
local biomes={
 {key="verdant refuge",floor=Color3.fromRGB(93,162,77),foliage=Color3.fromRGB(55,130,61),wood=Color3.fromRGB(111,79,51),stone=Color3.fromRGB(115,122,110),accent=Color3.fromRGB(177,151,104)},
 {key="toxic wilds",floor=Color3.fromRGB(121,147,67),foliage=Color3.fromRGB(67,117,51),wood=Color3.fromRGB(95,78,53),stone=Color3.fromRGB(94,107,83),accent=Color3.fromRGB(163,130,74)},
 {key="crystal hollow",floor=Color3.fromRGB(106,164,190),foliage=Color3.fromRGB(91,191,182),wood=Color3.fromRGB(87,96,123),stone=Color3.fromRGB(103,113,156),accent=Color3.fromRGB(142,115,222)},
 {key="ashen ridge",floor=Color3.fromRGB(108,81,73),foliage=Color3.fromRGB(165,77,48),wood=Color3.fromRGB(93,64,51),stone=Color3.fromRGB(84,78,81),accent=Color3.fromRGB(237,102,48)},
 {key="frostspire",floor=Color3.fromRGB(210,231,239),foliage=Color3.fromRGB(123,177,192),wood=Color3.fromRGB(107,121,132),stone=Color3.fromRGB(149,174,195),accent=Color3.fromRGB(107,204,234)},
 {key="stormwild",floor=Color3.fromRGB(123,147,166),foliage=Color3.fromRGB(73,124,135),wood=Color3.fromRGB(82,91,105),stone=Color3.fromRGB(95,103,141),accent=Color3.fromRGB(167,144,230)},
 {key="ancient core",floor=Color3.fromRGB(194,159,107),foliage=Color3.fromRGB(134,151,91),wood=Color3.fromRGB(117,88,61),stone=Color3.fromRGB(156,130,101),accent=Color3.fromRGB(218,186,120)},
}
local terrain={}
for _,p in ipairs(root:GetDescendants()) do
 if p:IsA("MeshPart") and p.Name:lower():find("sculpted terrain",1,true) then
  for _,b in ipairs(biomes) do
   if p.Name:lower():find(b.key,1,true) then
    table.insert(terrain,{part=p,biome=b})
   end
  end
 end
end
if #terrain~=7 then
 warn("Expected 7 sculpted terrain meshes; found "..#terrain..". No changes made.")
 return
end
local function nearestBiome(part)
 local pos=part.Position
 local best,bestDist=nil,math.huge
 for _,entry in ipairs(terrain) do
  local c=entry.part.Position
  local d=(Vector3.new(pos.X,0,pos.Z)-Vector3.new(c.X,0,c.Z)).Magnitude
  if d<bestDist then bestDist=d; best=entry.biome end
 end
 return best
end
local function category(name)
 local s=name:lower()
 if s:find("sculpted terrain",1,true) then return "floor" end
 if s:find("road") or s:find("path") or s:find("trail") or s:find("bridge") or s:find("combat area") or s:find("plaza") then return "accent" end
 if s:find("canopy") or s:find("leaf") or s:find("foliage") or s:find("crown") or s:find("bush") or s:find("fern") or s:find("shrub") or s:find("grass") or s:find("mushroom cap") then return "foliage" end
 if s:find("trunk") or s:find("branch") or s:find("stalk") or s:find("log") or s:find("root") then return "wood" end
 if s:find("crystal") or s:find("gem") or s:find("lava") or s:find("glow") then return "accent" end
 if s:find("rock") or s:find("stone") or s:find("boulder") or s:find("pillar") or s:find("ruin") or s:find("cliff") then return "stone" end
 -- Blender often exports tree/rock components with generic names.
 -- Neutral stone is safer than guessing which parts are foliage.
 return "stone"
end
local materials={
 floor=Enum.Material.Grass,
 foliage=Enum.Material.Grass,
 wood=Enum.Material.Wood,
 stone=Enum.Material.Slate,
 accent=Enum.Material.Ground,
}
History:SetWaypoint("Before V14 Complete Recolor")
local count=0
for _,p in ipairs(root:GetDescendants()) do
 if p:IsA("MeshPart") then
  local biome=nearestBiome(p)
  local kind=category(p.Name)
  p.Color=biome[kind]
  p.Material=materials[kind]
  p.Anchored=true
  if kind=="floor" then
   p.DoubleSided=true
   p.CanCollide=true
  end
  count+=1
 end
end
History:SetWaypoint("After V14 Complete Recolor")
print("Recolored "..count.." existing V14 meshes. No geometry was replaced.")
