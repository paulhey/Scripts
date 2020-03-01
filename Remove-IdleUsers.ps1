# First, get the users from quser
 $quser = quser 2>$null
 $header = ($quser[0] -split '\s\s+').Trim()
 $users = $quser[1..$($quser.Count)] -replace '\s\s+',';' | ConvertFrom-String -Delimiter ';' -PropertyNames $header
 
 