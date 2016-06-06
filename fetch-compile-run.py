import subprocess


ret = 0
ret += subprocess.call(["git", "fetch"])
ret += subprocess.call(["git", "merge"])


if ret == 0:
	ret = subprocess.call(["../pawno/pawncc.exe", "-Dgamemodes/", "ScavengeSurvive.pwn", "-;+", "-(+", "-\\)+", "-d3",])
else:
	print("git error")


if ret == 0:
	subprocess.call(["python.exe", "misc/gentrees.py"])
else:
	print("tree generation error")


if ret == 0:
	subprocess.call(["samp-server.exe"])
else:
	print("compilation error")
