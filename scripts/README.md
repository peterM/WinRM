# <center>Windows Remote Management (WinRM)</center>

### **To enable WinRM use:**

> `winrm quickconfig`

### **To crreate WinRM session**
 At first you need create credential object

> `$password = ConvertTo-SecureString "{your password}" -AsPlainText -Force`

Once you have password you can create credential:

> `$cred= New-Object System.Management.Automation.PSCredential ("domain\username", $password )`

Once you have credential object you can create WinRM session:

> `$session = New-PSSession –ComputerName {Computer-name} –Credential $cred`

Once you have created WinRM session you can enter it

> `Enter-PSSession $session`
> `Enter-PSSession –ComputerName {Computer-name} –Credential $cred`

Once you enter WinRm session you can write commands like: 
- get windows service: `Get-Service`
- get windows service with specific name: `Get-Service -DisplayName "Windows Management Instrumentation"`
- get windows service and restart it: `Get-Service -DisplayName "Windows Management Instrumentation" -computername | Restart-Service`

### **To close session you can use:**
> `Exit-PSSession`

Or if you want to get session and close them all
> `Get-PSSession | Remove-PSSession` 

### **When we searching in name or display name we can use wildcards like `*`**
> ` .....  -DisplayName "Windows*"`
