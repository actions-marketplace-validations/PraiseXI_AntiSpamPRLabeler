$envFilePath = "./.env"
$variableName = "GH_PAT"
$GHPAT = $null
$repoOwner = ""
$repoName = ""

#get Github PAt
Get-Content $envFilePath | ForEach-Object {
    # Split the line into name and value
    $line = $_.Trim()
    # TODO: Ignore comments and malformed lines
    $name, $value = $line -split '=', 2

    # Check if the current line contains the variable of interest
    if ($name -eq $variableName) {
        $GHPAT = $value
    }
}

#base64 encode PAT
$base64AuthInfo = [Convert]::TOBase64String([Text.Encoding]::ASCII.GetBytes(":$GHPat"))

# add label to PR
function Add-LabelToPullRequest {
    param (
        [int]$prNumber,
        [string]$label
    )
    $labelUri = "https://api.github.com/repos/$repoOwner/$repoName/issues/$prNumber/labels"
    $body = @{
        labels = @($label)
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $labelUri -Method POST -Headers @{
        Authorization = "Basic $base64AuthInfo"
        Accept        = "application/vnd.github.v3+json"
    } -Body $body -ContentType "application/json"
}

# Function to add a comment to PR
function Add-CommentToPullRequest {
    param (
        [int]$prNumber,
        [string]$comment
    )
    $commentUri = "https://api.github.com/repos/$repoOwner/$repoName/issues/$prNumber/comments"
    $body = @{
        body = $comment
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $commentUri -Method POST -Headers @{
        Authorization = "Basic $base64AuthInfo"
        Accept        = "application/vnd.github.v3+json"
    } -Body $body -ContentType "application/json"
}


# get all open PRS
$uri = "https://api.github.com/repos/$repoOwner/$repoName/pulls?state=open"
$response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
    Authorization = "Basic $base64AuthInfo"
    Accept        = "application/vnd.github.v3+json"
}

foreach ($pr in $response) {
    $prNumber = $pr.number
    $additions = $pr.additions
    $deletions = $pr.deletions
    $totalChanges = $additions + $deletions

    # Determine size label based on the number of changes
    $label = switch ($totalChanges) {
        { $_ -le 10 } { "Potential Spam" }
        Default { "" }
    }

    # Add the label to the pull request
    if ($label -ne "") {
        Add-LabelToPullRequest -prNumber $prNumber -label $label
        # Add a comment to the pull request
        $comment = "This PR has been automatically labeled as 'Potential Spam' due to its size. Please review."
        Add-CommentToPullRequest -prNumber $prNumber -comment $comment
    }
}