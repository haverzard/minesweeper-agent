import sys
from PyQt5.QtWidgets import QApplication

from util.input import process_input
from controller.agent import MinesweeperAgent
from view import MainWindow


if __name__ == "__main__":
    size, bcounts, coords = process_input("../tests/tc1.txt")
    ms = MinesweeperAgent(["model/template_facts.clp", "model/rules.clp", "model/minesweeper.clp"])
    ms.init_agent(size, bcounts, coords)
    ms.run_and_evaluate()
    print("Reached goal at Iteration {}".format(ms.max_steps_to_goal))
    print("Finished cycle at Iteration {}".format(ms.max_steps_to_finish))
    # app = QApplication(sys.argv)
    # app.setStyle("Fusion")
    # mainWindow = MainWindow()
    # mainWindow.show()
    # sys.exit(app.exec_())
