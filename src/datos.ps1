# =====================================================================
# src\datos.ps1 - Almacenamiento cifrado en reposo con AES-GCM (H-06 corregido)
# =====================================================================

$CarpetaDatos    = Join-Path $Raiz "datos"
$ArchivoUsuarios = Join-Path $CarpetaDatos "users.csv"
$ArchivoAccesos  = Join-Path $CarpetaDatos "access_log.csv"
$ArchivoClave    = Join-Path $CarpetaDatos "datahunt.key"
New-Item -ItemType Directory -Path $CarpetaDatos -Force | Out-Null

function Ahora {
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

function Obtener-ClaveCifrado() {
    if ($env:DATAHUNT_DATA_KEY) {
        $claveEnv = [Convert]::FromBase64String($env:DATAHUNT_DATA_KEY)
        if ($claveEnv.Length -eq 32) { return $claveEnv }
        throw "DATAHUNT_DATA_KEY debe ser una clave base64 de 32 bytes."
    }

    if (Test-Path $ArchivoClave) {
        $bytesGuardados = [System.IO.File]::ReadAllBytes($ArchivoClave)
        if ($bytesGuardados.Length -eq 32) { return $bytesGuardados }
    }

    $nuevaClave = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($nuevaClave)
    [System.IO.File]::WriteAllBytes($ArchivoClave, $nuevaClave)
    return $nuevaClave
}

function Cifrar-TextoPlano([string]$textoPlano) {
    $clave = Obtener-ClaveCifrado
    $nonce = New-Object byte[] 12
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($nonce)

    $textoBytes = [System.Text.Encoding]::UTF8.GetBytes($textoPlano)
    $cifrado    = New-Object byte[] $textoBytes.Length
    $tag        = New-Object byte[] 16

    $aesGcm = [System.Security.Cryptography.AesGcm]::new($clave, 16)
    try {
        $aesGcm.Encrypt($nonce, $textoBytes, $cifrado, $tag)
    }
    finally {
        $aesGcm.Dispose()
    }

    return "enc_aesgcm_v1:" +
        [Convert]::ToBase64String($nonce) + ":" +
        [Convert]::ToBase64String($tag) + ":" +
        [Convert]::ToBase64String($cifrado)
}

function Descifrar-TextoCifrado([string]$contenidoCifrado) {
    if (-not $contenidoCifrado) { return "" }

    if ($contenidoCifrado.StartsWith("enc_aesgcm_v1:")) {
        $partes = $contenidoCifrado -split ":", 4
        if ($partes.Count -ne 4) { throw "Formato de archivo cifrado inválido." }

        $clave      = Obtener-ClaveCifrado
        $nonce      = [Convert]::FromBase64String($partes[1])
        $tag        = [Convert]::FromBase64String($partes[2])
        $cifrado    = [Convert]::FromBase64String($partes[3])
        $descifrado = New-Object byte[] $cifrado.Length

        $aesGcm = [System.Security.Cryptography.AesGcm]::new($clave, 16)
        try {
            $aesGcm.Decrypt($nonce, $cifrado, $tag, $descifrado)
        }
        finally {
            $aesGcm.Dispose()
        }

        return [System.Text.Encoding]::UTF8.GetString($descifrado)
    }

    # Compatibilidad con CSV no cifrado previo a la Fase 9
    return $contenidoCifrado
}

function Leer-Csv([string]$ruta) {
    if (-not (Test-Path $ruta)) { return @() }
    $crudo = [System.IO.File]::ReadAllText($ruta, [System.Text.Encoding]::UTF8)
    if ([string]::IsNullOrWhiteSpace($crudo)) { return @() }

    $csvTexto = Descifrar-TextoCifrado $crudo.Trim()
    if ([string]::IsNullOrWhiteSpace($csvTexto)) { return @() }

    return @($csvTexto | ConvertFrom-Csv)
}

function Guardar-CsvCifrado([string]$ruta, $filas) {
    $lista = @($filas)
    if ($lista.Count -eq 0) {
        if (Test-Path $ruta) { Remove-Item -Path $ruta -Force }
        return
    }

    $csvTexto = ($lista | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine
    $cifrado  = Cifrar-TextoPlano $csvTexto
    [System.IO.File]::WriteAllText($ruta, $cifrado, [System.Text.Encoding]::UTF8)
}

function Agregar-Csv([string]$ruta, $registro) {
    $actuales = @(Leer-Csv $ruta)
    $actuales += [PSCustomObject]$registro
    Guardar-CsvCifrado $ruta $actuales
}
