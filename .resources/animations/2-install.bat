@ECHO OFF

echo.
echo Copying to mod directory...
echo %COPYTO%
echo.

FOR %%F in (hkx\*.HKX) DO (
	echo ^>^> %%F
	xcopy /Y /I /Q %%F ..\..\meshes\actors\character\animations\dse-display-model\poses > nul
)

FOR %%F in (hkx\horse\*.HKX) DO (
	echo ^>^> %%F
	xcopy /Y /I /Q %%F ..\..\meshes\actors\horse\animations\dse-display-model\poses > nul
)


echo.
rem pause