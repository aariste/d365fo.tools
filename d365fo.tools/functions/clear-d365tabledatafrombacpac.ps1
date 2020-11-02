﻿
<#
    .SYNOPSIS
        Clear out data for a table inside the bacpac file
        
    .DESCRIPTION
        Remove all data for a table inside a bacpac file, before restoring it into your SQL Server / Azure SQL DB
        
        It will extract the bacpac file as a zip archive, locate the desired table and remove the data that otherwise would have been loaded
        
        It will re-zip / compress a new bacpac file for you
        
    .PARAMETER Path
        Path to the bacpac file that you want to work against
        
        It can also be a zip file
        
    .PARAMETER TableName
        Name of the table that you want to delete the data for
        
        Supports an array of table names
        
        If a schema name isn't supplied as part of the table name, the cmdlet will prefix it with "dbo."
        
    .PARAMETER OutputPath
        Path to where you want the updated bacpac file to be saved
        
    .EXAMPLE
        PS C:\> Clear-D365TableDataFromBacpac -Path "C:\Temp\AxDB.bacpac" -TableName "BATCHJOBHISTORY" -OutputPath "C:\Temp\AXBD_Cleaned.bacpac"
        
        This will remove the data from the BatchJobHistory table from inside the bacpac file.
        
        It uses "C:\Temp\AxDB.bacpac" as the Path for the bacpac file.
        It uses "BATCHJOBHISTORY" as the TableName to delete data from.
        It uses "C:\Temp\AXBD_Cleaned.bacpac" as the OutputPath to where it will store the updated bacpac file.
        
    .EXAMPLE
        PS C:\> Clear-D365TableDataFromBacpac -Path "C:\Temp\AxDB.bacpac" -TableName "dbo.BATCHHISTORY","BATCHJOBHISTORY" -OutputPath "C:\Temp\AXBD_Cleaned.bacpac"
        
        This will remove the data from the BatchJobHistory table from inside the bacpac file.
        
        It uses "C:\Temp\AxDB.bacpac" as the Path for the bacpac file.
        It uses "dbo.BATCHHISTORY","BATCHJOBHISTORY" as the TableName to delete data from.
        It uses "C:\Temp\AXBD_Cleaned.bacpac" as the OutputPath to where it will store the updated bacpac file.
        
    .NOTES
        Tags: Bacpac, Servicing, Data, Deletion, SqlPackage
        
        Author: Mötz Jensen (@Splaxi)
        
#>

function Clear-D365TableDataFromBacpac {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('File')]
        [Alias('BacpacFile')]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string[]] $TableName,

        [string] $OutputPath,

        [switch] $ClearFromSource
    )
    
    begin {
        if (-not (Test-PathExists -Path $Path -Type Leaf)) { return }

        $compressPath = ""
        $newFilename = ""

        if ($ClearFromSource) {
            $compressPath = $Path.Replace(".bacpac", ".zip")
            $newFilename = Split-Path -Path $compressPath -Leaf

            Write-PSFMessage -Level Verbose -Message "Renaming the file '$Path' to '$compressPath'."
            Rename-Item -Path $Path -NewName $newFilename

            $newFilename = $newFilename.Replace(".zip", ".bacpac")
        }
        else {
            if ($OutputPath -like "*.bacpac") {
                $compressPath = $OutputPath.Replace(".bacpac", ".zip")
                $newFilename = Split-Path -Path $OutputPath -Leaf
            }
            else {
                $compressPath = $OutputPath
            }

            if (-not (Test-PathExists -Path $compressPath -Type Leaf -ShouldNotExist)) {
                Write-PSFMessage -Level Host -Message "The <c='em'>$compressPath</c> already exists. Consider changing the <c='em'>OutputPath</c> or <c='em'>delete</c> the <c='em'>$compressPath</c> file."
                return
            }

            if (-not (Test-PathExists -Path $OutputPath -Type Leaf -ShouldNotExist)) {
                Write-PSFMessage -Level Host -Message "The <c='em'>$OutputPath</c> already exists. Consider changing the <c='em'>OutputPath</c> or <c='em'>delete</c> the <c='em'>$OutputPath</c> file."
                return
            }

            Write-PSFMessage -Level Verbose -Message "Copying the file from '$Path' to '$compressPath'"
            Copy-Item -Path $Path -Destination $compressPath
            Write-PSFMessage -Level Verbose -Message "Copying was completed."

            if (Test-PSFFunctionInterrupt) { return }
        }

        Write-PSFMessage -Level Verbose -Message "Opening the file '$Path'."
        $zipFileMetadata = [System.IO.Compression.ZipFile]::Open($compressPath, [System.IO.Compression.ZipArchiveMode]::Update)
        Write-PSFMessage -Level Verbose -Message "File '$Path' was read succesfully."

        if ($null -eq $zipFileMetadata) {
            $messageString = "Unable to open the file <c='em'>$compressPath</c>."
            Write-PSFMessage -Level Host -Message $messageString
            Stop-PSFFunction -Message "Stopping because the file couldn't be opened." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', '')))
            return
        }
    }
    
    process {
        if (Test-PSFFunctionInterrupt) { return }
        
        foreach ($table in $TableName) {
            $fullTableName = ""

            if (-not ($table -like "*.*")) {
                $fullTableName = "dbo.$table"
            }
            else {
                $fullTableName = $table
            }

            Write-PSFMessage -Level Verbose -Message "Looking for $fullTableName."

            $entries = $zipFileMetadata.Entries | Where-Object Fullname -like "Data/*$fullTableName*"

            if ($entries.Count -lt 1) {
                Write-PSFMessage -Level Warning -Message "The $table wasn't found. Please ensure that the schema or name is correct."
            }
            else {
                for ($i = 0; $i -lt $entries.Count; $i++) {
                    Write-PSFMessage -Level Verbose -Message "Removing $($entries[$i]) from the file."

                    $entries[$i].delete()
                }
            }
        }
    }
    
    end {
        Write-PSFMessage -Level Verbose -Message "Search completed."

        $res = @{ }

        if ($null -ne $zipFileMetadata) {
            Write-PSFMessage -Level Verbose -Message "Closing and saving the file."
            $zipFileMetadata.Dispose()
        }
        
        if (Test-PSFFunctionInterrupt) { return }

        if ($newFilename -ne "") {
            Rename-Item -Path $compressPath -NewName $newFilename
            $res.File = Join-path -Path $(Split-Path -Path $compressPath -Parent) -ChildPath $newFilename
            $res.Filename = $newFilename
        }
        else {
            $res.File = $compressPath
            $res.Filename = $(Split-Path -Path $compressPath -Leaf)
        }

        [PSCustomObject]$res
    }
}