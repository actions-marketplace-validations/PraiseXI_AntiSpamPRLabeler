# Assuming repoOwner, repoName, and GITHUB_TOKEN are set as environment variables or action inputs
$repoOwner = `${{ github.repository_owner }}`
$repoName = `${{ github.event.repository.name }}`
$GITHUB_TOKEN = $env:GITHUB_TOKEN

# Base64 encode the GitHub Token
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$GITHUB_TOKEN"))

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

    $label = switch ($totalChanges) {
        { $_ -le 10 } { "Potential Spam" }
        Default { "" }
    }

    if ($label -ne "") {
        Add-LabelToPullRequest -prNumber $prNumber -label $label
        $comment = "This PR has been automatically labeled as 'Potential Spam' due to its size. Please review."
        Add-CommentToPullRequest -prNumber $prNumber -comment $comment
    }
}
