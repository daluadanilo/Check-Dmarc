# Check-Dmarc
Sript to check Dmarc protocols
It will also validate the adopted policy, if it is in good practice.

# Requirements
- Powershell prompt
- Internet Access

# How to use
Run the command
```
./check-dmarc.ps1 -Domain "mydomain.com"
```
To check if domains have DMARC policy, you can use the script "check-Dmarc-CSV.ps1"

Create a CSV file with the first line called "Domain" and below each line you can add the domains to be queried:
```
Domain

domain1.com

domain2.com

domain3.com
```
Save the CSV file and run the following command:
```
 .\check-Dmarc-CSV.ps1 -CsvPath C:\folder\file.csv -OutputCsv C:\folder\result.csv
 ```