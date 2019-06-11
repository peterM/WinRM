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
    
$command = {
    $path = 'C:\WinRM'
    $build2017Path = "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools"
    $build2019Path = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools"
    $installerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
    $shareRoot = "\\share.domain.local\some_folder"
    $vsConfig = "\\share.domain.local\some_folder\PathToFile\.vsconfig"

    If (!(test-path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }

    $pc = $env:computername

    net use $shareRoot /user:$user $plainPwd
    Copy-Item -Path $vsConfig -Recurse -Destination 'C:\WinRM\.vsconfig' -Container -Force
    Write-host "["$pc" ] =>>" "File '.vsconfig' written" -ForegroundColor Green

    Invoke-webrequest -uri 'https://aka.ms/vs/15/release/vs_buildtools.exe' -OutFile 'C:\WinRM\vs_buildtools2017.exe'
    Write-host "["$pc" ] =>>" "File 'vs_buildtools2017' written" -ForegroundColor Green

    Invoke-webrequest -uri 'https://aka.ms/vs/16/release/vs_buildtools.exe' -OutFile 'C:\WinRM\vs_buildtools2019.exe'
    Write-host "["$pc" ] =>>" "File 'vs_buildtools2019' written" -ForegroundColor Green

    Write-host "["$pc" ] =>>" "Build Tools ->  'vs_buildtools2019' -> Installing" -ForegroundColor Magenta
    $exitCode = Start-Process 'C:\WinRM\vs_buildtools2019.exe' -ArgumentList "--config", "C:\WinRM\.vsconfig", "--quiet", "--norestart", "--wait" -Wait -PassThru
    # Write-host $exitCode | Select-Object
    Write-host "["$pc" ] =>>" "Build Tools ->  'vs_buildtools2019' -> installed" -ForegroundColor Green

    Write-host "["$pc" ] =>>" "Build Tools ->  'vs_buildtools2017' -> Updating" -ForegroundColor Magenta
    $exitCode = Start-Process 'C:\WinRM\vs_buildtools2017.exe' -ArgumentList "update", "--quiet", "--norestart", "--wait" -Wait -PassThru
    # Write-host $exitCode | Select-Object
    Write-host "["$pc" ] =>>" "Build Tools ->  'vs_buildtools2017' -> updated" -ForegroundColor Green

    Write-host "["$pc" ] =>>" "Build Tools ->  'vs_buildtools2019' -> Updating" -ForegroundColor Magenta
    $exitCode = Start-Process 'C:\WinRM\vs_buildtools2019.exe' -ArgumentList "update", "--quiet", "--norestart", "--wait" -Wait -PassThru
    # Write-host $exitCode | Select-Object
    Write-host "["$pc" ] =>>" "Build Tools ->  'vs_buildtools2019' -> updated" -ForegroundColor Green

    Write-host "["$pc" ] =>>" "Build Tools 2017->  Update packages -> Updating" -ForegroundColor Magenta
    $exitCode = Start-Process $installerPath -ArgumentList "modify", "--installPath", $build2017Path, "--add", "Microsoft.VisualStudio.Component.NuGet.BuildTools", "--add", "Microsoft.Net.Component.4.5.TargetingPack", "--quiet", "--norestart", "--wait", "--force" -Wait -PassThru
    Write-host "["$pc" ] =>>" "Build Tools 2017->  Update packages -> Updated" -ForegroundColor Green

    Write-host "["$pc" ] =>>" "Build Tools 2019->  Update packages -> Updating" -ForegroundColor Magenta
    $exitCode = Start-Process $installerPath -ArgumentList "modify", "--installPath", $build2019Path, "--add", "Microsoft.VisualStudio.Component.NuGet.BuildTools", "--add", "Microsoft.Net.Component.4.5.TargetingPack", "--quiet", "--norestart", "--wait", "--force" -Wait -PassThru
    Write-host "["$pc" ] =>>" "Build Tools 2019->  Update packages -> Updated" -ForegroundColor Green

    Write-host "["$pc" ] =>>" "<<= *** Done --> Restarting *** =>>" -ForegroundColor Green
    Restart-Computer -ComputerName $pc -Force
}

Invoke-Command -ComputerName (Get-Content .\Machines.txt) -ScriptBlock $command -Credential $cred
#  Invoke-Command -ComputerName '001-VRT-TCA040' -ScriptBlock $command -Credential $cred