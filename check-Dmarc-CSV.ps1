# Execute As
# .\Check-DMARC.ps1 -CsvPath "C:\path\dominios.csv"


param (
    [string]$CsvPath
)

if (-not $CsvPath) {
    $CsvPath = Read-Host "Digite o caminho do arquivo CSV"
}

# Verifica se o arquivo existe
if (-Not (Test-Path $CsvPath)) {
    Write-Host "❌ Arquivo CSV não encontrado: $CsvPath" -ForegroundColor Red
    exit
}

# Importa os domi­nios do CSV
$domains = Import-Csv -Path $CsvPath

# Verifica cada domi­nio
foreach ($entry in $domains) {
    $Domain = $entry.Domain
    $dmarcDomain = "_dmarc.$Domain"

    try {
        Write-Host $Domain
        $dmarcRecord = Resolve-DnsName -Name $dmarcDomain -Type TXT -ErrorAction Stop
        $dmarcText = ($dmarcRecord | Where-Object { $_.QueryType -eq "TXT" }).Strings -join " "

        if ($dmarcText -match "v=DMARC1") {
            # Extrai a politica principal (p=)
            if ($dmarcText -match "p=([a-zA-Z]+)") {
                $policy = $matches[1]
                
                switch ($policy) {
                    "reject" {
                        Write-Host "✅ DMARC found for $Domain " -ForegroundColor Green
                        Write-Host "Policy: $policy → OK (Max. protection)" -ForegroundColor Green
                    }
                    "quarantine" {
                        Write-Host "✅ DMARC encontrado para $Domain" -ForegroundColor Green
                        Write-Host "Policy: $policy → OK (Moderate protection)" -ForegroundColor Green
                    }
                    "none" {
                        Write-Host "⚠  DMARC encontrado para $Domain" -ForegroundColor Yellow
                        Write-Host "Policy: $policy → Atention! No action is being taken." -ForegroundColor Yellow
                    }
                    default {
                        Write-Host "🔍 DMARC encontrado para $Domain" -ForegroundColor Cyan
                        Write-Host "Unknown policy: $policy" -ForegroundColor Cyan
                    }
                }
            } else {
                Write-Host "⚠  DMARC found for $Domain, but no policy identified!" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ No DMARC policies found for $Domain" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error when querying DMARC for $Domain" -ForegroundColor Red
    }
    Write-Host ""

}
