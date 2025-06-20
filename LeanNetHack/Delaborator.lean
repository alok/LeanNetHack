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

-- Extract game state components from Lean expression (similar to maze implementation)
def extractPosition : Lean.Expr → Lean.MetaM Position
  | e => do
    let e' ← Lean.Meta.whnf e
    let posArgs := Lean.Expr.getAppArgs e'
    let x ← Lean.Meta.whnf posArgs[0]!
    let y ← Lean.Meta.whnf posArgs[1]!
    let numX := (Lean.Expr.rawNatLit? x).get!
    let numY := (Lean.Expr.rawNatLit? y).get!
    return Position.mk numX numY

def extractBounds : Lean.Expr → Lean.MetaM DungeonBounds
  | e => do
    let e' ← Lean.Meta.whnf e
    let boundsArgs := Lean.Expr.getAppArgs e'
    let width ← Lean.Meta.whnf boundsArgs[0]!
    let height ← Lean.Meta.whnf boundsArgs[1]!
    let numWidth := (Lean.Expr.rawNatLit? width).get!
    let numHeight := (Lean.Expr.rawNatLit? height).get!
    return DungeonBounds.mk numWidth numHeight

-- Extract enhanced game state from Lean expression
partial def extractEnhancedGameState : Lean.Expr → Lean.MetaM EnhancedGameState
  | exp => do
    let exp' ← Lean.Meta.whnf exp
    let gameStateArgs := Lean.Expr.getAppArgs exp'
    -- Try to extract what we can, with fallbacks for demonstration
    let playerPos ← 
      try extractPosition gameStateArgs[0]!
      catch _ => pure { x := 1, y := 1 }
    
    let playerStats : PlayerStats := {
      hitpoints := 18, maxHitpoints := 20, strength := 16,
      dexterity := 14, constitution := 15, intelligence := 12,
      wisdom := 13, charisma := 11
    }
    
    let bounds : DungeonBounds := { width := 12, height := 8 }
    
    -- Simple dungeon map for demonstration
    let dungeonMap : DungeonMap := fun pos =>
      if pos.x = 0 || pos.y = 0 || pos.x + 1 = bounds.width || pos.y + 1 = bounds.height then
        (Terrain.wall, CellContent.empty)
      else if pos.x % 3 = 0 && pos.y % 2 = 0 then
        (Terrain.floor, CellContent.monster {
          monsterType := MonsterType.rat,
          position := pos,
          hitpoints := 3,
          maxHitpoints := 5,
          attackPower := 1
        })
      else if pos.x % 4 = 0 && pos.y % 3 = 0 then
        (Terrain.floor, CellContent.item {
          itemType := ItemType.gold 10,
          position := pos
        })
      else
        (Terrain.floor, CellContent.empty)
    
    pure {
      playerPos := playerPos,
      playerStats := playerStats,
      dungeonLevel := 1,
      bounds := bounds,
      dungeonMap := dungeonMap,
      inventory := [ItemType.weapon "dagger"]
    }

-- Simple extraction for basic game state (for backward compatibility)
partial def extractBasicGameState : Lean.Expr → Lean.MetaM GameState
  | exp => do
    let exp' ← Lean.Meta.whnf exp
    let gameStateArgs := Lean.Expr.getAppArgs exp'
    let playerPos ← 
      try extractPosition gameStateArgs[0]!
      catch _ => pure { x := 1, y := 1 }
    
    let playerStats : PlayerStats := {
      hitpoints := 20, maxHitpoints := 20, strength := 18,
      dexterity := 14, constitution := 16, intelligence := 12,
      wisdom := 13, charisma := 10
    }
    let bounds : DungeonBounds := { width := 10, height := 10 }
    pure ⟨playerPos, playerStats, 1, bounds⟩

-- Create a 2D array representation for rendering
def create2DArray {α : Type} (width height : Nat) (default : α) : Array (Array α) :=
  Array.replicate height (Array.replicate width default)

def update2DArray {α : Type} : Array (Array α) → Position → α → Array (Array α)
  | a, ⟨x, y⟩, v =>
    if h : y < a.size then
      let row := a[y]
      if h' : x < row.size then
        Array.set! a y (Array.set! row x v)
      else a
    else a

-- Convert array of characters to nethack_cell syntax
def charToNetHackCell : String → Lean.PrettyPrinter.Delaborator.DelabM (Lean.TSyntax `nethack_cell)
  | "." => `(nethack_cell| .)
  | "#" => `(nethack_cell| #)
  | "+" => `(nethack_cell| +)
  | "%" => `(nethack_cell| %)
  | "<" => `(nethack_cell| <)
  | ">" => `(nethack_cell| >)
  | "@" => `(nethack_cell| @)
  | "r" => `(nethack_cell| r)
  | "b" => `(nethack_cell| b)
  | "o" => `(nethack_cell| o)
  | "T" => `(nethack_cell| T)
  | "D" => `(nethack_cell| D)
  | "L" => `(nethack_cell| L)
  | "$" => `(nethack_cell| $)
  | ")" => `(nethack_cell| ))
  | "[" => `(nethack_cell| [)
  | "!" => `(nethack_cell| !)
  | "?" => `(nethack_cell| ?)
  | _ => `(nethack_cell| .) -- default to floor

-- Convert array of cells to a row
def delabNetHackRow : Array (Lean.TSyntax `nethack_cell) → Lean.PrettyPrinter.Delaborator.DelabM (Lean.TSyntax `nethack_row)
  | a => `(nethack_row| │ $a:nethack_cell* │)

-- Enhanced delaborator for EnhancedGameState
def delabEnhancedGameState : Lean.Expr → Lean.PrettyPrinter.Delaborator.Delab
  | e => do
    guard $ e.getAppNumArgs ≥ 5  -- EnhancedGameState has at least 5 fields
    let gameState ← 
      try extractEnhancedGameState e
      catch _ => failure -- Handle cases where extraction fails
    
    let width := gameState.bounds.width
    let height := gameState.bounds.height
    
    -- Create top border
    let topBar := Array.replicate width (← `(horizontal_border| ─))
    
    -- Create character grid based on actual game state
    let mut charArray := create2DArray width height "."
    
    -- Fill grid with terrain and entities
    for y in List.range height do
      for x in List.range width do
        let pos : Position := ⟨x, y⟩
        let char := cellToChar pos gameState.playerPos 
                      (gameState.dungeonMap pos).1 
                      (gameState.dungeonMap pos).2
        charArray := update2DArray charArray pos char
    
    -- Convert character array to syntax
    let mut rows : Array (Lean.TSyntax `nethack_row) := #[]
    for row in charArray do
      let cellArray ← row.mapM charToNetHackCell
      let rowSyntax ← delabNetHackRow cellArray
      rows := rows.push rowSyntax
    
    `(┌$topBar:horizontal_border*┐
      $rows:nethack_row*
      └$topBar:horizontal_border*┘)

-- Main delaborator function for GameState (fallback)
def delabGameState : Lean.Expr → Lean.PrettyPrinter.Delaborator.Delab
  | e => do
    guard $ e.getAppNumArgs ≥ 4  -- GameState has at least 4 fields
    let gameState ← 
      try extractBasicGameState e
      catch _ => failure -- Handle cases where extraction fails
    
    let width := gameState.bounds.width
    let height := gameState.bounds.height
    
    -- Create top border
    let topBar := Array.replicate width (← `(horizontal_border| ─))
    
    -- Create default floor grid
    let defaultChar := "."
    let charArray := create2DArray width height defaultChar
    
    -- Place player
    let charArrayWithPlayer := update2DArray charArray gameState.playerPos "@"
    
    -- Convert character array to syntax
    let mut rows : Array (Lean.TSyntax `nethack_row) := #[]
    for row in charArrayWithPlayer do
      let cellArray ← row.mapM charToNetHackCell
      let rowSyntax ← delabNetHackRow cellArray
      rows := rows.push rowSyntax
    
    `(┌$topBar:horizontal_border*┐
      $rows:nethack_row*
      └$topBar:horizontal_border*┘)

-- Register the delaborator for GameState.mk
@[delab app.GameState.mk] 
def delabGameStateMk : Lean.PrettyPrinter.Delaborator.Delab := do
  let e ← Lean.PrettyPrinter.Delaborator.SubExpr.getExpr
  delabGameState e

-- Register the delaborator for EnhancedGameState.mk
@[delab app.EnhancedGameState.mk]
def delabEnhancedGameStateMk : Lean.PrettyPrinter.Delaborator.Delab := do
  let e ← Lean.PrettyPrinter.Delaborator.SubExpr.getExpr
  delabEnhancedGameState e

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

-- Test the delaborators
#check testDungeon
#check testEnhancedDungeon

end LeanNetHack