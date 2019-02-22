﻿---
external help file: d365fo.tools-help.xml
Module Name: d365fo.tools
online version:
schema: 2.0.0
---

# Export-D365Model

## SYNOPSIS
Export a model from Dynamics 365 for Finance & Operations

## SYNTAX

```
Export-D365Model [-Path] <String> [-Model] <String> [[-BinDir] <String>] [[-MetaDataDir] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Export a model from a Dynamics 365 for Finance & Operations environment

## EXAMPLES

### EXAMPLE 1
```
Export-D365Model -Path c:\temp\d365fo.tools -Model CustomModelName
```

This will export the "CustomModelName" model from the default PackagesLocalDirectory path.
It export the model to the "c:\temp\d365fo.tools" location.

## PARAMETERS

### -Path
Path to the folder where you want to save the model file

```yaml
Type: String
Parameter Sets: (All)
Aliases: File

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Model
Name of the model that you want to work against

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BinDir
The path to the bin directory for the environment

Default path is the same as the AOS service PackagesLocalDirectory\bin

Default value is fetched from the current configuration on the machine

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: "$Script:PackageDirectory\bin"
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetaDataDir
The path to the meta data directory for the environment

Default path is the same as the aos service PackagesLocalDirectory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: "$Script:MetaDataDir"
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Tags: ModelUtil, Axmodel, Model, Export

Author: Mötz Jensen (@Splaxi)

## RELATED LINKS