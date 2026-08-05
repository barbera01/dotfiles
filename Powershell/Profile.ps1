oh-my-posh init pwsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/cloud-native-azure.omp.json' | Invoke-Expression 

function Select-AzureSubscription {
    Write-Host "Select Azure subscription:" -ForegroundColor Cyan
    $subs = @(
        az account list --only-show-errors |
        ConvertFrom-Json |
        Sort-Object name
    )

    if ($subs.Count -eq 0) {
        Write-Host "No subscriptions found (are you logged in?)" -ForegroundColor Red
        return
    }

    for ($i = 0; $i -lt $subs.Count; $i++) {
        $marker = if ($subs[$i].isDefault) { "*" } else { " " }
        Write-Host ("{0,2}) [{1}] {2}" -f ($i + 1), $marker, $subs[$i].name)
    }

    $choiceRaw = Read-Host "#?"
    $choice = 0

    if (-not [int]::TryParse($choiceRaw.Trim(), [ref]$choice)) {
        Write-Host "Invalid selection" -ForegroundColor Red
        return
    }

    if ($choice -lt 1 -or $choice -gt $subs.Count) {
        Write-Host "Invalid selection" -ForegroundColor Red
        return
    }
    $selected = $subs[$choice - 1]
    az account set --subscription $selected.id --only-show-errors
    Write-Host "✅ Active subscription: $($selected.name)" -ForegroundColor Green
}


function Select-AzureContext {
    if ($env:AZURE_CONFIG_DIR) {
        return
    }

    Write-Host "Select Azure CLI context:" -ForegroundColor Cyan

    $contexts = @(
        @{ Name = "SOR-Default"; Azure = "$HOME\.azure-sor-default"; Kube = "$HOME\.kube\config-sor-default" }
        @{ Name = "SOR-COM";     Azure = "$HOME\.azure-sor-com";     Kube = "$HOME\.kube\config-sor-com" }
        @{ Name = "ABA";         Azure = "$HOME\.azure-aba";         Kube = "$HOME\.kube\config-aba" }
        @{ Name = "ABA-DEV";     Azure = "$HOME\.azure-aba-dev";     Kube = "$HOME\.kube\config-aba-dev" }
        @{ Name = "none";        Azure = $null;                      Kube = $null }
    )

    for ($i = 0; $i -lt $contexts.Count; $i++) {
        Write-Host "$($i + 1)) $($contexts[$i].Name)"
    }

    $choice = Read-Host "#?"

    if (-not ($choice -match '^\d+$') -or
        $choice -lt 1 -or
        $choice -gt $contexts.Count) {
        Write-Host "Invalid selection" -ForegroundColor Red
        return
    }

    $ctx = $contexts[$choice - 1]

    if ($ctx.Name -eq "none") {
        Remove-Item Env:AZURE_CONFIG_DIR -ErrorAction SilentlyContinue
        Remove-Item Env:KUBECONFIG -ErrorAction SilentlyContinue
        Write-Host "Azure & Kubernetes context not set"
        return
    }

    # 🔒 Isolation
    $env:AZURE_CONFIG_DIR = $ctx.Azure
    $env:KUBECONFIG = $ctx.Kube

    if (-not (Test-Path $env:KUBECONFIG)) {
        New-Item -ItemType File -Path $env:KUBECONFIG | Out-Null
    }

    # 🔐 Correct login check (EXIT CODE BASED)
    az account show --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "🔐 Azure login required – using device code" -ForegroundColor Yellow
        az login --use-device-code --only-show-errors
    }

    Write-Host "✅ Azure config: $env:AZURE_CONFIG_DIR"
    Write-Host "✅ Kube config:  $env:KUBECONFIG"
}

function freelens {
    cmd /c start "" "$env:LOCALAPPDATA\Programs\Freelens\Freelens.exe"
}

Select-AzureContext

