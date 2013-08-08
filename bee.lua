-- BeeAnalyzer 4.3
-- Original code by Direwolf20
-- Hotfix 1 by Mandydax
-- Hotfix 2 by Mikeyhun/MaaadMike
-- 4.0 Major overhaul by MacLeopold
--     Breeds bees with best attributes in this order:
--     fertility, speed, nocturnal, flyer, cave, temperature tolerance, humidity tolerance
--     other attributes are ignored (lifespawn, flowers, effect and territory)
--     Can specify multiple target species to help with keeping to the correct line
-- 4.1 Minor fix for FTB Unleashed, no more inventory module or suckSneaky needed
-- 4.2 Major overhaul 2
--     Added magic bees, removed old bees
--     Added species graph
--     Changed targeting to target parent species
--     Changed breeding to keep stock of good bees to prevent losing attributes
--     Added logging
--     Changed scoring to look for best combination of princess and drone
-- 4.3 Updated targeting

-- attribute scoring for same species tie-breaking -----------------------------

scoresFertility = {
  [1] = 0.1,
  [2] = 0.2,
  [3] = 0.3,
  [4] = 0.4
}
scoresSpeed = {
  ["0.3"] = 0.01,
  ["0.6"] = 0.02,
  ["0.8"] = 0.03,
  ["1"]   = 0.04,
  ["1.2"] = 0.05,
  ["1.4"] = 0.06,
  ["1.7"] = 0.07
}
scores = {
  diurnal      =0.004,
  nocturnal    =0.002,
  tolerantFlyer=0.001,
  caveDwelling =0.0001
}
scoresTolerance = {
  ["NONE"]   = 0.00000,
  ["UP_1"]   = 0.00001,
  ["UP_2"]   = 0.00002,
  ["UP_3"]   = 0.00003,
  ["DOWN_1"] = 0.00001,
  ["DOWN_2"] = 0.00002,
  ["DOWN_3"] = 0.00003,
  ["BOTH_1"] = 0.00002,
  ["BOTH_2"] = 0.00004,
  ["BOTH_3"] = 0.00006
}

-- the bee graph ---------------------------------------------------------------

bees = {}

function addParent(parent, offspring)
  if bees[parent] then
    bees[parent].mutateTo[offspring] = true
  else
    bees[parent] = {
      --name = parent,
      score = nil,
      mutateTo = {[offspring]=true},
      mutateFrom = {}
    }
  end
end

function addOffspring(offspring, parentss)
  if bees[offspring] then
    for i, parents in ipairs(parentss) do
      table.insert(bees[offspring].mutateFrom, parents)
    end
  else
    bees[offspring] = {
      score = nil,
      mutateTo = {},
      mutateFrom = parentss
    }
  end
  for i, parents in ipairs(parentss) do
    for i, parent in ipairs(parents) do
      addParent(parent, offspring)
    end
  end
end

-- score bees that have no parent combinations as 1
-- iteratively find the next bee up the line and increase the score
function scoreBees()
  -- find all bees with no mutateFrom data
  local beeCount = 0
  local beeScore = 1
  for name, beeData in pairs(bees) do
    if #beeData.mutateFrom == 0 then
      beeData.score = beeScore
    else
      beeCount = beeCount + 1
    end
  end
  while beeCount > 0 do
    beeScore = beeScore * 4
    -- find all bees where all parent combos are scored
    for name, beeData in pairs(bees) do
      if not beeData.score then
        local scoreBee = true
        for i, beeParents in ipairs(beeData.mutateFrom) do
          local parent1 = bees[beeParents[1]]
          local parent2 = bees[beeParents[2]]

          if not parent1.score
              or parent1.score == beeScore
              or not parent2.score
              or parent2.score == beeScore then
            scoreBee = false
            break
          end
        end
        if scoreBee then
          beeData.score = beeScore
          beeCount = beeCount - 1
        end
      end
    end
  end
end

-- produce combinations from 1 or 2 lists
function choose(list, list2)
  local newList = {}
  if list2 then
    for i = 1, #list2 do
      for j = 1, #list do
        if list[j] ~= list[i] then
          table.insert(newList, {list[j], list2[i]})
        end
      end
    end
  else
    for i = 1, #list do
      for j = i, #list do
        if list[i] ~= list[j] then
          table.insert(newList, {list[i], list[j]})
        end
      end
    end
  end
  return newList
end

-- Forestry Bees ---------------------------------------------------------------

-- Agrarian Branch
addOffspring("Rural", {{"Diligent", "Meadows"}})
addOffspring("Farmed", {{"Rural", "Cultivated"}})
-- Apis Branch
addOffspring("Common", choose({"Forest", "Meadows", "Modest", "Marbled", "Tropical", "Wintry", "Marshy", "Water", "Rocky", "Embittered", "Unusual", "Mystical", "Sorcerous", "Attuned"}))
addOffspring("Cultivated", choose({"Common"}, {"Forest", "Meadows", "Modest", "Marbled", "Tropical", "Wintry", "Marshy", "Water", "Rocky", "Embittered", "Unusual", "Mystical", "Sorcerous", "Attuned"}))
-- Austere Branch
addOffspring("Frugal", {{"Sinister", "Modest"}, {"Fiendish", "Modest"}})
addOffspring("Austere", {{"Frugal", "Modest"}})
-- Beastly Branch
addOffspring("Jaded", {{"Ender", "Relic"}})
-- End Branch
addOffspring("Spectral", {{"Hermitic", "Ender"}})
addOffspring("Phantasmal", {{"Spectral", "Ender"}})
-- Festive Branch
addOffspring("Celebratory", {{"Austere", "Excited"}})
addOffspring("Hazardous", {{"Austere", "Desolate"}})
addOffspring("Leporine", {{"Meadows", "Forest"}})
addOffspring("Merry", {{"Wintry", "Forest"}})
addOffspring("Tipsy", {{"Wintry", "Meadows"}})
-- Frozen Branch
addOffspring("Icy", {{"Industrious", "Wintry"}})
addOffspring("Glacial", {{"Icy", "Wintry"}})
addOffspring("Frigid", {{"Diligent", "Wintry"}})
addOffspring("Absolute", {{"Frigid", "Ocean"}})
-- Heroic Branch
addOffspring("Heroic", {{"Steadfast", "Valiant"}})
-- Industrious Branch
addOffspring("Diligent", {{"Cultivated", "Common"}})
addOffspring("Unweary", {{"Diligent", "Cultivated"}})
addOffspring("Industrious", {{"Unweary", "Diligent"}})
-- Infernal Branch
addOffspring("Sinister", {{"Cultivated", "Modest"}, {"Cultivated", "Tropical"}})
addOffspring("Fiendish", {{"Sinister", "Cultivated"}, {"Sinister", "Modest"}, {"Sinister", "Tropical"}})
addOffspring("Demonic", {{"Fiendish", "Sinister"}})
-- Monastic Branch
addOffspring("Secluded", {{"Monastic", "Austere"}})
addOffspring("Hermitic", {{"Secluded", "Monastic"}})
-- Nobel Branch
addOffspring("Nobel", {{"Cultivated", "Common"}})
addOffspring("Majestic", {{"Nobel", "Cultivated"}})
addOffspring("Imperial", {{"Majestic", "Nobel"}})
-- Tropical Branch
addOffspring("Exotic", {{"Austere", "Tropical"}})
addOffspring("Edenic", {{"Exotic", "Tropical"}})
-- Vengeful Branch
addOffspring("Vindictive", {{"Monastic", "Demonic"}})
addOffspring("Vengeful", {{"Vindictive", "Demonic"}, {"Vindictive", "Monastic"}})
addOffspring("Avenging", {{"Vengeful", "Vindictive"}})

-- Extra Bees ------------------------------------------------------------------

-- Agricultural Branch
addOffspring("Bovine", {{"Rural", "Water"}})
addOffspring("Caffeinated", {{"Rural", "Tropical"}})
addOffspring("Citrus", {{"Farmed", "Modest"}})
addOffspring("Fermented", {{"Rural", "Fruity"}})
addOffspring("Minty", {{"Farmed", "Tropical"}})
-- Alloyed Branch
addOffspring("Impregnable", {{"Resilient", "Nobel"}})
-- Aquatic Branch
addOffspring("River", {{"Common", "Water"}})
addOffspring("Ocean", {{"Diligent", "Water"}})
addOffspring("Stained", {{"Ocean", "Ebony"}})
-- Barren Branch
addOffspring("Arid", {{"Meadows", "Modest"}})
addOffspring("Barren", {{"Arid", "Common"}})
addOffspring("Desolate", {{"Barren", "Arid"}})
-- Boggy Branch
addOffspring("Damp", {{"Common", "Marshy"}})
addOffspring("Boggy", {{"Damp", "Marshy"}})
addOffspring("Fungal", {{"Boggy", "Damp"}})
-- Caustic Branch
addOffspring("Corrosive", {{"Virulent", "Sticky"}})
addOffspring("Caustic", {{"Corrosive", "Fiendish"}})
addOffspring("Acidic", {{"Caustic", "Corrosive"}})
-- Energetic Branch
addOffspring("Excited", {{"Cultivated", "Valiant"}})
addOffspring("Energetic", {{"Excited", "Valiant"}})
addOffspring("Ecstatic", {{"Energetic", "Excited"}})
-- Fossilized
addOffspring("Fossiled", {{"Primeval", "Growing"}})
addOffspring("Oily", {{"Primeval", "Ocean"}})
addOffspring("Preserved", {{"Primeval", "Boggy"}})
addOffspring("Resinous", {{"Primeval", "Fungal"}})
-- Gemstone Branch
addOffspring("Diamond", {{"Lapis", "Imperial"}})
addOffspring("Emerald", {{"Lapis", "Noble"}})
addOffspring("Ruby", {{"Emerald", "Austere"}})
addOffspring("Sapphire", {{"Emerald", "Ocean"}})
-- Historic Branch
addOffspring("Ancient", {{"Noble", "Diligent"}})
addOffspring("Primeval", {{"Ancient", "Noble"}})
addOffspring("Prehistoric", {{"Primeval", "Majestic"}})
addOffspring("Relic", {{"Prehistoric", "Imperial"}})
-- Hostile Branch
addOffspring("Skeletal", {{"Desolate", "Frugal"}})
addOffspring("Decaying", {{"Desolate", "Modest"}})
addOffspring("Creepy", {{"Desolate", "Austere"}})
-- Metallic Branch
addOffspring("Galvanized", {{"Tarnished", "Cultivated"}})
addOffspring("Invincible", {{"Resilient", "Ender"}})
addOffspring("Lustered", {{"Resilient", "Unweary"}})
-- Nuclear Branch
addOffspring("Unstable", {{"Austere", "Rocky"}})
addOffspring("Nuclear", {{"Unstable", "Rusty"}})
addOffspring("Radioactive", {{"Nuclear", "Glittering"}})
-- Precious Branch
addOffspring("Lapis", {{"Resilient", "Water"}})
addOffspring("Glittering", {{"Corroded", "Imperial"}})
addOffspring("Shining", {{"Rusty", "Imperial"}})
addOffspring("Valuable", {{"Glittering", "Shining"}})
-- Refined Branch
addOffspring("Distilled", {{"Oily", "Industrious"}})
addOffspring("Refined", {{"Distilled", "Oily"}})
addOffspring("Elastic", {{"Refined", "Resinous"}})
addOffspring("Tarry", {{"Refined", "Fossiled"}})
-- Rocky Branch
addOffspring("Tolerant", {{"Diligent", "Rocky"}})
addOffspring("Robust", {{"Tolerant", "Rocky"}})
addOffspring("Resilient", {{"Robust", "Imperial"}})
-- Rusty Branch
addOffspring("Corroded", {{"Resilient", "Forest"}})
addOffspring("Leaden", {{"Resilient", "Unweary"}})
addOffspring("Rusty", {{"Resilient", "Meadows"}})
addOffspring("Tarnished", {{"Resilient", "Marshy"}})
-- Saccharine Branch
addOffspring("Sweetened", {{"Diligent", "Valiant"}})
addOffspring("Sugary", {{"Sweetened", "Diligent"}})
addOffspring("Fruity", {{"Ripening", "Rural"}})
-- Shadow Branch
addOffspring("Shadowed", {{"Tolerant", "Sinister"}})
addOffspring("Darkened", {{"Shadowed", "Embittered"}})
addOffspring("Abyssmal", {{"Darkened", "Shadowed"}})
-- Virulent Branch
addOffspring("Malicious", {{"Sinister", "Tropical"}})
addOffspring("Infectious", {{"Malicious", "Tropical"}})
addOffspring("Virulent", {{"Infectious", "Malicious"}})
-- Viscous Branch
addOffspring("Viscous", {{"Exotic", "Water"}})
addOffspring("Glutinous", {{"Viscous", "Exotic"}})
addOffspring("Sticky", {{"Glutinous", "Viscous"}})
-- Volcanic Branch
addOffspring("Furious", {{"Sinister", "Embittered"}})
addOffspring("Volcanic", {{"Furious", "Embittered"}})
addOffspring("Glowering", {{"Excited", "Furious"}})

-- Primary Branch
addOffspring("Bleached", {{"Wintry", "Valiant"}})
addOffspring("Ebony", {{"Rocky", "Valiant"}})
addOffspring("Maroon", {{"Forest", "Valiant"}})
addOffspring("Natural", {{"Tropical", "Valiant"}})
addOffspring("Prussian", {{"Water", "Valiant"}})
addOffspring("Saffron", {{"Meadows", "Valiant"}})
addOffspring("Sepia", {{"Marshy", "Valiant"}})
-- Secondary Branch
addOffspring("Amber", {{"Maroon", "Saffron"}})
addOffspring("Azure", {{"Prussian", "Bleached"}})
addOffspring("Indigo", {{"Maroon", "Prussian"}})
addOffspring("Lavender", {{"Maroon", "Bleached"}})
addOffspring("Lime", {{"Natural", "Bleached"}})
addOffspring("Slate", {{"Ebony", "Bleached"}})
addOffspring("Turquoise", {{"Natural", "Prussian"}})
-- Tertiary Branch
addOffspring("Ashen", {{"Slate", "Bleached"}})
addOffspring("Fuchsia", {{"Indigo", "Lavender"}})

-- no branch
addOffspring("Gnawing", {{"Barren", "Forest"}})
addOffspring("Decoposing", {{"Arid", "Common"}, {"Gnawing", "Common"}})
addOffspring("Growing", {{"Diligent", "Forest"}})
addOffspring("Thriving", {{"Growing", "Rural"}})
addOffspring("Blooming", {{"Growing", "Thriving"}})
addOffspring("Ripening", {{"Sugary", "Forest"}})

-- Magic Bees ------------------------------------------------------------------

-- Abominable Branch
addOffspring("Hateful", {{"Eldritch", "Infernal"}})
addOffspring("Spiteful", {{"Hateful", "Infernal"}})
addOffspring("Withering", {{"Demonic", "Spiteful"}})
-- Alchemical Branch
addOffspring("Minium", {{"Eldritch", "Frugal"}})
-- Arcane Branch
addOffspring("Esoteric", {{"Eldritch", "Cultivated"}})
addOffspring("Mysterious", {{"Eldritch", "Esoteric"}})
addOffspring("Arcane", {{"Mysterious", "Esoteric"}})
-- Aware Branch
addOffspring("Ethereal", {{"Arcane", "Supernatural"}})
addOffspring("Aware", {{"Ethereal", "Attuned"}})
addOffspring("Watery", {{"Ethereal", "Supernatural"}})
addOffspring("Windy", {{"Ethereal", "Supernatural"}})
addOffspring("Firey", {{"Ethereal", "Supernatural"}})
addOffspring("Earthen", {{"Ethereal", "Supernatural"}})
-- Essential Branch
addOffspring("Essence", {{"Arcane", "Ethereal"}})
addOffspring("Arkanen", {{"Essence", "Ethereal"}})
addOffspring("Quintessential", {{"Essence", "Arcane"}})
addOffspring("Vortex", {{"Essence", "Skulking"}})
addOffspring("Wight", {{"Ghastly", "Skulking"}})
addOffspring("Luft", {{"Essence", "Windy"}})
addOffspring("Blitz", {{"Luft", "Windy"}})
addOffspring("Wasser", {{"Essence", "Watery"}})
addOffspring("Eis", {{"Wasser", "Watery"}})
addOffspring("Erde", {{"Essence", "Earthen"}})
addOffspring("Staude", {{"Erde", "Earthen"}})
addOffspring("Feuer", {{"Essence", "Firey"}})
addOffspring("Magma", {{"Feuer", "Firey"}})
-- Extrinsic
addOffspring("Nameless", {{"Oblivion", "Ethereal"}})
addOffspring("Abandoned", {{"Nameless", "Oblivion"}})
addOffspring("Forlorn", {{"Abandoned", "Nameless"}})
addOffspring("Draconic", {{"Abandoned", "Imperial"}})
-- Fleshly Branch
addOffspring("Poultry", {{"Skulking", "Common"}})
addOffspring("Beefy", {{"Skulking", "Common"}})
addOffspring("Porcine", {{"Skulking", "Common"}})
-- Gem Branch
addOffspring("Apatine", {{"Rural", "Cuprum"}})
addOffspring("Diamandi", {{"Austere", "Auric"}})
addOffspring("Esmeraldi", {{"Austere", "Argentum"}})
-- Metallic2 Branch
addOffspring("Cuprum", {{"Industrious", "Meadows"}})
addOffspring("Stannum", {{"Industrious", "Forest"}})
addOffspring("Aluminum", {{"Industrious", "Cultivated"}})
addOffspring("Ardite", {{"Industrious", "Infernal"}})
addOffspring("Argentum", {{"Imperial", "Modest"}})
addOffspring("Cobalt", {{"Imperial", "Infernal"}})
addOffspring("Ferrous", {{"Common", "Industrious"}})
addOffspring("Plumbum", {{"Stannum", "Common"}})
addOffspring("Auric", {{"Minium", "Plumbum"}})
addOffspring("Manyullyn", {{"Ardite", "Cobalt"}})
-- Scholarly Branch
addOffspring("Pupil", {{"Arcane", "Monastic"}})
addOffspring("Scholarly", {{"Arcane", "Pupil"}})
addOffspring("Savant", {{"Scholarly", "Pupil"}})
-- Skulking Branch
addOffspring("Skulking", {{"Eldritch", "Modest"}})
addOffspring("Ghastly", {{"Skulking", "Ethereal"}})
addOffspring("Smouldering", {{"Skulking", "Hateful"}})
addOffspring("Spidery", {{"Skulking", "Tropical"}})
-- Soulful Branch
addOffspring("Spirit", {{"Ethereal", "Aware"}, {"Attuned", "Aware"}})
addOffspring("Soul", {{"Spirit", "Aware"}})
-- Supernatural Branch
addOffspring("Charmed", {{"Eldritch", "Cultivated"}})
addOffspring("Enchanted", {{"Eldritch", "Charmed"}})
addOffspring("Supernatural", {{"Enchanted", "Charmed"}})
-- Thaumic Branch
addOffspring("Aqua", {{"Watery", "Watery"}})
addOffspring("Aura", {{"Windy", "Windy"}})
addOffspring("Ignis", {{"Firey", "Firey"}})
addOffspring("Praecantatio", {{"Ethereal", "Ethereal"}})
addOffspring("Solum", {{"Earthen", "Earthen"}})
addOffspring("Stark", choose({"Earthen", "Firey", "Watery", "Windy"}))
addOffspring("Vis", {{"Eldritch", "Ethereal"}})
addOffspring("Flux", {{"Vis", "Demonic"}})
addOffspring("Attractive", {{"Vis", "Flux"}})
addOffspring("Rejuvenating", {{"Vis", "Imperial"}})
addOffspring("Pure", {{"Vis", "Rejuvenating"}})
addOffspring("Batty", {{"Skulking", "Windy"}})
addOffspring("Brainy", {{"Skulking", "Pupil"}})
addOffspring("Wispy", {{"Ethereal", "Ghastly"}})
-- Time Branch
addOffspring("Timely", {{"Ethereal", "Imperial"}})
addOffspring("Lordly", {{"Timely", "Imperial"}})
addOffspring("Doctoral", {{"Lordly", "Timely"}})
-- Veiled Branch
addOffspring("Eldritch", {{"Mystical", "Cultivated"}, {"Sorcerous", "Cultivated"}, {"Unusual", "Cultivated"}, {"Attuned", "Cultivated"}})

scoreBees()

-- logging ---------------------------------------------------------------------

local logFile = fs.open("bee.log", "w")
function log(msg)
  msg = msg or ""
  logFile.write(tostring(msg))
  logFile.flush()
  io.write(msg)
end
function logLine(msg)
  msg = msg or ""
  logFile.write(msg.."\n")
  logFile.flush()
  io.write(msg.."\n")
end

-- analyzing functions ---------------------------------------------------------

-- Fix for some versions returning bees.species.*
function fixName(name)
  return name:gsub("bees%.species%.",""):gsub("^.", string.upper)
end

function clearSystem()
  -- orient turtle
  while turtle.detect() do
    turtle.turnRight()
  end
  -- clear out analyzer
  turtle.turnRight()
  while turtle.suck() do end
  -- clear out beealyzer
  turtle.turnRight()
  turtle.suck()
  -- clear out apiary
  turtle.turnRight()
  while turtle.suck() do end
end
 
function getBees()
  -- get bees from apiary
  log("waiting for bees.")
  turtle.select(1)
  while not turtle.suck() do
    sleep(10)
    log(".")
  end
  log("*")
  while turtle.suck() do
    log("*")
  end
  logLine()
end

function countBees()
  -- spread dups and fill gaps
  local count = 0
  for i = 1, 16 do
    local slotCount = turtle.getItemCount(i)
    if slotCount == 1 then
      for j = 1, i-1 do
        if turtle.getItemCount(j) == 0 then
          turtle.select(i)
          turtle.transferTo(j)
          break
        end
      end
      count = count + 1
    elseif slotCount > 1 then
      for j = 2, slotCount do
        turtle.select(i)
        for k = 1, 16 do
          if turtle.getItemCount(k) == 0 then
            turtle.transferTo(k, 1)
          end
        end
      end
      if turtle.getItemCount(i) > 1 then
        turtle.dropDown(turtle.getItemCount(i)-1)
      end
    end
  end
  return count
end
 
function breedBees(princessSlot, droneSlot)
   turtle.select(princessSlot)
   turtle.drop()
   turtle.select(droneSlot)
   turtle.drop()
end
 
function ditchProduct()  
  print("ditching product...")
  turtle.turnLeft()
  m = peripheral.wrap("front")
  for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      turtle.drop()
      if not m.isBee() then
        turtle.suck()
        turtle.dropDown()
      else
        turtle.suck()
      end
    end
  end
  turtle.turnRight()
end
 
function scanBees()
  log("scanning bees")
  turtle.turnLeft()
  turtle.turnLeft()
  for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
      log(".")
      turtle.select(i)
      turtle.drop()
      while not turtle.suck() do
        sleep(1)
      end
    end
  end
  logLine()
  turtle.turnRight()
  turtle.turnRight()
end

function swapBee(slot1, slot2, freeSlot)
  turtle.select(slot1)
  turtle.transferTo(freeSlot)
  turtle.select(slot2)
  turtle.transferTo(slot1)
  turtle.select(freeSlot)
  turtle.transferTo(slot2)
end  

function analyzeBees()
  logLine("analyzing bees...")
  local freeSlot
  local princessSlot
  local princessData
  local droneData = {}
  turtle.turnLeft()
  local beealyzer = peripheral.wrap("front")
  for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      turtle.drop()
      local beeData = beealyzer.analyze()
      turtle.suck()
      beeData["speciesPrimary"] = fixName(beeData["speciesPrimary"])
      beeData["speciesSecondary"] = fixName(beeData["speciesSecondary"])
      if beeData["type"] == "princess" then
        princessData = beeData
        princessSlot = i
      else
        droneData[i] = beeData
      end
    else
      freeSlot = i
    end
  end
  if princessData then
    if princessSlot ~= 1 then
      swapBee(1, princessSlot, freeSlot)
      droneData[princessSlot] = droneData[1]
      droneData[1] = nil
      princessSlot = 1
    end
    -- bubble sort drones
    print("sorting drones...")
    for i = 2, 16 do
      if turtle.getItemCount(i) > 0 then
        droneData[i].score = scoreBee(princessData, droneData[i])
        for j = i - 1, 2, -1 do
          if droneData[j+1].score > droneData[j].score then
            swapBee(j+1, j, freeSlot)
            droneData[j+1], droneData[j] = droneData[j], droneData[j+1]
          end
        end
      end
    end
    printHeader()
    princessData.slot = 1
    printBee(princessData)
    for i = 2, 16 do
      if droneData[i] then
        droneData[i].slot = i
        printBee(droneData[i])
      end
    end
  end
  logLine()
  turtle.turnRight()
  return princessData, droneData
end

function scoreBee(princessData, droneData)
  local droneSpecies = {droneData["speciesPrimary"], droneData["speciesSecondary"]}
  -- check for untargeted species
  if not bees[droneSpecies[1]].targeted or not bees[droneSpecies[2]].targeted then
    return 0
  end
  local princessSpecies = {princessData["speciesPrimary"], princessData["speciesSecondary"]}
  local max = math.max
  local score
  --local scores = {}
  local maxScore = 0
  --logLine("parents "..princessSpecies[1]..":"..princessSpecies[2].." + "..droneSpecies[1]..":"..droneSpecies[2])
  for _, combo in ipairs({{princessSpecies[1], droneSpecies[1]}
                         ,{princessSpecies[1], droneSpecies[2]}
                         ,{princessSpecies[2], droneSpecies[1]}
                         ,{princessSpecies[2], droneSpecies[2]}}) do
    --log("  combo "..combo[1]..":"..combo[2])
    -- find maximum score for each combo
    score = max(bees[combo[1]].score, bees[combo[2]].score)
    --log(" base="..tostring(score))
    for name, beeData in pairs(bees) do
      if beeData.targeted then
        for i, parents in ipairs(beeData.mutateFrom) do
          if combo[1] == parents[1] and combo[2] == parents[2]
              or combo[2] == parents[1] and combo[1] == parents[2] then
            if beeData.score > score then
              --log(" "..name:sub(1,3).."="..tostring(beeData.score))
            end
            score = max(score, beeData.score)
          end
        end
      end
    end
    maxScore = maxScore + score
    --table.insert(scores, score)
    --maxScore = max(maxScore, score)
    --logLine()
  end
  --log("  scores:")
  -- add one for each combination that results in the maximum score
  score = maxScore
  --for _, s in ipairs(scores) do
    --log(" "..tostring(s))
  --end
  --logLine(" "..tostring(score))
  -- score attributes
  score = score + max(scoresFertility[droneData["fertility"]], scoresFertility[princessData["fertility"]])
  score = score + max(scoresSpeed[tostring(droneData["speed"])], scoresSpeed[tostring(princessData["speed"])])
  if droneData["diurnal"] or princessData["diurnal"] then score = score + scores["diurnal"] end
  if droneData["nocturnal"] or princessData["nocturnal"] then score = score + scores["nocturnal"] end
  if droneData["tolerantFlyer"] or princessData["tolerantFlyer"] then score = score + scores["tolerantFlyer"] end
  if droneData["caveDwelling"] or princessData["caveDwelling"] then score = score + scores["caveDwelling"] end
  score = score + max(scoresTolerance[droneData["toleranceTemperature"]], scoresTolerance[princessData["toleranceTemperature"]])
  score = score + max(scoresTolerance[droneData["toleranceHumidity"]], scoresTolerance[princessData["toleranceHumidity"]])
  return score
end

function printHeader()
  logLine()
  logLine("typ species f spd d n f c tmp hmd score")
  logLine("-|-|-------|-|---|-|-|-|-|---|---|-----")
end

toleranceString = {
  ["NONE"] = "    ",
  ["UP_1"] = " +1 ",
  ["UP_2"] = " +2 ",
  ["UP_3"] = " +3 ",
  ["DOWN_1"] = " -1 ",
  ["DOWN_2"] = " -2 ",
  ["DOWN_3"] = " -3 ",
  ["BOTH_1"] = "+-1 ",
  ["BOTH_2"] = "+-2 ",
  ["BOTH_3"] = "+-3 "
}
function printBee(beeData)
  log(beeData["slot"] < 10 and beeData["slot"].." " or beeData["slot"])
  if (beeData["type"] == "princess") then
    log("P ")
  else
    log("d ")
  end
  log(beeData["speciesPrimary"]:gsub("bees%.species%.",""):sub(1,3)..":"..beeData["speciesSecondary"]:gsub("bees%.species%.",""):sub(1,3).." ")
  log(tostring(beeData["fertility"]).." ")
  log(beeData["speed"] == 1 and "1.0 " or tostring(beeData["speed"]).." ")
  if beeData["diurnal"] then
    log("d ")
  else
    log("  ")
  end
  if beeData["nocturnal"] then
    log("n ")
  else
    log("  ")
  end
  if beeData["tolerantFlyer"] then
    log("f ")
  else
    log("  ")
  end
  if beeData["caveDwelling"] then
    log("c ")
  else
    log("  ")
  end
  log(toleranceString[beeData["toleranceTemperature"]])
  log(toleranceString[beeData["toleranceHumidity"]])
  if beeData.score then
    logLine(string.format("%5.1d", beeData.score).." ")
  else
    logLine()
  end
end

function dropExcess(droneData)
  print("dropping excess...")
  local count = 0
  for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
      -- check for untargeted species
      if droneData[i] and (not bees[droneData[i]["speciesPrimary"]].targeted
          or not bees[droneData[i]["speciesSecondary"]].targeted) then
        turtle.select(i)
        turtle.dropDown()
      else
        count = count + 1
      end
      -- drop drones over 9 to clear space for newly bred bees and product
      if count > 9 then
        turtle.select(i)
        turtle.dropDown()
        count = count - 1
      end
    end
  end  
end

function isPurebred(princessData, droneData)
  -- check if princess and drone are exactly the same and no chance for mutation
  if princessData["speciesPrimary"] ~= princessData["speciesSecondary"] then
    return false
  end
  for key, value in pairs(princessData) do
    if value ~= droneData[key] and key ~= "territory" and key ~= "type" then
      return false
    end
  end
  return true
end

function getUnknown(princessData, droneData)
  -- lists species that are not in the bee graph
  local unknownSpecies = {}
  if not bees[princessData["speciesPrimary"]] then
    table.insert(unknownSpecies, princessData["speciesPrimary"])
  end
  if not bees[princessData["speciesSecondary"]] then
    table.insert(unknownSpecies, princessData["speciesSecondary"])
  end
  for _, beeData in pairs(droneData) do
    if not bees[beeData["speciesPrimary"]] then
      table.insert(unknownSpecies, beeData["speciesPrimary"])
    end
    if not bees[beeData["speciesSecondary"]] then
      table.insert(unknownSpecies, beeData["speciesSecondary"])
    end
  end
  return unknownSpecies
end

-- targeting -------------------------------------------------------------------

-- set species and all parents to targeted
function targetBee(name)
  local bee = bees[name]
  if bee and not bee.targeted then
    bee.targeted = true
    for i, parents in ipairs(bee.mutateFrom) do
      for j, parent in ipairs(parents) do
        targetBee(parent)
      end
    end
  end
end

-- set bee graph entry to targeted if species was specified on the command line
-- otherwise set all entries to targeted
tArgs = { ... }
if #tArgs > 0 then
  logLine("targeting bee species:")
  for i, target in ipairs(tArgs) do
    targetBee(target)
    for name, data in pairs(bees) do
      if data.targeted and data.score > 1 then
        logLine(name .. string.rep(" ", 20-#name), data.score)
      end
    end
  end
else
  for _, beeData in pairs(bees) do
    beeData.targeted = true
  end
end

-- breeding loop ---------------------------------------------------------------

logLine("Clearing system...")
clearSystem()
while true do
  ditchProduct()
  countBees()
  scanBees()
  princessData, droneData = analyzeBees()
  if princessData then
    if isPurebred(princessData, droneData[2]) then
      logLine("Bees are purebred")
      turtle.turnRight()
      break
    end
    local unknownSpecies = getUnknown(princessData, droneData)
    if #unknownSpecies > 0 then
      logLine("Please add new species to bee graph:")
      for _, species in ipairs(unknownSpecies) do
        logLine("  "..species)
      end
      turtle.turnRight()
      break
    end
    breedBees(1, 2)
    dropExcess(droneData)
  end
  getBees()
end
logFile.close()
