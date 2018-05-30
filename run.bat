flex CLOG.l
pause
bison -d CLOG.y
pause
gcc CLOG.tab.c lex.yy.c -o clog.exe -lfl
pause
clog<test