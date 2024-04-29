# Execution policies
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4

### To view the execution policy for the 'CurrentUser' scope:
```console
Get-ExecutionPolicy -Scope CurrentUser
```

### To change the execution policy to 'RemoteSigned':
```console
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

# Self-signed certificates
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing?view=powershell-7.4

### To view information about self-signed certificates:
```console
Get-ChildItem cert:\CurrentUser\my -codesigning
```

### To create a new self-signed certificate:
```console
$params = @{
    Subject = 'CN=PowerShell Code Signing Cert'
    Type = 'CodeSigning'
    CertStoreLocation = 'Cert:\CurrentUser\My'
    HashAlgorithm = 'sha256'
}
$cert = New-SelfSignedCertificate @params
```

### To delete self-signed certificates:
```console
Remove-Item cert:\CurrentUser\my\{Thumbprint} -DeleteKey
```

### Before `Add-Signature.ps1` could be used to self-sign other scripts, it must be self-signed also:
```console
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert |
    Select-Object -First 1

Set-AuthenticodeSignature .\Add-Signature.ps1 $cert
```

### To sign the PowerShell profile script using the self-signed certificate:
```console
.\Add-Signature.ps1 -File Microsoft.PowerShell_profile.ps1
```
