import LeanNetHack

open LeanNetHack

/-
NetHack Debugger: Interactive debugging tools for game states
Combines delaborator visualization with text rendering for debugging
-/

-- Interactive debugging session
structure DebugSession where
  initialState : EnhancedGameState
  currentState : EnhancedGameState
  actionHistory : List EnhancedAction
  stepCount : Nat

-- Create a new debug session
def startDebugSession (state : EnhancedGameState) : DebugSession := {
  initialState := state
  currentState := state
  actionHistory := []
  stepCount := 0
}

-- Execute one action and update debug session
def debugStep (session : DebugSession) (action : EnhancedAction) : DebugSession := {
  initialState := session.initialState
  currentState := applyEnhancedAction session.currentState action
  actionHistory := session.actionHistory ++ [action]
  stepCount := session.stepCount + 1
}

-- Create a test debugging scenario
def testScenario : EnhancedGameState := {
  playerPos := { x := 3, y := 3 }
  playerStats := {
    hitpoints := 20, maxHitpoints := 20, strength := 18,
    dexterity := 14, constitution := 16, intelligence := 12,
    wisdom := 13, charisma := 10
  }
  dungeonLevel := 1
  bounds := { width := 10, height := 8 }
  dungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = 10 || pos.y + 1 = 8 then
      (Terrain.wall, CellContent.empty)
    else if pos = ⟨5, 4⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.orc,
        position := pos,
        hitpoints := 8,
        maxHitpoints := 10,
        attackPower := 3
      })
    else if pos = ⟨7, 2⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.weapon "sword",
        position := pos
      })
    else if pos = ⟨2, 6⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 50,
        position := pos
      })
    else if pos = ⟨8, 6⟩ then
      (Terrain.downstairs, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  inventory := [ItemType.potion "healing"]
}

-- Debug session demonstration
def session0 := startDebugSession testScenario
def session1 := debugStep session0 (EnhancedAction.move Direction.east)
def session2 := debugStep session1 (EnhancedAction.move Direction.east)
def session3 := debugStep session2 (EnhancedAction.move Direction.south)

-- Show progression through delaborator
#check session0.currentState
#check session1.currentState
#check session2.currentState
#check session3.currentState

-- Function to replay an entire action sequence
def replayActions (initial : EnhancedGameState) (actions : List EnhancedAction) : List EnhancedGameState :=
  actions.scanl applyEnhancedAction initial

-- Test action sequence
def actionSequence : List EnhancedAction := [
  EnhancedAction.move Direction.east,
  EnhancedAction.move Direction.south,
  EnhancedAction.move Direction.east,
  EnhancedAction.move Direction.south,
  EnhancedAction.pickup
]

def replayStates := replayActions testScenario actionSequence

-- Show each state in the replay (delaborator will visualize each)
#check replayStates[0]!  -- Initial state
#check replayStates[1]!  -- After move east
#check replayStates[2]!  -- After move south  
#check replayStates[3]!  -- After move east again
#check replayStates[4]!  -- After move south again
#check replayStates[5]!  -- After pickup attempt

-- Text debug output
def debugText : IO Unit := do
  IO.println "=== NetHack Debugging Session ==="
  IO.println "Initial state:"
  IO.println (compactRender session0.currentState)
  IO.println "\nAfter moving east:"
  IO.println (compactRender session1.currentState)
  IO.println "\nAfter moving east again:"
  IO.println (compactRender session2.currentState)
  IO.println "\nAfter moving south:"
  IO.println (compactRender session3.currentState)

#eval debugText

-- Advanced debugging: show reward progression
def analyzeRewards (states : List EnhancedGameState) : List Int :=
  match states with
  | [] => []
  | [_] => [0]
  | s1 :: s2 :: rest => 
    enhancedReward s1 s2 :: analyzeRewards (s2 :: rest)

def rewardAnalysis : List Int := analyzeRewards replayStates

#eval IO.println s!"Reward progression: {rewardAnalysis}"

-- Performance testing: large state transitions
def largeState : EnhancedGameState := {
  playerPos := { x := 10, y := 10 }
  playerStats := {
    hitpoints := 25, maxHitpoints := 30, strength := 20,
    dexterity := 16, constitution := 18, intelligence := 14,
    wisdom := 15, charisma := 12
  }
  dungeonLevel := 3
  bounds := { width := 25, height := 20 }
  dungeonMap := generateDungeon { width := 25, height := 20 } {
    monsterDensity := 15,
    itemDensity := 10,
    roomCount := 6,
    corridorWidth := 2
  }
  inventory := [
    ItemType.weapon "long sword",
    ItemType.armor "chain mail", 
    ItemType.potion "healing",
    ItemType.potion "strength",
    ItemType.scroll "identify"
  ]
}

-- The delaborator should handle this large state
#check largeState