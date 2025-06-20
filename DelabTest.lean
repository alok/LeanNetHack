import LeanNetHack

open LeanNetHack

-- Simple test cases for the delaborator
-- When you run `#check` or `#eval` on these, the delaborator should show visual representations

-- Basic game state
def smallDungeon : GameState := {
  playerPos := { x := 2, y := 1 }
  playerStats := {
    hitpoints := 15, maxHitpoints := 20, strength := 16,
    dexterity := 12, constitution := 14, intelligence := 10,
    wisdom := 11, charisma := 8
  }
  dungeonLevel := 1
  bounds := { width := 6, height := 4 }
}

-- Enhanced game state with content
def enhancedDungeon : EnhancedGameState := {
  playerPos := { x := 2, y := 2 }
  playerStats := {
    hitpoints := 18, maxHitpoints := 20, strength := 16,
    dexterity := 14, constitution := 15, intelligence := 12,
    wisdom := 13, charisma := 11
  }
  dungeonLevel := 1
  bounds := { width := 8, height := 5 }
  dungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = 8 || pos.y + 1 = 5 then
      (Terrain.wall, CellContent.empty)
    else if pos = ⟨3, 2⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.rat,
        position := pos,
        hitpoints := 3,
        maxHitpoints := 5,
        attackPower := 1
      })
    else if pos = ⟨5, 3⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 20,
        position := pos
      })
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.weapon "dagger"]
}

-- These should show visual representations when checked
#check smallDungeon
#check enhancedDungeon

-- Test state transitions
def afterMoveEast := applyEnhancedAction enhancedDungeon (EnhancedAction.move Direction.east)
#check afterMoveEast

-- Show that the delaborator works for computed states too
def computedState := 
  let initial := enhancedDungeon
  let step1 := applyEnhancedAction initial (EnhancedAction.move Direction.south)
  applyEnhancedAction step1 (EnhancedAction.move Direction.east)

#check computedState