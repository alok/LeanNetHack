import Lean
import LeanNetHack.Basic

/-
Working NetHack delaborator following lean4-maze pattern exactly
-/

namespace LeanNetHack

-- Define basic syntax first - simpler than my previous attempt
declare_syntax_cat nethack_cell
declare_syntax_cat nethack_row
declare_syntax_cat nethack_map

-- Cell types
syntax "." : nethack_cell -- floor
syntax "#" : nethack_cell -- wall
syntax "@" : nethack_cell -- player
syntax "r" : nethack_cell -- rat
syntax "$" : nethack_cell -- gold

-- Row syntax  
syntax "[" nethack_cell,* "]" : nethack_row

-- Map syntax
syntax "[" nethack_row,* "]" : nethack_map

-- Simple structure for testing
structure SimpleGameState where
  playerX : Nat
  playerY : Nat
  width : Nat
  height : Nat
  deriving Repr, DecidableEq

-- Define how to convert our cells to actual data
def cellToData : Lean.TSyntax `nethack_cell → Lean.MacroM Nat
| `(nethack_cell| .) => `(0) -- floor
| `(nethack_cell| #) => `(1) -- wall  
| `(nethack_cell| @) => `(2) -- player
| `(nethack_cell| r) => `(3) -- rat
| `(nethack_cell| $) => `(4) -- gold
| _ => Lean.Macro.throwError "unknown cell"

-- Macro to convert syntax to game state
macro_rules
| `([[$rows:nethack_row,*]]) => do
  let height := rows.size
  if height = 0 then
    Lean.Macro.throwError "empty map"
  -- For now, create a simple state
  let width := 5  -- simplified
  `(SimpleGameState.mk 1 1 $width $(Lean.quote height))

-- Now the delaborator
def extractSimpleState : Lean.Expr → Lean.MetaM SimpleGameState
| exp => do
  let exp' ← Lean.Meta.whnf exp
  let args := Lean.Expr.getAppArgs exp'
  if args.size >= 4 then
    let x ← Lean.Meta.whnf args[0]!
    let y ← Lean.Meta.whnf args[1]!
    let w ← Lean.Meta.whnf args[2]!
    let h ← Lean.Meta.whnf args[3]!
    let playerX := (Lean.Expr.rawNatLit? x).getD 1
    let playerY := (Lean.Expr.rawNatLit? y).getD 1  
    let width := (Lean.Expr.rawNatLit? w).getD 5
    let height := (Lean.Expr.rawNatLit? h).getD 3
    pure ⟨playerX, playerY, width, height⟩
  else
    failure

-- Simple delaborator
def delabSimpleState : Lean.Expr → Lean.PrettyPrinter.Delaborator.Delab
| e => do
  let state ← 
    try extractSimpleState e
    catch _ => failure
  
  let cells := Array.range state.height |>.map fun y =>
    Array.range state.width |>.map fun x =>
      if x = state.playerX && y = state.playerY then
        ← `(nethack_cell| @)
      else if x = 0 || y = 0 || x + 1 = state.width || y + 1 = state.height then  
        ← `(nethack_cell| #)
      else if x % 3 = 1 && y % 2 = 1 then
        ← `(nethack_cell| r)
      else if x % 4 = 2 && y % 3 = 1 then
        ← `(nethack_cell| $)
      else
        ← `(nethack_cell| .)
  
  let rows ← cells.mapM fun row => do
    `(nethack_row| [$row:nethack_cell,*])
  
  `([[$rows:nethack_row,*]])

-- Register the delaborator  
@[delab app.SimpleGameState.mk]
def delabSimpleStateMk : Lean.PrettyPrinter.Delaborator.Delab := do
  let e ← Lean.PrettyPrinter.Delaborator.SubExpr.getExpr
  delabSimpleState e

-- Test it
def testSimple : SimpleGameState := ⟨2, 1, 6, 4⟩

#check testSimple

end LeanNetHack