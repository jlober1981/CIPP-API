function Invoke-CIPPStandardTAP {
    <#
    .FUNCTIONALITY
    Internal
    #>
    param($Tenant, $Settings)
    $CurrentInfo = (New-GraphGetRequest -Uri 'https://graph.microsoft.com/beta/policies/authenticationmethodspolicy/authenticationMethodConfigurations/TemporaryAccessPass' -tenantid $Tenant)

    If ($Settings.remediate) {
        try {
            
            $CurrentInfo.state = 'enabled'
            $CurrentInfo.isUsableOnce = $Settings.config
            $CurrentInfo.minimumLifetimeInMinutes = '60'
            $CurrentInfo.maximumLifetimeInMinutes = '480'
            $CurrentInfo.defaultLifetimeInMinutes = '60'
            $CurrentInfo.defaultLength = '8'
            $body = ConvertTo-Json -Depth 10 -InputObject $CurrentInfo
            Write-Host "Sending body $body"
            New-GraphPostRequest -tenantid $tenant -Uri 'https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/TemporaryAccessPass' -Type patch -asApp $true -Body $body -ContentType 'application/json'
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Enabled Temporary Access Passwords.' -sev Info
        } catch {
            Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to enable TAP. Error: $($_.exception.message)" -sev Error
        }
    }
    if ($Settings.alert) {

        if ($CurrentInfo.state -eq 'enabled') {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Temporary Access Passwords is enabled.' -sev Info
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Temporary Access Passwords is not enabled.' -sev Alert
        }
    }
    if ($Settings.report) {
        if ($CurrentInfo.state -eq 'enabled') {
            $CurrentInfo.state = $true
        } else {
            $CurrentInfo.state = $false
        }
        Add-CIPPBPAField -FieldName 'TemporaryAccessPass' -FieldValue [bool]$CurrentInfo.state -StoreAs bool -Tenant $tenant
    }

}
