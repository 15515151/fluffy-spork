# IPv6 地址变化监控与通知脚本

📢 一个基于 PowerShell 的 IPv6 地址监控脚本，当检测到公网 IPv6 地址变化时，通过邮件/Telegram/Pushbullet 发送通知。

## 主要功能

✅ 实时监测指定网络接口的 IPv6 地址变化  
✅ 支持三种通知方式（邮件/Telegram/Pushbullet）  
✅ 自动记录最后有效的 IPv6 地址  
✅ 详细的运行日志记录  
✅ 错误处理与退出原因追踪  

## 使用前准备

1. **系统要求**
   - Windows 系统（已测试 Win10/Win11）
   - PowerShell 5.1 或更高版本

2. **网络要求**
   - 已配置 IPv6 网络环境
   - 出站端口开放（根据通知方式）：
     - 邮件：SMTP 端口（25/465/587）
     - Telegram：443
     - Pushbullet：443

## 配置说明

1. **基础配置**  
   用文本编辑器打开脚本，修改以下参数：

   ```powershell
   # --------------- 配置区域 ---------------
   $interfaceName = "以太网"          # 通过 Get-NetAdapter 查询的网卡名称
   $logFile = "C:\ip_logs\last_ipv6.txt"   # 地址记录文件路径
   $exitLogFile = "C:\ip_logs\exit_log.txt" # 运行日志路径
   $notificationMethod = "email"          # 通知方式：telegram / email / pushbullet
   2. **通知方式配置**  
   根据选择的通知方式配置对应参数：

   - 📧 **邮件通知**  
     ```powershell
     $emailFrom = "sender@example.com"    # 发件邮箱
     $emailTo = "receiver@example.com"    # 收件邮箱
     $smtpServer = "smtp.example.com"     # SMTP服务器
     $smtpPort = 587                      # 端口号
     $emailPassword = "your_password"     # 邮箱密码
     $enableSSL = $true                   # SSL加密
     ```

   - ✈️ **Telegram 通知**  
     [如何获取Token](https://core.telegram.org/bots#6-botfather)  
     ```powershell
     $telegramToken = "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
     $telegramChatID = "@your_channel_name"
     ```

   - 📱 **Pushbullet 通知**  
     [获取Access Token](https://www.pushbullet.com/#settings/account)  
     ```powershell
     $pushbulletToken = "o.123456ABCDEF123456abcdef12345678"
     ```

## 使用方法


. **计划任务**  
   创建每小时运行的计划任务：
    打开搜索 搜索任务计划程序 创建任务

## 日志文件说明

- `last_ipv6.txt`  
  记录最新检测到的有效 IPv6 地址

- `exit_log.txt`  
  记录脚本运行状态，包含以下信息：
  ```
  [时间] IPv6地址已更新为：240e:3b4:109e:cf00::1，通知已通过email成功发送。
  [时间] IPv6地址未发生变化，当前地址：240e:3b4:109e:cf00::1。
  [时间] 邮件发送失败：SMTP服务器连接超时
  ```

## 注意事项

1. **接口名称验证**  
   通过以下命令获取准确的网卡名称：
   ```powershell
   Get-NetAdapter | Select-Object Name, InterfaceDescription
   ```

2. **IPv6有效性验证**  
   确保获取的是公网 IPv6 地址（通常以 2xxx:/3xxx: 开头）

3. **邮件发送问题**  
   - 部分邮箱需要开启「SMTP服务授权」
   - Gmail 建议使用 App Password
   - 阿里/腾讯云服务器可能需要申请解封25端口
