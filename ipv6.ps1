# --------------- 配置区域（用户需修改以下参数） ---------------
$interfaceName = "以太网"      # 网卡名称（通过 Get-NetAdapter 查看）
$logFile = "C:\ip_logs\last_ipv6.txt"  # 记录上一次IP的文件路径
$exitLogFile = "C:\ip_logs\exit_log.txt"  # 记录退出原因的文件路径
$notificationMethod = "email"  # 推送方式：telegram / email / pushbullet

# Telegram配置（仅notificationMethod=telegram时生效）
$telegramToken = "YOUR_BOT_TOKEN"
$telegramChatID = "YOUR_CHAT_ID"

# Pushbullet配置（仅notificationMethod=pushbullet时生效）
$pushbulletToken = "YOUR_ACCESS_TOKEN"

# ---------------------- 邮件配置 ----------------------
$emailFrom = "YOUR_EMAIL_ADDRESS"    # 发件邮箱
$emailTo = "RECIPIENT_EMAIL_ADDRESS"     # 收件邮箱（如运营商短信邮箱）
$smtpServer = "SMTP_SERVER_ADDRESS"         # SMTP服务器地址
$smtpPort = 587                         # 端口（不启用SSL时通常为25，启用时为465/587）
$emailPassword = "YOUR_EMAIL_PASSWORD"             # 邮箱密码
$enableSSL = $false                     # SSL开关（根据邮箱支持性设置：$true 或 $false）


$logDirectory = Split-Path $logFile -Parent
if (-not (Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
}


if (-not (Test-Path $exitLogFile)) {
    New-Item -ItemType File -Path $exitLogFile -Force | Out-Null
}

#脚本逻辑
try {
    # 获取当前IPv6地址
    $currentIPv6 = (Get-NetIPAddress -AddressFamily IPv6 -InterfaceAlias $interfaceName | Where-Object {
        $_.PrefixOrigin -eq 'RouterAdvertisement' -and $_.SuffixOrigin -eq 'Link'
    }).IPAddress

    
    if (-not $currentIPv6) {
        $exitReason = "未获取到IPv6地址，脚本退出。"
        $exitReason | Out-File $exitLogFile -Append
        exit
    }

    
    $lastIPv6 = $null
    if (Test-Path $logFile) {
        $lastIPv6 = Get-Content $logFile -ErrorAction SilentlyContinue
    }

    
    if ($currentIPv6 -ne $lastIPv6) {
        
        $notificationSuccess = $false
        switch ($notificationMethod) {
            "email" {
                try {
                    # 临时忽略证书验证
                    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
                    
                    $securePassword = ConvertTo-SecureString $emailPassword -AsPlainText -Force
                    $credential = New-Object System.Management.Automation.PSCredential ($emailFrom, $securePassword)
                    
                    
                    $encoding = [System.Text.Encoding]::UTF8
                    
                    Send-MailMessage -From $emailFrom -To $emailTo -Subject "IPv6地址更新通知" -Body "新地址：$currentIPv6" `
                        -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $credential -Encoding $encoding -ErrorAction Stop
                    $notificationSuccess = $true
                } catch {
                    $exitReason = "邮件发送失败：$_"
                    $exitReason | Out-File $exitLogFile -Append
                } finally {
                    # 恢复证书验证
                    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
                }
                
                # 记录通知结果
                if ($notificationSuccess) {
                    $logMessage = "IPv6地址已更新为：$currentIPv6，通知已通过email成功发送。"
                    $logMessage | Out-File $exitLogFile -Append
                } else {
                    $logMessage = "IPv6地址已更新为：$currentIPv6，但通知通过email发送失败。"
                    $logMessage | Out-File $exitLogFile -Append
                }
            }
            "telegram" {
                try {
                    $message = "IPv6地址已更新为：$currentIPv6"
                    $apiUrl = "https://api.telegram.org/bot$telegramToken/sendMessage"
                    $parameters = @{
                        chat_id = $telegramChatID
                        text = $message
                    }
                    Invoke-RestMethod -Uri $apiUrl -Method Post -Body $parameters
                    $notificationSuccess = $true
                } catch {
                    $exitReason = "Telegram消息发送失败：$_"
                    $exitReason | Out-File $exitLogFile -Append
                }
                
                
                if ($notificationSuccess) {
                    $logMessage = "IPv6地址已更新为：$currentIPv6，通知已通过telegram成功发送。"
                    $logMessage | Out-File $exitLogFile -Append
                } else {
                    $logMessage = "IPv6地址已更新为：$currentIPv6，但通知通过telegram发送失败。"
                    $logMessage | Out-File $exitLogFile -Append
                }
            }
            "pushbullet" {
                try {
                    $message = "IPv6地址已更新为：$currentIPv6"
                    $apiUrl = "https://api.pushbullet.com/v2/pushes"
                    $headers = @{
                        "Access-Token" = $pushbulletToken
                        "Content-Type" = "application/json"
                    }
                    $body = @{
                        type = "note"
                        title = "IPv6地址更新通知"
                        body = $message
                    } | ConvertTo-Json
                    Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
                    $notificationSuccess = $true
                } catch {
                    $exitReason = "Pushbullet消息发送失败：$_"
                    $exitReason | Out-File $exitLogFile -Append
                }
                
                
                if ($notificationSuccess) {
                    $logMessage = "IPv6地址已更新为：$currentIPv6，通知已通过pushbullet成功发送。"
                    $logMessage | Out-File $exitLogFile -Append
                } else {
                    $logMessage = "IPv6地址已更新为：$currentIPv6，但通知通过pushbullet发送失败。"
                    $logMessage | Out-File $exitLogFile -Append
                }
            }
            default {
                $exitReason = "未知的通知方式：$notificationMethod"
                $exitReason | Out-File $exitLogFile -Append
                $logMessage = "IPv6地址已更新为：$currentIPv6，但通知方式未知，无法发送。"
                $logMessage | Out-File $exitLogFile -Append
            }
        }

        # 记录新地址到文件
        $currentIPv6 | Out-File $logFile -Force
    } else {
        #IPv6地址未变化
        $logMessage = "IPv6地址未发生变化，当前地址：$currentIPv6。"
        $logMessage | Out-File $exitLogFile -Append
    }
} catch {
    $exitReason = "脚本运行时发生错误：$_"
    $exitReason | Out-File $exitLogFile -Append
    exit
}
