SET PROJ_SERVER=genetic-disorder
SET PROJ_EXE=GeneticDisorder
SET BUTLER_EXE=..\..\tools\butler.bat

call %BUTLER_EXE% push build\%PROJ_EXE%Windows gatechgrad/%PROJ_SERVER%:win

call %BUTLER_EXE% push build\%PROJ_EXE%Mac gatechgrad/%PROJ_SERVER%:osx

call %BUTLER_EXE% push build\%PROJ_EXE%Linux gatechgrad/%PROJ_SERVER%:linux

pause > nul
