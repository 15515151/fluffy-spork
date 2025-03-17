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

  
   # 配置区域
   ```powershell
   $interfaceName = "以太网"          # 通过 Get-NetAdapter 查询的网卡名称
   $logFile = "C:\ip_logs\last_ipv6.txt"   # 地址记录文件路径
   $exitLogFile = "C:\ip_logs\exit_log.txt" # 运行日志路径
   $notificationMethod = "email"          # 通知方式：telegram / email / pushbullet
   ```
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


 **计划任务（ai生成）**  
   创建每小时运行的计划任务：
    以下是使用Windows任务计划程序创建定时任务的详细图文指南：

---

### **📅 创建计划任务步骤详解**
> 以Windows 11为例，其他版本路径可能略有不同

#### **第一步：打开任务计划程序**
1. 按下 `Win + S` 打开搜索
2. 输入 `任务计划程序` 
3. 选择顶部匹配结果进入程序
---

#### **第二步：创建基本任务**
1. 右侧操作栏选择 **"创建基本任务"**
2. 输入名称（例：`IPv6监控任务`）
3. 添加描述（可选）：`每小时检测IPv6地址变化`
4. 点击 **"下一步"**
---

#### **第三步：配置触发器**
1. 选择 **"每天"**（实际会通过重复间隔控制）
2. 点击 **"下一步"**
3. 设置开始时间（建议设为当前时间+5分钟）
4. 勾选 **"每天每隔 1 小时重复一次"**
5. 持续时间选择 **"无限期"**
6. 点击 **"下一步"**
---

#### **第四步：配置操作**
1. 选择 **"启动程序"** → **"下一步"**
2. 程序或脚本栏输入：
   ```powershell
   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
   ```
3. 添加参数栏输入：
   ```powershell
   -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\你的路径\ipv6_monitor.ps1"
   ```
   （请替换实际脚本路径）
4. 点击 **"下一步"**

> 🔔 参数说明：
> - `-ExecutionPolicy Bypass`：绕过执行策略限制
> - `-WindowStyle Hidden`：隐藏运行窗口
---

#### **第五步：高级配置**
1. 勾选 **"当单击完成时..."** → 点击 **"完成"**
2. 在任务列表中找到新建的任务
3. 右键选择 **"属性"** 进行高级设置：

**▶ 常规选项卡：**
- 勾选 **"不管用户是否登录都要运行"**
- 勾选 **"使用最高权限运行"**
- 配置为：`Windows 10`（兼容性更好）

**▶ 条件选项卡：**
- 取消勾选 **"只有在计算机使用交流电源时才启动此任务"**
- 取消勾选 **"只有在以下网络连接可用时才启动"**

**▶ 设置选项卡：**
- 勾选 **"如果任务失败，按以下频率重新启动"**
- 设置：每`15分钟`尝试，最多`3次`次重试

---

#### **第六步：测试任务**
1. 右键任务 → 选择 **"运行"**
2. 检查：
   - 查看`上次运行结果`是否显示`操作已成功完成`
   - 检查脚本生成的日志文件 `C:\ip_logs\exit_log.txt`
3. 等待1小时后验证自动运行

---

### **❗ 常见问题排查**
1. **错误代码 0x41301**  
   - 解决方法：在任务属性的"常规"选项卡中选择"只在用户登录时运行"

2. **脚本路径错误**  
   - 验证-Path参数中的脚本路径是否包含空格（如有空格需用双引号包裹）

3. **权限不足**  
   - 确保勾选了"使用最高权限运行"
   - 以管理员身份运行任务计划程序

4. **执行策略限制**  
   - 手动运行一次：`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

---

通过以上配置，您的IPv6监控脚本将会每小时自动运行一次，并在地址变化时发送通知。建议首次配置完成后观察24小时运行日志确保稳定性。

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
