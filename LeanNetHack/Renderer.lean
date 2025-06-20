import LeanNetHack.Basic

/-
Text renderer for NetHack game states
Creates ASCII snapshots for debugging and visualization
-/

namespace LeanNetHack

-- Text renderer that creates ASCII art snapshots
structure TextRenderer where
  width : Nat
  height : Nat
  showStats : Bool := true
  showInventory : Bool := true

-- Convert terrain to ASCII character
def terrainToAscii : Terrain → Char
  | Terrain.floor => '.'
  | Terrain.wall => '#'
  | Terrain.door => '+'
  | Terrain.corridor => '%'
  | Terrain.upstairs => '<'
  | Terrain.downstairs => '>'

-- Convert monster type to ASCII character
def monsterToAscii : MonsterType → Char
  | MonsterType.rat => 'r'
  | MonsterType.bat => 'b'
  | MonsterType.orc => 'o'
  | MonsterType.troll => 'T'
  | MonsterType.dragon => 'D'
  | MonsterType.lich => 'L'

-- Convert item type to ASCII character (simplified)
def itemToAscii : ItemType → Char
  | ItemType.weapon _ => ')'
  | ItemType.armor _ => '['
  | ItemType.potion _ => '!'
  | ItemType.scroll _ => '?'
  | ItemType.gold _ => '$'

-- Determine what character should be displayed at a position
def renderCell (pos : Position) (state : EnhancedGameState) : Char :=
  if pos = state.playerPos then
    '@'
  else
    let (terrain, content) := state.dungeonMap pos
    match content with
    | CellContent.empty => terrainToAscii terrain
    | CellContent.monster m => monsterToAscii m.monsterType
    | CellContent.item i => itemToAscii i.itemType
    | CellContent.both m _ => monsterToAscii m.monsterType -- Monster takes precedence

-- Create a text grid representation
def createTextGrid (state : EnhancedGameState) : Array (Array Char) :=
  let width := state.bounds.width
  let height := state.bounds.height
  Array.range height |>.map fun y =>
    Array.range width |>.map fun x =>
      renderCell ⟨x, y⟩ state

-- Convert grid to string with borders
def gridToString (grid : Array (Array Char)) : String :=
  let width := if grid.size > 0 then grid[0]!.size else 0
  let horizontalBar := Array.range width |>.map (fun _ => "─") |>.toList |> String.join
  let topBorder := "┌" ++ horizontalBar ++ "┐\n"
  let bottomBorder := "└" ++ horizontalBar ++ "┘\n"
  let rows := grid.map fun row =>
    "│" ++ String.mk row.toList ++ "│\n"
  topBorder ++ String.join rows.toList ++ bottomBorder

-- Format player stats as string
def formatStats (stats : PlayerStats) : String :=
  s!"HP: {stats.hitpoints}/{stats.maxHitpoints} " ++
  s!"Str: {stats.strength} Dex: {stats.dexterity} " ++
  s!"Con: {stats.constitution} Int: {stats.intelligence} " ++
  s!"Wis: {stats.wisdom} Cha: {stats.charisma}"

-- Format inventory as string
def formatInventory (inventory : List ItemType) : String :=
  if inventory.isEmpty then
    "Inventory: (empty)"
  else
    let itemStrings := inventory.map toString
    "Inventory: " ++ String.intercalate ", " itemStrings

-- Main rendering function
def renderGameState (renderer : TextRenderer) (state : EnhancedGameState) : String :=
  let grid := createTextGrid state
  let mapString := gridToString grid
  let header := s!"=== NetHack Level {state.dungeonLevel} ===\n"
  let posString := s!"Position: {state.playerPos}\n"
  
  let statsString := if renderer.showStats then
    formatStats state.playerStats ++ "\n"
  else ""
  
  let inventoryString := if renderer.showInventory then
    formatInventory state.inventory ++ "\n"
  else ""
  
  header ++ posString ++ statsString ++ inventoryString ++ "\n" ++ mapString

-- Create a simple enhanced game state for testing
def createTestState (width height : Nat) : EnhancedGameState :=
  let bounds : DungeonBounds := { width := width, height := height }
  let playerStats : PlayerStats := {
    hitpoints := 18, maxHitpoints := 20, strength := 16,
    dexterity := 14, constitution := 15, intelligence := 12,
    wisdom := 13, charisma := 11
  }
  
  -- Simple dungeon map with some variety
  let dungeonMap : DungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = width || pos.y + 1 = height then
      (Terrain.wall, CellContent.empty)
    else if pos.x % 4 = 0 && pos.y % 3 = 0 then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.rat,
        position := pos,
        hitpoints := 3,
        maxHitpoints := 5,
        attackPower := 1
      })
    else if pos.x % 5 = 0 && pos.y % 4 = 0 then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 15,
        position := pos
      })
    else if (pos.x + pos.y) % 7 = 0 then
      (Terrain.wall, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  
  {
    playerPos := { x := 2, y := 2 }
    playerStats := playerStats
    dungeonLevel := 1
    bounds := bounds
    dungeonMap := dungeonMap
    inventory := [ItemType.weapon "short sword", ItemType.potion "healing"]
  }

-- Test the renderer
def testRenderer : TextRenderer := {
  width := 15,
  height := 10,
  showStats := true,
  showInventory := true
}

-- Create test state and render it
def testStateRender : String :=
  let state := createTestState 15 10
  renderGameState testRenderer state

-- Function to save snapshot to file (when IO is available)
def saveSnapshot (filename : String) (state : EnhancedGameState) : IO Unit := do
  let renderer : TextRenderer := { width := state.bounds.width, height := state.bounds.height }
  let snapshot := renderGameState renderer state
  IO.FS.writeFile filename snapshot

-- Debugging helper: render a sequence of game states
def renderGameSequence (states : List EnhancedGameState) : List String :=
  let renderer : TextRenderer := { 
    width := 20, height := 15, 
    showStats := true, showInventory := false 
  }
  states.map (renderGameState renderer)

-- Interactive debugging: show before/after state change
def debugStateTransition (before after : EnhancedGameState) : String :=
  let renderer : TextRenderer := { 
    width := max before.bounds.width after.bounds.width,
    height := max before.bounds.height after.bounds.height,
    showStats := true, 
    showInventory := true 
  }
  "BEFORE:\n" ++ renderGameState renderer before ++ 
  "\nAFTER:\n" ++ renderGameState renderer after

-- Compact renderer for LSP/MCP display
def compactRender (state : EnhancedGameState) : String :=
  let renderer : TextRenderer := { 
    width := state.bounds.width, 
    height := state.bounds.height,
    showStats := false, 
    showInventory := false 
  }
  renderGameState renderer state

end LeanNetHack