import time

def diff(i):
    floatTime = i - time.monotonic()
    minutes, seconds = divmod(floatTime, 60)
    print(f"{minutes}:{seconds}")
    print("%02d:%02d" % (minutes, seconds))


t = time.monotonic

a = t()+20
diff(a)
