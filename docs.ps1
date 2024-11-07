if (!(Test-Path ".\Natural Docs\Natural Docs\NaturalDocs.exe" -PathType Leaf)) {
  Invoke-WebRequest -o Natural_Docs_2.3.zip https://naturaldocs.org/download/natural_docs/2.3/Natural_Docs_2.3.zip
  Expand-Archive -LiteralPath '.\Natural_Docs_2.3.zip' -DestinationPath 'Natural Docs'
}

. ".\\Natural Docs\\Natural Docs\\NaturalDocs.exe" -p .\docs -o html .\docs\html
node docs/pdf.js
