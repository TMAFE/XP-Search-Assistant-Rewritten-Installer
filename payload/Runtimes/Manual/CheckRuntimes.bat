@echo off
IF NOT EXIST %systemroot%\msagent\AgentSvr.exe start "MSAgent" MSAGENT.EXE
IF NOT EXIST %systemroot%\lhsp start "Lernout and Hampshire Api" tv_enua.exe
IF EXIST %systemroot%\Speech goto HASNEW
IF NOT EXIST %systemroot%\speech start "Speach Api" spchapi.exe
:HASNEW