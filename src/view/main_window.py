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
        # default delay
        self.delay = 0.1
        # setup ui
        self.setupUI()
        # self.initBoardUI()
        # multithreader
        self.threadPool = QThreadPool()
        self.worker = None
        # signals
        self.gameSignals = GameSignals()

    def changeDelay(self):
        try:
            delay = float(self.delayTextEdit.toPlainText())
            if delay < 0:
                raise Exception("Delay cannot be negative")
            self.delay = delay
        except Exception as e:
            print("Failed to set delay with value: " + self.delayTextEdit.toPlainText())
            self.spawnDialogWindow("Set Delay Failed",
                                   "Failed to set delay with value: " + self.delayTextEdit.toPlainText(),
                                   subtext=str(e), type="Warning", yesBtnLbl=None, noBtnLbl=None)
        else:
            print("Delay set to: " + str(self.delay) + " second(s)")
            self.spawnDialogWindow("Set Delay Succeed",
                                   "Delay set to: " + str(self.delay) + " second(s)",
                                   yesBtnLbl=None, noBtnLbl=None)
        finally:
            self.delayTextEdit.clear()
            self.delayTextEdit.insertPlainText(str(self.delay))

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
        # Setup field
        self.historyField.setReadOnly(True)
        self.historyField.setLineWrapMode(QTextEdit.NoWrap)
        # Setup delay field
        self.delayTextEdit.insertPlainText(str(self.delay))

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
        self.historyField.insertPlainText(selected_text)
        self.historyField.insertPlainText(matched_text)
        del matched_text, selected_text


    # Game methods
    def initAgent(self, filepath="../tests/tc1.txt"):
        size, bcounts, coords = process_input(filepath)
        self.ms = MinesweeperAgent(["model/template_facts.clp", "model/rules.clp", "model/minesweeper.clp"])
        self.ms.init_agent(size, bcounts, coords)

    # Handler methods
    def startGameBtnClickedHandler(self):
        if self.ms is None:
            print("Minesweeper Agent is not initialized")
            self.spawnDialogWindow("Minesweeper Agent is not initialized",
                                   "Please Load TC to initialize Minesweeper Agent",
                                   type="Warning", yesBtnLbl=None, noBtnLbl=None)
            return
        # connect game signals
        self.gameSignals.cell_status.connect(self.updateCellUI)
        self.gameSignals.flag_cell.connect(self.updateFlaggedCellUI)
        if not self.consoleOnlyCBox.isChecked():
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
        del self.ms.predicted_bombs, self.ms.env
        # clear minesweeper agent and worker
        self.ms = None
        self.worker = None
        # disconnect game signals
        self.gameSignals.cell_status.disconnect(self.updateCellUI)
        self.gameSignals.flag_cell.disconnect(self.updateFlaggedCellUI)
        try:
            self.gameSignals.history.disconnect(self.updateHistory)
        except Exception as e:
            pass

    # Helper methods
    def spawnDialogWindow(self, title, text, subtext="", type="Information",
                          yesBtnLbl="Yes", noBtnLbl="No", callback=None):
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
        if yesBtnLbl and noBtnLbl:
            message.addButton(yesBtnLbl, QMessageBox.YesRole)
            message.addButton(noBtnLbl, QMessageBox.NoRole)
            if callback:
                message.buttonClicked.connect(callback)
        else:
            message.setStandardButtons(QMessageBox.Ok)
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
