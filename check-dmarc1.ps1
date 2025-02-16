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

    if ($dmarcText -match "^v=DMARC1") {
        Write-Host "DMARC encontrado para $Domain" -ForegroundColor Green
    } else {
        Write-Host "Nenhuma política DMARC encontrada para $Domain" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao consultar DMARC ou política não configurada para $Domain" -ForegroundColor Red
}
