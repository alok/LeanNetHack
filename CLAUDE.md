# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LeanNetHack is a Lean 4 project aimed at creating a DSL (Domain Specific Language) for NetHack that enables solving the game through combinatorial optimization and deep reinforcement learning approaches. The project uses Lean 4's theorem proving capabilities to formally model NetHack's game mechanics and state space.

## Development Commands

- `lake build` - Build the entire project and verify compilation
- `lake exe leannethack` - Run the main executable
- `lake clean` - Clean build artifacts
- `uvx lean-lsp-mcp` - LSP MCP server for completions (requires MCP client integration)

## Code Style Guidelines

- **Naming Conventions**: 
  - `UpperCamelCase` for types, structures, classes (`GameState`, `NetHackAction`)
  - `lowerCamelCase` for functions and definitions (`movePlayer`, `isValidMove`)
  - `snake_case` for propositions and theorems (`valid_move_preserves_bounds`)
- **Indentation**: 2 spaces consistently
- **Imports**: Group by category (Std, Mathlib, project modules)
- **Documentation**: Use `/-- markdown blocks -/` for comprehensive documentation
- **Attributes**: Use `@[simp]`, `@[ext]` for optimization and extensionality lemmas

## Architecture

The codebase follows a standard Lean 4 library structure:

- `LeanNetHack.lean` - Root module that imports the library components
- `LeanNetHack/Basic.lean` - Core definitions and basic structures
- `Main.lean` - Executable entry point
- `lakefile.toml` - Lake build configuration with library and executable targets
- `lean-toolchain` - Specifies Lean 4 nightly version (currently nightly-2025-06-19)

## Development Guidelines

- Use named holes like `?holeName` to get well-typed fragment programs and ensure compounding during development
- Lean 4 syntax reminders:
  - Raw string syntax: `r#".."#`
  - Multiline strings use `\` to continue
  - Reserved names can be wrapped in «guillemets which allow spaces»
- Handle "unexpected token" errors by checking for misplaced docstrings - convert to module comments or multiline comments
- Make atomic commits as development progresses

## NetHack DSL Development

The project aims to model NetHack's complex game mechanics in Lean 4, providing:
- Formal state representations
- Action spaces and transition functions  
- Optimization objectives for combinatorial approaches
- Integration points for deep RL algorithms

Focus on building composable abstractions that can represent NetHack's rich gameplay while maintaining mathematical rigor through Lean's type system.

## Development Workflow

- Use `lake build` frequently to catch type errors early
- Use named holes like `?holeName` to get well-typed fragment programs during development
- Build atomic commits as development progresses
- Leverage Lean's dependent types for state invariants and game rule enforcement
- Use typeclasses for mathematical abstractions (optimization objectives, reward functions)
- Employ simprocs for efficient computation of game state properties and optimizations