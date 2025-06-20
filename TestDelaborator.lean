import LeanNetHack.Delaborator

open LeanNetHack

-- Test the delaborator with a simple game state
def myGame : GameState := {
  playerPos := { x := 2, y := 3 }
  playerStats := {
    hitpoints := 15, maxHitpoints := 20, strength := 16,
    dexterity := 12, constitution := 14, intelligence := 10,
    wisdom := 11, charisma := 8
  }
  dungeonLevel := 1
  bounds := { width := 8, height := 6 }
}

-- Test with explicit constructor
def explicitGame : GameState := 
  GameState.mk 
    { x := 1, y := 2 }
    { hitpoints := 20, maxHitpoints := 20, strength := 18, dexterity := 14, constitution := 16, intelligence := 12, wisdom := 13, charisma := 10 }
    1
    { width := 6, height := 4 }

-- Test delaborator by checking if it shows visual representation
#check myGame
#eval myGame

#check explicitGame  
#eval explicitGame

-- Try to force delaborator activation by checking the constructor directly
#check GameState.mk { x := 3, y := 2 } { hitpoints := 10, maxHitpoints := 20, strength := 15, dexterity := 12, constitution := 13, intelligence := 10, wisdom := 11, charisma := 9 } 2 { width := 5, height := 4 }

-- Also test a simple literal expression
#check (GameState.mk { x := 1, y := 1 } { hitpoints := 20, maxHitpoints := 20, strength := 18, dexterity := 14, constitution := 16, intelligence := 12, wisdom := 13, charisma := 10 } 1 { width := 4, height := 3 } : GameState)