@ECHO OFF

echo.
echo Compiling XML to HKX...
FOR %%F IN (xml\*.xml) DO (
	echo ^>^> %%F hkx\%%~nF.hkx
	hktcnv.exe %%F hkx\%%~nF.hkx
)

echo.
echo Converting HKX to SSE format...
FOR %%F in (hkx\*.HKX) DO (
	echo ^>^> %%F
	convert --platformamd64 "%%F" "%%F"
)

echo.
rem pause
