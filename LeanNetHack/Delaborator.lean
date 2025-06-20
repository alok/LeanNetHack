import Lean
import LeanNetHack.Basic

/-
NetHack Delaborator for visual game state representation
Inspired by lean4-maze project
-/

namespace LeanNetHack

-- Define custom syntax categories for NetHack visualization
declare_syntax_cat nethack_cell
declare_syntax_cat nethack_row
declare_syntax_cat horizontal_border
declare_syntax_cat nethack_top_row
declare_syntax_cat nethack_bottom_row

-- Border syntax
syntax "─" : horizontal_border

-- Top and bottom borders
syntax "\n┌" horizontal_border* "┐\n" : nethack_top_row
syntax "└" horizontal_border* "┘\n" : nethack_bottom_row

-- NetHack cell contents (using Unicode characters for visual appeal)
syntax "." : nethack_cell -- floor
syntax "#" : nethack_cell -- wall  
syntax "+" : nethack_cell -- door
syntax "%" : nethack_cell -- corridor
syntax "<" : nethack_cell -- upstairs
syntax ">" : nethack_cell -- downstairs
syntax "@" : nethack_cell -- player
syntax "r" : nethack_cell -- rat
syntax "b" : nethack_cell -- bat
syntax "o" : nethack_cell -- orc
syntax "T" : nethack_cell -- troll
syntax "D" : nethack_cell -- dragon
syntax "L" : nethack_cell -- lich
syntax "$" : nethack_cell -- gold
syntax ")" : nethack_cell -- weapon
syntax "[" : nethack_cell -- armor
syntax "!" : nethack_cell -- potion
syntax "?" : nethack_cell -- scroll

-- Row syntax
syntax "│" nethack_cell* "│\n" : nethack_row

-- Full game state syntax
syntax:max nethack_top_row nethack_row* nethack_bottom_row : term

-- Helper function to convert terrain to display character
def terrainToChar : Terrain → String
  | Terrain.floor => "."
  | Terrain.wall => "#"
  | Terrain.door => "+"
  | Terrain.corridor => "%"
  | Terrain.upstairs => "<"
  | Terrain.downstairs => ">"

-- Helper function to convert monster to display character
def monsterToChar : MonsterType → String
  | MonsterType.rat => "r"
  | MonsterType.bat => "b"
  | MonsterType.orc => "o"
  | MonsterType.troll => "T"
  | MonsterType.dragon => "D"
  | MonsterType.lich => "L"

-- Helper function to convert item to display character
def itemToChar : ItemType → String
  | ItemType.weapon _ => ")"
  | ItemType.armor _ => "["
  | ItemType.potion _ => "!"
  | ItemType.scroll _ => "?"
  | ItemType.gold _ => "$"

-- Determine what character should be displayed for a cell
def cellToChar (pos : Position) (playerPos : Position) (terrain : Terrain) 
    (content : CellContent) : String :=
  if pos = playerPos then
    "@"
  else
    match content with
    | CellContent.empty => terrainToChar terrain
    | CellContent.monster m => monsterToChar m.monsterType
    | CellContent.item i => itemToChar i.itemType
    | CellContent.both m _ => monsterToChar m.monsterType -- Monster takes precedence

-- Extract position from Lean expression following lean4-maze pattern
def extractPosition : Lean.Expr → Lean.MetaM Position
  | e => do
    let e' ← Lean.Meta.whnf e
    let args := e'.getAppArgs
    guard $ args.size ≥ 2
    let x ← Lean.Meta.whnf args[0]!
    let y ← Lean.Meta.whnf args[1]!
    let numX := (x.rawNatLit?).getD 0
    let numY := (y.rawNatLit?).getD 0
    return Position.mk numX numY

-- Extract dungeon bounds from Lean expression
def extractBounds : Lean.Expr → Lean.MetaM DungeonBounds
  | e => do
    let e' ← Lean.Meta.whnf e
    let args := e'.getAppArgs
    guard $ args.size ≥ 2
    let width ← Lean.Meta.whnf args[0]!
    let height ← Lean.Meta.whnf args[1]!
    let numWidth := (width.rawNatLit?).getD 5
    let numHeight := (height.rawNatLit?).getD 5
    return DungeonBounds.mk numWidth numHeight

-- Extract basic game state from constructor application
def extractBasicGameState : Lean.Expr → Lean.MetaM (Position × DungeonBounds)
  | e => do
    let e' ← Lean.Meta.whnf e
    guard $ e'.isApp
    let args := e'.getAppArgs
    guard $ args.size ≥ 4
    
    -- Extract player position (first field)
    let playerPos ← extractPosition args[0]!
    
    -- Extract bounds (fourth field)
    let bounds ← extractBounds args[3]!
    
    return (playerPos, bounds)

-- Helper to convert array of cells to a row syntax
def delabNetHackRow : Array (Lean.TSyntax `nethack_cell) → Lean.PrettyPrinter.Delaborator.DelabM (Lean.TSyntax `nethack_row)
  | a => `(nethack_row| │ $a:nethack_cell* │)


-- Helper to repeat a string n times
def repeatString (s : String) (n : Nat) : String :=
  (List.range n).foldl (fun acc _ => acc ++ s) ""

-- Generate visual dungeon representation
def generateDungeonVisual (playerPos : Position) (bounds : DungeonBounds) : String :=
  let rows := List.range bounds.height
  let cols := List.range bounds.width
  
  -- Create top border
  let topBorder := "┌" ++ repeatString "─" bounds.width ++ "┐\n"
  
  -- Create each row
  let dungeonRows := rows.map fun y =>
    let rowChars := cols.map fun x =>
      let pos := Position.mk x y
      if pos = playerPos then "@"
      else if x = 0 || y = 0 || x + 1 = bounds.width || y + 1 = bounds.height then "#"
      else "."
    "│" ++ String.join rowChars ++ "│\n"
  
  -- Create bottom border
  let bottomBorder := "└" ++ repeatString "─" bounds.width ++ "┘"
  
  topBorder ++ String.join dungeonRows ++ bottomBorder

-- Main delaborator function that creates visual representation
def delabGameState : Lean.Expr → Lean.PrettyPrinter.Delaborator.Delab
  | e => do
    -- Extract player position and bounds from the GameState constructor
    let (playerPos, bounds) ← 
      try extractBasicGameState e
      catch _ => 
        -- Fallback to simple test values if extraction fails
        pure (Position.mk 1 1, DungeonBounds.mk 5 4)
    
    -- Generate the visual representation
    let visual := generateDungeonVisual playerPos bounds
    
    -- Return as a string literal
    return Lean.Syntax.mkStrLit visual

-- Register the delaborator for GameState.mk
@[delab app.GameState.mk] 
def delabGameStateMk : Lean.PrettyPrinter.Delaborator.Delab := do
  let e ← Lean.PrettyPrinter.Delaborator.SubExpr.getExpr
  delabGameState e

-- Also try registering for the fully qualified name
@[delab app.LeanNetHack.GameState.mk]
def delabLeanNetHackGameState : Lean.PrettyPrinter.Delaborator.Delab := do
  let e ← Lean.PrettyPrinter.Delaborator.SubExpr.getExpr
  delabGameState e

-- Create a simple dungeon state for testing
def testDungeon : GameState := {
  playerPos := { x := 2, y := 2 }
  playerStats := {
    hitpoints := 20, maxHitpoints := 20, strength := 18,
    dexterity := 14, constitution := 16, intelligence := 12,
    wisdom := 13, charisma := 10
  }
  dungeonLevel := 1
  bounds := { width := 8, height := 6 }
}

-- Create enhanced test dungeon with monsters and items
def testEnhancedDungeon : EnhancedGameState :=
  let bounds : DungeonBounds := { width := 10, height := 6 }
  let playerStats : PlayerStats := {
    hitpoints := 18, maxHitpoints := 20, strength := 16,
    dexterity := 14, constitution := 15, intelligence := 12,
    wisdom := 13, charisma := 11
  }
  
  let dungeonMap : DungeonMap := fun pos =>
    if pos.x = 0 || pos.y = 0 || pos.x + 1 = bounds.width || pos.y + 1 = bounds.height then
      (Terrain.wall, CellContent.empty)
    else if pos = ⟨3, 2⟩ then
      (Terrain.floor, CellContent.monster {
        monsterType := MonsterType.rat,
        position := pos,
        hitpoints := 3,
        maxHitpoints := 5,
        attackPower := 1
      })
    else if pos = ⟨6, 3⟩ then
      (Terrain.floor, CellContent.item {
        itemType := ItemType.gold 25,
        position := pos
      })
    else if pos = ⟨8, 1⟩ then
      (Terrain.downstairs, CellContent.empty)
    else
      (Terrain.floor, CellContent.empty)
  
  {
    playerPos := { x := 1, y := 1 }
    playerStats := playerStats
    dungeonLevel := 1
    bounds := bounds
    dungeonMap := dungeonMap
    inventory := [ItemType.weapon "short sword", ItemType.potion "healing"]
  }

-- Test the delaborators with simple examples
def simpleTest : GameState := {
  playerPos := { x := 1, y := 1 }
  playerStats := {
    hitpoints := 20, maxHitpoints := 20, strength := 18,
    dexterity := 14, constitution := 16, intelligence := 12,
    wisdom := 13, charisma := 10
  }
  dungeonLevel := 1
  bounds := { width := 5, height := 4 }
}

-- Test with explicit constructor syntax
def explicitTest : GameState := 
  GameState.mk 
    { x := 3, y := 3 }  -- playerPos
    { hitpoints := 15, maxHitpoints := 20, strength := 16, dexterity := 12, constitution := 14, intelligence := 10, wisdom := 11, charisma := 8 }  -- playerStats
    2  -- dungeonLevel
    { width := 6, height := 5 }  -- bounds

-- Test both #check and #eval to see the difference
#check simpleTest  -- This shows the TYPE 
#eval simpleTest   -- This should show the VALUE (and trigger delaborator)
#check testDungeon
#eval testDungeon
#check explicitTest  -- Test explicit constructor
#eval explicitTest   -- Test explicit constructor
#check testEnhancedDungeon

end LeanNetHack