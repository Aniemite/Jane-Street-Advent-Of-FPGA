"""
Advent of Code 2025
Day 1: Secret Entrance

Python reference solution.

PART 1:
Simulates a circular dial with positions 0 to 99.
Starting from position 50, it processes rotation instructions
and counts how many times the dial ends at position 0
after completing a rotation.

PART 2:
Extended logic of the code where every individual click
that passes through position 0 must also be counted. So 
answer is how many times the dial passes through position 0
plus how many times it ends at position 0.

This file serves as the reference specification
for the RTL/FPGA implementation.
"""


def part1(filename="input.txt"):
    
    """
    Part 1 reference solution.
    Counts how many times the dial lands on position 0
    at the end of a rotation.
    """

    # Initial dial position
    pos = 50

    # Counter for how many times the dial reaches position 0
    count = 0

    # Read all rotation instructions from input file
    with open(filename, "r") as f:
        code = f.readlines()

    # Process each rotation instruction
    for action in code:
        action = action.strip()

        # Skip empty lines if any
        if not action:
            continue

        direction = action[0]          # 'L(left)' or 'R(right)'
        distance = int(action[1:])     # number of clicks

        # Rotate right (towards higher numbers)
        if direction == "R":
            pos += distance
            while pos >= 100:
                pos -= 100

        # Rotate left (towards lower numbers)
        elif direction == "L":
            pos -= distance
            while pos < 0:
                pos += 100

        # Count if dial ends at position 0
        if pos == 0:
            count += 1


    return count




def part2(filename="input.txt"):
    """
    Part 2 reference solution.

    Counts the number of times the dial points at position 0
    on ANY individual click, including during rotations and
    at the end of a rotation.
    """

    # Initial dial position
    pos = 50

    # Counter for number of times dial points at 0
    count = 0

    # Reading all rotation instructions from input file
    with open(filename, "r") as f:
        code = f.readlines()

    # Process each rotation instruction
    for action in code:
        action = action.strip()

        # Skipping empty lines
        if not action:
            continue

        direction = action[0]          # 'L(left)' or 'R(right)'
        distance = int(action[1:])     # number of clicks

        # Performing rotation one click at a time
        for i in range(distance):
            if direction == "R":
                pos += 1
                if pos == 100:
                    pos = 0

            elif direction == "L":
                pos -= 1
                if pos == -1:
                    pos = 99

            # Counting every time the dial points at 0
            if pos == 0:
                count += 1

    return count




# Usage:
#   For Part 1:
#       part1("input.txt")
#
#   For Part 2:
#       part2("input.txt")



