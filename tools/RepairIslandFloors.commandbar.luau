-- Mutant Islands: SAFE floor/color repair for existing island models.
-- In Roblox Studio Edit mode: select island Models in Explorer,
-- then paste this file's contents into View > Command Bar and run ONCE.
-- Save a backup first. This script does NOT create missing terrain.
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local themes = {
 {keys={"verdant","forest","refuge"}, color=Color3.fromRGB(91,158,80), material=Enum.Material.Grass},
 {keys={"toxic","swamp","bog"}, color=Color3.fromRGB(104,126,62), material=Enum.Material.Ground},
 {keys={"crystal","hollow"}, color=Color3.fromRGB(113,176,204), material=Enum.Material.Slate},
 {keys={"ashen","volcano","ridge"}, color=Color3.fromRGB(98,76,73), material=Enum.Material.Basalt},
 {keys={"frost","ice","snow"}, color=Color3.fromRGB(204,229,239), material=Enum.Material.Snow},
 {keys={"storm","thunder"}, color=Color3.fromRGB(105,126,157), material=Enum.Material.Slate},
 {keys={"ancient","core","desert"}, color=Color3.fromRGB(185,152,109), material=Enum.Material.Sand},
}
local function themeFor(name)
 local s=name:lower()
 for _,t in ipairs(themes) do
  for _,key in ipairs(t.keys) do
   if s:find(key,1,true) then return t end
  end
 end
 return nil
end
local function isFloor(name)
 local s=name:lower()
 for _,key in ipairs({"ground","terrain","floor","landmass","islandbase","surface"}) do
  if s:find(key,1,true) then return true end
 end
 return false
end
local selected=Selection:Get()
if #selected==0 then warn("Select your island Models in Explorer first."); return end
local updated,missing=0,0
ChangeHistoryService:SetWaypoint("Before Mutant Islands Repair")
for _,island in ipairs(selected) do
 if not island:IsA("Model") then continue end
 local theme=themeFor(island.Name)
 if not theme then warn("Skipped unrecognized island: "..island.Name); continue end
 local found=false
 for _,part in ipairs(island:GetDescendants()) do
  if part:IsA("BasePart") and isFloor(part.Name) then
   found=true
   part.Anchored=true
   part.CanCollide=true
   part.CanQuery=true
   part.Transparency=0
   part.Color=theme.color
   part.Material=theme.material
   if part:IsA("MeshPart") then
    part.CollisionFidelity=Enum.CollisionFidelity.Hull
   end
   updated+=1
  end
 end
 if not found then
  missing+=1
  warn(island.Name..": No floor/ground named part found. Check its mesh or Terrain manually.")
 end
end
ChangeHistoryService:SetWaypoint("After Mutant Islands Repair")
print(("Floor repair finished: %d parts updated; %d islands need manual ground inspection."):format(updated,missing))
