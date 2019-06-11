# MIT License
# 
# Copyright (c) 2019 Peter Malík (MalikP.)
# Repository: https://github.com/peterM/WinRM
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

param (    
    [string]$plainPwd = "pwdString",
    [string]$user = "domain\user"
)
    
$password = ConvertTo-SecureString $plainPwd -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $password)

$command1 = {
    net use '\\share.domain.local\some_folder' /user:$user $plainPwd
    Copy-Item -Path '\\share.domain.local\some_folder\Path\Microsoft.CodeAnalysis' -Recurse -Destination 'C:\Windows\Microsoft.NET\' -Container -Force
    Write-Output $env:computername | Select-Object
 }
Invoke-Command -ComputerName (Get-Content .\Machines.txt) -ScriptBlock $command1 -Credential $cred
