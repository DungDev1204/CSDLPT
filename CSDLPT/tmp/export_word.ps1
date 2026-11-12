$ErrorActionPreference = 'Stop'
$inputDoc = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../output/Bao_cao_CSDLPT_Nhom_8.docx'))
$outputPdf = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../output/Bao_cao_CSDLPT_Nhom_8.pdf'))
$wordApp = New-Object -ComObject Word.Application
$wordApp.Visible = $false
$wordApp.DisplayAlerts = 0
$wordDoc = $null
try {
  $wordDoc = $wordApp.Documents.Open($inputDoc, $false, $true)
  $wordDoc.Repaginate()
  $count = $wordDoc.ComputeStatistics(2)
  Write-Output "Word pages: $count"
  $wordDoc.ExportAsFixedFormat($outputPdf, 17)
} finally {
  if ($null -ne $wordDoc) { $wordDoc.Close(0) }
  $wordApp.Quit()
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wordApp) | Out-Null
}
