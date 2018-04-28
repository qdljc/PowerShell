<#
.SYNOPSIS
	添加硬盘.
.DESCRIPTION
	调整时无需重启。
.INPUTS
	同名csv/*.csv 或者 “VC VM HD_capacity” 3个参数
.EXAMPLE
    .\vm-adddisk.ps1 -vc VC                                     //无参数会找和脚本同名的 csv 文件作为输入。-vc cshj/zj/dmz/736/zsc/db 其中之一。
    .\vm-adddisk.ps1 -vc VC [-File *.csv]                       //指定同目录下的 csv 文件作为输入
    .\vm-adddisk.ps1 -vc VC [-vm VM -hd [INT]HD_capacity]       //也可以同时指定 3个参数
.LINK
    http://blog.sina.com.cn/qdljc
.NOTES
	20180411	lujc
	[+] Created
	20180411	lujc
	[+] Updated 
	20180427	Lujc
	[+] Updated 
#>


# 参数定义。L27、L29、L31、L33 这4行的变量后面不要加任何提示。否则会触发该参数组。
[CmdletBinding(DefaultParameterSetName='Filename')]
param
(
    [Parameter(ParameterSetName='Filename',Mandatory=$false)]
    [string]$File,
    [Parameter(ParameterSetName='Parameter',Mandatory=$true)]
    [Parameter(ParameterSetName='Filename',Mandatory=$true)]
    $VC,
    [Parameter(ParameterSetName='Parameter',Mandatory=$true)]
    $VM,
    [Parameter(ParameterSetName='Parameter',Mandatory=$true)]
    [INT]$HD
)

$mydata = (get-date -format "yyyyMMddHHmm")
$mypath = Get-Location
$LogFile = "$mypath/vmadddisk_log_$mydata.txt"
$ErrFile = "$mypath/vmadddisk_err_$mydata.txt"
$Errlist = "$mypath/vmadddisk_errlist_$mydata.csv"
Write-Output "=====Start:$(get-date)=====" | Tee-Object -FilePath $LogFile | Tee-Object -FilePath $ErrFile


# 参数合规判断，并整理参数，生成输入。
$mypath = Get-Location
If ( $PSCmdlet.ParameterSetName -eq "Filename") {
    If ( $file[0] -eq "." ) {
        $file = $file.Substring(1,$file.length-1)
        If ( $file[0] -eq "/" ) { $file = $file.Substring(1,$file.length-1) }
    } 
    If ( !$file ) {
        $myname = $MyInvocation.MyCommand.Name
	    $file = $myname -replace ".ps1",".csv"
    }
    If ( !(Test-Path -Path $mypath/$file) ) {
        echo "$($mypath)/$($file) 不存在！" | Tee-Object -FilePath $ErrFile
        break
    } else {
        echo "将根据 $($mypath)/$($file) 的内容进行设置。" | Tee-Object -FilePath $LogFile
        # 读取文件内容作为输入
        $vmlist = Import-CSV $mypath/$file -UseCulture -Encoding OEM
    }
} elseIf ( $PSCmdlet.ParameterSetName -eq "Parameter") {
    # If ( $VC -eq "cshj" -or $VC -eq "zj" -or $VC -eq "dmz" -or $VC -eq "736" -or $VC -eq "zsc" -or $VC -eq "db" ) {
    #     # 从 vcs.dat 中读取VC信息。
    #     If ( !(Test-Path -Path $mypath/vcs.dat) ) { echo "$($mypath)/vcs.dat 不存在！" | Tee-Object -FilePath $ErrFile ; break } else {
    #     $vcs = Import-Csv -Path $mypath/vcs.dat -UseCulture -Encoding OEM }
    #     $VIServer = $vcs | foreach {$_ | ? {$_.vc -eq $vc}}
    # } else { Write-Output "VC 不正确，请输入 cshj/zj/dmz/736/zsc/db 其中之一。" | Tee-Object -FilePath $ErrFile ; break }

    If ( $HD -le "0" ) { Write-Output "HD 必需大于0。" | Tee-Object -FilePath $ErrFile ; break }

    # 没有文件，只有单个配置，生成输入。
    $vmlist = @()
    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'vmname' -Value $vm
    $item | Add-Member -type NoteProperty -Name 'ip' -Value ''
    $item | Add-Member -type NoteProperty -Name 'disk' -Value $hd
    $vmlist += $item
}

$vcsm = @() 
    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'VC' -Value 'vc1'
    $item | Add-Member -type NoteProperty -Name 'ipaddr' -Value '1.1.1.1'
    $item | Add-Member -type NoteProperty -Name 'username' -Value '1'
    $item | Add-Member -type NoteProperty -Name 'password' -Value '1'
    $vcsm += $item
    Remove-Variable item ; $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'VC' -Value 'vc2'
    $item | Add-Member -type NoteProperty -Name 'ipaddr' -Value '2.2.2.2'
    $item | Add-Member -type NoteProperty -Name 'username' -Value '2'
    $item | Add-Member -type NoteProperty -Name 'password' -Value '2'
    $vcsm += $item
    Remove-Variable item ; $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'VC' -Value 'vc3'
    $item | Add-Member -type NoteProperty -Name 'ipaddr' -Value '3.3.3.3'
    $item | Add-Member -type NoteProperty -Name 'username' -Value '3'
    $item | Add-Member -type NoteProperty -Name 'password' -Value '3'
    $vcsm += $item
    Remove-Variable item ; $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'VC' -Value 'vc4'
    $item | Add-Member -type NoteProperty -Name 'ipaddr' -Value '4.4.4.4'
    $item | Add-Member -type NoteProperty -Name 'username' -Value '4'
    $item | Add-Member -type NoteProperty -Name 'password' -Value '4'
    $vcsm += $item
    Remove-Variable item ; $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'VC' -Value 'vc5'
    $item | Add-Member -type NoteProperty -Name 'ipaddr' -Value '5.5.5.5'
    $item | Add-Member -type NoteProperty -Name 'username' -Value '5'
    $item | Add-Member -type NoteProperty -Name 'password' -Value '5'
    $vcsm += $item
    Remove-Variable item ; $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'VC' -Value 'vc6'
    $item | Add-Member -type NoteProperty -Name 'ipaddr' -Value '6.6.6.6'
    $item | Add-Member -type NoteProperty -Name 'username' -Value '6'
    $item | Add-Member -type NoteProperty -Name 'password' -Value '6'
    $vcsm += $item
    Remove-Variable item








# Connect-VIServer
If ( $VC -eq "cshj" -or $VC -eq "zj" -or $VC -eq "dmz" -or $VC -eq "736" -or $VC -eq "zsc" -or $VC -eq "db" ) {
    # 从 vcs.dat 中读取VC信息。
    If ( !(Test-Path -Path $mypath/vcs.dat) ) { echo "$($mypath)/vcs.dat 不存在！使用脚本内部信息" | Tee-Object -FilePath $ErrFile ; $vcs = $vcsm } else {
    $vcs = Import-Csv -Path $mypath/vcs.dat -UseCulture -Encoding OEM }
    $VIServer = $vcs | foreach {$_ | ? {$_.vc -eq $vc}}
} else { Write-Output "VC 不正确，请输入 cshj/zj/dmz/736/zsc/db 其中之一。" | Tee-Object -FilePath $ErrFile ; break }

Connect-VIServer -Server $VIServer.ipaddr -username $VIServer.username -password $VIServer.password | Out-Null









function AddVMDisk ($vmlist)
{
    $vms=Get-Vm $vmlist.vmname

    ForEach ($vm in $vms){
        # # 检测存储空间是否满足磁盘需求.
        $datastore = $vm | Get-Datastore
        [INT]$DISK_free = [math]::Round($datastore.FreeSpaceGB,2)
        [INT]$DISK_need = ($vmlist | ?{$_.vmname -eq $vm.name}).disk
        
        echo "`n=====`n现在开始处理 $vm. 添加一个容量为 $DISK_need GB的磁盘。" | Tee-Object -FilePath $LogFile -Append
        echo "DataStore $datastore 上剩余磁盘 $DISK_free GB。" | Tee-Object -FilePath $LogFile -Append
        echo "DataStore $datastore 上需要磁盘 $DISK_need GB。`n" | Tee-Object -FilePath $LogFile -Append
    
        If (($DISK_free-$DISK_need) -lt 100) 	{
            Write-Output "$datastore 存储空间不能满足本次部署! 部署后的空间不足100G。 需要 $DISK_need GB，存储空间可用 $DISK_free GB." | Tee-Object -FilePath $ErrFile -Append | Tee-Object -FilePath $LogFile -Append
            $DISKOK="NO"
        }
        else {
            $DISKOK="Yes"
        }
    
        #存储空间满足需求的，并且已经成功关机的，开始设置；不满足的，保存列表，最后输出。
        If ($DISKOK -eq "Yes") 	{
            Write-Host "开始添加硬盘。。。" -ForegroundColor Green -NoNewline
            $VM | New-HardDisk -CapacityGB $DISK_need -Confirm:$false | Tee-Object -FilePath $LogFile -Append
            Write-Host "添加硬盘完毕。" -ForegroundColor Green
        }
        Else {
            $vmnoset = $vm | select @{"N"="vmname"; "E"="name"},@{"N"="Disk Now"; "E"={($_ | Get-HardDisk).CapacityGB}},@{"N"="Disk Add"; "E"={$DISK_need}}
            $vmsnoset += $vmnoset 
        }
    }
    
    
    
    If ($vmsnoset) { 
        $vmsnoset | Export-Csv -Path $Errlist -NoTypeInformation -Encoding OEM
        Write-Host "未处理清单。具体请到日志中查看。" -ForegroundColor Yellow
        $vmsnoset | Select vmname
        Write-Host "`n出现错误，未处理的机器清单: $($Errlist)，请重新整理后再次添加；" -ForegroundColor Yellow 
    }
    If (Test-Path -Path $LogFile) { Write-Host "`nProcess Log: $($LogFile)；" -ForegroundColor Yellow }
    If (Test-Path -Path $ErrFile) { Write-Host "--Error Log: $($ErrFile)。" -ForegroundColor Yellow }
    Write-Output "`n=====END:$(get-date)=====" | Tee-Object -FilePath $LogFile -Append | Tee-Object -FilePath $ErrFile -Append
    
}

AddVMDisk $vmlist


