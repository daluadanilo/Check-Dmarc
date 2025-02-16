param (
    [string]$Domain
)

if (-not $Domain) {
    $Domain = Read-Host "Digite o domínio para verificar DMARC"
}

# Define o domínio DMARC
$dmarcDomain = "_dmarc.$Domain"

# Realiza a consulta DNS
try {
    $dmarcRecord = Resolve-DnsName -Name $dmarcDomain -Type TXT -ErrorAction Stop
    $dmarcText = ($dmarcRecord | Where-Object { $_.QueryType -eq "TXT" }).Strings -join " "

    if ($dmarcText -match "v=DMARC1") {
        # Extrai a política principal (p=)
        if ($dmarcText -match "p=([a-zA-Z]+)") {
            $policy = $matches[1]
            
            switch ($policy) {
                "reject" {
                    Write-Host "✅ DMARC encontrado para $Domain " -ForegroundColor Green
                    Write-Host "Política: $policy → OK (Proteção máxima)" -ForegroundColor Green
                }
                "quarantine" {
                    Write-Host "✅ DMARC encontrado para $Domain" -ForegroundColor Green
                    Write-Host "Política: $policy → OK (Proteção moderada)" -ForegroundColor Green
                }
                "none" {
                    Write-Host "⚠ DMARC encontrado para $Domain" -ForegroundColor Yellow
                    Write-Host "Política: $policy → Atenção! Nenhuma ação está sendo aplicada." -ForegroundColor Yellow
                }
                default {
                    Write-Host "🔍 DMARC encontrado para $Domain" -ForegroundColor Cyan
                    Write-Host "Política desconhecida: $policy" -ForegroundColor Cyan
                }
            }
        } else {
            Write-Host "⚠ DMARC encontrado, mas não foi possível identificar a política!" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Nenhuma política DMARC encontrada para $Domain" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao consultar DMARC ou política não configurada para $Domain" -ForegroundColor Red
}
