#UPDATE THE CORPORATE DESKTOP IMAGES
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

#For reference, foreground colour is 234, 0, 40
$RGBComma = "234,0,40" #Background RGB with comma delimiters

#GET SCREEN RESOLUTON

Add-Type -AssemblyName System.Windows.Forms
$ScreenBounds = ([System.Windows.Forms.Screen]::PrimaryScreen | Select Bounds)
$ScreenWidth = ($ScreenBounds.Bounds.Width)
$ScreenHeight = ($ScreenBounds.Bounds.Height)

Start-Process "${BinFolder}\bginfo420.exe" -argumentlist "/nolicprompt `"${BGInfoLocation}\Login61.bgi`" /timer:0" -wait
Start-Process "${BinFolder}\ImageMagick\convert.exe" -argumentlist "`"${BGInfoLocation}\backgroundDefault.bmp`" -gravity northeast -background `"rgb(${RGBComma})`" -extent ${ScreenWidth}x${ScreenHeight} `"${BGInfoLocation}\backgroundDefault.jpg`"" -wait

If (!(Test-Path "${OobeFolder}\info" -PathType Container)) {
	New-Item "${OobeFolder}\info" -ItemType Directory -Force
}
If (!(Test-Path "${OobeFolder}\info\backgrounds" -PathType Container)) {
	New-Item "${OobeFolder}\info\backgrounds" -PathType Directory -Force
}
Start-Process "${BinFolder}\LeadCmd\LFC.exe" -argumentlist "`"$BGInfoLocation`" `"$BGInfoLocation`" /b24 /f10 /q2 /noui" -wait
$BackgroundSize = (Get-ItemProperty -Path "${BGInfoLocation}\backgroundDefault.jpg" | Format-Wide -Property Length | Out-String).Trim()
If ("$BackgroundSize" -ge "256000") {
	Start-Process "${BinFolder}\LeadCmd\LFC.exe" -argumentlist "`"$BGInfoLocation`" `"$BGInfoLocation`" /b24 /f10 /q20 /noui" -wait
}
Copy-Item -Path "${BGInfoLocation}\backgroundDefault.jpg" -Destination "${OobeFolder}\info\backgrounds\backgroundDefault.jpg" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background" -Name OEMBackground -Value 1 -Type DWORD -Force
Start-Process "${env:WinDir}\System32\rundll32.exe" -ArgumentList "user32.dll, UpdatePerUserSystemParameters" -wait
