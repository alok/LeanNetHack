import LeanNetHack

open LeanNetHack

/-
Quick iteration script for rapid development
Usage: lake env lean --run Scripts/IterateScript.lean
Change the test scenario and re-run to see instant visualization updates
-/

-- CHANGE THIS SCENARIO FOR QUICK ITERATION:
def scenario : EnhancedGameState := {
  playerPos := { x := 3, y := 3 }  -- Try changing this position
  playerStats := {
    hitpoints := 25, maxHitpoints := 30, strength := 20,
    dexterity := 16, constitution := 18, intelligence := 14,
    wisdom := 15, charisma := 12
  }
  dungeonLevel := 2  -- Try changing level
  bounds := { width := 10, height := 8 }
  dungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = 10 || pos.y + 1 = 8 then
      (Terrain.wall, CellContent.empty)
    -- TRY ADDING/CHANGING MONSTERS:
    else if pos = ⟨5, 4⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.dragon,  -- Try: rat, orc, troll, dragon
        position := pos,
        hitpoints := 15,
        maxHitpoints := 20,
        attackPower := 6
      })
    else if pos = ⟨7, 2⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.troll,
        position := pos,
        hitpoints := 12,
        maxHitpoints := 15,
        attackPower := 4
      })
    -- TRY ADDING/CHANGING ITEMS:
    else if pos = ⟨2, 6⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.weapon "magic sword",  -- Try different items
        position := pos
      })
    else if pos = ⟨8, 5⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 100,
        position := pos
      })
    -- TRY CHANGING TERRAIN:
    else if pos = ⟨6, 6⟩ then
      (Terrain.downstairs, CellContent.empty)  -- Try: upstairs, door
    else if pos.x = 5 && pos.y ∈ [2, 3] then
      (Terrain.wall, CellContent.empty)  -- Add walls
    else
      (Terrain.floor, CellContent.empty)
  inventory := [
    ItemType.weapon "long sword",
    ItemType.armor "plate mail", 
    ItemType.potion "super healing",
    ItemType.scroll "teleport"
  ]
}

-- CHANGE THESE ACTIONS FOR DIFFERENT GAMEPLAY:
def testActions : List EnhancedAction := [
  EnhancedAction.move Direction.east,     -- Try different directions
  EnhancedAction.move Direction.east,
  EnhancedAction.move Direction.south,
  EnhancedAction.attack Direction.east,   -- Try attacking the dragon
  EnhancedAction.move Direction.south,
  EnhancedAction.move Direction.south,
  EnhancedAction.pickup               -- Try picking up the weapon
]

def main : IO Unit := do
  IO.println "⚡ RAPID ITERATION TESTING"
  IO.println "========================="
  IO.println "Modify the scenario above and re-run to see instant changes!\n"
  
  -- Show initial scenario
  IO.println "🎯 CURRENT SCENARIO:"
  IO.println (compactRender scenario)
  
  -- Execute actions one by one
  let mut currentState := scenario
  IO.println "\n🎬 ACTION SEQUENCE:"
  
  for (action, i) in testActions.zipIdx do
    currentState := applyEnhancedAction currentState action
    IO.println s!"#{i+1} {action}:"
    IO.println (compactRender currentState)
    IO.println ""
  
  -- Show final stats
  let finalStats := currentState.playerStats
  let finalInv := currentState.inventory.length
  IO.println s!"📊 FINAL: Level {currentState.dungeonLevel}, HP {finalStats.hitpoints}/{finalStats.maxHitpoints}, Items {finalInv}"
  
  -- Quick save for comparison
  saveSnapshot "iteration_test.txt" currentState
  IO.println "💾 Saved to iteration_test.txt"
  
  IO.println "\n✨ CHANGE SCENARIO ABOVE AND RE-RUN FOR INSTANT FEEDBACK!"

#eval main