import LeanNetHack

open LeanNetHack

-- Test if delaborator actually works for #check (types, not evaluation)

def testState : EnhancedGameState := {
  playerPos := { x := 2, y := 2 }
  playerStats := {
    hitpoints := 18, maxHitpoints := 20, strength := 16,
    dexterity := 14, constitution := 15, intelligence := 12,
    wisdom := 13, charisma := 11
  }
  dungeonLevel := 1
  bounds := { width := 6, height := 4 }
  dungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = 6 || pos.y + 1 = 4 then
      (Terrain.wall, CellContent.empty)
    else if pos = ⟨3, 2⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.rat,
        position := pos,
        hitpoints := 3,
        maxHitpoints := 5,
        attackPower := 1
      })
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.weapon "sword"]
}

-- This should show the TYPE (not evaluated content)
-- If delaborator works, it should show ASCII dungeon
-- If not, it should just show "testState : EnhancedGameState"
#check testState

-- Let's also test if the delaborator triggers on computed expressions
#check (applyEnhancedAction testState (EnhancedAction.move Direction.east))

-- And test basic GameState
def simpleState : GameState := {
  playerPos := { x := 1, y := 1 }
  playerStats := {
    hitpoints := 15, maxHitpoints := 20, strength := 16,
    dexterity := 12, constitution := 14, intelligence := 10,
    wisdom := 11, charisma := 8
  }
  dungeonLevel := 1
  bounds := { width := 4, height := 3 }
}

#check simpleState