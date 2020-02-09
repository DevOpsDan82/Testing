function Search-Drives {
    [CmdletBinding()]
    param (
        [string]$SearchPattern = '*',
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        $ComputerName = $env:COMPUTERNAME,
        [string]$PathOutput,
        [string]$FileName,
        [pscredential]$Credential
    )

    $username =  $Credential.UserName
    $password = $Credential.GetNetworkCredential().Password
    
    foreach ($computer in $ComputerName) {
        

    Invoke-Command -ComputerName $computer -Credential $Credential -ArgumentList `
                                            $SearchPattern, `
                                            $computer, `
                                            $PathOutput, `
                                            $FileName, `
                                            $username, `
                                            $password, `
                                            $Credential -ScriptBlock {

    $SearchPattern = $args[0]
    $computer = $args[1]
    $PathOutput = $args[2]
    $FileName =  $args[3]
    $username =  $args[4]
    $password =  $args[5]
    $Credential = $args[6]

    # Initialize some variables 
    $drives = [System.Environment]::GetLogicalDrives();
    $workingDir = New-Item -Path C:\ -Name 'fileSearcher' -ItemType Directory
    [System.Collections.ArrayList]$contentOutput = @()
    # Loop through system drives
    foreach ($drive in $drives) {
        $directoryInfo = [System.IO.DriveInfo]::new($drive)
        if (!$directoryInfo.IsReady) {
            continue
        }

        # Set bat script variables in memory 
        $driveName = $drive.Replace(':\','')

        $filter = "$drive$SearchPattern"

        $fileOutput = "$workingDir\$computer$driveName$FileName"

        $contentOutput.Add($fileOutput)
        
        $batScript = @"
@ECHO OFF
IF EXIST $($workingDir) (
CALL :searchDir
) ELSE (
mkdir $($workingDir)
CALL :searchDir

:searchDir ...
dir "$($filter)" /s /b /a-d /-c > $($fileOutput)
)
"@

        $scriptName = "fileSearch$driveName.bat"
        # Create bat file on disk
        $script = New-Item -Path $workingDir.FullName -Name $scriptName -ItemType file -Value $batScript
        # Create and run Scheduled task
        $action = New-ScheduledTaskAction `
                            -Execute 'cmd.exe' `
                            -Argument "/c $script"
        $time = [datetime]::Now
        $trigger =  New-ScheduledTaskTrigger -At $time -Once
        $settings = New-ScheduledTaskSettingsSet

        Register-ScheduledTask -TaskName "File Searcher" -Action $action -Trigger $trigger -Settings $settings -Description "File Searcher" -User $username -Password $password
        Start-ScheduledTask 'File Searcher' -AsJob
        Unregister-ScheduledTask -TaskName 'File Searcher' -Confirm:$false
        
    }

    # Wait for Processes to finish
    while ($true) {
        $CIM_Processes = Get-CIMinstance -class Win32_Process -Filter "Name LIKE 'cmd.exe'" -ErrorAction SilentlyContinue;
        $CommandLine = $CIM_Processes | Select-Object -ExpandProperty CommandLine;
        if ($CommandLine -like "*fileSearcher*") {
            continue
        }
        else {
            break
        }
    }
    
    $result = Test-Path $PathOutput -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue
    if ($result -eq $false) {

        mkdir $PathOutput -Force
    }
    $newFileName = "$env:COMPUTERNAME$FileName"
    New-PSDrive -Name 'Output' -Root $("$PathOutput") -PSProvider 'FileSystem' -Credential $Credential -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue
    $content = $workingDir.FullName + '\*.txt'
    $outPath = $workingDir.FullName + "\$newFileName"
    Get-Content $content | Set-Content -Path $outPath
    $newFile = $workingDir.FullName + "\$newFileName"
    Copy-Item $newFile -Destination $PathOutput -Force
    Remove-Item -Path $workingDir -Recurse -Force
    Remove-PSDrive -Name 'Output'
        
}-AsJob
}
}
#Example 
#Search-Drives -ComputerName win10,devbox -Credential (Get-Credential elserdev\administrator) -SearchPattern '*.jpg' -PathOutput '\\devbox\c$' -FileName 'JPGResults.txt'
#Search-Drives -ComputerName win10 -Credential (Get-Credential elserdev\administrator)  -PathOutput 'C:\results' -FileName 'AllDriveResults.txt'
#Search-Drives -ComputerName (Get-Content C:\computers.txt) -Credential (Get-Credential elserdev\administrator)  -PathOutput '\\devbox\c$' -FileName 'AllDriveResults.txt'