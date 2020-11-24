from clips import Environment
import numpy as np
import re

class MinesweeperAgent():
    def __init__(self, clps=[]):
        self.env = Environment()
        for clp in clps:
            self.env.load(clp)
        self.board = None
        self.board_mask = None
        self.max_fact_id = "0"
        self.predicted_bombs = []

    def init_agent(self, size, bcounts, coords):
        self.size = size
        self.bombs_count = bcounts
        self.coords = coords
        self.opened = 0
        self.max_steps_to_goal = None

        self.env.reset()
        self.env.assert_string(f"(board-size {size})")
        self.env.assert_string(f"(bombs-remaining {bcounts})")
        self.board = np.zeros((size, size), dtype=int)
        self.board_mask = np.zeros((size, size), dtype=int)

        for row in range(size):
            for col in range(size):
                for coord in coords:
                    if coord in [(col-1, row), (col, row-1), (col+1, row), (col, row+1), (col-1, row-1), (col-1, row+1), (col+1, row-1), (col+1, row+1)]:
                        if (col, row) not in coords:
                            self.board[size-row-1, col] += 1

        for coord in coords:
            self.env.assert_string(f"(bomb {coord[0]} {coord[1]})")


        for row in range(size):
            for col in range(size):
                self.env.assert_string(f"(tile (x {col}) (y {size-row-1}) (value {self.board[row][col]}))")

    def run_and_evaluate(self):
        for fact in self.env.facts():
            self.max_fact_id = fact.index
            print(fact)
        for i in range(1600):
            self.env.run(1)
            if self.max_steps_to_goal is None and self.opened == self.size**2:
                self.max_steps_to_goal = i
            if not self.env.agenda_changed:
                self.max_steps_to_finish = i
                break

            for act in self.env.activations():
                print(act)
                break

            for fact in self.env.facts():
                if fact.index > self.max_fact_id:
                    self.max_fact_id = fact.index
                    str_fact = str(fact)
                    if "opened " in str_fact:
                        x, y = map(int, re.findall(r"\(opened \(x (\d+)\) \(y (\d+)\)\)", str_fact)[0])
                        self.board_mask[self.size-y-1, x] = 9
                        self.opened += 1
                    if "flagged " in str_fact:
                        self.predicted_bombs.append(fact)
                    print(fact)

            # Pass data to gui here
            for row in range(self.size-1, -1, -1):
                for col in range(self.size):
                    if self.board_mask[self.size-row-1, col] != 9:
                        print("■ ", end="")
                    else:
                        print(self.board[self.size-row-1, col], end=" ")
                print()
