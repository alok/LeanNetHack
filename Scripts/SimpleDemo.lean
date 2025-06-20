import LeanNetHack

open LeanNetHack

/-
Simple working demo - no complex list operations
Run with: lake env lean --run Scripts/SimpleDemo.lean
-/

def testState : EnhancedGameState := {
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
      (Terrain.downstairs, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.weapon "dagger"]
}

def main : IO Unit := do
  IO.println "🎮 NetHack Visualization System - WORKING DEMO"
  IO.println "==============================================="
  
  -- Show initial state
  IO.println "\n📍 INITIAL STATE:"
  IO.println (compactRender testState)
  
  -- Apply actions step by step
  let state1 := applyEnhancedAction testState (EnhancedAction.move Direction.east)
  IO.println "\n📍 AFTER MOVE EAST:"
  IO.println (compactRender state1)
  
  let state2 := applyEnhancedAction state1 (EnhancedAction.move Direction.east)
  IO.println "\n📍 AFTER MOVE EAST AGAIN:"
  IO.println (compactRender state2)
  
  let state3 := applyEnhancedAction state2 (EnhancedAction.move Direction.south)
  IO.println "\n📍 AFTER MOVE SOUTH:"
  IO.println (compactRender state3)
  
  let state4 := applyEnhancedAction state3 (EnhancedAction.attack Direction.east)
  IO.println "\n📍 AFTER ATTACK RAT:"
  IO.println (compactRender state4)
  
  let state5 := applyEnhancedAction state4 (EnhancedAction.move Direction.east)
  IO.println "\n📍 AFTER MOVE TO RAT POSITION:"
  IO.println (compactRender state5)
  
  let state6 := applyEnhancedAction state5 (EnhancedAction.move Direction.north)
  IO.println "\n📍 AFTER MOVE NORTH TO GOLD:"
  IO.println (compactRender state6)
  
  let state7 := applyEnhancedAction state6 (EnhancedAction.pickup)
  IO.println "\n📍 AFTER PICKUP GOLD:"
  IO.println (compactRender state7)
  
  -- Show reward calculation
  let reward1 := enhancedReward testState state1
  let reward4 := enhancedReward state3 state4
  let reward7 := enhancedReward state6 state7
  
  IO.println "\n💰 REWARDS:"
  IO.println s!"Move reward: {reward1}"
  IO.println s!"Combat reward: {reward4}" 
  IO.println s!"Pickup reward: {reward7}"
  
  -- Save snapshots
  IO.println "\n💾 SAVING SNAPSHOTS:"
  saveSnapshot "simple_initial.txt" testState
  saveSnapshot "simple_combat.txt" state4
  saveSnapshot "simple_final.txt" state7
  IO.println "Snapshots saved to simple_*.txt"
  
  -- Test text renderer features
  IO.println "\n📋 FULL RENDERER TEST:"
  let fullRenderer : TextRenderer := { 
    width := 8, height := 6, 
    showStats := true, showInventory := true 
  }
  let fullRender := renderGameState fullRenderer state7
  IO.println fullRender
  
  IO.println "✅ DEMO COMPLETE - All systems working!"

#eval main