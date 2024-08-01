$FileLogdate = Get-Date -format 'yyyymmdd-hhmm'
Start-transcript -path "C:\Admin\$FileLogdate.txt" -noclobber

# Replace the following variables with your own values
$oldDomain = "Choose the domain you want migrate from"
$newDomain = "Choose the domanin you want to migrate"
$csvPath = "Put the CSV file path"

# Load the CSV file and loop through each user
$users = Import-Csv $csvPath
foreach ($user in $users) {
    
    # Get the user's current UPN
    $currentUpn = $user.UserPrincipalName

    # Get the users current SIP proxyaddresses
    # $proxylist = Get-aduser -Identity $user.SamAccountName -Properties proxyaddresses | Select-Object @{L = "ProxyAddresses"; E = { ($_.proxyaddresses -like 'sip:*')}}

    # Replace the old domain with the new domain
    $newUpn = $currentUpn.Replace("@$oldDomain", "@$newDomain")
    Write-Output "Changing UPN for $currentUpn to $NewUpn"

    # Update the user's UPN
    Set-ADUser -Identity $user.SamAccountName -UserPrincipalName $newUpn

    #update the user Mail attribute
    Write-Output "Changing EmailAddress for $currentUpn to $NewUpn"
    Set-ADUser -Identity $user.SamAccountName -EmailAddress $newUpn

    # Change ProxyAddresses
    Write-Output "Changing ProxyAddresses for $CurrentUpn"
    Set-Aduser -Identity $user.SamAccountName -Remove @{ProxyAddresses="SMTP:"+$currentUpn}
    Set-Aduser -Identity $user.SamAccountName -Add @{ProxyAddresses="SMTP:"+$newUpn}
    Set-Aduser -Identity $user.SamAccountName -Add @{ProxyAddresses="smtp:"+$currentUpn}

    #remove SIP address
    Write-Output "Removing SIP address for $CurrentUpn"
    Set-ADUser -Identity $user.SamAccountName -Remove @{Proxyaddresses="$($user.SIPaddress)"}
 
	#Add to group required for Signature if you use Exclaimer to manage your signatures
	#Add-ADGroupMember -Identity "Choose exclaimer group" -Members $user.SamAccountName
	

}

Stop-Transcript