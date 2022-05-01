@echo off
::
:: Copyright (c) 2022 Robert Di Pardo <dipardo.r@gmail.com>
::
:: This program is free software; you can redistribute it and/or
:: modify it under the terms of the GNU General Public License
:: as published by the Free Software Foundation; either version
:: 2 of the License, or (at your option) any later version.
::
:: This program is distributed in the hope that it will be
:: useful, but WITHOUT ANY WARRANTY; without even the implied
:: warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
:: PURPOSE. See the GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program; if not, write to the Free Software Foundation,
:: Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
::
SETLOCAL

set "VERSION=0.14-alpha"
set "PLUGIN=dbgpPlugin"
set "SLUG_NAME=out\%PLUGIN%_v%VERSION%_win32"
set "SLUGX64_NAME=out\%PLUGIN%_v%VERSION%_x64"
set "SLUG=%SLUG_NAME%.zip"
set "SLUGX64=%SLUGX64_NAME%.zip"
set "DOCS=.\src\include\*GPL LICENCE.txt .\out\Doc"

del /S /Q /F out\*.zip
echo D | xcopy /DIY README.txt ".\out\Doc"
echo D |xcopy /DIY CHANGELOG.txt ".\out\Doc"
7z a -tzip "%SLUG%" ".\out\Win32\Release\%PLUGIN%.dll" %DOCS% -y
7z a -tzip "%SLUGX64%" ".\out\Win64\Release\%PLUGIN%.dll" %DOCS% -y

ENDLOCAL
