from clips import Environment, Symbol, CLIPSError, TemplateSlotDefaultType
import numpy as np

class MinesweeperAgent():
    def __init__(self, clps=[]):
        self.env = Environment()
        for clp in clps:
            self.env.load(clp)
        self.board = None

    def init_agent(self, size, coords):
        self.env.assert_string(f"(board-size {size})")
        self.board = np.zeros((size, size), dtype=int)

        for row in range(size):
            for col in range(size):
                for coord in coords:
                    if coord in [(col-1, row), (col, row-1), (col+1, row), (col, row+1), (col-1, row-1), (col-1, row+1), (col+1, row-1), (col+1, row+1)]:
                        if (col, row) not in coords:
                            self.board[row, col] += 1
        print(self.board)
        for row in range(size):
            for col in range(size):
                self.env.assert_string(f"(tile (x {col}) (y {row}) (value {self.board[row][col]}))")

        for f in self.env.facts():
            print(f)

if __name__ == "__main__":
    from input import process_input
    size, coords = process_input("../tests/tc1.txt")
    ms = MinesweeperAgent(["model/template_facts.clp"])
    ms.init_agent(size, coords)