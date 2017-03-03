Function ClearBG {
	# *****************************************************
	#Some clever tricks to negate some of BGinfo's unwanted
	#behaviour. Mainly stopping snapshots being taken over
	#a background with a pre-existing snapshot.
	Write-Host "Cleaning up Registry Background settings"
	$RegConvertedWallPaper = New-Object PSObject -Property @{
		key = "HKCU:\Control Panel\Desktop"
		name = "ConvertedWallPaper"
	}
	$RegWallPaperSource = New-Object PSObject -Property @{
		key = "HKCU:\Software\Microsoft\Internet Explorer\Desktop\General"
		name = "WallPaperSource"
	}
	$RegWallpaper = New-Object PSObject -Property @{
		key = "HKCU:\Control Panel\Desktop"
		name = "Wallpaper"
	}
	
	If (($OSVersion -gt $WinXP)) {
		# "Windows 7"
		$WPSource = (Get-ItemProperty $RegWallPaperSource.key).($RegWallPaperSource.Name)
		Write-Host "Source: $WPSource"
		$ConvertedWP = (Get-ItemProperty $RegConvertedWallPaper.key).($RegConvertedWallpaper.Name)
		Write-Host "Converted: $ConvertedWP"
		$Wallpaper = (Get-ItemProperty $RegWallpaper.Key).($RegWallpaper.Name)
		Write-Host "Wallpaper: $Wallpaper"
		$BGColor = (Get-ItemProperty "HKCU:\Control Panel\Colors").Background
		Write-Host "Background Colour: $BGColor"
		# "Create ConvertedWallpaper value if it does not exist"
		If (!($ConvertedWP)) {
			# "The value doesn't exist"
			# "Check the source image isn't our BGInfo picture"
			Write-Host "Converted wallpaper doesn't exists or is empty"
			If ($WPSource.Contains("backgroundDefault.bmp")) {
				# "It is our BG info picture, so create the value with empty data and clear the wp source and actual desktop"
				Write-Host "Current wallpaper source is our default image. Clear all values"
				$ConvertedWP = ""
				$WPSource = ""
				$Wallpaper = ""
			} Else {
				# "It isn't our BG info picture, so copy the value's data"
				Write-Host "Current wallpaper source is not out default image. Updating converted wallpaper entry"
				$ConvertedWP = "$WPSource"
			}
		} Else {
			# "The value does exist, so let's do some processing!!"
			# "#Check if the source image and the converted wallpaper match"
			If ("$ConvertedWP" -eq "$WPSource") {
				# "#they do match! change the actual wallpaper value to match also"
				Write-Host "Source image and converted wallpaper match."
				Write-Host "Updating Wallpaper to match"
				$Wallpaper = $WPSource
			} ElseIf ($WPSource.Contains("backgroundDefault.bmp")) {	
				# "#they don't match and the WP source is our BG info picture"
				# "#set the actual wallpaper back to the converted wallpaper"
				# $ConvertedWP
				Write-Host "Source image and converted wallpaper do not match."
				Write-Host "Source image is the default background image."
				Write-Host "Set Wallpaper to match converted wallpaper."
				$Wallpaper = $ConvertedWP
				$WPSource = $ConvertedWP
			} ElseIf ("$WPSource" -eq "") {
				# "#they don't match and the WP source is empty"
				# "#set converted WP and actual wallpaper to empty"
				Write-Host "Source image and converted wallpaper do not match."
				Write-Host "Source image is empty."
				Write-Host "Clear values for Wallpaper and Converted Wallpaper"
				$Wallpaper = ""
				$ConvertedWP = ""
			} else {
				# "they don't match.. update Converted WP"
				Write-Host "Source image and converted wallpaper do not match."
				Write-Host "Set converted wallpaper to match wallpaper source"
				$ConvertedWP = $WPSource
				$Wallpaper = $WPSource
			}
		}
		If ("$BGColor" -eq "255 255 255") {
			If (!($Wallpaper)) {
				Write-Host "Desktop is solid white"
				$Script:StaffBGInfoFile = "StaffWhite.bgi"
			}
		}
		SetRegValue $RegWallpaper.key $RegWallpaper.name String "$Wallpaper"
		SetRegValue $RegWallPaperSource.key $RegWallPaperSource.name String "$WPSource"
		SetRegValue $RegConvertedWallPaper.key $RegConvertedWallPaper.name String "$ConvertedWP"
	}
}

Function SetRegValue ($rKey, $rName, $rType, $rValue) {
	Write-Host "New-ItemProperty `"$rKey`" -Name `"$rName`" -Type $rType -Value `"$rValue`" -Force"
	New-ItemProperty "$rKey" -Name "$rName" -Type $rType -Value "$rValue" -Force
	$Written = (Get-ItemProperty $rKey).($rName)
	Write-Host "Written value: $Written"
}


# Main Body
[reflection.assembly]::LoadWithPartialName("'Microsoft.VisualBasic")

$InstallFolder = "${env:ProgramFiles}\Organisation Name"
$WPLocation = "${InstallFolder}\wallpaper"
$WPLfolderexists = (Test-Path $WPLocation -PathType Container)	#Check existence of the local WallPaper Location.
#EXIT IF THE LOCAL WALLPAPER FOLDER DOES NOT EXIST
If (!($WPLfolderexists)) {
	Exit 0
}
$BGInfoLocation = "${WPLocation}\bginfo"
$BGIfolderexists = (Test-Path $BGInfoLocation -PathType Container)	#Check existence of the BGInfo Location.
#Exit if the BGInfo folder does not exist
If (!($BGIfolderexists)) {
	Exit 0
}
$BinFolder = "${WPLocation}\bin"
$OobeFolder = "${env:WinDir}\System32\Oobe"
$OSName = (Get-WmiObject Win32_OperatingSystem).caption
$ComputerName = "${env:ComputerName}".ToUpper()
$UserName = "${env:username}".ToLower()
$OSVersion = (Get-WmiObject Win32_OperatingSystem).version.Split(".")
$OSVersion = $OSVersion[0]+$OSVersion[1]
$Win2k = 50
$WinXP = 51
$WinV = 60
$Win7 = 61
$Win8 = 62
$Win81 = 63

#RUN BGINFO
If ($OSName.ToLower().Contains("server")) {
	Write-Host "This is a Server!"
	Write-Host "Running BGInfo next..."
	Start-Process "${BinFolder}\bginfo420.exe" -ArgumentList "/nolicprompt `"${BGInfoLocation}\Server.bgi`" /timer:0" -Wait
} ElseIf ($UserName.StartsWith("staff")) {
	# THE CURRENT USER IS A MEMBER OF STAFF
	Write-Host "User is a member of staff"
	If (("$ComputerName" -eq "B002731") -or ("$ComputerName" -eq "B003600") -or ("$ComputerName" -eq "B004216") -or ("$ComputerName" -eq "B003825") -or ("$ComputerName" -eq "B007004")) {
		#                   JBc                                  AFo                                 ABr                                  SWn                                 Apprentice
		# Do not run BGInfo for IT Crew on our own PCs. We know our B numbers..... don't we?
		If ("$UserName" -eq "staffafo" -or "$UserName" -eq "staffabr" -or "$UserName" -eq "staffjbc" -or "$UserName" -eq "staffswn" -or "$UserName" -eq "staffppr"){
			Write-Host "IT Support on one of their own machines - not running BGInfo"
			Exit 0
		}
	}
	$StaffBGInfoFile = "Staff.bgi"
	ClearBG
	Write-Host "Running BGInfo next... $StaffBGInfoFile"
	Start-Process "${BinFolder}\bginfo420.exe" -ArgumentList "/nolicprompt `"${BGInfoLocation}\$StaffBGInfoFile`" /timer:0" -Wait
} ElseIf (([Microsoft.VisualBasic.Information]::isnumeric($UserName.Substring(0,1))) -or ($UserName.ToLower().StartsWith("assess")) -or ($UserName.ToLower().StartsWith("candidate"))) {
	# THE CURRENT USER IS A STUDENT
	Write-Host "User is a student"
	Write-Host "Running BGInfo next..."
	Start-Process "${BinFolder}\bginfo420.exe" -ArgumentList "/nolicprompt `"${BGInfoLocation}\Student.bgi`" /timer:0" -Wait
} Else {
	# THE CURRENT USER IS NEITHER A DEDICATED STUDENT OR STAFF ACCOUNT
	Write-Host "User is not a student or staff"
	Write-Host "Running BGInfo next..."
	Start-Process "${BinFolder}\bginfo420.exe" -ArgumentList "/nolicprompt `"${BGInfoLocation}\Guest.bgi`" /timer:0" -Wait
}
