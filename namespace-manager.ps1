<# The purpose of this script is to create or modify namespace entries

Supply a CSV file with the following headers

    Action = 
        Create = A new namespace entry to be created
        Modify = Change an existing entry
    Path = Namespace path '\\<domain>.com\<foldername>\<foldername>'
    SharePath = Share path '\\<servername>\<sharename>\<foldername>'
    State = Offline / Online
    ReferralPriorityClass =
        GlobalHigh - The highest priority class for a DFS target. Targets assigned this class receive global preference.
        SiteCostHigh - The highest site cost priority class for a DFS target. Targets assigned this class receive the most preference among targets of the same site cost for a given DFS client.
        SiteCostNormal - The middle or normal site cost priority class for a DFS target.
        SiteCostLow - The lowest site cost priority class for a DFS target. Targets assigned this class receive the least preference among targets of the same site cost for a given DFS client.
        GlobalLow - The lowest level of priority class for a DFS target. Targets assigned this class receive the least preference globally.
#>

# Functions

    # Prompt the user to select the CSV file for the script
    Function Get-FileName($initialDirectory){
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.InitialDirectory = $initialDirectory
        $OpenFileDialog.Filter = "CSV (*.csv) | *.csv"
        $OpenFileDialog.Title = "Select ADD NAMESPACE CSV"
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.FileName
    }

# Variables

    # Getting the desktop path of the user launching the script. Just as a default starting path
    $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

    # Calling function to obtain file and path info from user
    $FilePath  = Get-FileName -initialDirectory $DesktopPath

    # Create array for data
    $csv      = @()

    # Import file into array
    $csv      = Import-Csv -Path $FilePath 

    # Set loop value
    $i = 0
    
# Doing the work

    ForEach ($item In $csv) 
    {
        # Increasing loop value
        $i = $i+1
        
        # Put the objects into string variables, because new-dfsnfoldertarget likes strings
        [string]$action = $item.action
        [string]$Path = $item.Path
        [string]$State = $item.State
        [string]$SharePath = $item.SharePath
        [string]$ReferralPriorityClass = $item.ReferralPriorityClass
        
        Switch ($action){

            Create {

                    
                    Write-Progress -Activity "Adding entry to $Path" -Status "Progress:" -PercentComplete ($i/$csv.Count*100)
                    Write-host "Create"
                    $item | format-table action,path,sharepath,State,ReferralPriorityClass
                    
                    # Doing the work
                    New-DfsnFolderTarget -Path $Path -TargetPath $SharePath -State $State -ReferralPriorityClass $ReferralPriorityClass            
                    } # End Create

            Modify {

                    Write-Progress -Activity "Setting $Path $SharePath to $State" -Status "Progress:" -PercentComplete ($i/$csv.Count*100)
                    Write-host "Modify"
                    $item | format-table action,path,sharepath,State,ReferralPriorityClass
                    
                    # Doing the work
                    Set-DfsnFolderTarget -Path $Path -TargetPath $SharePath -State $State -ReferralPriorityClass $ReferralPriorityClass
                    } # End Modify
            
            Default {
                    
                    write-host "Incorrect action on" + $item
                                       
                    } # End Default
        } # End switch
        
    } # End loop
