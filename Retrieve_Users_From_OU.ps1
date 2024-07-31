# Replace 'SecurityGroupName' with the name of your security group
$groupName = "SecurityGroupName which you want the users"

# Retrieve users from the security group
$users = Get-ADGroupMember -Identity $groupName | Where-Object {$_.objectClass -eq 'user'}

# Define an array to store user information
$userInfo = @()

# Iterate through each user and retrieve required information
foreach ($user in $users) {
    $userDetails = Get-ADUser -Identity $user -Properties UserPrincipalName, DisplayName, Mail, Title, Department, Enabled, Company, Created
    $userProperties = @{
        'Name'              = $userDetails.Name
        'SamAccountName'    = $userDetails.SamAccountName
        'UserPrincipalName' = $userDetails.UserPrincipalName
        'DisplayName'       = $userDetails.DisplayName
        'Mail'              = $userDetails.Mail
        'Title'             = $userDetails.Title
        'Department'        = $userDetails.Department
        'Enabled'           = if ($userDetails.Enabled) { "Enabled" } else { "Disabled" }
        'Company'           = $userDetails.Company
        'Creation'          = $userDetails.Created.ToShortDateString()
        'CreatedTime'       = $userDetails.Created.ToLongTimeString()
    }
    
    # Add user information to the array
    $userInfo += New-Object PSObject -Property $userProperties
}

# Specify the file path and filename separately (you will need edit this part)
$filePath = "C:choos the path to save your file "users.csv"

# Export user information to CSV file
$userInfo | Export-Csv -Path $filePath -NoTypeInformation
