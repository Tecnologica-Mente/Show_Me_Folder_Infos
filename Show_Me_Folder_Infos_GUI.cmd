@setlocal DisableDelayedExpansion
@echo off


::========================================================================================
::
::   This script displays some information about the contents of a specific folder.
::
::   Homepage: https://github.com/Tecnologica-Mente
::      Email: <not available>
::
::========================================================================================




::========================================================================================================================================
:MainMenu

cls
color 07
title  Show Me Folder Infos GUI v1.1.0
mode 100, 30
set "smfitemp=%SystemRoot%\Temp\__SMFI"
if exist "%smfitemp%\.*" rmdir /s /q "%smfitemp%\" %nul%

echo:
echo:
echo:             Welcome to Show Me Folder Infos GUI v1.1.0
echo:
echo:       ____________________________________________________________________________________
echo:
echo:             Please select:
echo:
echo:             [1] To show all the files contained in the current folder divided by subfolders
echo:                 and other informations
echo:             [2] To extract a list of what is displayed in the previous point [1]
echo:             [3] To extract a list of the number of all subfolders and files contained
echo:                 in this folder (relative path)
echo:             [4] To extract a list of the number of all subfolders and files contained
echo:                 in this folder (absolute path)
echo:             ________________________________________________________________________
echo:                                                                     
echo:             [5] Read Me
echo:             [6] Exit
echo:       ____________________________________________________________________________________
echo:
echo:             Enter a menu option in the Keyboard [1,2,3,4,5,6]:
echo:
choice /C:123456 /N
set _erl=%errorlevel%

if %_erl%==6 exit /b
if %_erl%==5 start https://github.com/Tecnologica-Mente/Show_Me_Folder_Infos & goto :MainMenu
if %_erl%==4 setlocal & set sw2=TRUE  & call :SubFoldersFilesList & cls & endlocal & goto :MainMenu
if %_erl%==3 setlocal & set sw2=FALSE & call :SubFoldersFilesList & cls & endlocal & goto :MainMenu
if %_erl%==2 setlocal & set sw1=TRUE  & call :ShowOrListAllFiles  & cls & endlocal & goto :MainMenu
if %_erl%==1 setlocal & set sw1=FALSE & call :ShowOrListAllFiles  & cls & endlocal & goto :MainMenu
goto :MainMenu

::========================================================================================================================================
:ShowOrListAllFiles
@echo off
title %~nx0
chcp 65001 >NUL
set "dir=%cd%"
::
:: Recursive Loop routine - First Written by Ste on - 2020.01.24 - Rev 1 - Mod by Tecnologica-Mente
::
setlocal EnableDelayedExpansion
rem THIS IS A RECURSIVE SOLUTION [ALBEIT IF YOU CHANGE THE RECURSIVE TO FALSE, NO]
rem By removing the /s switch from the first loop if you want to loop through
rem the base folder only.
set recursive=TRUE
if %recursive% equ TRUE ( set recursive=/s ) else ( set recursive= )
endlocal & set recursive=%recursive%

setlocal EnableExtensions EnableDelayedExpansion
cd /d %dir%
set /A cnt_files=0
set /A cnt_dirs=0
set longer_filename=
set /A longer_filename_lenght=0
set longer_pathname=
set /A longer_pathname_lenght=0
set deepest_pathfolder=
set /A deepest_pathfolder_levels=0
set /A len=1
if %sw1% EQU TRUE ( set "prnt=>>files_list_info.txt" ) else ( set "prnt=" )
set !prnt!=%prnt%                                                   %= Do not edit this line. =%
echo Directory %cd%%prnt:~1%                                        %= Takes a substring, starting from 1 (the second character) until the end of the string. =%
for %%F in ("*") do (                                               %= Loop through the current directory. =%
  echo    → %%F
  set /A cnt_files+=1
  rem set /A cnt_dirs+=1                                            %= The current directory should not be counted. =%
  call :length len "%%F"                                            %= Usage: Function Name, Returned length, String Variable =%
  if !len! GTR !longer_filename_lenght! (
    set longer_filename=%%F
    set /A longer_filename_lenght=!len!
  )
)%prnt%

for /f "delims==" %%D in ('dir "%dir%" /ad /b %recursive%') do (    %= Loop through the sub-directories only if the recursive variable is TRUE. =%
  set /A cnt_dirs+=1
  echo Directory %%D
  call :length len2 "%%D"                                           %= Usage: Function Name, Returned length, String Variable =%
  if !len2! GTR !longer_pathname_lenght! (
    set longer_pathname=%%D
    set /A longer_pathname_lenght=!len2!
  )

  rem ***** Count all occurrences of a character within a string (Begin) *****
  set "string=%%D"                                                  %= String to search for the character =%
  set "str2=!string:\=!"                                            %= Character to search for in the string ("\" in the example) =%
  call :strlen string ret
  call :strlen str2 ret2
  Set /A "count_occurrences=ret-ret2"
  if !count_occurrences! GTR !deepest_pathfolder_levels! (
    set deepest_pathfolder=%%D
    set /A deepest_pathfolder_levels=!count_occurrences!
  )
  rem ***** Count all occurrences of a character within a string (End) *****

  echo %recursive% | find "/s" >NUL 2>NUL && (
    pushd %%D
    cd /d %%D
    for /f "delims==" %%F in ('dir "*" /b') do (                    %= Then loop through each pushd' folder and work on the files and folders =%
      echo %%~aF | find /v "d" >NUL 2>NUL && (                      %= This will weed out the directories by checking their attributes for the lack of 'd' with the /v switch therefore you can now work on the files only. =%
      rem You can do stuff to your files here.
      rem Below are some examples of the info you can get by expanding the %%F variable.
      rem Uncomment one at a time to see the results.
      echo    → %%~F           &rem expands %%F removing any surrounding quotes (")
      rem echo    → %%~dF          &rem expands %%F to a drive letter only
      rem echo    → %%~fF          &rem expands %%F to a fully qualified path name
      rem echo    → %%~pF          &rem expands %%A to a path only
      rem echo    → %%~nF          &rem expands %%F to a file name only
      rem echo    → %%~xF          &rem expands %%F to a file extension only
      rem echo    → %%~sF          &rem expanded path contains short names only
      rem echo    → %%~aF          &rem expands %%F to file attributes of file
      rem echo    → %%~tF          &rem expands %%F to date/time of file
      rem echo    → %%~zF          &rem expands %%F to size of file
      rem echo    → %%~dpF         &rem expands %%F to a drive letter and path only
      rem echo    → %%~nxF         &rem expands %%F to a file name and extension only
      rem echo    → %%~fsF         &rem expands %%F to a full path name with short names only
      rem echo    → %%~dp$dir:F    &rem searches the directories listed in the 'dir' environment variable and expands %%F to the fully qualified name of the first one found. If the environment variable name is not defined or the file is not found by the search, then this modifier expands to the empty string
      rem echo    → %%~ftzaF       &rem expands %%F to a DIR like output line
      set /A cnt_files+=1
      call :length len "%%F"                                        %= Usage: Function Name, Returned length, String Variable =%
      if !len! GTR !longer_filename_lenght! (
        set longer_filename=%%F
        set /A longer_filename_lenght=!len!
      )
      )
    )
    popd
  )
)%prnt%
echo:%prnt%
echo Total files in current folder and its subfolders: %cnt_files%%prnt%
echo Total subfolders in current folder (current folder is not counted): ^%cnt_dirs%%prnt%
echo The (first) file with the longest name is: %longer_filename% (!longer_filename_lenght! characters long)%prnt%
echo The (first) path with the longest name is: %longer_pathname% (!longer_pathname_lenght! characters long)%prnt%
echo The (first) folder with the deepest path is: %deepest_pathfolder% (!deepest_pathfolder_levels! levels)%prnt%
endlocal

:: echo/ & pause & cls
echo:
if %sw1% EQU TRUE ( echo File "files_list_info.txt" created successfully. )
echo Press any key to continue...
pause >nul
popd
exit /b

goto :EOF
:: Function that calculates the length of a string
:length <return_var> <string>
setlocal enabledelayedexpansion
if "%~2"=="" (set ret=0) else set ret=1
set "tmpstr=%~2"
for %%I in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if not "!tmpstr:~%%I,1!"=="" (
        set /a ret += %%I
        set "tmpstr=!tmpstr:~%%I!"
    )
)
endlocal & set "%~1=%ret%"
goto :EOF

:: Function that calculates the number of backslashes of a string
:strLen string len
:$source http://www.dostips.com/?t=Function.strLen
(SETLOCAL ENABLEDELAYEDEXPANSION
 set "str=A!%~1!"
 set "len=0"
 for /L %%A in (12,-1,0) do (set /a "len|=1<<%%A"
    for %%B in (!len!) do if "!str:~%%B,1!"=="" set /a "len&=~1<<%%A")
)
ENDLOCAL&IF "%~2" NEQ "" SET /a %~2=%len%
EXIT /b
goto :EOF

::========================================================================================================================================
:SubFoldersFilesList
REM dir *.* /a /b /s /o >files_list.txt
@echo off
setlocal enabledelayedexpansion
if %sw2% EQU TRUE ( set "p_type=a" ) else ( set "p_type=r" )
set !p_type!=%p_type%                                               %= Do not edit this line. =%
pushd %cd%
(
  set mypath=%cd%
  echo List of all files contained in the current directory: !mypath!
  echo:
  for /r %%a in (*) do (
    set x=%%a
    if %sw2% EQU TRUE ( echo !mypath!!x:%cd%=! ) else ( echo !x:%cd%=! )
  )
)>files_list_%p_type%.txt
popd
echo:
echo File "files_list_%p_type%.txt" created successfully.
echo Press any key to continue...
pause >nul
popd
exit /b

::========================================================================================================================================