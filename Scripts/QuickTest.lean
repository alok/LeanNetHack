import LeanNetHack

open LeanNetHack

/-
Quick test script for rapid iteration
Run with: lake env lean --run Scripts/QuickTest.lean
-/

-- Minimal test scenario for fast iteration
def quickState : EnhancedGameState := {
  playerPos := { x := 1, y := 1 }
  playerStats := {
    hitpoints := 20, maxHitpoints := 20, strength := 18,
    dexterity := 14, constitution := 16, intelligence := 12,
    wisdom := 13, charisma := 10
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
    else if pos = ⟨4, 1⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 10,
        position := pos
      })
    else
      (Terrain.floor, CellContent.empty)
  inventory := []
}

-- Quick action sequence
def quickActions : List EnhancedAction := [
  EnhancedAction.move Direction.east,    -- Move to (2,1)
  EnhancedAction.move Direction.east,    -- Move to (3,1) 
  EnhancedAction.move Direction.east,    -- Move to (4,1) - get gold
  EnhancedAction.pickup,                 -- Pick up gold
  EnhancedAction.move Direction.west,    -- Move back to (3,1)
  EnhancedAction.move Direction.south,   -- Move to (3,2) - position to attack rat
  EnhancedAction.attack Direction.east   -- Attack rat at (4,2) - wait, rat is at (3,2)
]

def runQuickTest : IO Unit := do
  IO.println "⚡ QUICK TEST - NetHack Visualization"
  IO.println "========================================"
  
  let mut currentState := quickState
  
  -- Show initial state
  IO.println "INITIAL:"
  IO.println (compactRender currentState)
  
  -- Execute actions and show each frame
  for (action, i) in quickActions.zipIdx do
    currentState := applyEnhancedAction currentState action
    IO.println s!"STEP {i+1} - {action}:"
    IO.println (compactRender currentState)
  
  IO.println "✅ Quick test complete!"

#eval runQuickTest