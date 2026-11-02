
@echo off
title Ejecutor de problemas - Elixir

:menu
cls
echo ================================
echo       PARCIAL 2 - ELIXIR
echo ================================
echo.
echo 1. Problema 1 - Robot de rescate
echo 2. Problema 3 - Busqueda de ADN
echo 3. Salir
echo.

set /p opcion="Selecciona una opcion: "

if "%opcion%"=="1" goto problema1
if "%opcion%"=="2" goto problema3
if "%opcion%"=="3" exit /b

goto menu

:problema1
start "Problema 1" cmd /k "cd /d "%~dp0Problema1" && elixir -r Structs.exs -r Lector.exs -r Validacion.exs -r Expansion.exs -r Rescate.exs -r Svg.exs -r RobotRescate.exs -e "RobotRescate.main()""
goto menu

:problema3
start "Problema 3" cmd /k "cd /d "%~dp0problema3" && elixir -pa . BusquedaMotivosAdn.exs"
goto menu
