-- Mutant Islands V14: color the EXISTING imported Blender MeshParts.
-- Run once in Roblox Studio Command Bar in EDIT mode, after saving a backup.
-- Does not generate islands or modify their positions/mesh geometry.
local model=workspace:FindFirstChild("v14")
if not model then warn("Cannot find Workspace.v14"); return end
local ChangeHistoryService=game:GetService("ChangeHistoryService")
local palettes={
 {keys={"Verdant Refuge"},ground=Color3.fromRGB(95,169,83),leaf=Color3.fromRGB(60,137,67),stone=Color3.fromRGB(117,127,116),wood=Color3.fromRGB(115,80,52),path=Color3.fromRGB(184,151,105)},
 {keys={"Toxic Wilds"},ground=Color3.fromRGB(122,151,66),leaf=Color3.fromRGB(75,117,58),stone=Color3.fromRGB(93,112,84),wood=Color3.fromRGB(91,77,55),path=Color3.fromRGB(137,121,81)},
 {keys={"Crystal Hollow"},ground=Color3.fromRGB(110,176,200),leaf=Color3.fromRGB(103,199,198),stone=Color3.fromRGB(102,116,163),wood=Color3.fromRGB(89,95,134),path=Color3.fromRGB(153,166,198)},
 {keys={"Ashen Ridge"},ground=Color3.fromRGB(115,83,75),leaf=Color3.fromRGB(193,92,52),stone=Color3.fromRGB(82,74,77),wood=Color3.fromRGB(92,61,48),path=Color3.fromRGB(151,110,85)},
 {keys={"Frostspire"},ground=Color3.fromRGB(213,235,245),leaf=Color3.fromRGB(135,184,206),stone=Color3.fromRGB(143,172,194),wood=Color3.fromRGB(100,114,133),path=Color3.fromRGB(178,202,219)},
 {keys={"Stormwild"},ground=Color3.fromRGB(123,150,167),leaf=Color3.fromRGB(86,129,148),stone=Color3.fromRGB(95,104,140),wood=Color3.fromRGB(83,84,106),path=Color3.fromRGB(147,145,170)},
 {keys={"Ancient Core"},ground=Color3.fromRGB(199,165,110),leaf=Color3.fromRGB(140,150,92),stone=Color3.fromRGB(163,135,102),wood=Color3.fromRGB(116,88,65),path=Color3.fromRGB(210,177,124)},
}
local function biomeFor(n)
 for _,b in ipairs(palettes) do
  for _,key in ipairs(b.keys) do
   if n:lower():find(key:lower(),1,true) then return b end
  end
 end
end
local function typeFor(n)
 n=n:lower()
 if n:find("terrain") or n:find("ground") or n:find("island surface") then return "ground" end
 if n:find("road") or n:find("path") or n:find("trail") or n:find("bridge") or n:find("plaza") or n:find("combat area") then return "path" end
 if n:find("leaf") or n:find("canopy") or n:find("foliage") or n:find("bush") or n:find("grass") or n:find("fern") or n:find("fungal cap") then return "leaf" end
 if n:find("trunk") or n:find("branch") or n:find("stalk") or n:find("wood") or n:find("log") then return "wood" end
 if n:find("rock") or n:find("stone") or n:find("cliff") or n:find("ruin") or n:find("pillar") or n:find("crystal") or n:find("boulder") then return "stone" end
 return nil
end
local updated,skipped=0,0
ChangeHistoryService:SetWaypoint("Before V14 Biome Colors")
for _,p in ipairs(model:GetDescendants()) do
 if p:IsA("MeshPart") then
  local biome=biomeFor(p.Name)
  local kind=typeFor(p.Name)
  if biome and kind then
   p.Color=biome[kind]
   p.Material=(kind=="ground" and Enum.Material.Grass)
       or (kind=="leaf" and Enum.Material.Grass)
       or (kind=="wood" and Enum.Material.Wood)
       or (kind=="stone" and Enum.Material.Slate)
       or Enum.Material.Ground
   p.Transparency=0
   p.Anchored=true
   if kind=="ground" then
    p.DoubleSided=true
    p.CanCollide=true
   end
   updated+=1
  else
   skipped+=1
  end
 end
end
ChangeHistoryService:SetWaypoint("After V14 Biome Colors")
print(("V14 colors updated %d meshes; skipped %d (unrecognized names)."):format(updated,skipped))
-- Note: Imported Blender material slots are not automatically preserved in Roblox.
-- For single-color MeshParts this colors the entire object; multi-color meshes need textures.
