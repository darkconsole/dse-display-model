@ECHO OFF

echo.
echo Compiling Human XML to HKX...
FOR %%F IN (xml\*.xml) DO (
	echo ^>^> %%F hkx\%%~nF.hkx
	hktcnv.exe %%F hkx\%%~nF.hkx
)

echo Compiling Horse XML to HKX...
FOR %%F IN (xml\horse\*.xml) DO (
	echo ^>^> %%F hkx\horse\%%~nF.hkx
	hktcnv.exe %%F hkx\horse\%%~nF.hkx
)

echo.
echo Converting Human HKX to SSE format...
FOR %%F in (hkx\*.HKX) DO (
	echo ^>^> %%F
	convert --platformamd64 "%%F" "%%F" > nul 2> nul
)

echo Converting Horse HKX to SSE format...
FOR %%F in (hkx\horse\*.HKX) DO (
	echo ^>^> %%F
	convert --platformamd64 "%%F" "%%F" > nul 2> nul
)

echo.
rem pause
