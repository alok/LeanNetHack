import Lean
import LeanNetHack

/-
Simplified NetHack delaborator following lean4-maze pattern exactly
-/

-- Create a simplified game state that's easy to delaborate
structure SimpleNetHackState where
  bounds : DungeonBounds    -- width x height  
  playerPos : Position      -- player position
  monsters : List Position  -- monster positions
  deriving Repr, DecidableEq

-- Declare syntax categories exactly like maze
declare_syntax_cat nh_cell
declare_syntax_cat nh_row  
declare_syntax_cat nh_border
declare_syntax_cat nh_top_row
declare_syntax_cat nh_bottom_row

syntax "─" : nh_border

syntax "\n┌" nh_border* "┐\n" : nh_top_row
syntax "└" nh_border* "┘\n" : nh_bottom_row

-- NetHack cells
syntax "." : nh_cell -- floor
syntax "#" : nh_cell -- wall
syntax "@" : nh_cell -- player  
syntax "r" : nh_cell -- monster

syntax "│" nh_cell* "│\n" : nh_row

syntax:max nh_top_row nh_row* nh_bottom_row : term

-- Extract position exactly like maze extractXY
def extractPosition_delab : Lean.Expr → Lean.MetaM Position
| e => do
  let e' ← Lean.Meta.whnf e
  let posArgs := Lean.Expr.getAppArgs e'
  let x ← Lean.Meta.whnf posArgs[0]!
  let y ← Lean.Meta.whnf posArgs[1]!
  let numX := (Lean.Expr.rawNatLit? x).get!
  let numY := (Lean.Expr.rawNatLit? y).get!
  return Position.mk numX numY

-- Extract bounds exactly like maze extractXY  
def extractBounds_delab : Lean.Expr → Lean.MetaM DungeonBounds
| e => do
  let e' ← Lean.Meta.whnf e
  let boundsArgs := Lean.Expr.getAppArgs e'
  let width ← Lean.Meta.whnf boundsArgs[0]!
  let height ← Lean.Meta.whnf boundsArgs[1]!
  let numWidth := (Lean.Expr.rawNatLit? width).get!
  let numHeight := (Lean.Expr.rawNatLit? height).get!
  return DungeonBounds.mk numWidth numHeight

-- Extract monster list exactly like maze extractWallList
partial def extractMonsterList : Lean.Expr → Lean.MetaM (List Position)
| exp => do
  let exp' ← Lean.Meta.whnf exp
  let f := Lean.Expr.getAppFn exp'
  if f.constName!.toString == "List.cons"
  then let consArgs := Lean.Expr.getAppArgs exp'
       let rest ← extractMonsterList consArgs[2]!
       let monsterPos ← extractPosition_delab consArgs[1]!
       return monsterPos :: rest
  else return [] -- "List.nil"

-- Extract simple game state exactly like maze extractGameState
partial def extractSimpleNetHackState : Lean.Expr → Lean.MetaM SimpleNetHackState
| exp => do
    let exp' ← Lean.Meta.whnf exp
    let gameStateArgs := Lean.Expr.getAppArgs exp'
    let bounds ← extractBounds_delab gameStateArgs[0]!
    let playerPos ← extractPosition_delab gameStateArgs[1]!
    let monsters ← extractMonsterList gameStateArgs[2]!
    pure ⟨bounds, playerPos, monsters⟩

-- Update 2D array exactly like maze
def update2dArray_nh {α : Type} : Array (Array α) → Position → α → Array (Array α)
| a, ⟨x, y⟩, v =>
   Array.set! a y $ Array.set! a[y]! x v

def update2dArrayMulti_nh {α : Type} : Array (Array α) → List Position → α → Array (Array α)
| a,    [], _ => a
| a, p::ps, v =>
     let a' := update2dArrayMulti_nh a ps v
     update2dArray_nh a' p v

-- Create row exactly like maze
def delabNHRow : Array (Lean.TSyntax `nh_cell) → Lean.PrettyPrinter.Delaborator.DelabM (Lean.TSyntax `nh_row)
| a => `(nh_row| │ $a:nh_cell* │)

-- Main delaborator exactly like maze delabGameState
def delabSimpleNetHackState : Lean.Expr → Lean.PrettyPrinter.Delaborator.Delab
| e =>
  do guard $ e.getAppNumArgs == 3  -- Exactly like maze!
     let ⟨bounds, playerPos, monsters⟩ ←
       try extractSimpleNetHackState e
       catch _ => failure -- can happen if game state has variables in it

     let topBar := Array.replicate bounds.width $ ← `(nh_border| ─)
     let emptyCell ← `(nh_cell| .)

     let a0 := Array.replicate bounds.height $ Array.replicate bounds.width emptyCell
     let a1 := update2dArray_nh a0 playerPos $ ← `(nh_cell| @)
     let a2 := update2dArrayMulti_nh a1 monsters $ ← `(nh_cell| r)
     let aa ← Array.mapM delabNHRow a2

     `(┌$topBar:nh_border*┐
       $aa:nh_row*
       └$topBar:nh_border*┘)

-- Register delaborator exactly like maze
@[delab app.SimpleNetHackState.mk] 
def delabSimpleNetHackStateMk : Lean.PrettyPrinter.Delaborator.Delab := do
  let e ← Lean.PrettyPrinter.Delaborator.SubExpr.getExpr
  delabSimpleNetHackState e

-- Test it
def testSimpleState : SimpleNetHackState := {
  bounds := { width := 8, height := 5 },
  playerPos := { x := 2, y := 2 },
  monsters := [{ x := 4, y := 1 }, { x := 6, y := 3 }]
}

-- This should show visual dungeon if delaborator works
#check testSimpleState

def testSimpleState2 : SimpleNetHackState := {
  bounds := { width := 6, height := 4 },
  playerPos := { x := 1, y := 1 },
  monsters := [{ x := 3, y := 2 }]
}

#check testSimpleState2