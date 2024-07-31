#Please be CAREFUL when running scripts, analyse it first.

# Define the directory path
$directory = "C:\ or desired path" #this is a variable to register the path 
 
# This line will get files older than 180 days
$oldFiles = Get-ChildItem -Path $directory | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-180) }
 
#This will delete old files
foreach ($file in $oldFiles) {
    Remove-Item -Path $file.FullName -Force
}