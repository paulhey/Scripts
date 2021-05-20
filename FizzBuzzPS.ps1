[CmdletBinding()]
param (
  [Parameter()]
  [int]
  $Min = 1,
  #
  [Parameter()]
  [int]
  $Max = 125,
  # Parameter help description
  [Parameter()]
  [switch]
  $HashMode
)

$Words = [ordered]@{
  3  = "Fizz"
  5  = "Buzz"
  7  = "Woof"
  11 = "Ouch"
  13 = "Bang"
}


Write-Host "Running with range [$Min --> $Max]" -ForegroundColor Magenta
if ($HashMode) {
  $List = @(
    foreach ($n in $Min..$Max){
      @{ 
        Number = $n
        Word   = ''
      }
    }
  )

  $List.ForEach({
      foreach ($key in $Words.Keys){
        if ( 
          ($_['Number'] -is [int]) -and 
          (($_['Number'] % $key) -eq 0) 
        ) {
          $_['Word'] = @($_['Word'], $Words.$key) -join ''
        } 
      }
      if ($_['Word'] -ne ''){
        $_['Number'] = $_['Word']
      }
    })

  Write-Host ($List.Number -join ', ')
} else {
  [bool] $PrintN = $true
  foreach ($n in $Min..$Max){
    $out = ""
    foreach ($key in $Words.Keys){
      if (($n % $key) -eq 0 ){
        $out = $out + $Words.$key
        $PrintN = $false
      }
    }
    if ($PrintN) {
      $out = $n
    } else {
      $PrintN = $true
    }
    Write-Host -NoNewline "$out, "
  }
}

Write-Host
Write-Host "Done (-:" -ForegroundColor Green