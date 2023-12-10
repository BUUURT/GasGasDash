import time
import sys
import os
from os.path import abspath, dirname, join
import random
import ast

"""TODO
[] tail light
[] ignition map
[] launch control logic
[] arduino logic
[] pit message
"""

# import requests

from PyQt6.QtCore import QObject, QUrl
from PyQt6.QtCore import pyqtSlot as Slot
from PyQt6.QtCore import pyqtSignal as Signal
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtQuick import QQuickView

from bikeClass import Bike

bike = Bike(_rpm=True)


class Bridge(QObject):
    #@Slot(str, result=str)
    #def raceTimeData(self,value):
    #    data = requests.get(r'http://192.168.254.12:9000/dashGet')
    #    data = ast.literal_eval(data.text)
    #    return data[value]

    #example of slot signal both direction
    # @Slot(str, result=str)
    # def testSlot(self, i):
    #     print(i)

    @Slot(result=str)
    def sensorDict(self):
        return bike.call_sensorDict()

    @Slot(result=str)
    def sessionTime(self):
        return bike.sessionTime()

    @Slot()
    def sessionTime_Reset(self):
        bike.sessionTime(reset=True)

    @Slot()
    def sessionTime_plusFive(self):
        bike.sessionTime(plusFive=True)

    @Slot(int)
    def ignitionMapUpdate(self,map):
        bike.ignitionMapUpdate(map)

def uiBoot():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Instance of the Python object
    bridge = Bridge()
    qmlFile = join(dirname(__file__), "display/DashMain.qml")
    engine.load(abspath(qmlFile))

    sys.exit(app.exec_())


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Instance of the Python object
    bridge = Bridge()

    # Expose the Python object to QML
    context = engine.rootContext()
    context.setContextProperty("con", bridge)

    # Get the path of the current directory, and then add the name of the QML file, to load it.
    qmlFile = join(dirname(__file__), "display/DashMain.qml")
    engine.load(abspath(qmlFile))

    sys.exit(app.exec())
