import LeanNetHack

open LeanNetHack

/-
Working demo script for NetHack visualization
Run with: lake env lean --run Scripts/WorkingDemo.lean
-/

-- Simple demo state for testing
def demoState : EnhancedGameState := {
  playerPos := { x := 2, y := 2 }
  playerStats := {
    hitpoints := 20, maxHitpoints := 25, strength := 18,
    dexterity := 15, constitution := 16, intelligence := 12,
    wisdom := 14, charisma := 11
  }
  dungeonLevel := 1
  bounds := { width := 8, height := 6 }
  dungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = 8 || pos.y + 1 = 6 then
      (Terrain.wall, CellContent.empty)
    else if pos = ⟨4, 3⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.rat,
        position := pos,
        hitpoints := 4,
        maxHitpoints := 5,
        attackPower := 2
      })
    else if pos = ⟨6, 2⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 25,
        position := pos
      })
    else if pos = ⟨5, 4⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.weapon "sword",
        position := pos
      })
    else if pos = ⟨6, 4⟩ then
      (Terrain.downstairs, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.weapon "dagger"]
}

-- Action sequence
def actions : List EnhancedAction := [
  EnhancedAction.move Direction.east,
  EnhancedAction.move Direction.east,
  EnhancedAction.move Direction.south,
  EnhancedAction.attack Direction.east,
  EnhancedAction.move Direction.east,
  EnhancedAction.move Direction.south,
  EnhancedAction.pickup
]

-- Generate state sequence
def generateStates (initial : EnhancedGameState) (actionList : List EnhancedAction) : List EnhancedGameState :=
  actionList.foldl (fun acc action => acc ++ [applyEnhancedAction acc.getLast! action]) [initial]

def main : IO Unit := do
  IO.println "🎮 NetHack Visualization Demo"
  IO.println "=========================="
  
  let states := generateStates demoState actions
  
  -- Show frame by frame
  for (state, i) in states.zipIdx do
    IO.println s!"Frame {i}:"
    if i = 0 then
      IO.println "INITIAL STATE"
    else
      IO.println s!"After: {actions[i-1]!}"
    IO.println (compactRender state)
    IO.println ""
  
  -- Show rewards
  IO.println "💰 Rewards:"
  for i in List.range (states.length - 1) do
    let reward := enhancedReward states[i]! states[i+1]!
    IO.println s!"Step {i+1}: {reward}"
  
  -- Save snapshots
  IO.println "\n💾 Saving snapshots..."
  saveSnapshot "demo_initial.txt" states[0]!
  saveSnapshot "demo_final.txt" states.getLast!
  IO.println "Snapshots saved!"
  
  IO.println "\n✅ Demo complete!"

-- Test delaborator separately  
def testDelabs : IO Unit := do
  IO.println "\n🔍 Testing Delaborators:"
  IO.println "Check the visual output above for ASCII dungeons"

#eval main
#eval testDelabs