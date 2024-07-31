$timeoutSeconds = 10
$results = @()
 
$serverlist = get-adcomputer -Filter { Enabled -eq $true -and OperatingSystem -like "*Server*" } -Properties OperatingSystem | select Name,OperatingSystem
 
foreach ($server in $serverlist) {
    #re-initialise $hash
    $hash = @{}
    $connex = Test-Connection $server.Name -Count 1 -TTL 100 -Quiet
    if ($connex) {
        $code = {
            (Get-HotFix -computername $using:server.Name | Select-Object @{l="InstalledOn";e={[DateTime]$_.psbase.properties["installedon"].value}}| Sort InstalledOn)[-1] | Select -ExpandProperty InstalledOn
         }
         $j = Start-Job -ScriptBlock $code
         if (Wait-Job $j -Timeout $timeoutSeconds) {
            $patch = Receive-Job $j
         }
         Remove-Job -force $j
    }
    else {
        #server can't be contacted
        $patch =  "offline"
    }
    $hash=[ordered]@{
        Computername=$server.Name
        PatchDate=$patch
        OperatingSystem=$Server.OperatingSystem
    }
    [pscustomobject]$hash
    $results += [pscustomobject]$hash
}
 
#output just the computer names, sorted alphabetically
$results | sort computername | select computername | Out-file C:\temp\Server_names.txt
 
#output the computer names, patch date and operating system, sorted by computer name
$results | sort computername | Export-Csv C:\temp\Server_patches.csv
