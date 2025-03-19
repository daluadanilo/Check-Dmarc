# Execute as:
# .\Check-DMARC.ps1 -CsvPath "C:\path\dominios.csv" -OutputCsv "C:\path\resultado.csv"

param (
    [string]$CsvPath,
    [string]$OutputCsv = "DMARC_Results.csv"
)

if (-not $CsvPath) {
    $CsvPath = Read-Host "Enter the path of the CSV file"
}

# Check if file exists
if (-Not (Test-Path $CsvPath)) {
    Write-Host "❌ CSV file not found: $CsvPath" -ForegroundColor Red
    exit
}

# Import domains from CSV
$domains = Import-Csv -Path $CsvPath
$results = @()

# Check each domain
foreach ($entry in $domains) {
    $Domain = $entry.Domain
    $dmarcDomain = "_dmarc.$Domain"
    $policy = "notconfigured"

    try {
        Write-Host $Domain
        $dmarcRecord = Resolve-DnsName -Name $dmarcDomain -Type TXT -ErrorAction Stop
        $dmarcText = ($dmarcRecord | Where-Object { $_.QueryType -eq "TXT" }).Strings -join " "

        if ($dmarcText -match "v=DMARC1") {
            # Extract the main policy (p=)
            if ($dmarcText -match "p=([a-zA-Z]+)") {
                $policy = $matches[1]

                switch ($policy) {
                    "reject" {
                        Write-Host "✅ DMARC found for $Domain " -ForegroundColor Green
                        Write-Host "Policy: $policy → OK (Max. protection)" -ForegroundColor Green
                    }
                    "quarantine" {
                        Write-Host "✅ DMARC found for $Domain" -ForegroundColor Green
                        Write-Host "Policy: $policy → OK (Moderate protection)" -ForegroundColor Green
                    }
                    "none" {
                        Write-Host "⚠  DMARC found for $Domain" -ForegroundColor Yellow
                        Write-Host "Policy: $policy → Attention! No action is being taken." -ForegroundColor Yellow
                    }
                    default {
                        Write-Host "🔍 DMARC found for $Domain" -ForegroundColor Cyan
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

    # Adds results to array for export
    $results += [PSCustomObject]@{
        Domain = $Domain
        DMARC  = $policy
    }

    Write-Host ""
}

# Exporta os resultados para CSV
$results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
Write-Host "📂 Results exported to: $OutputCsv" -ForegroundColor Cyan
