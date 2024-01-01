# PowerShell version of the GitHub commit automation script

# Start date
$start_date = "2024-01-01"
$current_date = [datetime]::ParseExact($start_date, "yyyy-MM-dd", $null)
$last_date = $current_date

# Define tasks
function RunTask {
    param(
        [int]$taskNum,
        [string]$date
    )
    
    switch ($taskNum) {
        0 { "Task 1: Writing to a file" | Out-File -Append -FilePath "$date.txt" }
        1 { "Task 2: Appending some random text" | Out-File -Append -FilePath "$date.txt" }
        2 { "Task 3: Logging the current date" | Out-File -FilePath "$date.log" }
        3 { "Task 4: Creating a backup file" | Out-File -FilePath "$($date)_backup.txt" }
        4 { 
            "Task 5: Writing a random number" | Out-File -FilePath "$($date)_random.txt"
            Get-Random | Out-File -Append -FilePath "$($date)_random.txt"
        }
    }
}

# Calculate number of days between Jan 1 and April 1 (2024 is a leap year, so it's 92 days)
$num_days = 92

# Loop until April 1
for ($i=1; $i -le $num_days; $i++) {
    # Format current date as string
    $current_date_str = $current_date.ToString("yyyy-MM-dd")
    
    # Determine the number of commits for this day (ALWAYS at least 1)
    $num_commits = 1
    
    # On some days, make more than one commit (20% chance)
    if ((Get-Random -Minimum 0 -Maximum 5) -eq 0) {
        $num_commits = Get-Random -Minimum 2 -Maximum 4  # Make 2 to 3 additional commits
    }

    # Loop to make multiple commits
    for ($c=1; $c -le $num_commits; $c++) {
        # Determine the number of tasks to run (between 1 and 5)
        $num_tasks = Get-Random -Minimum 1 -Maximum 6

        # Create shuffled array of task indices
        $indices = 0..4 | Get-Random -Count 5

        # Run the selected number of tasks
        for ($j=0; $j -lt $num_tasks; $j++) {
            RunTask -taskNum $indices[$j] -date $current_date_str
        }

        # Git operations
        git add .
        git commit -m "updates for $current_date_str"

        # Set the Git committer date and amend the commit
        $commit_date = "$current_date_str 14:00:00"
        $env:GIT_COMMITTER_DATE = $commit_date
        git commit --amend --no-edit --date="$commit_date"
    }

    # Move to the next day
    $last_date = $current_date
    $current_date = $current_date.AddDays(1)
    
    # Output progress
    Write-Host "Processed day $i of $($num_days): $current_date_str"
}

Write-Host "Script completed successfully!" 