<#	
	.NOTES
	===========================================================================
	 Created with: 	Notepad++
	 Created on:   	10/06/2018 15:39
	 Created by:   	M.JMK
	 Organization: 	
	 Filename:     	Add-Log.ps1
	 Version:		1.0
	===========================================================================
	.DESCRIPTION
		My personal log function for every Powershell script I do.
#>

function Add-Log{ #OK
<#
.SYNOPSIS
	Main log writing function
	
.DESCRIPTION
	My personal function to write in a log file
	
.EXAMPLE
	Add-Log -level "error" -message "an error occured"

.EXAMPLE
	Add-Log -Start

.EXAMPLE
	Add-Log -level "Info" -message "this is an information"
	
.PARAMETER message
	the content of the message to write in the log file

.PARAMETER level
	the level for the log (Error, Warning, Info, Success)

.PARAMETER path
	the path for the file if you want to write in another log than C:\temp\PS_log.log

.PARAMETER overwrite
	this parameter will erase the content of the file with the new inputs

.PARAMETER start
	this parameter will write some text inputs for the initialization of the log

.PARAMETER stop
	this parameter will write some text inputs for the end of the log
#>

    [CmdletBinding(DefaultParameterSetName="AddLog")]
    param (
		[Parameter(Position=0,
		Mandatory=$true,
		ParameterSetName="AddLog",
		HelpMessage='The content of the message for the log')]
		[ValidateNotNullOrEmpty()]
		[alias("log")]
		[string]$message,
		
		[Parameter(Position=1,
		Mandatory=$true,
		ParameterSetName="AddLog",
		HelpMessage='The level for the log: Error, Warning, Info or Success')]
		[ValidateNotNullOrEmpty()]
		[ValidateSet("Error","Warning","Info","Success")]
		[string]$level,
		
		[Parameter(ParameterSetName="Start")]
		[switch]$Overwrite,
		
		[Parameter(ParameterSetName="Start")]
		[alias("Begin")]
		[switch]$Start,
		
		[Parameter(ParameterSetName="Stop")]
		[alias("End")]
		[switch]$Stop,

		[string]$Path="C:\temp\PS_New-MailboxDeactivation.log"
	)
	
	Begin{
		#if the path exists and $Overwrite is specified, remove the file and create a new one
		if((Test-Path $Path -PathType "Leaf") -AND ($Overwrite)) {
			Clear-Content $Path
			Write-warning "The old log content has been removed."
		}
		#if the file doesn't already exists
		elseif(!(Test-Path $Path -PathType "Leaf")){
			Write-Verbose "Creating the $Path file."
			New-Item $Path -Force -ItemType File 
		}
	}

	Process{
		switch($PSCmdlet.ParameterSetName){
			"AddLog" { #Adding content to the log
				#Format date for the log
				$formatedDate = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
				
				#check level of information
				switch ($level){
					'Error'{
						Write-Error $message
						$levelLog = 'ERROR:'
						break
					}
					'Warning'{
						Write-Warning $message
						$levelLog = 'WARNING:'
						break		
					}
					'Info'{
						Write-Verbose $message
						$levelLog = 'INFO:'
						break
					}
					'Success'{
						$levelLog = 'SUCCESS:'
						break
					}
				}
			
				#Write in the log
				"$formatedDate : $levelLog : $message" | Out-File -FilePath $Path -Append
			}

			"Start" { #initializing the beginning of the log
					$startDate = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
					"###### BEGINNING OF THE SCRIPT #####" | Out-File -FilePath $Path -Append
					"Start date for the script: $startDate" | Out-File -FilePath $Path -Append
					"####################################" | Out-File -FilePath $Path -Append
					"####################################" | Out-File -FilePath $Path -Append
					"####################################" | Out-File -FilePath $Path -Append
					"" | Out-File -FilePath $Path -Append
					"" | Out-File -FilePath $Path -Append
			}

			"Stop" { #formating the end of the log
				#Counting number of errors
				$logContent = Get-Content $Path
				$nbErrors = (Select-String -InputObject $logContent -Pattern "ERROR" -AllMatches).Matches.Count

				#Counting number of warnings
				$nbWarnings = (Select-String -InputObject $logContent -Pattern "WARNING:" -AllMatches).Matches.Count

				#Counting number of success
				$nbSuccess = (Select-String -InputObject $logContent -Pattern "SUCCESS:" -AllMatches).Matches.Count

				$endDate = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
				
				"" | Out-File -FilePath $Path -Append
				"" | Out-File -FilePath $Path -Append
				"####################################" | Out-File -FilePath $Path -Append
				"####################################" | Out-File -FilePath $Path -Append
				"######### END OF THE SCRIPT ########" | Out-File -FilePath $Path -Append
				"End script date: $endDate" | Out-File -FilePath $Path -Append

				if($nbSuccess -gt 0){
					"Operation ran successfully on $nbSuccess objects" | Out-File -FilePath $Path -Append
				}

				if($nbErrors -gt 0){
					"Number of errors: $nbErrors" | Out-File -FilePath $Path -Append
				}
				if($nbWarnings -gt 0){
					"Number of warnings: $nbWarnings" | Out-File -FilePath $Path -Append
				}
				elseif(($nbErrors = 0) -and ($nbWarnings = 0)){
					"No errors nor warnings detected during this run." | Out-File -FilePath $Path -Append
				}
			}
		}
	}
}