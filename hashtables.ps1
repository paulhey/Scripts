<#
  .Description
  Adapted from https://thesurlyadmin.com/2013/02/21/objects-and-hashtables/
  Word file taken from https://github.com/dwyl/english-words/
  Use words_alpha.txt

  HashTable construction based on information from:
  https://evotec.xyz/how-i-didnt-know-how-powerful-and-fast-hashtables-are/
  https://powershellexplained.com/2016-11-06-powershell-hashtable-everything-you-wanted-to-know-about/
  https://evotec.xyz/powershell-few-tricks-about-hashtable-and-array-i-wish-i-knew-when-i-started/

  There are five types being compared for performance in building and searching:
  1. Standard Object Array
  2. Standard hashtable
  3. Optimized Object Array
  4. Optimized hashtable
  5. Custom Array-Hashtable

  .Notes
  On my system (Pop_OS 20.10, i7-6700HQ), single run:
  ( Build and Search are times in ms)

  WordMax = 1000 => ~5 seconds
  Name                     Build    Search
  ----                     -----    ------
  Original ObjectArray  253.4651 2877.8113
  Original HashTable     22.2453   17.1099
  Faster PSCustomObject  15.8197  855.7602
  Faster HashTable        5.9904   13.8139
  Faster HashArray        6.7736   39.7411

  WordMax = 10000 => ~45 seconds
  Name                      Build     Search
  ----                      -----     ------
  Original ObjectArray  6247.8513 29274.6449
  Original HashTable      196.578    13.5784
  Faster PSCustomObject  153.2265  8879.8152
  Faster HashTable         45.757    16.1021
  Faster HashArray        41.0512   228.9509

  and WordMax = 100000 => ~22 minutes
  Name                        Build      Search
  ----                        -----      ------
  Original ObjectArray  714695.4769 424185.3322
  Original HashTable      2804.2919     26.6829
  Faster PSCustomObject    2016.044 148693.3055
  Faster HashTable         807.2425     11.4109
  Faster HashArray         669.8482   2385.1635

  .: HashTable is fastest to search using 'Fast'
  HashTable and HashArray is faster to construct
  at scale.
#>

[CmdletBinding()]
param (
  [Parameter()]
  [int]
  $SearchMax = 100,
  # Parameter help description
  [Parameter()]
  [int]
  $WordMax = 1000,
  # WordFile
  [Parameter(Mandatory)]
  [string]
  $WordFile
)

# Initialize some variables
$dict = Get-Content $WordFile | Select-Object -First $WordMax
$TestHash = @{}
$TestObj = @()
$FTestObj = @()
$FTestHash = @{}

# Build an array of Results
# Each result should have a Name, Build (time in ms), and Search (time in ms)
$results = @(
  # Original Object array from TheSurlyAdmin
  [PSCustomObject]@{
    Name   = 'Original ObjectArray'
    Build  = (Measure-Command {
        0..($WordMax - 1) | ForEach-Object {
          $TestObj += New-Object PSObject -Property @{
            Key        = $dict[$_]
            WordNumber = $_
          }
        }
      }).TotalMilliseconds
    Search = (Measure-Command {
        1..($SearchMax - 1) | ForEach-Object {
          $Num = Get-Random -Minimum 0 -Maximum ($WordMax - 1)
          $Found = $TestObj | Where-Object { $_.Key -eq $dict[$Num] }
        }
      }).TotalMilliseconds
  }
  # Original HashTable from TheSurlyAdmin
  [PSCustomObject]@{
    Name   = 'Original HashTable'
    Build  = (Measure-Command {
        0..($WordMax - 1) | ForEach-Object {
          $TestHash.Add($dict[$_], $_)
        }
      }).TotalMilliseconds
    Search = (Measure-Command {
        1..($SearchMax - 1) | ForEach-Object {
          $Num = Get-Random -Minimum 0 -Maximum ($WordMax - 1)
          $Found = $TestHash[$dict[$Num]]
        }
      }).TotalMilliseconds
  }
  # Faster object array initialization
  [PSCustomObject]@{
    Name   = 'Faster PSCustomObject'
    Build  = (Measure-Command {
        $FTestObj = @(
          foreach ( $i in 0..($WordMax - 1) ){
            [pscustomobject]@{
              Key   = $dict[$i]
              Index = $i
            }
          })
      }).TotalMilliseconds
    Search = (Measure-Command {
        foreach ($i in 1..($SearchMax - 1)){
          $Search = Get-Random -Minimum 0 -Maximum ($WordMax - 1)
          $Found = $FTestObj.Where({ $_.Key -eq $dict[$Search] })
        }
      }).TotalMilliseconds
  }
  # Faster hashtable initialization
  [PSCustomObject]@{
    Name   = 'Faster HashTable'
    Build  = (Measure-Command {
        foreach ($i in 0..($WordMax - 1)){
          $FTestHash[$dict[$i]] = $i
        }
      }).TotalMilliseconds
    Search = (Measure-Command {
        foreach ($i in 1..($SearchMax - 1)){
          $Search = Get-Random -Minimum 0 -Maximum ($WordMax - 1)
          $Found = $FTestHash[$dict[$Search]]
        }
      }).TotalMilliseconds
  }
  # a custom array-of-hashtables algorithm
  [PSCustomObject]@{
    Name   = 'Faster HashArray'
    Build  = (Measure-Command {
        $TestHA = @(
          foreach ( $i in 0..($WordMax - 1) ){
            @{
              "$($dict[$i])" = $i
            }
          })
      }).TotalMilliseconds
    Search = (Measure-Command {
        foreach ($i in 1..($SearchMax - 1)) {
          $Search = Get-Random -Minimum 0 -Maximum ($WordMax - 1)
          $Found = $TestHA.${$dict[$Search]}
        }
      }).TotalMilliseconds
  }
)

$results | Format-Table -AutoSize