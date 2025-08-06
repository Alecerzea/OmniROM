@ECHO OFF
set delete=No
set blocksize=16384
ECHO ===============================================
ECHO = CSO/CHD/ISO/CUEBIN Conversion by Refraction + RedDevilus (Version Feb 18 2024) =
ECHO ===============================================
ECHO.
ECHO PLEASE NOTE: This will affect all files in this folder!
ECHO Be sure to run this from the same directory as the files you wish to convert.
ECHO.
ECHO 1 - Convert ISO to CSO
ECHO 2 - Convert ISO to CHD
ECHO 3 - Convert CUE/BIN to CHD
ECHO 4 - Convert CSO to CHD
ECHO 5 - Convert DVD CHD to CSO
ECHO 6 - Extract DVD CHD to ISO
ECHO 7 - Extract CD CHD to CUE/BIN
ECHO 8 - Extract CSO to ISO
ECHO.
SET /P M=Type 1, 2, 3, 4, 5, 6, 7, or 8 then press ENTER:
IF %M%==1 GOTO convertisotocso
IF %M%==2 GOTO convertisotochd
IF %M%==3 GOTO convertcuebintochd
IF %M%==4 GOTO convertcsotochd
IF %M%==5 GOTO convertchdtocso
IF %M%==6 GOTO extractdvdchdtoiso
IF %M%==7 GOTO extractcdchdtoiso
IF %M%==8 GOTO extractcsotoiso
GOTO done

REM ============================CONVERT ISO TO CSO =============================

:convertisotocso
ECHO Do you want to delete the original ISO files as they are converted?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO convertisotocsosize
)
if %D%==y ( 
set delete=Yes
GOTO convertisotocsosize
)
if %D%==N ( 
set delete=No
GOTO convertisotocsosize
)
if %D%==n ( 
set delete=No
GOTO convertisotocsosize
)
GOTO convertisotocso

:convertisotocsosize
ECHO Please pick a block size you would like to use
ECHO.
ECHO 1 - 16kb (bigger files, faster access/less CPU, choose this if you're unsure)
ECHO 2 - 128kb (balanced)
ECHO 3 - 256kb (smaller files, slower access/more CPU)
SET /P S=Type 1, 2, or 3 then press ENTER:
IF %S%==1 (
set blocksize=16384
GOTO convertisotocsostart
)
IF %S%==2 (
set blocksize=131072
GOTO convertisotocsostart
)
IF %S%==3 (
set blocksize=262144
GOTO convertisotocsostart
)
GOTO convertisotocsosize

:convertisotocsostart
if exist "maxcso.exe" (
  FOR %%I IN (*.iso) DO (
  	maxcso --block=%blocksize% "%%I"
 	 FOR %%S IN ("%%~nI.cso") DO (
  		IF %%~zS LSS 1 ( call :errorcsocompressfailed %%S )
  	)
  	IF %delete% == Yes ( del "%%I" )
  )
) else ( GOTO errorcso )
GOTO done

REM =====================================================================================

REM ============================CONVERT ISO TO CHD =============================

:convertisotochd
ECHO Do you want to delete the original ISO files as they are converted?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO convertisotochdsize
)
if %D%==y ( 
set delete=Yes
GOTO convertisotochdsize
)
if %D%==N ( 
set delete=No
GOTO convertisotochdsize
)
if %D%==n ( 
set delete=No
GOTO convertisotochdsize
)
GOTO convertisotochd

:convertisotochdsize
ECHO Please pick a block size you would like to use
ECHO.
ECHO 1 - 16kb (bigger files, faster access/less CPU, choose this if you're unsure)
ECHO 2 - 128kb (balanced)
ECHO 3 - 256kb (smaller files, slower access/more CPU)
SET /P S=Type 1, 2, or 3 then press ENTER:
IF %S%==1 (
set blocksize=16384
GOTO convertisotochdstart
)
IF %S%==2 (
set blocksize=131072
GOTO convertisotochdstart
)
IF %S%==3 (
set blocksize=262144
GOTO convertisotochdstart
)
GOTO convertisotochdsize

:convertisotochdstart
if exist "chdman.exe" (
  FOR %%I IN (*.iso) DO (
	chdman createraw -us 2048 -hs %blocksize% -f -i "%%I" -o "%%~nI.chd"
	FOR %%S IN ("%%~nI.chd") DO (
	 	IF %%~zS LSS 1 ( call :errorchdfailed %%S )
	)
  	IF %delete% == Yes ( del "%%I" )
  )
) else ( GOTO errorchd )
GOTO done

REM =====================================================================================

REM ============================CONVERT CUEBIN TO CHD =============================

:convertcuebintochd
ECHO Do you want to delete the original CUE/BIN files as they are converted?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO convertcuebintochdsize
)
if %D%==y ( 
set delete=Yes
GOTO convertcuebintochdsize
)
if %D%==N ( 
set delete=No
GOTO convertcuebintochdsize
)
if %D%==n ( 
set delete=No
GOTO convertcuebintochdsize
)
GOTO convertcuebintochd

:convertcuebintochdsize
ECHO Please pick a block size you would like to use
ECHO.
ECHO 1 - 16kb (bigger files, faster access/less CPU, choose this if you're unsure)
ECHO 2 - 128kb (balanced)
ECHO 3 - 256kb (smaller files, slower access/more CPU)
SET /P S=Type 1, 2, or 3 then press ENTER:
IF %S%==1 (
set blocksize=17136
GOTO convertcuebintochdstart
)
IF %S%==2 (
set blocksize=132192
GOTO convertcuebintochdstart
)
IF %S%==3 (
set blocksize=264384
GOTO convertcuebintochdstart
)
GOTO convertcuebintochdsize

:convertcuebintochdstart
if exist "chdman.exe" (
  FOR %%I IN (*.cue) DO (
	if exist "%%~nI.bin" (
		chdman createcd -hs %blocksize% -i "%%I" -o "%%~nI.chd"
		FOR %%S IN ("%%~nI.chd") DO (
		 	IF %%~zS LSS 1 ( call :errorchdfailed %%S )
		)
	) else ( call :errorchdfailed "%%~nI.bin" )
  
  	IF %delete% == Yes ( 
		del "%%I"
		del "%%~nI.bin"
  	)
  )
) else ( GOTO errorchd )
GOTO done

REM =====================================================================================

REM ================================CONVERT CSO TO CHD ==================================
:convertcsotochd
ECHO Do you want to delete the original CSO files as they are converted to CHD?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO convertcsotochdsize
)
if %D%==y ( 
set delete=Yes
GOTO convertcsotochdsize
)
if %D%==N ( 
set delete=No
GOTO convertcsotochdsize
)
if %D%==n ( 
set delete=No
GOTO convertcsotochdsize
)
GOTO convertcsotochd

:convertcsotochdsize
ECHO Please pick a block size you would like to use
ECHO.
ECHO 1 - 16kb (bigger files, faster access/less CPU, choose this if you're unsure)
ECHO 2 - 128kb (balanced)
ECHO 3 - 256kb (smaller files, slower access/more CPU)
SET /P S=Type 1, 2, or 3 then press ENTER:
IF %S%==1 (
set blocksize=16384
GOTO convertcsotochdstart
)
IF %S%==2 (
set blocksize=131072
GOTO convertcsotochdstart
)
IF %S%==3 (
set blocksize=262144
GOTO convertcsotochdstart
)
GOTO convertcsotochdsize

:convertcsotochdstart

if exist "maxcso.exe" (
  if exist "chdman.exe" (
  	FOR %%I IN (*.cso) DO (
		maxcso --decompress "%%I"

		FOR %%S IN ("%%~nI.iso") DO (
			IF %%~zS LSS 1 ( call :errorcsoextractfailed %%S )
		)
	
		if exist "%%~nI.iso" (
			chdman createraw -us 2048 -hs %blocksize% -f -i "%%~nI.iso" -o "%%~nI.chd"
			FOR %%S IN ("%%~nI.chd") DO (
		 		IF %%~zS LSS 1 ( call :errorchdfailed %%S )
			)
			del "%%~nI.iso"
		) else ( call :errorchdfailed "%%~nI.iso" )
	
		IF %delete% == Yes ( del "%%I" )
  	)
  ) else ( GOTO errorchd )
) else ( GOTO errorcso )
GOTO done

REM =====================================================================================

REM ================================CONVERT CHD TO CSO ==================================
:convertchdtocso
ECHO Do you want to delete the original CHD files as they are converted to CSO?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO convertchdtocsosize
)
if %D%==y ( 
set delete=Yes
GOTO convertchdtocsosize
)
if %D%==N ( 
set delete=No
GOTO convertchdtocsosize
)
if %D%==n ( 
set delete=No
GOTO convertchdtocsosize
)
GOTO convertchdtocso

:convertchdtocsosize
ECHO Please pick a block size you would like to use
ECHO.
ECHO 1 - 16kb (bigger files, faster access/less CPU, choose this if you're unsure)
ECHO 2 - 128kb (balanced)
ECHO 3 - 256kb (smaller files, slower access/more CPU)
SET /P S=Type 1, 2, or 3 then press ENTER:
IF %S%==1 (
set blocksize=16384
GOTO convertchdtocsostart
)
IF %S%==2 (
set blocksize=131072
GOTO convertchdtocsostart
)
IF %S%==3 (
set blocksize=262144
GOTO convertchdtocsostart
)
GOTO convertchdtocsosize

:convertchdtocsostart

if exist "maxcso.exe" (
  if exist "chdman.exe" (
  	FOR %%I IN (*.chd) DO (
		chdman extractraw -i "%%I" -o "%%~nI.iso"

		FOR %%S IN ("%%~nI.iso") DO (
			IF %%~zS LSS 1 call :errorchdextractfailed "%%~nI.iso"
		)
	
		if exist "%%~nI.iso" (
			maxcso --block=%blocksize% "%%~nI.iso"
 			FOR %%S IN ("%%~nI.cso") DO (
  				IF %%~zS LSS 1 ( call :errorcsocompressfailed %%S )
  			)
			del "%%~nI.iso"
		) else ( call :errorchdextractfailed "%%~nI.iso" )
	
		IF %delete% == Yes ( del "%%I" )
  	)
  ) else ( GOTO errorchd )
) else ( GOTO errorcso )
GOTO done

REM =====================================================================================

REM ================================EXTRACT DVD CHD TO ISO ==============================
:extractdvdchdtoiso
ECHO Do you want to delete the original CSO files as they are converted?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO extractdvdchdtoisostart
)
if %D%==y ( 
set delete=Yes
GOTO extractdvdchdtoisostart
)
if %D%==N ( 
set delete=No
GOTO extractdvdchdtoisostart
)
if %D%==n ( 
set delete=No
GOTO extractdvdchdtoisostart
)
GOTO extractdvdchdtoiso

:extractdvdchdtoisostart
if exist "chdman.exe" (
  FOR %%I IN (*.chd) DO (
  	chdman extractraw -i "%%I" -o "%%~nI.iso"
  	FOR %%S IN ("%%~nI.iso") DO (
  		IF %%~zS LSS 1 ( call :errorchdextractfailed %%S )
  	)

 	IF %delete% == Yes ( del "%%I" )
  )
) else ( GOTO errorchd )
GOTO done

REM =====================================================================================

REM =============================EXTRACT CD CHD TO CUE/BIN ==============================
:extractcdchdtoiso
ECHO Do you want to delete the original CHD files as they are converted?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO extractcdchdtoisostart
)
if %D%==y ( 
set delete=Yes
GOTO extractcdchdtoisostart
)
if %D%==N ( 
set delete=No
GOTO extractcdchdtoisostart
)
if %D%==n ( 
set delete=No
GOTO extractcdchdtoisostart
)
GOTO extractcdchdtoiso

:extractcdchdtoisostart
if exist "chdman.exe" (
FOR %%I IN (*.chd) DO (
  	chdman extractcd -i "%%I" -o "%%~nI.cue"
  	FOR %%S IN ("%%~nI.cue") DO (
  		IF %%~zS LSS 1 ( call :errorchdextractfailed %%S )
  	)
	FOR %%S IN ("%%~nI.bin") DO (
  		IF %%~zS LSS 1 ( call :errorchdextractfailed %%S )
  	)
 	IF %delete% == Yes ( del "%%I" )
  )
) else ( GOTO errorchd )
GOTO done

REM =====================================================================================

REM ================================EXTRACT CSO TO ISO ==================================
:extractcsotoiso
ECHO Do you want to delete the original CSO files as they are converted?
SET /P D=Type Y or N then press ENTER:
if %D%==Y ( 
set delete=Yes
GOTO extractcsotoisostart
)
if %D%==y ( 
set delete=Yes
GOTO extractcsotoisostart
)
if %D%==N ( 
set delete=No
GOTO extractcsotoisostart
)
if %D%==n ( 
set delete=No
GOTO extractcsotoisostart
)
GOTO extractcsotoiso

:extractcsotoisostart
if exist "maxcso.exe" (
FOR %%I IN (*.cso) DO (
  	maxcso --decompress "%%I"
  	FOR %%S IN ("%%~nI.iso") DO (
  		IF %%~zS LSS 1 ( call :errorcsoextractfailed %%S )
  	)
 	IF %delete% == Yes ( del "%%I" )
  )
) else ( GOTO errorcso )
GOTO done

REM =====================================================================================



REM =============================ERROR CONDITIONS AND EXIT ==============================

:errorcso
ECHO maxcso failed, maxcso file is missing.
PAUSE
EXIT

:errorcsocompressfailed
del %1
ECHO CSO compress failed, new file %1 is missing or empty.
PAUSE
EXIT

:errorcsoextractfailed
del %1
ECHO CSO decompress failed, extracted file %1 is missing or empty.
PAUSE
EXIT

:errorchd
ECHO chdman failed, chdman file is missing.
PAUSE
EXIT

:errorchdextractfailed
del %1
ECHO CHD decompress failed, extracted file %1 is missing or empty.
PAUSE
EXIT

:errorchdfailed
del %1
ECHO CHD compress failed, extracted file %1 is missing or empty.
PAUSE
EXIT

:done
ECHO process complete!
PAUSE
EXIT
