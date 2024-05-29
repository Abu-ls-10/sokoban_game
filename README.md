# Sokoban Game on RISC-V 32I

## Overview

Welcome to the Sokoban game implemented for the RISC-V 32I architecture! This project features a classic puzzle-solving game where players navigate a character to push boxes onto target locations. The game utilizes an 8x8 LED-Matrix for visual representation and a D-Pad for user input.

## Features

- **Multiplayer Mode**: Compete with friends in a turn-based multiplayer mode.
- **Randomized Puzzles**: Each game generates unique puzzles using the Linear Congruential Generator (LCG) formula.
- **LED-Matrix Display**: The game board is visually represented using an 8x8 LED-Matrix.
- **D-Pad Controls**: Use the WASD keys or the D-Pad buttons for navigation.

## Game Elements

### LED-Matrix Representation

- **Walls**: Maroon
- **Player**: Light Purple
- **Box**: Brown
- **Empty Spaces**: Black
- **Target**: White

### D-Pad Input

- **W**: Move Up
- **A**: Move Left
- **S**: Move Down
- **D**: Move Right

## Gameplay

### Starting a Game

1. The game begins in competitive mode.
2. Enter the number of players when prompted.
3. All players receive the same puzzle for fairness.

### Randomized Puzzles

The game uses the LCG formula with parameters 75 and 74, seeding with the system time to ensure puzzle randomness.

### Game Flow

- Players take turns navigating the character and pushing boxes.
- After each turn, the console displays "NEXT PLAYER'S TURN!"
- Once all players complete their turns, a standings board is printed.

### Special Situations

- If a player pushes a box into a corner, the game prompts the player to restart.
- Enter `0` to end the game and `1` to restart the current puzzle.

### Victory

When a player successfully places the box onto the target, a success message is displayed in the console.

## Project Structure

The project contains the following key components:

- **Data Section**: Stores the initial positions of the character, box, and target, along with various strings used in the game.
- **Main Program**: Handles the game loop, player input, and game logic.
- **Helper Functions**: Includes functions for board initialization, LED updates, and random number generation.

## Building and Running

To build and run the Sokoban game on a RISC-V simulator:

1. Clone the repository.
2. Assemble the code using Ripes as a RISC-V simulator.
3. Run the program.
