# Check-Dmarc
Sript para verificar protocolos Dmarc
Irá validar a política adotada também, caso esteja em boas práticas.

# Requisitos
Prompt do Powershell

# Como usar
Execute o comando ./check-dmarc.ps1 -Domain "meudominio.com"

Para consultar os dominios se tem DMARC policy, poderá usar o script "check-Dmarc-CSV.ps1"

Crie um arquivo CSV com a primeira linha chamado "Domain" e abaixo de cada linha poderá adicionar os dominios a serem consultados

Domain
domain1.com
domain2.com
domain3.com

Salve o arquivo CSV e execute o seguinte comando

 .\check-Dmarc-CSV.ps1 -CsvPath C:\folder\file.csv