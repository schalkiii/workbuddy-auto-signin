<#
.SYNOPSIS
    Send the WorkBuddy check-in result to a Feishu (Lark) group bot webhook.
.DESCRIPTION
    Reads the JSON log produced by signin.py, extracts the human-readable
    "report" field, and posts it as a text message to the given webhook.
    Notification failures are non-fatal (only a warning is printed).
.PARAMETER Webhook
    Feishu bot webhook URL (https://open.feishu.cn/open-apis/bot/v2/hook/xxxx).
.PARAMETER LogPath
    Path to the signin.py output log file.
#>
param(
    [Parameter(Mandatory = $true)][string]$Webhook,
    [Parameter(Mandatory = $true)][string]$LogPath
)

$text = ""
if (Test-Path $LogPath) {
    $raw = Get-Content -Raw -Encoding UTF8 $LogPath
    if ($raw) {
        try {
            $obj = $raw | ConvertFrom-Json
            $text = $obj.report
            if (-not $text) { $text = $raw.Trim() }
        }
        catch {
            $text = $raw.Trim()
        }
    }
}
if (-not $text) { $text = "(无输出)" }

$payload = @{
    msg_type = "text"
    content  = @{ text = "WorkBuddy 签到：$text" }
} | ConvertTo-Json -Compress

try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
    Invoke-RestMethod -Uri $Webhook -Method Post `
        -ContentType "application/json; charset=utf-8" -Body $bytes | Out-Null
    Write-Host "[OK] Feishu notification sent"
}
catch {
    Write-Host "[WARN] Feishu notification failed: $_"
}
