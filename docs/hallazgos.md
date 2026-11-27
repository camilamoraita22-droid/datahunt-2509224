# Hallazgos de protección de datos — Aeropuerto Internacional de Mérida (Registro de pasajeros)

## H-01: Contraseñas almacenadas en texto plano
- **Ubicación:** `src\rutas\registro.ps1` y `src\rutas\login.ps1` (columna `password` en `datos\users.csv`).
- **Descripción:** La contraseña del pasajero se guarda y compara tal como se recibe, sin aplicar hashing seguro con salt.
- **Riesgo:** Quien acceda al archivo CSV o a una copia de respaldo obtiene de inmediato las credenciales de acceso de los pasajeros.

## H-02: Panel de administración sin autenticación ni control de acceso
- **Ubicación:** `src\rutas\admin.ps1` (ruta `/admin`).
- **Descripción:** Cualquier visitante que entre a `/admin` puede consultar todos los registros de pasajeros y la bitácora de accesos sin iniciar sesión ni validar roles.
- **Riesgo:** Exposición no autorizada de datos personales de pasajeros y registros de actividad del sistema.

## H-03: Datos personales y credenciales impresos en consola (`[DEBUG]`)
- **Ubicación:** `src\rutas\registro.ps1` y `src\rutas\login.ps1`.
- **Descripción:** Al registrar o iniciar sesión, el servidor imprime en la salida estándar de PowerShell los datos enviados por el usuario, incluyendo la contraseña.
- **Riesgo:** Quien vea la pantalla, terminal o logs redirigidos de la sesión puede leer contraseñas y datos personales en texto claro.

## H-04: Tráfico servido por HTTP sin cifrado en tránsito
- **Ubicación:** `app.ps1` (`http://$($Direccion):$Puerto/`).
- **Descripción:** El listener opera sobre HTTP sin TLS/HTTPS, por lo que formularios, credenciales y respuestas viajan sin cifrar en el canal.
- **Riesgo:** Interceptación o lectura de datos en tránsito si el servicio se expone o escucha fuera de un entorno local aislado.

## H-05: Recolección de metadatos adicionales no informados al titular
- **Ubicación:** `src\rutas\registro.ps1` (`ip`, `navegador`, `idioma`, `fecha_registro`).
- **Descripción:** Además de los campos declarados para el servicio de registro de pasajeros, el sistema captura dirección IP, `User-Agent`, `Accept-Language` y marca de tiempo sin avisarlo previamente.
- **Riesgo:** Falta de transparencia y tratamiento de datos no informado en el momento de la recolección.

## H-06: Archivos CSV almacenados sin cifrado en reposo
- **Ubicación:** `src\datos.ps1` (`datos\users.csv` y `datos\access_log.csv`).
- **Descripción:** Los datos de pasajeros y la bitácora de accesos se escriben en archivos CSV planos sin cifrado en reposo.
- **Riesgo:** Lectura directa de toda la información almacenada si un atacante o usuario sin autorización accede al sistema de archivos.

## H-07: Ausencia de aviso de privacidad y consentimiento explícito en el registro
- **Ubicación:** `src\rutas\registro.ps1` (`Formulario-Registro`).
- **Descripción:** El formulario de alta no presenta aviso de privacidad ni solicita consentimiento informado antes de recolectar y almacenar los datos personales.
- **Riesgo:** Incumplimiento de los principios de información y consentimiento en el tratamiento de datos personales.
