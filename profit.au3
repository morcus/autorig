#include <INet.au3>
#include <Date.au3>
#include <Array.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <Constants.au3>


$firstrun=1
$profileList=""
$eth=0
$ethhash=0
$bestvalue=0
$bestmoney=""

func profileload ()
	$l=1
	_FileReadToArray ("config.csv", $profileList, "", ",")
	;~ 	_ArrayDisplay($profileList)
	while $l < UBound($profileList, 1)
		if $profileList[$l][0] == 1 Then
			ConsoleWrite( $profileList[$l][1] & @CRLF)
	 		calculateprofit ( $profileList[$l][1] , $profileList[$l][2] , $profileList[$l][3] , $profileList[$l][4] , $profileList[$l][5] , $profileList[$l][6] , $profileList[$l][7] , $profileList[$l][8])
		EndIf
		$l = $l + 1
	WEnd
EndFunc

func calculateprofit ( $name, $hashrate, $ethdual, $power, $powercost, $fee, $hardwarecost, $whattomineid )
	$HTMLSource = _INetGetSource('http://whattomine.com/coins/' & $whattomineid & '.json?utf8&hr=' & $hashrate & '&p=' & $power & '&fee=' & $fee & '&cost=' & $powercost & '&hcost=' & $hardwarecost & '&commit=Calculate')
;~ 	msgbox (0,0,$HTMLSource)

	$revenue = StringTrimLeft ($HTMLSource, StringInStr ( $HTMLSource, '"revenue":"') + 11 )
	$revenue = StringTrimRight (StringMid ($revenue, 1, StringInStr ( $revenue, '"')), 1)
;~ 	msgbox (0,0,$revenue)

	if StringInStr ($HTMLSource, "Ethereum") > 0 Then
		$eth = $revenue
		$ethhash = $hashrate
	elseif $ethdual > 0 Then
		$revenue = $revenue + ( $eth / $ethhash * $ethdual )
	EndIf

	$revenuenet = $revenue - ($power / 1000 * $powercost * 24)

	if $revenuenet > $bestvalue Then
		$bestvalue = $revenuenet
		$bestmoney = $name
	EndIf

	FileWriteLine( "results.csv", $name & ',' & $revenue & ',' & $revenuenet)
EndFunc


while 1
	filedelete ( "results.csv")
	FileWriteLine ( "results.csv", "name, revenue, revenuenet")
	$bestvalue="0"
	profileload()
	FileWriteLine ( "results.csv", $bestmoney & ',' & "BEST" & ',' & $bestvalue)

	if $firstrun == 1 Then
		$firstrun = 0
		$exec=$bestmoney
		run("kill.bat")
		sleep (5 * 1000)
		run($bestmoney & ".bat")
		FileWriteLine ("log.csv", _NowDate() & " - " & _NowTime() & ',' & $bestmoney & ',' & $bestvalue & ',First Run')
	Else
		if not $bestmoney == $exec Then
			run("kill.bat")
			sleep (5 * 1000)
			run($bestmoney & ".bat")
			FileWriteLine ("log.csv", _NowDate() & " - " & _NowTime & ',' & $bestmoney & ',' & $bestvalue & ',' & $exec)
			$exec=$bestmoney
;~ 			msgbox(0,0,"new money is " & $bestmoney)
		EndIf
	EndIf
	sleep (180 * 1000)
WEnd