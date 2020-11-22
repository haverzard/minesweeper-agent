from clips import Environment, Symbol, CLIPSError, TemplateSlotDefaultType
import numpy as np

class MinesweeperAgent():
    def __init__(self, clps=[]):
        self.env = Environment()
        for clp in clps:
            self.env.load(clp)
        self.board = None

    def init_agent(self, size, bcounts, coords):
        self.env.reset()
        self.env.assert_string(f"(board-size {size})")
        self.env.assert_string(f"(bombs-remaining {bcounts})")
        self.board = np.zeros((size, size), dtype=int)

        for row in range(size):
            for col in range(size):
                for coord in coords:
                    if coord in [(col-1, row), (col, row-1), (col+1, row), (col, row+1), (col-1, row-1), (col-1, row+1), (col+1, row-1), (col+1, row+1)]:
                        if (col, row) not in coords:
                            self.board[size-row-1, col] += 1

        for coord in coords:
            self.env.assert_string(f"(bomb {coord[0]} {coord[1]})")

        print(self.board)
        for row in range(size):
            for col in range(size):
                self.env.assert_string(f"(tile (x {col}) (y {size-row-1}) (value {self.board[row][col]}))")

        self.env.run()

        for f in self.env.facts():
            print(f)

if __name__ == "__main__":
    from input import process_input
    size, bcounts, coords = process_input("../tests/tc1.txt")
    ms = MinesweeperAgent(["model/template_facts.clp", "model/rules.clp", "model/minesweeper.clp"])
    ms.init_agent(size, bcounts, coords)