@echo off


SETLOCAL
echo Cleaning Up Workspace
if exist work (
    rmdir /S /Q work 2> nul
)

if exist logs (
    rmdir /S /Q logs 2> nul
)

del /f /q *.ini
del /f /q transcript*
del /f /q *.wlf
del /f /q *.obj

mkdir logs

goto :done


:exit_setup
    echo.
    echo Improper environment or Microsoft Visual Studio 9.0 not installed.
	echo Make sure you have Microsoft Visual Studio 9.0 Professional/Express edition installed with the necessary SDK's.
    echo.
    goto :done

:done
	set /p name= over & out
	ENDLOCAL
