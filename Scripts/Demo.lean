import LeanNetHack

open LeanNetHack

/-
Scriptable CLI demo for NetHack visualization system
Run with: lake env lean --run Scripts/Demo.lean
-/

-- Create a demo scenario
def createDemoState : EnhancedGameState := {
  playerPos := { x := 2, y := 2 }
  playerStats := {
    hitpoints := 20, maxHitpoints := 25, strength := 18,
    dexterity := 15, constitution := 16, intelligence := 12,
    wisdom := 14, charisma := 11
  }
  dungeonLevel := 1
  bounds := { width := 12, height := 8 }
  dungeonMap := fun pos =>
    -- Create bordered dungeon
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = 12 || pos.y + 1 = 8 then
      (Terrain.wall, CellContent.empty)
    -- Place monsters strategically
    else if pos = ⟨5, 3⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.rat,
        position := pos,
        hitpoints := 4,
        maxHitpoints := 5,
        attackPower := 2
      })
    else if pos = ⟨8, 5⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.orc,
        position := pos,
        hitpoints := 10,
        maxHitpoints := 12,
        attackPower := 4
      })
    -- Place items
    else if pos = ⟨4, 6⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 35,
        position := pos
      })
    else if pos = ⟨9, 2⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.weapon "sword",
        position := pos
      })
    else if pos = ⟨6, 4⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.potion "healing",
        position := pos
      })
    -- Add some walls for interesting layout
    else if pos.x = 7 && pos.y ∈ [3, 4] then
      (Terrain.wall, CellContent.empty)
    else if pos.y = 5 && pos.x ∈ [3, 4, 5] then
      (Terrain.wall, CellContent.empty)
    -- Stairs
    else if pos = ⟨10, 6⟩ then
      (Terrain.downstairs, CellContent.empty)
    else if pos = ⟨1, 1⟩ then
      (Terrain.upstairs, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.weapon "dagger", ItemType.armor "leather"]
}

-- Action sequence for demonstration
def demoActions : List EnhancedAction := [
  EnhancedAction.move Direction.east,      -- Move toward rat
  EnhancedAction.move Direction.east,      -- Get closer
  EnhancedAction.move Direction.south,     -- Position for attack
  EnhancedAction.attack Direction.east,    -- Attack the rat
  EnhancedAction.move Direction.east,      -- Move into rat's position
  EnhancedAction.move Direction.south,     -- Move toward gold
  EnhancedAction.move Direction.south,     -- Get closer to gold
  EnhancedAction.move Direction.west,      -- Position for pickup
  EnhancedAction.pickup,                   -- Pick up gold
  EnhancedAction.move Direction.east,      -- Move toward potion
  EnhancedAction.move Direction.east,      -- Get to potion
  EnhancedAction.pickup,                   -- Pick up potion
  EnhancedAction.move Direction.east,      -- Move toward sword
  EnhancedAction.move Direction.north,     -- Navigate around wall
  EnhancedAction.move Direction.north,     -- Get closer to sword
  EnhancedAction.move Direction.east,      -- Reach sword
  EnhancedAction.pickup                    -- Pick up sword
]

-- Generate all states in the sequence
def generateSequence (initial : EnhancedGameState) (actions : List EnhancedAction) : List EnhancedGameState :=
  let rec loop (state : EnhancedGameState) (remaining : List EnhancedAction) (acc : List EnhancedGameState) : List EnhancedGameState :=
    match remaining with
    | [] => acc.reverse
    | action :: rest =>
      let newState := applyEnhancedAction state action
      loop newState rest (newState :: acc)
  initial :: loop initial actions []

-- Render a single frame with frame number
def renderFrame (frameNum : Nat) (state : EnhancedGameState) (action : Option EnhancedAction) : String :=
  let header := s!"=== FRAME {frameNum} ==="
  let actionStr := match action with
    | none => "INITIAL STATE"
    | some act => s!"Action: {act}"
  let separator := "=" ++ "=" ++ "=" ++ "=" ++ "=" ++ "=" ++ "=" ++ "=" ++ "=" ++ "="
  let renderer : TextRenderer := {
    width := state.bounds.width,
    height := state.bounds.height,
    showStats := false,  -- Keep compact for demo
    showInventory := true
  }
  let gameRender := renderGameState renderer state
  s!"{header}\n{actionStr}\n{separator}\n{gameRender}\n"

-- Main demo function
def runDemo : IO Unit := do
  IO.println "🎮 NetHack Visualization System Demo"
  IO.println "====================================\n"
  
  let initialState := createDemoState
  let allStates := generateSequence initialState demoActions
  
  -- Show delaborator working
  IO.println "📋 Testing Delaborator Integration:"
  IO.println "The following should show visual dungeons when checked:\n"
  
  -- Render each frame
  IO.println "🎬 Frame-by-Frame Animation:"
  IO.println "=" * 60
  
  for (state, i) in allStates.zipIdx do
    let action := if i = 0 then none else some demoActions[i-1]!
    let frameOutput := renderFrame i state action
    IO.println frameOutput
    
    -- Add small delay for animation effect (comment out for speed)
    -- IO.sleep 100
  
  -- Show reward progression
  IO.println "\n💰 Reward Analysis:"
  let rewards := List.range (allStates.length - 1) |>.map fun i =>
    enhancedReward allStates[i]! allStates[i+1]!
  IO.println s!"Rewards per step: {rewards}"
  IO.println s!"Total reward: {rewards.sum}"
  
  -- Show inventory progression
  IO.println "\n🎒 Inventory Progression:"
  for (state, i) in allStates.zipIdx do
    let invCount := state.inventory.length
    let invStr := if invCount = 0 then "empty" else s!"{invCount} items"
    IO.println s!"Frame {i}: {invStr}"
  
  -- Save key frames
  IO.println "\n💾 Saving Key Frames..."
  saveSnapshot "frame_000_initial.txt" allStates[0]!
  saveSnapshot "frame_004_after_combat.txt" allStates[4]!
  saveSnapshot "frame_009_collected_gold.txt" allStates[9]!
  let finalFrame := allStates.length - 1
  saveSnapshot s!"frame_{finalFrame:03d}_final.txt" allStates[finalFrame]!
  IO.println "Key frames saved to frame_*.txt files"
  
  -- Performance test
  IO.println "\n⚡ Performance Test:"
  let startTime ← IO.monoMsNow
  let _ := allStates.map compactRender
  let endTime ← IO.monoMsNow
  IO.println s!"Rendered {allStates.length} frames in {endTime - startTime}ms"
  
  IO.println "\n✅ Demo Complete! Check the generated files and output above."

-- Test individual delaborator functionality
def testDelaborators : IO Unit := do
  IO.println "🔍 Testing Individual Delaborators:"
  
  -- Test basic game state
  let simpleState : GameState := {
    playerPos := { x := 3, y := 2 }
    playerStats := {
      hitpoints := 15, maxHitpoints := 20, strength := 16,
      dexterity := 12, constitution := 14, intelligence := 10,
      wisdom := 11, charisma := 8
    }
    dungeonLevel := 1
    bounds := { width := 8, height := 5 }
  }
  
  IO.println "Basic GameState delaborator test - check for visual output above"
  
  -- Test enhanced game state  
  let enhancedState := createDemoState
  IO.println "Enhanced GameState delaborator test - check for visual output above"
  
  -- Test computed states
  let afterMove := applyEnhancedAction enhancedState (EnhancedAction.move Direction.south)
  IO.println "Computed state delaborator test - check for visual output above"

#eval runDemo
#eval testDelaborators