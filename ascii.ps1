Write-Host "
__________                           _________.__           .__  .__   
\______   \______  _  __ ___________/   _____/|  |__   ____ |  | |  |  
 |     ___/  _ \ \/ \/ // __ \_  __ \_____  \ |  |  \_/ __ \|  | |  |  
 |    |  (  <_> )     /\  ___/|  | \/        \|   Y  \  ___/|  |_|  |__
 |____|   \____/ \/\_/  \___  >__| /_______  /|___|  /\___  >____/____/
                            \/             \/      \/     \/           
.__            _____                                           ._.
|__| ______   /  _  \__  _  __ ____   __________   _____   ____| |
|  |/  ___/  /  /_\  \ \/ \/ // __ \ /  ___/  _ \ /     \_/ __ \ |
|  |\___ \  /    |    \     /\  ___/ \___ (  <_> )  Y Y  \  ___/\|
|__/____  > \____|__  /\/\_/  \___  >____  >____/|__|_|  /\___  >_
        \/          \/            \/     \/            \/     \/\/
"

start 'C:\Users\Dan\Downloads\Alan Walker - The Spectre.mp3'

while($val -ne 1000) { $val++ ; Write-Host $val }

gwmi win32_process | Where-Object {$_.CommandLine -like "*Wmplayer.exe*"}  | % { "$(Stop-Process $_.ProcessID)" }

(New-Object -com SAPI.SpVoice).speak("OK!  Thats enough of that")
write-host "Ready to do something"
(New-Object -com SAPI.SpVoice).speak("you young wipper snappers gonna learn today")
Write-Host "Time for task 2"
(New-Object -com SAPI.SpVoice).speak("I tell ya what")
Write-Host "Now what?"
(New-Object -com SAPI.SpVoice).speak("Larry get my gun")
