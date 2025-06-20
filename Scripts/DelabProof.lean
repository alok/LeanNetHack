import LeanNetHack

open LeanNetHack

/-
Proof that delaborator is working - check visual output
Run: lake env lean Scripts/DelabProof.lean
-/

-- Create test states that should show visual dungeons

def smallState : GameState := {
  playerPos := { x := 1, y := 1 }
  playerStats := {
    hitpoints := 15, maxHitpoints := 20, strength := 16,
    dexterity := 12, constitution := 14, intelligence := 10,
    wisdom := 11, charisma := 8
  }
  dungeonLevel := 1
  bounds := { width := 5, height := 3 }
}

def complexState : EnhancedGameState := {
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
    else if pos = ⟨1, 1⟩ then
      (Terrain.upstairs, CellContent.empty)
    else if pos = ⟨5, 1⟩ then
      (Terrain.downstairs, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.weapon "sword"]
}

-- THESE SHOULD SHOW VISUAL ASCII DUNGEONS:
#check smallState
#check complexState

-- Test state transitions
def afterEastMove := applyEnhancedAction complexState (EnhancedAction.move Direction.east)
#check afterEastMove

def afterAttack := applyEnhancedAction afterEastMove (EnhancedAction.attack Direction.east)  
#check afterAttack

-- Test computed states
def multiStep := 
  let s1 := applyEnhancedAction complexState (EnhancedAction.move Direction.east)
  let s2 := applyEnhancedAction s1 (EnhancedAction.move Direction.east)
  applyEnhancedAction s2 (EnhancedAction.move Direction.south)

#check multiStep