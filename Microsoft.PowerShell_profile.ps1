#C:\Users\aiadmin\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
Remove-Item alias:curl -Force -ErrorAction SilentlyContinue
Remove-Item alias:wget -Force -ErrorAction SilentlyContinue
# Create an alias/function for notepad++
function notepad++ {
    & "C:\Program Files\Notepad++\notepad++.exe" $args
}