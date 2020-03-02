# First, get the users from quser
$quser = quser 2>$null
$header = ($quser[0] -split '\s\s+').Trim()
$users = $quser[1..$($quser.Count)] -replace '\s\s+', ';' | ConvertFrom-String -Delimiter ';' -PropertyNames $header
foreach ($user in $users){
  if ($user.STATE -ne 'ACTIVE') {
    Write-Host -ForegroundColor Green "[State : $($user.STATE)] logoff $($user.ID)"
  } else {
    Write-Host -ForegroundColor Magenta "[State : $($user.STATE)] User $($user.USERNAME) is $($user.STATE)."
  }
}
