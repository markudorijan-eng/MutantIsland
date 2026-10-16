-- Mutant Islands: gameplay markers, walkable roads, enemies and quest NPCs.
-- Paste into Studio Command Bar in EDIT mode. Save a backup first.
-- Creates only a separate folder; does not edit or replace Blender v14.
local root=workspace:FindFirstChild("v14")
if not root then warn("Workspace.v14 not found"); return end
local terrain={}
for _,obj in ipairs(root:GetDescendants()) do
 if obj:IsA("MeshPart") and obj.Name:lower():find("sculpted terrain",1,true) then
  table.insert(terrain,obj)
 end
end
if #terrain~=7 then warn("Expected seven terrain meshes, found "..#terrain); return end
local old=workspace:FindFirstChild("MutantGameplay")
if old then old:Destroy() end
local folder=Instance.new("Folder");folder.Name="MutantGameplay";folder.Parent=workspace
local function makePart(name,size,cf,color,material,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
 p.Material=material;p.Anchored=true;p.CanCollide=true;p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function label(part,title,subtitle)
 local bb=Instance.new("BillboardGui");bb.Name="Info";bb.Size=UDim2.fromOffset(210,75)
 bb.StudsOffsetWorldSpace=Vector3.new(0,5,0);bb.AlwaysOnTop=true;bb.MaxDistance=110;bb.Parent=part
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=0.3
 t.BackgroundColor3=Color3.fromRGB(25,32,37);t.TextColor3=Color3.new(1,1,1)
 t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.Text=title.."\n"..subtitle;t.Parent=bb
end
local function pointOn(mesh,dx,dz)
 -- Terrain mesh bounding box is only used for horizontal location.
 -- Raycast down to its actual top face, so paths are not suspended in the air.
 local x=mesh.Position.X+dx
 local z=mesh.Position.Z+dz
 local origin=Vector3.new(x,mesh.Position.Y+mesh.Size.Y+500,z)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
 params.FilterDescendantsInstances={mesh}
 local hit=workspace:Raycast(origin,Vector3.new(0,-2000,0),params)
 return hit and (hit.Position+Vector3.new(0,0.6,0)) or nil
end
local names={
 ["verdant refuge"]={"Moss Crawler","Thorn Brute","Ancient Treant"},
 ["toxic wilds"]={"Bog Leech","Venom Stalker","Toxic Hydra"},
 ["crystal hollow"]={"Shardling","Crystal Warden","Prism Titan"},
 ["ashen ridge"]={"Ash Imp","Magma Hound","Magma Colossus"},
 ["frostspire"]={"Snow Wisp","Frost Knight","Frost Guardian"},
 ["stormwild"]={"Spark Sprite","Thunder Harpy","Thunder Roc"},
 ["ancient core"]={"Dust Sentinel","Relic Guardian","Eternal Guardian"}
}
local function buildRoad(parent,mesh,a,b)
 local prev
 for i=0,28 do
  local alpha=i/28
  local dx=a.X+(b.X-a.X)*alpha
  local dz=a.Z+(b.Z-a.Z)*alpha
  local pos=pointOn(mesh,dx,dz)
  if pos and prev then
   local delta=pos-prev
   local len=delta.Magnitude
   if len>0.1 and len<20 then
    local p=makePart("WalkableRoad",Vector3.new(8,0.35,len+0.6),CFrame.lookAt((pos+prev)/2,pos),Color3.fromRGB(169,144,109),Enum.Material.Cobblestone,parent)
    p.CanCollide=true
   end
  end
  prev=pos
 end
end
local made=0
for _,mesh in ipairs(terrain) do
 local key=mesh.Name:lower()
 local mobs
 for theme,data in pairs(names) do
  if key:find(theme,1,true) then mobs=data;break end
 end
 if not mobs then continue end
 local island=Instance.new("Model");island.Name=mesh.Name:gsub(" sculpted terrain","").." Gameplay";island.Parent=folder
 -- Compact local paths near terrain center; skips positions with no solid terrain.
 local center=pointOn(mesh,0,0)
 local spots={Vector3.new(-32,0,-26),Vector3.new(34,0,-24),Vector3.new(8,0,40)}
 if center then
  local hub=makePart("QuestHub",Vector3.new(12,1,12),CFrame.new(center),Color3.fromRGB(220,185,114),Enum.Material.Cobblestone,island)
  for quest,offset in ipairs(spots) do
   local pos=pointOn(mesh,offset.X,offset.Z)
   if pos then
    buildRoad(island,mesh,Vector3.new(0,0,0),offset)
    local npc=makePart("QuestNPC_"..quest,Vector3.new(4,7,4),CFrame.new(pos+Vector3.new(0,4,0)),Color3.fromRGB(247,193,88),Enum.Material.SmoothPlastic,island)
    label(npc,"QUEST "..quest,quest==1 and "Defeat 10 "..mobs[1] or quest==2 and "Defeat 6 "..mobs[2] or "Defeat "..mobs[3])
    for n=1,(quest==3 and 1 or 4) do
     local angle=n*math.pi*2/(quest==3 and 1 or 4)
     local ep=pointOn(mesh,offset.X+math.cos(angle)*12,offset.Z+math.sin(angle)*12)
     if ep then
      local enemy=makePart(mobs[quest],Vector3.new(5,5,5),CFrame.new(ep+Vector3.new(0,3,0)),quest==1 and Color3.fromRGB(111,192,100) or quest==2 and Color3.fromRGB(204,113,96) or Color3.fromRGB(150,94,206),Enum.Material.SmoothPlastic,island,Enum.PartType.Ball)
      enemy.CanCollide=false
      label(enemy,mobs[quest],quest==3 and "BOSS" or "ENEMY")
     end
    end
   end
  end
  made+=1
 else
  warn("No terrain raycast at center of "..mesh.Name.."; skipped gameplay on this island")
 end
end
print("Gameplay placeholders placed on "..made.." Blender islands. Roads, enemies and NPCs are visual prototypes only; combat/quests not yet scripted.")
