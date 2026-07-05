function git-config {
    git --git-dir=$HOME/.local/share/yadm/repo.git --work-tree=$HOME @args
}

Set-Alias -Name config -Value git-config

function git-branch-name {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    # 1. Get input (arguments or clipboard)
    $inputStr = $null
    if ($Arguments.Length -gt 0) {
        $inputStr = $Arguments -join " "
    } else {
        try {
            $inputStr = Get-Clipboard -Raw
        } catch {
            Write-Error "Could not read from clipboard."
            return
        }
    }

    if ([string]::IsNullOrEmpty($inputStr)) {
        Write-Error "Error: No input provided and clipboard is empty."
        return
    }

    # 2. Extract JIRA ticket (case-insensitive: e.g. ABC-1234 or JIRA-99)
    $jiraRegex = '\b([a-zA-Z]+-\d+)\b'
    $jiraTicket = $null
    $cleanedTitle = $inputStr

    if ($inputStr -match $jiraRegex) {
        $jiraTicket = $Matches[1].ToUpper()
        # Remove JIRA ticket from description to avoid duplicates
        $escapedTicket = [regex]::Escape($Matches[1])
        $cleanedTitle = $inputStr -replace $escapedTicket, ""
    }

    # 3. Strip brackets, colons, punctuation and replace with spaces
    $cleanedTitle = $cleanedTitle -replace '[^a-zA-Z0-9\s]', ' '

    # 4. Lowercase only
    $cleanedTitle = $cleanedTitle.ToLower()

    # 5. Split by spaces and join with dashes
    $words = $cleanedTitle.Split(" `t`n`r", [System.StringSplitOptions]::RemoveEmptyEntries)
    $description = $words -join "-"

    # 6. Format branch name: description/JIRA-TICKET
    if ($jiraTicket) {
        $branchName = "$description/$jiraTicket"
    } else {
        $branchName = $description
    }

    # Clean up trailing/leading dashes/slashes and multiple consecutive dashes/slashes
    $branchName = $branchName -replace '-+', '-'
    $branchName = $branchName -replace '/+', '/'
    $branchName = $branchName.Trim("-").Trim("/")

    if ([string]::IsNullOrEmpty($branchName)) {
        Write-Error "Error: Could not format a valid branch name from the input."
        return
    }

    # Copy the formatted branch name back to the clipboard
    try {
        Set-Clipboard -Value $branchName
    } catch {
        # Ignore clipboard write issues
    }

    # Print the final formatted branch name
    Write-Output $branchName
}

# SIG # Begin signature block
# MIIFlAYJKoZIhvcNAQcCoIIFhTCCBYECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPYfT66XVvVSzlKpGQ3yCeoQR
# /xegggMiMIIDHjCCAgagAwIBAgIQSdCh+TuMR79Jn4SUOpBhXDANBgkqhkiG9w0B
# AQsFADAnMSUwIwYDVQQDDBxQb3dlclNoZWxsIENvZGUgU2lnbmluZyBDZXJ0MB4X
# DTI0MDQyODIyMjY0OVoXDTI1MDQyODIyNDY0OVowJzElMCMGA1UEAwwcUG93ZXJT
# aGVsbCBDb2RlIFNpZ25pbmcgQ2VydDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
# AQoCggEBAMzmXAGXGucureIXmePPk4fE0l/LNbtJR1/+ldmCg+yf7bKduy4QkZ+f
# +T/qd3HaCup5p3jRnEFD6IhqbPX3gcn5XHmxMq5PdjhKzswjuhffvSIQ7kUGHnkc
# gy2QBgF5Jj9OLjBYZ+4AEWbPOCvM27vZ1Piccf61p8te+1CH/QKy8JhnqlvBSODV
# wE5kQCNqGACYqFwBSpPaqxj1VMrgd4/Y+z8zPGMBtbCdciSsofXRTFwwFFEOT3tT
# 7ZfT+8QFnBSNTHAnUOOs8agpFXiI2qY9lbvpUX1opsIdw67LL52cc/+irtcsnptr
# D9qsrI9XehH5ujl1yVRiSqwzjVpxlv0CAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeA
# MBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQVezLGqK5oYCfkueerlaMa
# azUVmTANBgkqhkiG9w0BAQsFAAOCAQEAVl8nQmVw/YDG3tLk05jyx8y8Hz/dKqRe
# x6EWogc10mMujx03nUfUXVQpzbTPx/Hwa60qmj0AmHJ6SqzhtCDwv0C9pHy0jMe6
# s+LOj+EoRf00b4xRXmGMNvnBOijicW6eVC3ygnx3X93LOwGxpYAx+4DnypusUHUq
# vYdYvac8YFQE28Lo5N5MdfUkrrOX9TnGDNELiUvqxDHWGqm8mqtM5XUKL6FD+D28
# JQr8a/GJSEeJpLTAwzphojs2RmTYkcjHi91k45mJJ1NtCw4m1HYEraQZDbBZHz+I
# FArAiD8evLcCnVK/d/l2eqrsz3k/P0ylWkXUKSS7MSpZbNzpLJYiGzGCAdwwggHY
# AgEBMDswJzElMCMGA1UEAwwcUG93ZXJTaGVsbCBDb2RlIFNpZ25pbmcgQ2VydAIQ
# SdCh+TuMR79Jn4SUOpBhXDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQURrMtb5UA3sFVIwzZl2Ye
# p9x/F1swDQYJKoZIhvcNAQEBBQAEggEAcriLDdBh79h/zyB2KVimArd/lH0FYNBx
# eJIDLa2cPKPQS4SKr7sEGFcWuARaJrrEPIUnYFLT8nBCuHHytsKzuMBvs7pMdyGF
# 4XL5PN13zW5fcH/sAhuaOjCskZO4/RdRAX/j5CEspeEUVn66jFgIPZS9ZMQAHLrj
# G2FWUsZHkKa4JCRqN8SJxLrzwnX8pO/HQmR2kb8NTNzL+7J98OFjRN7+bbSy9Dbn
# MorI5e+HQZXidg0TDoiPfLHB6sGXITAdyp63J+BnWpEezrPkYna3sW1HMC2+F5LJ
# 10//TXfAcvObjAzpY6d2/7Sf16Qhppfvm7cX6SDO0lmjXYat8G7JJw==
# SIG # End signature block
