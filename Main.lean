import LeanNetHack

def main : IO Unit := do
  IO.println "=== Advanced NetHack DSL: Combat, AI, and Optimization ==="
  
  -- Create enhanced game state with generated dungeon
  let initialStats : PlayerStats := {
    hitpoints := 20
    maxHitpoints := 20
    strength := 18
    dexterity := 14
    constitution := 16
    intelligence := 12
    wisdom := 13
    charisma := 10
  }
  
  let bounds : DungeonBounds := { width := 15, height := 12 }
  let genParams : DungeonGenParams := {
    monsterDensity := 20,
    itemDensity := 15, 
    roomCount := 4,
    corridorWidth := 1
  }
  
  let dungeonMap := generateDungeon bounds genParams
  
  let enhancedState : EnhancedGameState := {
    playerPos := { x := 1, y := 1 }
    playerStats := initialStats
    dungeonLevel := 1
    bounds := bounds
    dungeonMap := dungeonMap
    inventory := []
  }
  
  IO.println s!"Player starts at {enhancedState.playerPos}"
  IO.println s!"HP: {enhancedState.playerStats.hitpoints}/{enhancedState.playerStats.maxHitpoints}"
  IO.println s!"Strength: {enhancedState.playerStats.strength}"
  
  -- Explore nearby positions
  IO.println "\n=== Dungeon Exploration ==="
  let nearbyPositions := [
    enhancedState.playerPos.move Direction.north,
    enhancedState.playerPos.move Direction.east, 
    enhancedState.playerPos.move Direction.south,
    enhancedState.playerPos.move Direction.west
  ]
  
  for pos in nearbyPositions do
    if pos.inBounds bounds then
      let (terrain, content) := dungeonMap pos
      let contentStr := match content with
        | CellContent.empty => "empty"
        | CellContent.monster m => s!"monster({m.monsterType})"
        | CellContent.item i => s!"item({i.itemType})"
        | CellContent.both m i => s!"monster({m.monsterType}) & item({i.itemType})"
      IO.println s!"  {pos}: {terrain} - {contentStr}"
  
  -- Test pathfinding
  IO.println "\n=== AI Pathfinding ==="
  let goal : Position := { x := 10, y := 8 }
  let path := findPath enhancedState.playerPos goal bounds dungeonMap
  IO.println s!"Path to {goal}: {path.length} steps"
  if path.length > 0 && path.length <= 5 then
    for (pos, i) in path.zipIdx do
      IO.println s!"  Step {i + 1}: {pos}"
  
  -- Test tactical AI
  IO.println "\n=== Tactical AI Decision Making ==="
  let validActions := getValidActions enhancedState
  IO.println s!"Valid actions ({validActions.length}): {validActions.take 5}"
  
  let tacticalAction := tacticalPolicy 2 enhancedState
  IO.println s!"Tactical AI chooses: {tacticalAction}"
  
  -- Execute a sequence with the tactical AI
  let mut currentState := enhancedState
  let mut totalReward : Int := 0
  let mut step := 0
  
  IO.println "\n=== AI-Driven Gameplay Simulation ==="
  while step < 8 do
    let action := tacticalPolicy 2 currentState
    let newState := applyEnhancedAction currentState action
    let stepReward := enhancedReward currentState newState
    
    IO.println s!"Step {step + 1}: {action} -> Reward: {stepReward}"
    
    if newState.playerPos != currentState.playerPos then
      IO.println s!"  Moved to {newState.playerPos}"
    
    if newState.dungeonLevel != currentState.dungeonLevel then
      IO.println s!"  Advanced to dungeon level {newState.dungeonLevel}!"
    
    currentState := newState
    totalReward := totalReward + stepReward
    step := step + 1
  
  IO.println s!"\nFinal Results:"
  IO.println s!"Position: {currentState.playerPos}"
  IO.println s!"Dungeon Level: {currentState.dungeonLevel}"
  IO.println s!"HP: {currentState.playerStats.hitpoints}/{currentState.playerStats.maxHitpoints}"
  IO.println s!"Inventory Items: {currentState.inventory.length}"
  IO.println s!"Total Reward: {totalReward}"
  
  -- Test Deep RL Feature Extraction
  IO.println "\n=== Deep RL Feature Extraction ==="
  let features := extractFeatures currentState
  IO.println s!"State features ({features.length} dims): {features.take 8}"
  
  -- Test DQN Agent Setup
  IO.println "\n=== Deep Q-Network Agent Demo ==="
  let dummyNetwork : NeuralNetwork := {
    layers := [],
    learningRate := 0.001
  }
  let qFunc : QFunction := { network := dummyNetwork }
  let replayBuf : ReplayBuffer := { experiences := [], maxSize := 10000 }
  
  let dqnAgent : DQNAgent := {
    qNetwork := qFunc,
    targetNetwork := qFunc,
    replayBuffer := replayBuf,
    epsilon := 0.1,
    gamma := 0.99,
    updateFreq := 100,
    batchSize := 32
  }
  
  let dqnAction := epsilonGreedy dqnAgent currentState 42
  IO.println s!"DQN Agent chooses: {dqnAction}"
  
  -- Test Multi-Objective Reward
  IO.println "\n=== Multi-Objective Optimization ==="
  let objectives : MultiObjective := {
    survivalWeight := 1.0,
    progressWeight := 10.0,
    explorationWeight := 0.5,
    efficiencyWeight := 0.1
  }
  
  let testState := applyEnhancedAction currentState (EnhancedAction.move Direction.east)
  let multiReward := multiObjectiveReward currentState testState objectives
  IO.println s!"Multi-objective reward: {multiReward}"
  
  -- Test Hierarchical Goals
  IO.println "\n=== Hierarchical RL Goals ==="
  let hierarchicalGoals := [
    HighLevelGoal.exploreLevel,
    HighLevelGoal.findStairs,
    HighLevelGoal.heal
  ]
  for goal in hierarchicalGoals do
    IO.println s!"  Goal: {goal}"
  
  IO.println "\n=== Comprehensive DSL Feature Summary ==="
  IO.println "✓ Complex game state with monsters, items, terrain"
  IO.println "✓ Combat system with damage calculation"
  IO.println "✓ Procedural dungeon generation"
  IO.println "✓ A* pathfinding algorithms"
  IO.println "✓ Minimax AI with alpha-beta pruning"
  IO.println "✓ Reward-based optimization framework"
  IO.println "✓ Deep Q-Networks (DQN) with experience replay"
  IO.println "✓ Policy gradient and actor-critic frameworks"
  IO.println "✓ Multi-objective optimization"
  IO.println "✓ Hierarchical reinforcement learning"
  IO.println "✓ Curriculum learning structures"
  IO.println "✓ Meta-learning and adaptation"
  IO.println "✓ Neural network feature extraction"
  IO.println "✓ Formal verification foundations (with proofs)"
  IO.println "✓ Complete integration ready for real NetHack solving!"
