import LeanNetHack

open LeanNetHack

/-
Test file demonstrating NetHack delaborator and text renderer
This file shows how the visualization system works
-/

-- Simple game state that should render with the delaborator
def simpleState : GameState := {
  playerPos := { x := 3, y := 2 }
  playerStats := {
    hitpoints := 15, maxHitpoints := 20, strength := 16,
    dexterity := 12, constitution := 14, intelligence := 10,
    wisdom := 11, charisma := 8
  }
  dungeonLevel := 1
  bounds := { width := 8, height := 5 }
}

-- Enhanced game state with monsters and items
def complexState : EnhancedGameState := 
  let bounds : DungeonBounds := { width := 12, height := 8 }
  let playerStats : PlayerStats := {
    hitpoints := 14, maxHitpoints := 20, strength := 18,
    dexterity := 15, constitution := 16, intelligence := 11,
    wisdom := 12, charisma := 10
  }
  
  let dungeonMap : DungeonMap := fun pos =>
    -- Create walls around the border
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = bounds.width || pos.y + 1 = bounds.height then
      (Terrain.wall, CellContent.empty)
    -- Place some monsters
    else if pos = ⟨4, 3⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.rat,
        position := pos,
        hitpoints := 2,
        maxHitpoints := 5,
        attackPower := 1
      })
    else if pos = ⟨8, 5⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.orc,
        position := pos,
        hitpoints := 8,
        maxHitpoints := 12,
        attackPower := 3
      })
    -- Place some items
    else if pos = ⟨6, 2⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 35,
        position := pos
      })
    else if pos = ⟨3, 6⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.weapon "dagger",
        position := pos
      })
    -- Place stairs
    else if pos = ⟨10, 6⟩ then
      (Terrain.downstairs, CellContent.empty)
    else if pos = ⟨1, 1⟩ then
      (Terrain.upstairs, CellContent.empty)
    -- Add some walls for interesting topology
    else if pos.x = 5 && pos.y ∈ [2, 3, 4] then
      (Terrain.wall, CellContent.empty)
    else if pos.y = 4 && pos.x ∈ [7, 8, 9] then
      (Terrain.wall, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  
  {
    playerPos := { x := 2, y := 3 }
    playerStats := playerStats
    dungeonLevel := 2
    bounds := bounds
    dungeonMap := dungeonMap
    inventory := [
      ItemType.weapon "short sword", 
      ItemType.armor "leather armor",
      ItemType.potion "healing"
    ]
  }

-- Test the text renderer
def testRenderer : String :=
  let renderer : TextRenderer := { 
    width := 12, height := 8, 
    showStats := true, showInventory := true 
  }
  renderGameState renderer complexState

-- Test compact rendering (for LSP display)
def compactTest : String := compactRender complexState

-- Test debugging state transitions
def afterMove : EnhancedGameState := 
  applyEnhancedAction complexState (EnhancedAction.move Direction.east)

def debugTransition : String := debugStateTransition complexState afterMove

-- The delaborator should automatically visualize these when checked
#check simpleState
#check complexState

-- Print text renderings
#eval IO.println "=== Text Renderer Test ==="
#eval IO.println testRenderer

#eval IO.println "\n=== Compact Renderer Test ==="
#eval IO.println compactTest

#eval IO.println "\n=== Debug Transition Test ==="
#eval IO.println debugTransition

-- Test creating a snapshot file
def saveTestSnapshot : IO Unit := do
  saveSnapshot "test_nethack_state.txt" complexState
  IO.println "Snapshot saved to test_nethack_state.txt"

#eval saveTestSnapshot