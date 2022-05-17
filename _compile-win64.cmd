@echo off
fpc -Px86_64 -O3 tvlist.pas
del tvlist.res tvlist.obj tvlist.o tvlist.or
