# import serial
import time
import json

# import matplotlib.path as path
import subprocess
import threading

# import board
# import busio
# import RPi.GPIO as GPIO
# import adafruit_bno055
# import adafruit_gps
# import adafruit_max31855
# import digitalio

# from influxdb_client import InfluxDBClient, Point, WritePrecision
# from influxdb_client.client.write_api import SYNCHRONOUS

### to do ###
# timeout for speed and rpm
"""
TODO
[] tail light
[] ignition map
[] launch control logic
[] arduino logic
[] influx
"""

class Bike:
    def __init__(
        self,
        debug=False,
        _wheelspeed=False,
        _rpm=False,
        _imu=False,
        _engTemp=False,
        influxUrl="http://192.168.254.40:8086",
        influxToken="rc0LjEy36DIyrb1CX6rnUDeMJ0-ldW5Mps1KOwkSRrRhbRWDsGzPlNn6BOiyg96vWEKRMZ3xwsfZVgIAxL2gCw==",
        race="test5",
    ):
        self.gpioPin_wheelspeed = 17
        self.gpioPin_rpm = 27
        self.gpioPin_engineTemp = 17
        self.gpioPin_ignitionA = 16 #TODO build circuit for ignition control
        self.gpioPin_ignitionA = 20

        """_args enables sensor type, off by default"""
        # influx config
        # self.org = "rammers"
        # self.bucket = race
        # self.client = InfluxDBClient(url=influxUrl, token=influxToken)
        # self.write_api = self.client.write_api(write_options=SYNCHRONOUS)

        # race data from timing service
        self.lap = 0
        self.distance = 0
        self.bestLap = 0

        # bike data
        self.rider = "default"
        self.speed = 0  # mph
        self.rpm = 0
        self.engineTemp = 0  # F
        self.airTemp = 0  # F
        self.ignitionMap = 1
        self.rpm_elapse = (
            time.monotonic()
        )  # time value for calculating duration between signals
        self.wheel_elapse = time.monotonic()
        self.sessionTime_elapse = time.monotonic()+1802 #30minute

        if _wheelspeed == True or _rpm == True:  # configure GPIO if used
            self.GPIO = GPIO
            self.GPIO.setmode(GPIO.BCM)
            self.GPIO.setwarnings(False)

        if _wheelspeed == True:
            # self.GPIO.setup(17, GPIO.IN, GPIO.PUD_DOWN)
            self.GPIO.setup(self.gpioPin_wheelspeed, GPIO.IN, GPIO.PUD_UP)
            self.GPIO.add_event_detect(
                self.gpioPin_wheelspeed,
                GPIO.FALLING,
                callback=self.speedCalc,
                bouncetime=20,
            )

        if _rpm == True:
            self.GPIO.setup(self.gpioPin_rpm, GPIO.IN, GPIO.PUD_DOWN)
            self.GPIO.add_event_detect(
                self.gpioPin_rpm, GPIO.RISING, callback=self.rpmCalc, bouncetime=2
            )

        if _imu == True:  # IMU
            self.imu = adafruit_bno055.BNO055_I2C(busio.I2C(board.SCL, board.SDA))

        if _engTemp == True:  # thermocouple
            self.spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
            self.cs = digitalio.DigitalInOut(board.D5)
            self.max31855 = adafruit_max31855.MAX31855(self.spi, self.cs)

        self.sensorDict = dict()
        self.sensorThread = threading.Thread(target=self.call_sensorDict)
        self.sensorThread.start()

        # self.influxThread = threading.Thread(target=self.influxUpdate, args=(self.sensorDict,))
        # self.influxThread.start()

    def call_engTemp(self):
        try:
            i = self.max31855.temperature
            if self.units == "standard":
                i = i * 9 / 5 + 32
            engineTemp = round(i, 0)
        except:
            engineTemp = 0
        return engineTemp

    def call_imu(self):
        try:
            airTemp = (
                round(self.imu.temperature * 9 / 5 + 32, 0)
                if self.units == "standard"  # TODO fix
                else round(self.imu.temperature, 0)
            )
            rotX = round(self.imu.euler[0], 6)
            rotY = round(self.imu.euler[1], 6)
            rotZ = round(self.imu.euler[2], 6)
            accelX = round(self.imu.acceleration[0], 6)
            accelY = round(self.imu.acceleration[1], 6)
            accelZ = round(self.imu.acceleration[2], 6)
        except:
            airTemp = 0
            rotX = 0
            rotY = 0
            rotZ = 0
            accelX = 0
            accelY = 0
            accelZ = 0
        return {
            "airTemp": airTemp,
            "rotX": rotX,
            "rotY": rotY,
            "rotZ": rotZ,
            "accelX": accelX,
            "accelY": accelY,
            "accelZ": accelZ,
        }

    def speedCalc(self, channel):
        # circ = 3140 #mm @ 500mm dia / ~20"
        wheelTimeDelta = time.monotonic() - self.wheel_elapse
        self.wheel_elapse = time.monotonic()
        if self.units == "standard":
            self.speed = round(7.023979 / wheelTimeDelta, 2)  # mph/mmps conversion
        if self.units == "metric":
            self.speed = round(wheelTimeDelta / 277.778, 2)  # mmps to kmh
        # return self.speed

    def rpmCalc(self, channel):
        rpmTimeDelta = time.monotonic() - self.rpm_elapse
        self.rpm_elapse = time.monotonic()
        self.rpm = int(60 / rpmTimeDelta)  # 1rev/pulse  conversion
        # return self.rpm

    def call_sensorDict(self):
        while True:
            #lap = self.lap
            #imuDict = self.call_imu()

            self.sensorDict = {
                "speed": self.speed,
                "rpm": self.rpm,
                # brake :
                "engTemp": self.call_engTemp(),
                "airTemp": imuDict["airTemp"],
                "rotationX": imuDict["rotX"],
                "rotationY": imuDict["rotX"],
                "rotationZ": imuDict["rotZ"],
                "accelX": imuDict["accelX"],
                "accelY": imuDict["accelY"],
                "accelZ": imuDict["accelZ"],
            }

            # try:
            #     sensorList = [f"{k}={v}" for k,v in self.sensorDict.items()]
            #     data = f'rammerRpi,lap={self.lap} {",".join(sensorList)}'#{str(time.time()).replace(".","")+"0"}'
            #     self.write_api.write(self.bucket,self.org, data)
            #
            # except:
            #     print('influx error')
            time.sleep(0.016)
    def ignitionMapUpdate(self,ignitionMap):
        self.ignitionMap = ignitionMap
        #TODO define logic for driving circuit

    def messageRefresh(self):
        # TODO
        pass

    def sessionTime(self, reset=False, interval=1801, plusFive=False):
        if reset == True:
            self.sessionTime_elapse = time.monotonic() + interval
        if plusFive == True:
            self.sessionTime_elapse += 300
        floatTime = self.sessionTime_elapse - time.monotonic()
        sign = "-" if floatTime<0 else ""
        floatTime = abs(floatTime)
        minutes, seconds = divmod(floatTime, 60)
        return sign+"%02d:%02d" % (minutes, seconds)


if __name__ == "__main__":
    i = Bike()
    # while True:
    # print(i.EngineTemp)
    # time.sleep(0.5)
    # i.speedCalc()
    # print(i.speed)
    # time.sleep(0.1)
#     #p = Process(target=i.runner())
#     p =Process(target=a)
#     j = Process(target=joy)
#     p.start()
#     j.start()
