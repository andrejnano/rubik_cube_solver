# FLP 2019/2020
# Logicky projekt
# Rubikova kocka
# Author: Andrej Nano (xnanoa00)

all: compile

compile:
	swipl -g start -o flp20-log -c flp20-log.pl

pack:
	zip flp-log-xnanoa00.zip flp20-log.pl README.md Makefile

clean:
	rm -r flp20-log
	rm -f flp-log-xnanoa00.zip