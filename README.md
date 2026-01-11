# Advent of Code 2025 – Day 1: Secret Entrance  
## Hardcaml RTL Solution (Jane Street FPGA Challenge)


This repository contains a hardware (RTL) implementation of **Advent of Code 2025 – Day 1: Secret Entrance**, developed as part of the **Jane Street FPGA Challenge**.

The puzzle involves simulating a circular safe dial that moves left or right according to a sequence of rotation instructions. The goal is to determine how many times the dial points at position `0` under two different counting rules.

Instead of solving the puzzle purely in software, this project translates the problem into a **clocked hardware design** using **Hardcaml**, expressing the solution at the Register Transfer Level (RTL). A small Python program is included as a reference specification, while the Hardcaml implementation represents the actual hardware solution evaluated in this submission.

## Problem Summary

The puzzle describes a safe with a circular dial labeled from `0` to `99`. The dial starts at position `50` and is moved according to a sequence of rotation instructions. Each instruction specifies a direction (`L` for left or `R` for right) and a distance, representing the number of clicks the dial should be rotated in that direction. The dial wraps around circularly, so moving left from `0` goes to `99`, and moving right from `99` goes to `0`.

### Part 1

In Part 1, the task is to follow the sequence of rotations and count how many times the dial **ends at position `0` after completing an entire rotation instruction**. Only the final position after each instruction is considered, and intermediate positions during a rotation are ignored.

### Part 2

Part 2 introduces a stricter counting rule. Instead of counting only the final position after each rotation, the dial must be checked **after every individual click**. The count is incremented whenever any single click causes the dial to point at position `0`, whether this happens in the middle of a rotation or at its end.

This second rule significantly changes the problem, as large rotations may cause the dial to pass through position `0` multiple times within a single instruction.


## Design Approach (High-Level)

The hardware design models the safe dial as a **clocked system**, where each clock cycle represents a single dial click. This makes time explicit in the design and aligns naturally with the problem statement, especially for Part 2 where every individual click must be observed.

Instead of using software-style loops to process large rotation distances, the design uses a **counter register** to track how many clicks remain in the current instruction. On each clock cycle, the dial position is updated by one step, the counter is decremented, and the system determines whether further movement is required. This approach is fully synthesizable and scales naturally to very large distances without any modification.

The architecture is intentionally **sequential rather than parallel**. Each dial movement depends on the previous position, and the exact order of clicks is essential for correct zero counting. As a result, the design prioritizes correctness, clarity, and determinism over aggressive parallelism or pipelining, which would not provide meaningful benefits for this problem.

A small Python implementation is used as a **reference specification** to validate correctness, but the actual solution evaluated in this submission is the Hardcaml RTL design. The hardware behavior is derived directly from the problem rules rather than from the structure of the software code.

## Hardware Architecture

The hardware design is organized around a small set of registers and combinational logic that together model the behavior of the safe dial over time. All state updates occur on clock edges, and all decisions are derived from the current values stored in registers.

### Registers

The design uses the following registers:

- **`pos`**  
  Stores the current position of the dial. This is a 7-bit register, which is sufficient to represent values from `0` to `99`. The register is reset to `50`, matching the initial condition specified in the problem.

- **`remaining_steps`**  
  Tracks how many dial clicks remain for the current rotation instruction. This register replaces the loop typically used in a software solution. When a new instruction is accepted, `remaining_steps` is initialized to the instruction’s distance and is decremented by one on each clock cycle while the dial is moving.

- **`zero_count`**  
  Accumulates the total number of times the dial points at position `0`. This register is incremented only when a clock cycle corresponds to a valid dial click that results in the dial landing on `0`.

### Per-Cycle Behavior

On each clock cycle, the following sequence occurs:

1. If no movement is currently in progress and a new instruction is marked as valid, the instruction distance is loaded into `remaining_steps`.
2. If `remaining_steps` is greater than zero, the dial position is updated by one step in the specified direction, with wrap-around applied at the boundaries.
3. After the position update, the design checks whether the dial has landed on position `0`. If so, `zero_count` is incremented.
4. The `remaining_steps` register is decremented, and the system either continues moving or becomes idle once the count reaches zero.

This structure ensures that each dial click is processed in exactly one clock cycle, making the timing behavior explicit and easy to reason about.

## Zero Counting Logic

Part 2 of the puzzle requires counting **every individual click** that causes the dial to point at position `0`, including those that occur in the middle of a rotation. This makes the timing of the count critical and rules out approaches that only examine the final position of each instruction.

In the hardware design, zero counting is implemented by observing the **next dial position** computed for a given clock cycle. A zero hit is detected only when two conditions are simultaneously true:

- A valid dial movement is occurring (i.e., there are remaining steps in the current instruction).
- The dial position *after* the click equals `0`.

By checking the next position rather than the current one, the design correctly captures cases where the dial passes through `0` during a long rotation. Idle cycles, reset cycles, and cycles where no movement occurs are explicitly excluded from the count to avoid double-counting or false positives.

This logic ensures that:
- Zero crossings at the end of a rotation are counted.
- Zero crossings that occur mid-rotation are also counted.
- Large rotation distances correctly contribute multiple zero hits when appropriate.

As a result, the hardware behavior exactly matches the Part 2 specification of the puzzle.

## Scalability & Design Choices

### Scalability

The design scales naturally to very large rotation distances. Each dial click is processed in a single clock cycle, and the number of remaining clicks is tracked using a counter register. As a result, instructions with distances that are 10×, 100×, or even 1000× larger require no changes to the hardware design and simply take proportionally more clock cycles to complete.

### Efficiency

The implementation prioritizes correctness, clarity, and determinism over aggressive micro-optimizations. The hardware uses a small number of registers and simple combinational logic, resulting in realistic and predictable resource usage. Given the sequential nature of the problem, this approach provides an effective balance between simplicity and performance.

### Architectural Decisions

The problem is inherently sequential: each dial movement depends on the previous position, and the exact order of clicks determines the correct zero count. For this reason, the design intentionally avoids pipelining or parallel execution, as such techniques would add complexity without improving correctness or clarity. The resulting architecture closely mirrors the problem specification while remaining fully synthesizable.

### Language Choice

Hardcaml was chosen for this implementation due to its strong typing and compositional style, which help express hardware intent clearly and reduce the likelihood of wiring or bit-width errors. These features make it well-suited for describing concise and readable RTL designs compared to more verbose traditional HDLs.

## Testbench & Verification

A cycle-accurate testbench is included to verify the correctness of the RTL design. The testbench drives the clock and reset signals, feeds rotation instructions into the hardware, and observes the resulting output values over time.

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


This input sequence exercises all critical aspects of the design, including left and right rotations, wrap-around behavior at the dial boundaries, and zero crossings that occur both at the end of a rotation and during a rotation.

The expected results for this input are:
- **Part 1:** `3`
- **Part 2:** `6`

The testbench encodes this sequence as a series of instructions using direction, distance, and validity signals, then runs the simulation for enough clock cycles to allow all movements to complete. The final value of `zero_count` is read from the output and compared against the expected result.

This verification strategy ensures that the Hardcaml RTL implementation faithfully matches the puzzle specification and the Python reference model.


## How to Run the Testbench

The RTL design and testbench are written using **Hardcaml** and are intended to be run within a standard OCaml + Hardcaml development environment.

The testbench (`rtl/test_safe_dial.ml`) instantiates the hardware design, drives the clock and reset signals, feeds a sequence of rotation instructions, and observes the resulting outputs over time.

To run the testbench locally, the typical workflow is:

1. Set up an OCaml environment with Hardcaml installed (for example, using `opam`).
2. Build and run the testbench using a standard OCaml build system (such as `dune`), linking against the Hardcaml libraries.

When the testbench is run successfully with the provided example input, it produces the following output:

Final zero_count = 6


This confirms correct handling of wrap-around behavior and mid-rotation zero crossings as required by Part 2 of the puzzle.


## Notes on Originality

This project was developed as an original hardware implementation specifically for the Jane Street FPGA Challenge.

A small Python program was written first as a **reference specification** to understand and validate the puzzle logic. The Hardcaml RTL design was then developed independently by translating the problem requirements into a clocked hardware model, focusing on explicit state, timing, and synthesizable behavior.

All architectural decisions—such as replacing software-style loops with counters, modeling one dial click per clock cycle, and detecting zero crossings using next-state logic—were made to reflect proper RTL design principles rather than software execution patterns.

The author is able to fully explain the design, its trade-offs, and its behavior at the register-transfer level.




