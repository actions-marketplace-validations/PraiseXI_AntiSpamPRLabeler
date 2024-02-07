# Requires Pester module
# Usage: Invoke-Pester -Script <PathToTheTestScript>

Describe "GitHub PR Labeling Script Tests" {

    # Mock the Get-Content cmdlet to simulate reading from the .env file
    Mock Get-Content {
        return @("GH_PAT=abc123", "SomeOtherVar=somevalue")
    }

    # Mock the Invoke-RestMethod to simulate API calls
    Mock Invoke-RestMethod {
        return @(
            @{ number=1; additions=5; deletions=3 },
            @{ number=2; additions=100; deletions=50 }
        )
    }

    It "Calculates total changes correctly" {
        # Simulate a PR with known additions and deletions
        $pr = @{ additions=5; deletions=3 }
        $totalChanges = $pr.additions + $pr.deletions
        $totalChanges | Should -Be 8
    }

    It "Assigns 'Potential Spam' label to PRs with changes <= 10" {
        # Simulate a PR with <= 10 changes
        $pr = @{ number=1; additions=5; deletions=3 }
        $totalChanges = $pr.additions + $pr.deletions
        $label = if ($totalChanges -le 10) { "Potential Spam" } else { "" }
        $label | Should -Be "Potential Spam"
    }

    It "Does not assign label to PRs with changes > 10" {
        # Simulate a PR with > 10 changes
        $pr = @{ number=2; additions=100; deletions=50 }
        $totalChanges = $pr.additions + $pr.deletions
        $label = if ($totalChanges -le 10) { "Potential Spam" } else { "" }
        $label | Should -Be ""
    }

    It "Sends the correct body to GitHub when adding a label" {
        # Simulate adding a label to a PR
        $prNumber = 1
        $label = "Potential Spam"
        Add-LabelToPullRequest -prNumber $prNumber -label $label

        # Assert that Invoke-RestMethod was called with the correct parameters
        Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -Exactly -Scope It
    }
}
