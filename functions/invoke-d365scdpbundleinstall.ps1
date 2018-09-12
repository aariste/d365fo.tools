<#
.SYNOPSIS
Invoke the SCDPBundleInstall.exe file

.DESCRIPTION
A cmdlet that wraps some of the cumbersome work into a streamlined process 

.PARAMETER Path
Path to the update package that you want to install into the environment

The cmdlet only supports an already extracted ".axscdppkg" file

.PARAMETER MetaDataDir
The path to the meta data directory for the environment 

Default path is the same as the aos service packageslocaldirectory 

.PARAMETER InstallOnly
Switch to instruct the cmdlet to only run the Install option and ignore any TFS / VSTS folders
and source control in general

Use it when testing an update on a local development machine (VM) / onebox

.EXAMPLE
Invoke-D365SCDPBundleInstall -Path "c:\temp\HotfixPackageBundle.axscdppkg"

This will install the "HotfixPackageBundle.axscdppkg" into the default 
PackagesLocalDirectory location on the machine

.NOTES
Author: Mötz Jensen (@splaxi)
#>
function Invoke-D365SCDPBundleInstall {
    [CmdletBinding(DefaultParameterSetName = 'InstallOnly')]
    param (
        [Parameter(Mandatory = $True, ParameterSetName = 'InstallOnly', Position = 0 )]
        [switch] $InstallOnly,

        [Parameter(Mandatory = $true, ParameterSetName = 'Tfs', Position = 0 )]
        [ValidateSet('Prepare', 'Install')]
        [string] $Command = 'Prepare',

        [Parameter(Mandatory = $True, Position = 1 )]
        [Alias('Hotfix')]
        [Alias('File')]
        [string] $Path,

        [Parameter(Mandatory = $false, Position = 2 )]
        [string] $MetaDataDir = "$Script:MetaDataDir",

        [Parameter(Mandatory = $false, ParameterSetName = 'Tfs', Position = 3 )]
        [string] $TfsWorkspaceDir = "$Script:MetaDataDir",

        [Parameter(Mandatory = $false, ParameterSetName = 'Tfs', Position = 4 )]
        [string] $TfsUri = "$Script:TfsUri",

        [Parameter(Mandatory = $false, Position = 4 )]
        [switch] $ShowModifiedFiles

    )
    
    Invoke-TimeSignal -Start
    $StartTime = Get-Date
    $executable = Join-Path $Script:BinDir "\bin\SCDPBundleInstall.exe"

    if (!(Test-PathExists -Path $Path,$executable -Type Leaf)) {return}
    if (!(Test-PathExists -Path $MetaDataDir -Type Container)) {return}
    
    if ($InstallOnly.IsPresent) {
        $param = @("-install", 
        "-packagepath=$Path", 
        "-metadatastorepath=$MetaDataDir")
    }
    else{
        switch($Command){
            "Prepare" {
                $param = @("-prepare")
            }
            "Install"{
                $param = @("-install")
            }
        }
        $param = $param + @("-packagepath=`"$Path`"",
                            "-metadatastorepath=`"$MetaDataDir`"",
                            "-tfsworkspacepath=`"$TfsWorkspaceDir`"",
                            "-tfsprojecturi=`"$TfsUri`"")
    }

    Write-PSFMessage -Level Verbose -Message "Invoking SCDPBundleInstall.exe" -Target $param
    Start-Process -FilePath $executable -ArgumentList $param -NoNewWindow -Wait
    
    if ($ShowModifiedFiles.IsPresent) {
        $res = Get-ChildItem -Path $MetaDataDir -Recurse | Where-Object {$_.LastWriteTime -gt $StartTime}

        $res | ForEach-Object {
            Write-PSFMessage -Level Verbose -Message "Object modified by the install: $($_.FullName)"
        }

        $res
    }

    Invoke-TimeSignal -End
}