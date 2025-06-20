import Lean

-- Minimal test to see if delaborators work at all in our setup

structure SimpleCoords where
  x : Nat
  y : Nat
  deriving Repr, DecidableEq

-- Simple delaborator test
def extractSimpleCoords : Lean.Expr → Lean.MetaM SimpleCoords
| exp => do
    let exp' ← Lean.Meta.whnf exp
    let args := Lean.Expr.getAppArgs exp'
    if args.size >= 2 then
      let x ← Lean.Meta.whnf args[0]!
      let y ← Lean.Meta.whnf args[1]!
      let numX := (Lean.Expr.rawNatLit? x).getD 0
      let numY := (Lean.Expr.rawNatLit? y).getD 0
      pure ⟨numX, numY⟩
    else
      failure

def delabSimpleCoords : Lean.Expr → Lean.PrettyPrinter.Delaborator.Delab
| e => do
  guard $ e.getAppNumArgs == 2
  let coords ← 
    try extractSimpleCoords e
    catch _ => failure
  
  `(⟨$(Lean.quote coords.x), $(Lean.quote coords.y)⟩)

@[delab app.SimpleCoords.mk]
def delabSimpleCoordsMk : Lean.PrettyPrinter.Delaborator.Delab := do
  let e ← Lean.PrettyPrinter.Delaborator.SubExpr.getExpr
  delabSimpleCoords e

-- Test
def testCoords : SimpleCoords := ⟨3, 4⟩

#check testCoords