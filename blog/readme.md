# Readme

<!-- https://anthonychu.ca/post/blazor-azure-storage-static-websites/ -->

Run below, note that we escape the $ with a \`$ if running in powershell. Or just run the `deploy.ps1` script.

```powershell
dotnet publish -c Release -o out
$null = az storage blob upload-batch --account-name sacodebeaverblog -s ".\out\Blog\dist" -d `$web
$null = az storage blob update --account-name sacodebeaverblog -c `$web -n _framework/wasm/mono.wasm --content-type application/wasm
```

Remember to enable deep linking as described in [blazor-azure-storage-static-websites](https://anthonychu.ca/post/blazor-azure-storage-static-websites/)

Custom domain [Enable custom domain & SSL for a static website in Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website-custom-domain)

## Libraries used

- [MarkdownSharp](https://github.com/StackExchange/MarkdownSharp)