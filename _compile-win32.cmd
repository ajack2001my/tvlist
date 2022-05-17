@echo off
fpc -O3 tvlist.pas
del tvlist.res tvlist.obj tvlist.o tvlist.or
