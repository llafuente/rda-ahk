if (!(Test-Path ".\Natural_Docs\Natural Docs\NaturalDocs.exe" -PathType Leaf)) {
  Invoke-WebRequest -o Natural_Docs_2.3.zip https://naturaldocs.org/download/natural_docs/2.3/Natural_Docs_2.3.zip
  Expand-Archive -LiteralPath '.\Natural_Docs_2.3.zip' -DestinationPath 'Natural_Docs'
}

.\Natural_Docs\Natural Docs\NaturalDocs.exe docs\
