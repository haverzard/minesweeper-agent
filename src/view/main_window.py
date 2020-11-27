import os
import time
from enum import IntEnum
from PyQt5.uic import loadUi
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *

from .worker import Worker
from model import *
from controller import *
from util import *

class PageIdx(IntEnum):
    MAIN_MENU = 0
    IN_GAME = 1

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        loadUi(os.path.join(os.getcwd(), "view", "main_window.ui"), self)
        # change page helper
        self.changePage = lambda idx: self.stackedWidget.setCurrentIndex(idx)
        # game agent
        self.initAgent()
        # setup ui
        self.setupUI()
        self.initBoardUI()
        # multithreader
        self.threadPool = QThreadPool()

    def setupUI(self):
        # main menu page
        self.playGameBtn.clicked.connect(lambda: self.changePage(PageIdx.IN_GAME))
        self.exitBtn.clicked.connect(lambda: self.close())
        # in game page
        self.quitGameBtn.clicked.connect(lambda: self.changePage(PageIdx.MAIN_MENU))

    def initBoardUI(self):
        for row in range(self.ms.size):
            for col in range(self.ms.size):
                button = QPushButton()
                button.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
                # button.setStyleSheet(self.getCellStyleSheet(cell.owner))
                self.field.addWidget(button, row, col)

    def initAgent(self):
        size, bcounts, coords = process_input("../tests/tc1.txt")
        self.ms = MinesweeperAgent(["model/template_facts.clp", "model/rules.clp", "model/minesweeper.clp"])
        self.ms.init_agent(size, bcounts, coords)
        # self.ms.run_and_evaluate()
        # print("Reached goal at Iteration {}".format(self.ms.max_steps_to_goal))
        # print("Finished cycle at Iteration {}".format(self.ms.max_steps_to_finish))

    # Helper methods
    def spawnDialogWindow(self, title, text, yesBtnLbl="Yes", noBtnLbl="No",
                          subtext="", type="Information", callback=None):
        message = QMessageBox()
        if type == "Question":
            message.setIcon(QMessageBox.Question)
        elif type == "Warning":
            message.setIcon(QMessageBox.Warning)
        elif type == "Critical":
            message.setIcon(QMessageBox.Critical)
        else:
            message.setIcon(QMessageBox.Information)
        message.setWindowTitle(title)
        message.setText(text)
        message.setInformativeText(subtext)
        message.addButton(yesBtnLbl, QMessageBox.YesRole)
        message.addButton(noBtnLbl, QMessageBox.NoRole)
        if callback: message.buttonClicked.connect(callback)
        message.exec_()
