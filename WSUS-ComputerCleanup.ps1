[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
$wsusserver=@"
"labtest0sccm",$false,8530
"@
Write-Host Using Wsus server $wsusserver
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($wsusserver)
$LogFile='c:\temp\WSUSCompAdd.log' 

#Delete aged log files
Remove-Item 'c:\temp\WSUSCompAdd.log' -ErrorAction SilentlyContinue

#Get Computers
Write-Host "Provide Hostnames that are going to be removed"
Start-Process Notepad.exe "$env:TEMP\computers.txt" -Wait
$computers= get-content("$env:TEMP\computers.txt") -ErrorAction SilentlyContinue
if(![string]::IsNullOrEmpty($computers)){
            $i=0;
            $computers | foreach-object {
                        "------------------WSUS Maintenance-------------------------"

                        Write-Host "Processing Computer "($_)" ; $i out of $($computers.count)" -ForegroundColor Green

                        "Processing Computer ($_) ; $i out of $($computers.count) " | Out-File -FilePath $LogFile -Append -Force -ErrorAction SilentlyContinue

                        Write-Host "Searching computer in WSUS Database" -ForegroundColor Green
                        "Searching Computer ($_) WSUS DB " | Out-File -FilePath $LogFile -Append -Force -ErrorAction SilentlyContinue
                        $Client = $wsus.SearchComputerTargets("$_")





                        if(![string]::IsNullOrEmpty($Client)){
                                        Write-Host "Found computer in WSUS DB" -ForegroundColor Green
                                        "Found computer in WSUS DB; performing delete operation" | Out-File -FilePath $LogFile -Append -Force -ErrorAction SilentlyContinue
                                        #Define WSUS group Name

                                        $Client[0].Delete()

                                        $_
                                        $validate=$true
                        }else{

                            Write-Host "$_ Computer object not found in WSUS DB hence, do nothing"  -ForegroundColor Yellow
                            "Computer object not found in WSUS DB hence, do nothing" | Out-File -FilePath $LogFile -Append -Force -ErrorAction SilentlyContinue
                            $validate=$false
                        }
                        #Validation
                        Write-Host "Performing validation operation for $($_)" -ForegroundColor Green
                        "Performing validation operation for $($_)" | Out-File -FilePath $LogFile -Append -Force -ErrorAction SilentlyContinue
                        $Client = $wsus.SearchComputerTargets("$_")
                        if([string]::IsNullOrEmpty($Client) -and $validate -ne $false){

                                                Write-Host "$($_) has been successfully deleted" -ForegroundColor Green
                                                "$($_) has been successfully deleted" | Out-File -FilePath $LogFile -Append -Force -ErrorAction SilentlyContinue

                        }else{

                            Write-Host "Failed to delete object $($_), please verify computer object is available in WSUS database" -ForegroundColor Red
                            "Failed to delete object $($_), please verify computer object is available in WSUS database" | Out-File -FilePath $LogFile -Append -Force -ErrorAction SilentlyContinue

                        }

                        $i++
                        } 

            }Else{

                    Write-Host "No computers are found, please verify computer objects are available in text file 'c:\temp\comp.txt' " -ForegroundColor Yellow

}

Read-Host "Press Enter to exit"


