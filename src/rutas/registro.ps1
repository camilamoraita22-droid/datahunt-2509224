# =====================================================================
# src\rutas\registro.ps1 - Alta de clientes
# H-01 y H-03 corregidos; H-05 y H-07 atendidos con aviso y consentimiento
# =====================================================================

function Hashear-Password([string]$password) {
    $saltBytes = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($saltBytes)

    $pbkdf2 = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
        $password,
        $saltBytes,
        100000,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256
    )
    try {
        $hashBytes = $pbkdf2.GetBytes(32)
    }
    finally {
        $pbkdf2.Dispose()
    }

    $saltB64 = [Convert]::ToBase64String($saltBytes)
    $hashB64 = [Convert]::ToBase64String($hashBytes)
    return "pbkdf2_sha256`$100000`$$saltB64`$$hashB64"
}

function Formulario-Registro([string]$mensaje = "") {
    $html = ""
    if ($mensaje) { $html += "<p class='mensaje'>$(Escapar $mensaje)</p>" }

    $html += "<div class='aviso'><p>Antes de registrarte, revisa nuestro <a href='/aviso'>Aviso de privacidad</a> para conocer qué datos recabamos, con qué finalidad y cómo se protege tu información.</p></div>"
    $html += "<form method='post' action='/registro'>"
    $html += "<label>Correo electrónico <input type='email' name='email' required></label>"
    $html += "<label>Contraseña <input type='password' name='password' required minlength='8'></label>"
    foreach ($campo in $Campos) {
        $html += "<label>$(Escapar $campo.Etiqueta) <input type='$($campo.Tipo)' name='$($campo.Nombre)' required></label>"
    }
    # H-07 corregido: solicita consentimiento explícito vinculado al aviso de privacidad
    $html += "<label><input type='checkbox' name='acepta_aviso' value='1' required> He leído y acepto el <a href='/aviso'>Aviso de privacidad</a> y consiento el tratamiento de mis datos personales para el servicio de $(Escapar $Servicio).</label><br>"
    $html += "<button>Crear cuenta</button></form>"
    return $html
}

$Rutas["/registro"] = {
    param($ctx)
    $peticion = $ctx.Request

    if ($peticion.HttpMethod -ne "POST") {
        Enviar $ctx (Nueva-Pagina "Crear cuenta" (Formulario-Registro))
        return
    }

    $form = Leer-Formulario $ctx

    if (-not $form["email"] -or -not $form["password"]) {
        Enviar $ctx (Nueva-Pagina "Crear cuenta" (Formulario-Registro "El correo y la contraseña son obligatorios."))
        return
    }
    if ($form["acepta_aviso"] -ne "1") {
        Enviar $ctx (Nueva-Pagina "Crear cuenta" (Formulario-Registro "Debes aceptar el Aviso de privacidad para crear tu cuenta.")) 400
        return
    }
    if (Leer-Csv $ArchivoUsuarios | Where-Object { $_.email -eq $form["email"] }) {
        Enviar $ctx (Nueva-Pagina "Crear cuenta" (Formulario-Registro "Ese correo ya está registrado."))
        return
    }

    $registro = [ordered]@{}
    $registro["email"] = $form["email"]
    $registro["password"] = Hashear-Password $form["password"]
    foreach ($campo in $Campos) {
        $registro[$campo.Nombre] = $form[$campo.Nombre]
    }

    # H-05 y H-07 atendidos: metadatos técnicos y aceptación explícita declarados en el aviso
    $registro["acepta_aviso"]   = "1"
    $registro["ip"]             = $peticion.RemoteEndPoint.Address.ToString()
    $registro["navegador"]      = $peticion.UserAgent
    $registro["idioma"]         = $peticion.Headers["Accept-Language"]
    $registro["fecha_registro"] = Ahora

    Agregar-Csv $ArchivoUsuarios $registro

    Enviar $ctx (Nueva-Pagina "Cuenta creada" "<p>Tu cuenta se creó correctamente. Ya puedes <a href='/login'>iniciar sesión</a>.</p>")
}
