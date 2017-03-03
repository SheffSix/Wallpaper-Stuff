function CheckWallpaper {
	$Compliance = "Compliant"
	$InstallFolder = "${env:ProgramFiles}\XXX"
	$WPLocation = "${InstallFolder}\wallpaper"
	$WPSource = "\\XXX\scripts\files\wallpaper201408"
	$WPTouch = "${WPLocation}\touch.ts"
	$OldWPLocation = "${env:SystemDrive}\XXX\wallpaper"
	
	$WPLfolderexists = (Test-Path $WPLocation -PathType Container)	#Check existance of the local WallPaper Location.
	$WPSfolderexists = (Test-Path $WPSource -PathType Container)	#Check existance of WallPaper Source Folder
	$OldWPfolderexists = (Test-Path $OldWPLocation -PathType Container) #Check existence of old wallpaper location
	
	#If the source folder cannot be found on the network, we must assume that the local wallpaper is up-to-date
	#as we are unable to check or remediate without the source files.
	If (!($WPSfolderexists)) { Return $Compliance }
	
	#If the old wallpaper location exists, we are non-compliant
	If ($OldWPfolderexists) {
		$Compliance = "NonCompliant"
		Return $Compliance
	}

    #If the image.txt file does not exist in the new location, we are non-compliant
    If (!(Test-Path -Path "${InstallFolder}\image.txt")) {
	    $Compliance = "NonCompliant"
		Return $Compliance
	}

    #If the refresh.txt file does not exist in the new location, we are non-compliant
    If (!(Test-Path -Path "${InstallFolder}\refresh.txt")) {
	    $Compliance = "NonCompliant"
		Return $Compliance
	}
	
	#If the local wallpaper folder exists, check to see if it is up-to-date.
	If ($WPLfolderexists) {
		$touchexists = (Test-Path $WPTouch -PathType Leaf)	#Check existance of the touch file.
																#this is a file who's last write time is forced
																#to match that of the source folder. We compare the
																#dates of the two files to determine if we need to
																#re-synchronise or not.
		If (!($touchexists)) {
			$Compliance = "NonCompliant"	#The touch file does not exist. This probably means we have never
											#synchronised. We are Non-Compliant.
		} else {
			$WPTouchDate = (Get-ItemProperty -Path $WPTouch | Format-wide -Property LastWriteTime | out-string).trim()
				#^Get the Last Write Time attribute from the local Touch file.
			$WPSourceDate = (Get-ItemProperty -Path $WPSource | Format-Wide -Property LastWriteTime | out-string).trim()
				#^Get the Last Write Time attribute from the source folder.
			#Check to see if the Last Write Time attribute from the local file and the source folder match.
			If (!((Get-Date $WPTouchDate) -eq (Get-Date $WPSourceDate))) {
				$Compliance = "NonCompliant"	#The Last Write Time attributes do not match. We are Non-Compliant.
			}
		}
	} else {
		$Compliance = "NonCompliant"	#The local wallpaper folder does not exist. We are Non-Compliant.
	}
	Return $Compliance
}

$Compliance = CheckWallpaper

$Compliance
