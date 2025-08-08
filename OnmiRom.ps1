Clear-Host
Write-Host "==============================================="
Write-Host "= CSO/CHD/ISO/CUEBIN Conversion Tool by Refraction + RedDevilus ="
Write-Host "===============================================`n"

Write-Host "IMPORTANT: Make sure this script is located in the same folder as the ROM files you want to convert.`n"

Write-Host "Available Options:"
Write-Host "1 - Convert ISO to CSO"
Write-Host "2 - Convert ISO to CHD"
Write-Host "3 - Convert CUE/BIN to CHD"
Write-Host "4 - Convert CSO to CHD"
Write-Host "5 - Convert DVD CHD to CSO"
Write-Host "6 - Extract DVD CHD to ISO"
Write-Host "7 - Extract CD CHD to CUE/BIN"
Write-Host "8 - Extract CSO to ISO`n"

$choice = Read-Host "Type 1, 2, 3, 4, 5, 6, 7, or 8 then press ENTER"

function Ask-BlockSize {
    Write-Host "`nPlease pick a block size you would like to use:"
    Write-Host "1 - 16KB (bigger files, faster access, less CPU – recommended)"
    Write-Host "2 - 128KB (balanced)"
    Write-Host "3 - 256KB (smaller files, slower access, more CPU)"
    $bchoice = Read-Host "Type 1, 2, or 3 then press ENTER"

    switch ($bchoice) {
        "1" { return 16384 }
        "2" { return 131072 }
        "3" { return 262144 }
        default { 
            Write-Host "Invalid choice. Using default block size: 16384"
            return 16384
        }
    }
}

function Ask-DeleteOriginal($type) {
    $response = Read-Host "`nDo you want to delete the original $type files as they are converted?`nType Y or N then press ENTER"
    return $response -match '^[yY]'
}

function Convert-ISOtoCSO {
    $delete = Ask-DeleteOriginal "ISO"
    $blocksize = Ask-BlockSize

    if (-not (Test-Path ".\maxcso.exe")) { Write-Error "maxcso.exe not found."; return }

    Get-ChildItem *.iso | ForEach-Object {
        $output = "$($_.BaseName).cso"
        Write-Host "`nConverting $($_.Name) → $output"
        & .\maxcso.exe --block=$blocksize "$($_.FullName)"

        if (-not (Test-Path $output) -or ((Get-Item $output).Length -le 0)) {
            Write-Error "Conversion failed for $($_.Name)"
            return
        }

        if ($delete) {
            Remove-Item $_.FullName -Force
        }

        Write-Host "✔ Converted: $($_.Name) → $output"
    }
}

function Convert-ISOtoCHD {
    $delete = Ask-DeleteOriginal "ISO"
    if (-not (Test-Path ".\chdman.exe")) { Write-Error "chdman.exe not found."; return }

    Get-ChildItem *.iso | ForEach-Object {
        $output = "$($_.BaseName).chd"
        Write-Host "`nConverting $($_.Name) → $output"
        & .\chdman.exe createcd -i "$($_.FullName)" -o "$output" -compression 9

        if (-not (Test-Path $output) -or ((Get-Item $output).Length -le 0)) {
            Write-Error "Conversion failed for $($_.Name)"
            return
        }

        if ($delete) {
            Remove-Item $_.FullName -Force
        }

        Write-Host "✔ Converted: $($_.Name) → $output"
    }
}

function Convert-CUEBINtoCHD {
    $delete = Ask-DeleteOriginal "CUE/BIN"
    if (-not (Test-Path ".\chdman.exe")) { Write-Error "chdman.exe not found."; return }

    Get-ChildItem *.cue | ForEach-Object {
        $output = "$($_.BaseName).chd"
        Write-Host "`nConverting $($_.Name) → $output"
        & .\chdman.exe createcd -i "$($_.FullName)" -o "$output" -compression 9

        if (-not (Test-Path $output) -or ((Get-Item $output).Length -le 0)) {
            Write-Error "Conversion failed for $($_.Name)"
            return
        }

        if ($delete) {
            Remove-Item $_.FullName -Force
            $binFile = "$($_.BaseName).bin"
            if (Test-Path $binFile) { Remove-Item $binFile -Force }
        }

        Write-Host "✔ Converted: $($_.Name) → $output"
    }
}

function Convert-CSOtoCHD {
    $delete = Ask-DeleteOriginal "CSO"
    if (-not (Test-Path ".\maxcso.exe")) { Write-Error "maxcso.exe not found."; return }
    if (-not (Test-Path ".\chdman.exe")) { Write-Error "chdman.exe not found."; return }

    Get-ChildItem *.cso | ForEach-Object {
        $tempISO = "$($_.BaseName)_temp.iso"
        $output = "$($_.BaseName).chd"
        Write-Host "`nDecompressing $($_.Name) → $tempISO"
        & .\maxcso.exe --decompress "$($_.FullName)" -o "$tempISO"
        & .\chdman.exe createcd -i "$tempISO" -o "$output" -compression 9
        Remove-Item $tempISO -Force

        if ($delete) {
            Remove-Item $_.FullName -Force
        }

        Write-Host "✔ Converted: $($_.Name) → $output"
    }
}

function Convert-CHDtoCSO {
    $delete = Ask-DeleteOriginal "CHD"
    $blocksize = Ask-BlockSize

    if (-not (Test-Path ".\chdman.exe")) { Write-Error "chdman.exe not found."; return }
    if (-not (Test-Path ".\maxcso.exe")) { Write-Error "maxcso.exe not found."; return }

    Get-ChildItem *.chd | ForEach-Object {
        $baseName = $_.BaseName
        $iso = "$baseName.iso"
        $cso = "$baseName.cso"

        Write-Host "`nExtracting CHD to ISO: $iso"
        & .\chdman.exe extractraw -i "$($_.Name)" -o "$iso"

        if (-not (Test-Path $iso) -or ((Get-Item $iso).Length -le 0)) {
            Write-Error "Failed to extract $iso"
            return
        }

        Write-Host "Compressing ISO to CSO: $cso"
        & .\maxcso.exe --block=$blocksize "$iso"

        if (-not (Test-Path $cso) -or ((Get-Item $cso).Length -le 0)) {
            Write-Error "CSO compression failed for $cso"
            return
        }

        Remove-Item $iso -Force
        if ($delete) {
            Remove-Item $_.FullName -Force
        }

        Write-Host "✔ Converted $($_.Name) → $cso"
    }
}

function Extract-DVDCHDtoISO {
    $delete = Ask-DeleteOriginal "DVD CHD"
    if (-not (Test-Path ".\chdman.exe")) { Write-Error "chdman.exe not found."; return }

    Get-ChildItem *.chd | ForEach-Object {
        $output = "$($_.BaseName).iso"
        Write-Host "`nExtracting $($_.Name) → $output"
        & .\chdman.exe extractraw -i "$($_.FullName)" -o "$output"

        if (-not (Test-Path $output) -or ((Get-Item $output).Length -le 0)) {
            Write-Error "Extraction failed for $($_.Name)"
            return
        }

        if ($delete) {
            Remove-Item $_.FullName -Force
        }

        Write-Host "✔ Extracted: $($_.Name) → $output"
    }
}

function Extract-CDCHDtoCUEBIN {
    $delete = Ask-DeleteOriginal "CD CHD"
    if (-not (Test-Path ".\chdman.exe")) { Write-Error "chdman.exe not found."; return }

    Get-ChildItem *.chd | ForEach-Object {
        $base = $_.BaseName
        $cue = "$base.cue"
        $bin = "$base.bin"
        Write-Host "`nExtracting $($_.Name) → $cue and $bin"
        & .\chdman.exe extractcd -i "$($_.FullName)" -o "$bin" -c "$cue"

        if ((-not (Test-Path $cue)) -or (-not (Test-Path $bin)) -or ((Get-Item $bin).Length -le 0)) {
            Write-Error "Extraction failed for $($_.Name)"
            return
        }

        if ($delete) {
            Remove-Item $_.FullName -Force
        }

        Write-Host "✔ Extracted: $($_.Name) → $cue and $bin"
    }
}

function Extract-CSOtoISO {
    $delete = Ask-DeleteOriginal "CSO"
    if (-not (Test-Path ".\maxcso.exe")) { Write-Error "maxcso.exe not found."; return }

    Get-ChildItem *.cso | ForEach-Object {
        $output = "$($_.BaseName).iso"
        Write-Host "`nExtracting $($_.Name) → $output"
        & .\maxcso.exe --decompress "$($_.FullName)" -o "$output"

        if (-not (Test-Path $output) -or ((Get-Item $output).Length -le 0)) {
            Write-Error "Decompression failed for $($_.Name)"
            return
        }

        if ($delete) {
            Remove-Item $_.FullName -Force
        }

        Write-Host "✔ Extracted: $($_.Name) → $output"
    }
}

switch ($choice) {
    "1" { Convert-ISOtoCSO }
    "2" { Convert-ISOtoCHD }
    "3" { Convert-CUEBINtoCHD }
    "4" { Convert-CSOtoCHD }
    "5" { Convert-CHDtoCSO }
    "6" { Extract-DVDCHDtoISO }
    "7" { Extract-CDCHDtoCUEBIN }
    "8" { Extract-CSOtoISO }
    default { Write-Host "Invalid option selected." }
}

Write-Host "`nPress any key to exit..."
[void][System.Console]::ReadKey($true)