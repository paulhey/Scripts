Start-Transcript -Path $PSScriptRoot\RemoveIdleUsers.log -Append

# First, get the users from quser
$quser = query user 2>$null
$header = ($quser[0] -split '\s\s+').Trim()
$users = $quser[1..$($quser.Count)] 
foreach ($line in $users){
  if ($line -match 'Disc'){
    # need to replace empty session name with something. -- in this case
    $line = $line -replace "^(\s\w+\s\s)", '$1--'
  }
  $user = $line -replace '\s\s+', ';' |
    ConvertFrom-String -Delimiter ';' -PropertyNames $header

  if ($user.STATE -ne 'ACTIVE') {
    Write-Host -ForegroundColor Green "[State : $($user.USERNAME) : $($user.STATE)] logoff $($user.ID)"
    logoff $user.ID
  } else {
    Write-Host -ForegroundColor Magenta "[State : $($user.USERNAME) : $($user.STATE)] User is $($user.STATE)."
  }
}
