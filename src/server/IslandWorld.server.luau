-- Mutant Islands: visible, playable, colorful starter world.
-- Rojo syncs this server script; press Play to generate the islands.
-- Existing Workspace models are left untouched.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local old = Workspace:FindFirstChild("MutantIslandsGenerated")
if old then old:Destroy() end
local world = Instance.new("Folder")
world.Name = "MutantIslandsGenerated"
world.Parent = Workspace

local function part(name, size, cf, color, material, parent, shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Anchored=true
    p.CanCollide=true
    p.Color=color
    p.Material=material
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    p.Parent=parent or world
    return p
end

local themes={
    {name="Verdant Refuge",pos=Vector3.new(0,65,0),ground=Color3.fromRGB(91,166,84),accent=Color3.fromRGB(45,109,58),mat=Enum.Material.Grass},
    {name="Toxic Wilds",pos=Vector3.new(340,65,0),ground=Color3.fromRGB(120,153,66),accent=Color3.fromRGB(64,100,42),mat=Enum.Material.Ground},
    {name="Crystal Hollow",pos=Vector3.new(212,65,266),ground=Color3.fromRGB(105,178,205),accent=Color3.fromRGB(96,86,183),mat=Enum.Material.Slate},
    {name="Ashen Ridge",pos=Vector3.new(-212,65,266),ground=Color3.fromRGB(109,80,73),accent=Color3.fromRGB(225,94,43),mat=Enum.Material.Basalt},
    {name="Frostspire",pos=Vector3.new(-340,65,0),ground=Color3.fromRGB(204,231,243),accent=Color3.fromRGB(100,172,219),mat=Enum.Material.Snow},
    {name="Stormwild",pos=Vector3.new(-212,65,-266),ground=Color3.fromRGB(117,145,166),accent=Color3.fromRGB(87,92,184),mat=Enum.Material.Slate},
    {name="Ancient Core",pos=Vector3.new(212,65,-266),ground=Color3.fromRGB(199,160,105),accent=Color3.fromRGB(125,90,65),mat=Enum.Material.Sand},
}

local function tree(parent, pos, scale, leaves)
    part("TreeTrunk",Vector3.new(4,17,4)*scale,CFrame.new(pos+Vector3.new(0,8.5*scale,0)),Color3.fromRGB(104,75,50),Enum.Material.Wood,parent)
    local canopy=part("TreeCanopy",Vector3.new(17,18,17)*scale,CFrame.new(pos+Vector3.new(0,21*scale,0)),leaves,Enum.Material.Grass,parent,Enum.PartType.Ball)
    canopy.CanCollide=false
end

local starterSpawn
for i,t in ipairs(themes) do
    local model=Instance.new("Model")
    model.Name=t.name
    model.Parent=world
    local center=t.pos
    local ground=part("Ground",Vector3.new(205,18,205),CFrame.new(center),t.ground,t.mat,model)
    ground.Shape=Enum.PartType.Cylinder
    -- Cylinder's axis is X, so rotate it to make a flat island.
    ground.CFrame=CFrame.new(center)*CFrame.Angles(0,0,math.rad(90))
    -- The cylinder thickness is local X; local Y/Z are the diameter.
    ground.Size=Vector3.new(18,205,205)
    local top=center.Y+9
    part("IslandRock",Vector3.new(16,190,190),CFrame.new(center-Vector3.new(0,12,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(89,91,96),Enum.Material.Rock,model,Enum.PartType.Cylinder)
    part("CentralPlaza",Vector3.new(35,1,35),CFrame.new(center+Vector3.new(0,9.6,0)),Color3.fromRGB(204,188,152),Enum.Material.Cobblestone,model)
    for j=1,12 do
        local angle=(j/12)*math.pi*2
        local radius=59+(j%3)*9
        local offset=Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
        if i==1 or i==2 or i==6 then
            tree(model,center+offset+Vector3.new(0,9,0),0.7+(j%3)*0.13,t.accent)
        else
            local rock=part("BiomeRock",Vector3.new(7+(j%3)*3,9+(j%4)*3,8+(j%3)*3),CFrame.new(center+offset+Vector3.new(0,14,0))*CFrame.Angles(0,j,0),t.accent,Enum.Material.Rock,model)
            rock.CanCollide=true
        end
    end
    local sign=part("IslandNameSign",Vector3.new(24,8,1),CFrame.new(center+Vector3.new(0,17,-26)),t.accent,Enum.Material.Wood,model)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.Parent=sign
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.Text=t.name
    label.TextScaled=true
    label.TextColor3=Color3.new(1,1,1)
    label.Font=Enum.Font.GothamBold
    label.Parent=gui
    if i==1 then
        local spawn=Instance.new("SpawnLocation")
        spawn.Name="MutantIslandsSpawn"
        spawn.Size=Vector3.new(13,1,13)
        spawn.CFrame=CFrame.new(center+Vector3.new(0,10.6,0))
        spawn.Anchored=true
        spawn.Neutral=true
        spawn.Enabled=true
        spawn.CanCollide=true
        spawn.Transparency=0
        spawn.Color=Color3.fromRGB(87,203,131)
        spawn.Material=Enum.Material.Neon
        spawn.Parent=model
        starterSpawn=spawn
    end
end

-- Existing spawn pads can take priority over a newly created SpawnLocation.
-- Force both initial spawn and respawns to the safe starter island.
if starterSpawn then
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("SpawnLocation") and descendant ~= starterSpawn then
            descendant.Enabled = false
        end
    end
    local function attachPlayer(player)
        player.RespawnLocation = starterSpawn
        local function placeCharacter(character)
            local root = character:WaitForChild("HumanoidRootPart", 10)
            if not root then return end
            task.wait(0.15)
            if character.Parent then
                character:PivotTo(starterSpawn.CFrame * CFrame.new(0, 5, 0))
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
        player.CharacterAdded:Connect(placeCharacter)
        if player.Character then task.defer(placeCharacter, player.Character) end
    end
    Players.PlayerAdded:Connect(attachPlayer)
    for _, player in ipairs(Players:GetPlayers()) do attachPlayer(player) end
end

Lighting.ClockTime=13.5
Lighting.Brightness=2.5
Lighting.Ambient=Color3.fromRGB(125,133,145)
Lighting.OutdoorAmbient=Color3.fromRGB(145,155,165)
print("Mutant Islands: 7 colorful islands and a working spawn generated!")
