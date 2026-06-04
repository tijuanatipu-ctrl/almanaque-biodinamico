@echo off
title General Pinto 3D Maze — Generador de Screensaver
color 0A

echo.
echo  Generando screensaver de Windows (.scr)...
echo  Esto puede tardar unos segundos.
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0crear-scr.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR: No se pudo generar el screensaver.
    echo  Asegurate de ejecutar como Administrador si hay problemas.
    pause
)
