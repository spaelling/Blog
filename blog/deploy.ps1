dotnet publish -c Release -o out
$null = az storage blob upload-batch --account-name sacodebeaverblog -s ".\out\Blog\dist" -d `$web
$null = az storage blob update --account-name sacodebeaverblog -c `$web -n _framework/wasm/mono.wasm --content-type application/wasm