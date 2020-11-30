from clips import Environment
import numpy as np
import re
import time

class MinesweeperAgent():
    def __init__(self, clps=[]):
        self.env = Environment()
        for clp in clps:
            self.env.load(clp)

    def init_agent(self, size, bcounts, coords):
        self.board = None
        self.board_mask = None
        self.predicted_bombs = []
        self.size = size
        self.bombs_count = bcounts
        self.coords = coords
        self.opened = 0
        self.max_steps_to_goal = None
        self.max_fact_id = 0

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

    def run_and_evaluate(self, state={ 'paused': False, 'started': True },  signals=None, delay=0):
        # unpack signals
        cell_status_signal = signals.cell_status if (signals is not None) else None
        flag_cell_signal = signals.flag_cell if (signals is not None) else None
        history_signal = signals.history if (signals is not None) else None
        # print initial facts
        for fact in self.env.facts():
            self.max_fact_id = fact.index
            print(fact)
        # run
        i = 0
        while True:
            selected_rule = None
            for act in self.env.activations():
                selected_rule = str(act)
                break

            self.env.run(1)
            if self.max_steps_to_goal is None and self.opened == self.size**2:
                self.max_steps_to_goal = i
            if not self.env.agenda_changed:
                self.max_steps_to_finish = i
                break

            selected_text = "\nSelected Rule    : " + re.findall(r" ([^: ]+):", selected_rule)[0] + "\n\n"
            print(selected_text)
            matched_text = "Matched Facts    :\n"
            print(matched_text)
            matched_facts = re.findall(r": ([^: ]+)", selected_rule)
            matched_facts_idx = set()
            if matched_facts:
                for fact in matched_facts[0].split(","):
                    idx = re.findall(r"f\-(\d+)", fact)
                    if idx:
                        matched_facts_idx.add(int(idx[0]))

            first_hit = True
            for fact in self.env.facts():
                if fact.index <= self.max_fact_id:
                    if fact.index in matched_facts_idx:
                        print(str(fact))
                        matched_text = matched_text + str(fact) + "\n"

                else:
                    if first_hit:
                        print("Asserted Facts   :")
                        first_hit = False
                    self.max_fact_id = fact.index
                    str_fact = str(fact)
                    if "clicked " in str_fact:
                        x, y = map(int, re.findall(r"\(clicked \(x (\d+)\) \(y (\d+)\)\)", str_fact)[0])
                        self.board_mask[self.size-y-1, x] = 9
                        self.opened += 1
                        if cell_status_signal:
                            cell_status_signal.emit(self.size-y-1, x, self.board[self.size-y-1, x])
                    if "flagged " in str_fact:
                        self.predicted_bombs.append(fact)
                        # update ui
                        x, y = map(int, re.findall(r"\(flagged \(x (\d+)\) \(y (\d+)\)\)", str_fact)[0])
                        if flag_cell_signal:
                            flag_cell_signal.emit(self.size-y-1, x)
                    if "failed " in str_fact:
                        print(str_fact)
                        exit()
                    print(fact)

                if history_signal:
                    history_signal.emit(selected_text, matched_text)

            # Pass data to gui here
            if not cell_status_signal:
                for row in range(self.size-1, -1, -1):
                    normalized_row = self.size-row-1
                    for col in range(self.size):
                        if self.board_mask[normalized_row, col] != 9:
                            print("■ ", end="")
                        else:
                            print(self.board[normalized_row, col], end=" ")
                    print()

            time.sleep(delay)
            i += 1
        del self.board, self.board_mask

        if not state['started']:
            return

        while state['paused']:
            time.sleep(0.3)
