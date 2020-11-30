import os
import time
from enum import IntEnum
from PyQt5.uic import loadUi
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
# from PyQt5.QtWidgets import QApplication, QWidget, QInputDialog, QLineEdit, QFileDialog
from PyQt5.QtGui import QIcon

from .worker import Worker
from model import *
from controller import *
from util import *

class PageIdx(IntEnum):
    MAIN_MENU = 0
    IN_GAME = 1

class GameSignals(QObject):
    # cell status (row, col, value)
    cell_status = pyqtSignal(int, int, int)
    # flag cell (row, col)
    flag_cell = pyqtSignal(int, int)
    history = pyqtSignal(str, str)

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        loadUi(os.path.join(os.getcwd(), "view", "main_window.ui"), self)
        # change page helper
        self.changePage = lambda idx: self.stackedWidget.setCurrentIndex(idx)
        # game agent
        self.ms = None
        # self.initAgent()
        # setup ui
        self.setupUI()
        # self.initBoardUI()
        # multithreader
        self.threadPool = QThreadPool()
        self.worker = None
        # signals
        self.gameSignals = GameSignals()
        # fields
        self.delay = 0.1

    def changeDelay(self):
        self.delay = float(self.delayTextEdit.toPlainText())

    def openFileNameDialog(self):
        options = QFileDialog.Options()
        options |= QFileDialog.DontUseNativeDialog
        fileName, _ = QFileDialog.getOpenFileName(self,"QFileDialog.getOpenFileName()", "","All Files (*);;Python Files (*.py)", options=options)
        if fileName:
            self.initAgent(fileName)
            self.initBoardUI()
            # print(fileName)

    # UI methods
    def setupUI(self):
        # main menu page
        self.playGameBtn.clicked.connect(lambda: self.changePage(PageIdx.IN_GAME))
        self.exitBtn.clicked.connect(lambda: self.close())
        # in game page
        self.startGameBtn.clicked.connect(self.startGameBtnClickedHandler)
        self.quitGameBtn.clicked.connect(lambda: self.changePage(PageIdx.MAIN_MENU))
        self.delayPlayBtn.clicked.connect(self.changeDelay)
        self.loadTCBtn.clicked.connect(self.openFileNameDialog)

    def initBoardUI(self):
        while self.field.count():
            child = self.field.takeAt(0)
            if child.widget() is not None:
                child.widget().deleteLater()
        for row in range(self.ms.size):
            for col in range(self.ms.size):
                button = QPushButton()
                button.setProperty("status", "unknown")
                button.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
                button.setStyleSheet(self.getCellStyleSheet())
                self.field.addWidget(button, row, col)

    def updateCellUI(self, row, col, value):
        button = self.field.itemAtPosition(row, col).widget()
        if button.property("status") == "flagged": return
        if value == -1:
            return
        else:
            button.setText(str(value))
            button.setProperty("status", "opened")
            button.setStyle(button.style());

    def updateFlaggedCellUI(self, row, col):
        button = self.field.itemAtPosition(row, col).widget()
        button.setText("▶")
        button.setProperty("status", "flagged")
        button.setStyle(button.style());

    def updateHistory(self, selected_text, matched_text):
        self.historyField.clear()
        self.historyField.setReadOnly(True)
        self.historyField.setLineWrapMode(QTextEdit.NoWrap)
        self.historyField.moveCursor(QTextCursor.End)
        self.historyField.insertPlainText(selected_text)
        self.historyField.moveCursor(QTextCursor.End)
        self.historyField.insertPlainText(matched_text)


    # Game methods
    def initAgent(self, filepath="../tests/tc1.txt"):
        size, bcounts, coords = process_input(filepath)
        self.ms = MinesweeperAgent(["model/template_facts.clp", "model/rules.clp", "model/minesweeper.clp"])
        self.ms.init_agent(size, bcounts, coords)

    # Handler methods
    def startGameBtnClickedHandler(self):
        if self.ms is None:
            print("Minesweeper Agent is not initialized")
            return
        # connect game signals
        self.gameSignals.cell_status.connect(self.updateCellUI)
        self.gameSignals.flag_cell.connect(self.updateFlaggedCellUI)
        self.gameSignals.history.connect(self.updateHistory)
        # create worker
        self.worker = Worker(self.ms.run_and_evaluate, signals=self.gameSignals, delay=self.delay)
        # connect signals
        self.worker.signals.exception.connect(self.gameThreadException)
        self.worker.signals.result.connect(self.gameThreadResult)
        self.worker.signals.done.connect(self.gameThreadDone)
        # Run thread
        self.threadPool.start(self.worker)

    def gameThreadException(self, exception):
        print(exception)

    def gameThreadResult(self, res):
        print(f"Function result: {res}")

    def gameThreadDone(self):
        print("Game thread done")
        print("Reached goal at Iteration {}".format(self.ms.max_steps_to_goal))
        print("Finished cycle at Iteration {}".format(self.ms.max_steps_to_finish))
        print(self.ms.predicted_bombs)

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

    def getCellStyleSheet(self):
        stylesheet = """QPushButton {
                            background-color: #ffffff;
                            border-radius: 1 solid black;
                        }
                        QPushButton[status='unknown'] { background-color: #ffffff; }
                        QPushButton[status='opened'] { background-color: #a0a0a0; }
                        QPushButton[status='flagged'] { background-color: pink; }
                     """
        return stylesheet
