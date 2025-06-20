import LeanNetHack

open LeanNetHack

/-
Visual check script to verify delaborators are working
When you run `lake env lean Scripts/VisualCheck.lean`, you should see 
visual ASCII art dungeons rendered inline for each #check
-/

-- Test states for delaborator verification
def testState1 : GameState := {
  playerPos := { x := 2, y := 1 }
  playerStats := {
    hitpoints := 15, maxHitpoints := 20, strength := 16,
    dexterity := 12, constitution := 14, intelligence := 10,
    wisdom := 11, charisma := 8
  }
  dungeonLevel := 1
  bounds := { width := 5, height := 3 }
}

def testState2 : EnhancedGameState := {
  playerPos := { x := 2, y := 2 }
  playerStats := {
    hitpoints := 18, maxHitpoints := 20, strength := 16,
    dexterity := 14, constitution := 15, intelligence := 12,
    wisdom := 13, charisma := 11
  }
  dungeonLevel := 1
  bounds := { width := 7, height := 5 }
  dungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = 7 || pos.y + 1 = 5 then
      (Terrain.wall, CellContent.empty)
    else if pos = ⟨4, 2⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.orc,
        position := pos,
        hitpoints := 8,
        maxHitpoints := 10,
        attackPower := 3
      })
    else if pos = ⟨5, 3⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 25,
        position := pos
      })
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.weapon "sword"]
}

-- These should show visual ASCII dungeons when processed
#check testState1
#check testState2

-- Test state transitions
def afterMove := applyEnhancedAction testState2 (EnhancedAction.move Direction.east)
#check afterMove

def afterAttack := applyEnhancedAction afterMove (EnhancedAction.attack Direction.east)
#check afterAttack