import time
import sys
import os
from os.path import abspath, dirname, join
import random
import ast


# import requests

from PyQt6.QtCore import QObject, QUrl
from PyQt6.QtCore import pyqtSlot as Slot
from PyQt6.QtCore import pyqtSignal as Signal
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtQuick import QQuickView

from bikeClass import Bike

bike = Bike()


class Bridge(QObject):
#    @Slot(result=str)
# def airTemp(self):
#    return bike.airTemp

#    @Slot(str, result=str)
#    def raceTimeData(self,value):
#        data = requests.get(r'http://192.168.254.12:9000/dashGet')
#        data = ast.literal_eval(data.text)
#        return data[value]
    # @Slot(result=str)
    # def sessionTime(self):
    #     floatTime = time.monotonic()
    #     minutes, seconds = divmod(floatTime, 60)
    #     return "%02d:%02d" % (minutes, seconds)
    
    # @Slot(str, result=str)
    # def testSlot(self, i):
    #     print(i)

    @Slot(result=str)
    def sessionTime(self):
        return bike.sessionTime()

    @Slot()
    def sessionTime_Reset(self):
        bike.sessionTime(reset=True)

    @Slot()
    def sessionTime_plusFive(self):
        bike.sessionTime(plusFive=True)


#   @Slot(result=str)
#    def speed(self):
#        return str(time.time())[:2]
#        return bike.speed

#    @Slot(result=int)
#    def rpm(self):
#        x = str(time.time())
#        y = x.split(".")[0][-1:]
#        y = float(y) * 0.1
#        speed = 13000 * y
#        return int(speed)

#    @Slot(result=int)
#    def spin(self):
#        i = str(time.time())
#        n = i.split(".")[1][0]
#        n = int(n) * 36
#        return int(n)

#    @Slot(result=int)
#    def rand(self):
#        i = random.randrange(360)
#        return int(i)


#    @Slot(result=series)
#    def chart(self, series):
#        series.clear()
#        for i in range(10):
#            return series.append(i,random.random()*100)


def uiBoot():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Instance of the Python object
    bridge = Bridge()

    # Expose the Python object to QML
    #    context = engine.rootContext()
    #    context.setContextProperty("con", bridge)

    # Get the path of the current directory, and then add the name
    # of the QML file, to load it.
    # qmlFile = join(dirname(__file__), "dash_v9.qml")
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

    # Get the path of the current directory, and then add the name
    # of the QML file, to load it.
    qmlFile = join(dirname(__file__), "display/DashMain.qml")
    #    qmlFile = join(dirname(__file__), 'stck.qml')
    engine.load(abspath(qmlFile))

    sys.exit(app.exec())