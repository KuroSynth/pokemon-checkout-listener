param(
    [string]$Topic = $env:NTFY_TOPIC_PC,
    [ValidateSet("edge","chrome","default")]
    [string]$Browser = "edge"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Topic)) {
    $Topic = Read-Host "Pega tu NTFY_TOPIC"
}

$Topic = $Topic.Trim()

if ([string]::IsNullOrWhiteSpace($Topic)) {
    Write-Host "ERROR: NTFY_TOPIC vacio." -ForegroundColor Red
    exit 1
}

function Open-Checkout {
    param([string]$Url)

    if ([string]::IsNullOrWhiteSpace($Url)) { return }

    try { $uri = New-Object System.Uri($Url) }
    catch { return }

    $hostName = $uri.Host.ToLowerInvariant()

    if (
        $hostName -ne "amazon.com.mx" -and
        -not $hostName.EndsWith(".amazon.com.mx")
    ) { return }

    if (-not $uri.AbsolutePath.ToLowerInvariant().Contains("/checkout/")) { return }

    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host ("[{0}] CHECKOUT RECIBIDO" -f (Get-Date -Format "HH:mm:ss.fff")) -ForegroundColor Green
    Write-Host $Url -ForegroundColor Cyan
    Write-Host "ABRIENDO NAVEGADOR..." -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host ""

    switch ($Browser) {
        "edge"   { Start-Process "msedge.exe" -ArgumentList $Url }
        "chrome" { Start-Process "chrome.exe" -ArgumentList $Url }
        default  { Start-Process $Url }
    }
}

$streamUrl = "https://ntfy.sh/$Topic/json"

Write-Host ""
Write-Host "NTFY -> AMAZON CHECKOUT LISTENER PC" -ForegroundColor Green
Write-Host "Stream: $streamUrl"
Write-Host "Browser: $Browser"
Write-Host "Solo abre URLs de checkout de Amazon Mexico."
Write-Host "Esperando mensajes en tiempo real..."
Write-Host ""

while ($true) {
    $response = $null
    $reader = $null
    $stream = $null

    try {
        Write-Host ("[{0}] Conectando..." -f (Get-Date -Format "HH:mm:ss.fff")) -ForegroundColor DarkGreen

        $request = [System.Net.HttpWebRequest]::Create($streamUrl)
        $request.Method = "GET"
        $request.Accept = "application/x-ndjson"
        $request.UserAgent = "PokemonCheckoutPC/1.0"
        $request.Timeout = 15000
        $request.ReadWriteTimeout = 300000
        $request.KeepAlive = $true

        $response = $request.GetResponse()
        $stream = $response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)

        Write-Host ("[{0}] CONECTADO A NTFY" -f (Get-Date -Format "HH:mm:ss.fff")) -ForegroundColor Green

        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            try { $msg = $line | ConvertFrom-Json }
            catch { continue }

            if ($msg.event -ne "message") { continue }

            $click = [string]$msg.click
            if (-not [string]::IsNullOrWhiteSpace($click)) {
                Open-Checkout -Url $click
            }
        }
    }
    catch {
        Write-Host (
            "[{0}] Stream desconectado: {1}" -f
            (Get-Date -Format "HH:mm:ss"),
            $_.Exception.Message
        ) -ForegroundColor Yellow
    }
    finally {
        if ($reader) { $reader.Close(); $reader.Dispose() }
        if ($stream) { $stream.Close(); $stream.Dispose() }
        if ($response) { $response.Close(); $response.Dispose() }
    }

    Write-Host "Reconectando en 1 segundo..." -ForegroundColor DarkYellow
    Start-Sleep -Seconds 1
}
