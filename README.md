# Advent of Code 2025 – Day 1: Secret Entrance  
## Hardcaml RTL Solution (Jane Street FPGA Challenge)


This repository contains hardware (RTL) implementation of **Advent of Code 2025 – Day 1: Secret Entrance**, developed as part of the **Jane Street FPGA Challenge**.

The puzzle involves simulating a circular safe dial that moves left or right according to the given sequence of rotation instructions. The main goal is to determine how many times the dial points at position `0` under two different counting rules.

Instead of solving the puzzle purely in software, this project translates the problem into a **hardware design** using **Hardcaml**, expressing the solution at the Register Transfer Level (RTL). A small Python program is included as a reference, while the Hardcaml implementation represents the actual hardware solution for this submission.

## Problem Summary

The puzzle describes a safe with a circular dial labeled from `0` to `99`. The dial starts at position `50` and is moved according to the rotation instructions. Each instruction specifies a direction (`L` for left or `R` for right) and a distance, representing the number of clicks the dial should be rotated in that direction. The dial wraps around circularly, so moving left from `0` goes to `99`, and moving right from `99` goes to `0`.

### Part 1

In Part 1, the task is to follow the given input instructions and count how many times the dial **ends at position `0` after completing one instruction**. Only the final position after every individual instruction is considered, and intermediate positions during a rotation are not considered.

### Part 2

Part 2 introduces a new counting rule. Instead of counting only the final position, the dial must be checked **after every individual click**. The count is incremented whenever any click causes the dial to point at the position `0`, whether this happens in the middle of a rotation or at its end.

This second rule significantly changes the problem, as large rotations may cause the dial to pass through position `0` multiple times within a single signal.


## Design Approach (High-Level)

The hardware design models the safe-dial as a **clocked system**, where each clock cycle represents a single dial click. This makes time explicit in the design and aligns with the problem statement.

Instead of using software-style loops to process large rotation distances which i'm used to, the design uses a **counter register** to track how many clicks remain in the current instruction. On each clock cycle, the dial position is updated by one step, the counter is decremented, and the system determines if further movement is required. This approach is fully synthesizable and scales to very large distances without any modification.

The architecture is intentionally **sequential rather than parallel**. Each dial movement depends on the previous position, and the exact order of clicks is essential for correct zero counting. 

A Python implementation is used as a **reference** to validate correctness, but the actual solution in this submission is the Hardcaml RTL design. 

## Hardware Architecture

The hardware design is based on a set of registers and combinational logic, all state updates occur on clock ticks.

### Registers

The design uses the following registers:

- **`pos`**  
  Stores the current position of the dial. This is a 7-bit register, which is sufficient to represent values from `0` to `99`. This register is reset to `50`, matching the initial condition specified in the problem.

- **`remaining_steps`**  
  Tracks how many dial clicks remain for the current instruction. This register replaces the loop used in a software solution. When a new instruction is given, `remaining_steps` is given the value of the distance in instruction and is decremented by one on each clock tick while the dial is moving.

- **`zero_count`**  
  counts the total number of times the dial points at position `0`. This register is incremented only when a clock cycle corresponds to a valid dial click that results in the dial landing on `0`.

### Per-Cycle Behavior

On each clock cycle, the following sequence occurs:

1. If no movement is currently in progress and a new instruction is marked as valid, the instruction distance is loaded into `remaining_steps`.
2. If `remaining_steps` is greater than zero, the dial position is updated by one step in the given direction (L/R), with wrap-around applied at the boundaries.
3. After the position update, it checks whether the dial has landed on position `0`. If so, `zero_count` is incremented.
4. The `remaining_steps` register is decremented, and the system either continues moving or becomes idle once the count reaches zero.


## Zero Counting Logic

Part 2 of the puzzle requires counting **every individual click** that causes the dial to point at position `0`, including those that occur in the middle of an instruction. 

In the hardware design, zero counting is implemented by observing the **next dial position** computed for a given clock cycle. A zero hit is detected only when two conditions are simultaneously true:

- A valid dial movement is occurring 
- The dial position *after* the click equals `0`.

By checking the next position rather than the current one, the design correctly captures cases where the dial passes through `0` during a longer rotation. Idle cycles, reset cycles, and cycles where no movement occurs are explicitly excluded from the count to avoid double-counting.

By doing this we include:
- Zero crossings at the end of a rotation.
- Zero crossings that occur mid-rotation.
- Large rotation distances correctly contribute multiple zero hits when appropriate.


## Scalability & Design Choices

### Scalability

The design scales to very large inputs. Each dial click is processed in a single clock tick, and the number of remaining clicks is tracked using a counter register. As a result, instructions with distances that are 10×, 100×, or even 1000× larger require no changes to the hardware design and simply take more clock cycles to complete.

### Efficiency

The implementation prioritizes correctness over aggressive micro-optimizations. The hardware uses a small number of registers and simple combinational logic, resulting in realistic and predictable resource usage. Given the sequential nature of the problem, this approach provides an effective balance between simplicity and performance.

### Language Choice

Hardcaml was chosen for this implementation as it is highly encouraged by jane street, and was a great challenge for me as my first RTL project.

## Testbench & Verification

A testbench is included to verify the correctness of the RTL design. The testbench drives the clock and reset signals, feeds rotation instructions into the hardware, and observes the resulting output values over time.

To validate correctness, the testbench uses the **official example input provided in the Advent of Code problem statement**:

L68
L30
R48
L5
R60
L55
L1
L99
R14
L82


This input sequence tests all critical aspects of the design, including left and right rotations, wrap-around behavior at the dial boundaries, and zero crossings that occur both at the end of a rotation and during a rotation.

The expected results for this input are:
- **Part 1:** `3`
- **Part 2:** `6`

The testbench encodes this sequence as a series of instructions using direction and distance, then runs the simulation for enough clock cycles to allow all movements to complete. The final value of `zero_count` is read from the output and compared against the expected result.


## How to Run the Testbench

The RTL design and testbench are written using **Hardcaml** and are intended to be run within a standard OCaml + Hardcaml development environment.

To run the testbench locally, the typical workflow is:

1. Set up an OCaml environment with Hardcaml installed.
2. Build and run the testbench using a standard OCaml build system (such as `dune`), linking against the Hardcaml libraries.

When the testbench is run successfully with the provided example input, it gives the following output:

Final zero_count = 6



## End note

I am truly passionate for the world of Quant Finance, and this was my first ever real life project that I made by myself. I aspire to be a Quant Developer some day, and this serves as my starting point.
I learnt a lot during this project, from RTL concepts to a completely new language, Hardcaml. I look forward to participating in more such events, and eventually becoming a quant some day at jane street!



