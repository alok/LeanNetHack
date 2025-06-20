# LeanNetHack

A NetHack Domain Specific Language (DSL) implemented in Lean 4 with formal verification, AI algorithms, and ASCII visualization.

## 🎯 **Project Overview**

LeanNetHack provides a mathematically rigorous foundation for NetHack game mechanics using Lean 4's theorem proving capabilities. It combines game development, formal verification, and AI research in a unified framework.

## ✨ **Features**

### 🎮 **Core Game Engine**
- **Complete NetHack mechanics**: Movement, combat, items, terrain, monsters
- **Formal state representation**: Position, stats, inventory, dungeon levels
- **Action system**: Move, attack, pickup, wait, descend stairs
- **Terrain system**: Walls, floors, corridors, stairs, doors

### 🧮 **Formal Verification**
- **Proven game properties**: Movement preserves bounds, HP constraints
- **State transition correctness**: Verified action sequences
- **Safety guarantees**: Invalid moves are blocked, HP never exceeds max
- **Policy verification**: Greedy strategy maintains non-negative HP

### 🤖 **AI & Optimization**
- **Pathfinding**: A* and breadth-first search algorithms
- **Minimax AI**: Alpha-beta pruning for tactical decisions  
- **Policy evaluation**: Reward-based optimization framework
- **Multi-objective optimization**: Survival, exploration, efficiency

### 📺 **Visualization System**
- **ASCII art renderer**: Professional dungeon visualization with Unicode borders
- **Frame-by-frame debugging**: See exact state transitions
- **Scriptable CLI**: Rapid iteration and testing
- **File snapshots**: Save/load game states for analysis

## 🚀 **Quick Start**

### Prerequisites
- **Lean 4** (nightly-2025-06-19 or later)
- **Lake** (Lean build system)

### Installation
```bash
git clone https://github.com/alok/LeanNetHack.git
cd LeanNetHack
lake build
```

### Demo
```bash
# Quick visualization test
lake env lean --run Scripts/QuickTest.lean

# Full feature demo
lake env lean --run Scripts/SimpleDemo.lean

# Interactive iteration
# Edit Scripts/IterateScript.lean and re-run for instant feedback
lake env lean --run Scripts/IterateScript.lean
```

## 📋 **Example Output**

```
🎮 NetHack Visualization System - WORKING DEMO

📍 INITIAL STATE:
┌────────┐
│########│
│#......#│
│#.@...$#│  <- @ = player, $ = gold, r = rat
│#...r..#│
│#....>.#│  <- > = downstairs
│########│
└────────┘

📍 AFTER MOVE EAST:
┌────────┐
│########│
│#......#│
│#..@..$#│  <- Player moved east
│#...r..#│
│#....>.#│
│########│
└────────┘
```

## 🏗️ **Architecture**

```
LeanNetHack/
├── LeanNetHack/
│   ├── Basic.lean          # Core game types and mechanics
│   ├── Renderer.lean       # ASCII visualization system
│   └── Delaborator.lean    # Lean 4 delaborator (WIP)
├── Scripts/
│   ├── QuickTest.lean      # Fast iteration testing
│   ├── SimpleDemo.lean     # Full feature demonstration
│   └── IterateScript.lean  # Interactive development
└── Main.lean               # Executable entry point
```

## 🎲 **Game Mechanics**

### Movement System
- **Wall collision**: Players cannot move through walls
- **Monster blocking**: Cannot move onto occupied tiles
- **Bounds checking**: Positions must be within dungeon bounds
- **Terrain awareness**: Different movement rules for terrain types

### Combat System  
- **Damage calculation**: `max(1, attacker_strength - defender_armor/2)`
- **Monster health**: Persistent HP tracking with max HP limits
- **Death handling**: Monsters removed when HP ≤ 0

### Item System
- **Pickup mechanics**: Items collected into inventory
- **Multiple item types**: Weapons, armor, potions, scrolls, gold
- **Inventory management**: Type-safe item representation

## 🔬 **Research Applications**

### Formal Methods
- **Game rule verification**: Prove properties about game mechanics
- **State space analysis**: Formal reasoning about reachable states
- **Correctness guarantees**: Mathematically verified implementations

### AI Development
- **Algorithm testing**: Benchmark pathfinding and decision making
- **Policy optimization**: Reward function design and evaluation
- **Multi-agent scenarios**: Future extensions for multiple entities

### Visualization Research
- **ASCII art generation**: Algorithmic dungeon rendering
- **Real-time debugging**: Interactive state exploration
- **Performance profiling**: Efficient visualization techniques

## 📊 **Status**

### ✅ **Working Systems**
- Core game mechanics with proper collision detection
- ASCII visualization with Unicode borders
- Formal proofs for safety properties
- Scriptable CLI interface for rapid development
- Pathfinding and minimax AI algorithms

### 🚧 **In Progress**
- Delaborator for inline visual representation
- Neural network integration  
- Advanced AI algorithms (MCTS, deep RL)
- Extended monster/item systems

### 📈 **Future Work**
- Integration with actual NetHack game engine
- Machine learning model training infrastructure
- Multiplayer and network game support
- Advanced visualization modes

## 🤝 **Contributing**

Contributions welcome! Areas of interest:
- **Lean 4 delaborator implementation** (following lean4-maze pattern)
- **Extended game mechanics** (spells, dungeon generation, etc.)
- **AI algorithm implementations** (deep RL, planning, etc.)
- **Visualization enhancements** (colors, animations, etc.)

## 📜 **License**

MIT License - See LICENSE file for details.

## 🙏 **Acknowledgments**

- **lean4-maze** project for delaborator inspiration
- **NetHack DevTeam** for the original game
- **Lean 4** community for theorem proving tools