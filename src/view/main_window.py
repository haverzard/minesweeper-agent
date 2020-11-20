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

class PageIdx(IntEnum):
    MAIN_MENU = 0

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        loadUi(os.path.join(os.getcwd(), "view", "main_window.ui"), self)
        # change page helper
        self.changePage = lambda idx: self.stackedWidget.setCurrentIndex(idx)
        # setup ui
        self.setupUI()
        self.humanPlayer = None
        # multithreader
        self.threadPool = QThreadPool()
        self.workerMinimax = None
        self.workerLocal = None

    def setupUI(self):
        # main menu page
        # self.playGameBtn.clicked.connect(lambda: self.changePage(PageIdx.SELECT_SIZE))
        self.exitBtn.clicked.connect(lambda: self.close())

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
