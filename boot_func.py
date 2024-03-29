import time
import sys
import os
from os.path import abspath, dirname, join
import random
import ast
import threading
import datetime

# import requests

from PyQt5.QtCore import QObject, QUrl, QVariant
from PyQt5.QtCore import pyqtSlot as Slot
from PyQt5.QtCore import pyqtSignal as Signal
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtQuick import QQuickView

# from bikeClass import Bike
#
# bike = Bike(_wheelspeed=True, _rpm=True, _gps=False, _imu=True, _engTemp=True)


class Bridge(QObject):
    @Slot(result=QVariant)
    def sensorRefresh(self):
        return bike.sensorDict

    # @Slot(result=)
    # def sensorRefresh(self):
    #     return bike.sensorRefresh()

    @Slot(result=str)
    def messageRefresh(self):
        return bike.messageRefresh()

    @Slot(result=str)
    def sessionTime(self):
        floatTime = time.monotonic() - bike.sessionTime
        minutes, seconds = divmod(floatTime, 60)
        return "%02d:%02d" % (minutes, seconds)

        # influxUrl='http://192.168.254.40:8086',
        # influxToken="rc0LjEy36DIyrb1CX6rnUDeMJ0-ldW5Mps1KOwkSRrRhbRWDsGzPlNn6BOiyg96vWEKRMZ3xwsfZVgIAxL2gCw==",
        # race='test3',

    @Slot(result=str)
    def speed(self):
        # return str(bike.speedCalc())
        return "0"

    @Slot(result=int)
    def rpm(self):
        # return bike.rpmCalc()
        i = str(time.time()).split(".")
        elm = i[0][-1:] + i[1][:2]
        r = int(elm) * 13000 / 999
        r = int(r)
        return r

    @Slot(result=int)
    def accelX(self):
        # return bike.imu.acceleration[0]
        return 0

    @Slot(result=int)
    def accelY(self):
        # return bike.imu.acceleration[1]
        return 0

    @Slot(result=str)
    def clock(self):
        return str(datetime.datetime.now().strftime("%H:%M"))

    @Slot(str, result=str)
    def raceTimeData(self, value):
        data = requests.get(r"http://192.168.254.12:9000/dashGet")
        data = ast.literal_eval(data.text)
        return data[value]


class Debug(QObject):
    @Slot(result=QVariant)
    def sensorRefresh(self):
        sensorDict = {
            "speed": int(str(time.monotonic()).split(".")[0][-2:]),
            "rpm": int(str(time.monotonic()).split(".")[0][-1:]) * 1444,
            # brake :
            "engTemp": int(str(time.monotonic()).split(".")[0][-2:]) * 10,
            "airTemp": int(str(time.monotonic()).split(".")[0][-2:])
            ##"gps_lat" : 0,
            # "gps_long" : gpsTup[1],
            # "rotationX" : imuDict['rotX'],
            # "rotationY" : imuDict['rotX'],
            # "rotationZ" : imuDict['rotZ'],
            # "accelX" : imuDict['accelX'],
            # "accelY" : imuDict['accelY'],
            # "accelZ" : imuDict['accelZ']
        }
        return sensorDict

    @Slot(result=str)
    def sessionTime(self):
        floatTime = 1482382.062 - time.monotonic()  # -bike.sessionTime
        minutes, seconds = divmod(floatTime, 60)
        return "%02d:%02d" % (minutes, seconds)


if __name__ == "__main__":

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Instance of the Python object
    # bridge = Bridge()
    bridge = Debug()

    # Expose the Python object to QML
    context = engine.rootContext()
    context.setContextProperty("con", bridge)
    qmlFile = join(dirname(__file__), "display/Dash_root.qml")
    # qmlFile = join(dirname(__file__), "display/gasdash.qml")
    engine.load(abspath(qmlFile))
    sys.exit(app.exec_())
