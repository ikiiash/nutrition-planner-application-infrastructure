# =============================================================================
# stop-student-infra.ps1
# Automaticke vypnutie AKS clustrov a PostgreSQL serverov pre studentov FSA
# Spusta sa denne o 22:00 CEST cez Azure Automation
# =============================================================================

# Zabrani reusovaniu expirovaného kontextu z predchadzajuceho behu
Disable-AzContextAutosave -Scope Process

# Prihlasenie cez Managed Identity Automation Accountu
Connect-AzAccount -Identity

$prefixes = @(${join(", ", [for p in student_prefixes : "\"${p}\""])})

foreach ($prefix in $prefixes) {
    $rg   = "rg-fsa-$prefix"
    $aks  = "aks-fsa-$prefix"
    $psql = "psql-fsa-$prefix"

    Write-Output ">>> [$prefix] Zacinam vypinanie..."

    # --- AKS ---
    try {
        $aksCluster = Get-AzAksCluster -ResourceGroupName $rg -Name $aks -ErrorAction Stop
        if ($aksCluster.PowerState.Code -ne "Stopped") {
            Write-Output "    AKS: zastavujem $aks"
            Stop-AzAksCluster -ResourceGroupName $rg -Name $aks -NoWait
        } else {
            Write-Output "    AKS: uz je zastaveny"
        }
    } catch {
        Write-Warning "    AKS: chyba pri zastavovani $aks - $_"
    }

    # --- PSQL ---
    try {
        $psqlServer = Get-AzPostgreSqlFlexibleServer -ResourceGroupName $rg -Name $psql -ErrorAction Stop
        if ($psqlServer.State -ne "Stopped") {
            Write-Output "    PSQL: zastavujem $psql"
            Stop-AzPostgreSqlFlexibleServer -ResourceGroupName $rg -Name $psql
        } else {
            Write-Output "    PSQL: uz je zastaveny"
        }
    } catch {
        Write-Warning "    PSQL: chyba pri zastavovani $psql - $_"
    }

    Write-Output ">>> [$prefix] Hotovo"
}

Write-Output "=== Vsetky studentske resources zastavene ==="
