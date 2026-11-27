# Reporte de Cierre y Protección de Datos — Data Hunt (E-PDD-1)

- **Alumna:** Camila Alexandra Moraita Medina (2509224)
- **Institución:** Universidad Politécnica de Yucatán (UPY)
- **Caso de estudio:** Aeropuerto Internacional de Mérida — Registro de pasajeros
- **Stack técnico:** PowerShell 7, Git, `PBKDF2-HMAC-SHA-256` (`Rfc2898DeriveBytes`), `AES-GCM` (`AesGcm`), almacenamiento CSV cifrado en reposo

## Resumen de remediación por hallazgo

| ID | Hallazgo original | Estado final | Medida implementada |
| :--- | :--- | :--- | :--- |
| **H-01** | Contraseñas en texto plano | Corregido | Hash `PBKDF2-HMAC-SHA-256` (100,000 iteraciones) con `salt` aleatoria de 16 bytes y comparación en tiempo constante (`FixedTimeEquals`). |
| **H-02** | `/admin` sin autenticación | Corregido | Exigencia de clave de administración (`DATAHUNT_ADMIN_KEY` o `X-Admin-Key`) con respuesta `401` ante accesos no autorizados y exclusión de hashes en la vista. |
| **H-03** | Datos y credenciales en logs `[DEBUG]` | Corregido | Eliminación de impresiones en consola con datos personales o contraseñas en `/registro` y `/login`. |
| **H-04** | Tráfico HTTP sin cifrado en tránsito | Mitigado / Documentado | Operación local aislada en `localhost:5000`; para exposición en red se recomienda terminación TLS/HTTPS mediante proxy inverso. |
| **H-05** | Metadatos técnicos no informados | Atendido | Declaración explícita de `ip`, `navegador`, `idioma` y `fecha_registro` en `/aviso` con finalidad de seguridad y trazabilidad. |
| **H-06** | Archivos CSV sin cifrado en reposo | Corregido | Cifrado autenticado `AES-GCM` (`enc_aesgcm_v1`) en `src\datos.ps1` y exclusión de `datos\` y claves mediante `.gitignore`. |
| **H-07** | Sin aviso de privacidad ni consentimiento | Corregido | Ruta `/aviso`, casilla obligatoria de aceptación en `/registro` y portal de atención de derechos ARCO en `/arco`. |

## Verificación de funcionamiento

1. Alta de pasajeros en `/registro` exigiendo aceptación del aviso de privacidad y almacenando contraseñas hasheadas.
2. Inicio de sesión en `/login` validando contra hash `PBKDF2` y registrando intentos en la bitácora cifrada.
3. Acceso restringido a `/admin` mediante clave (`401` si falta o es incorrecta).
4. Consulta y eliminación de datos mediante `/arco` previa verificación de credenciales.
5. Persistencia cifrada en `datos\` (`enc_aesgcm_v1:`) sin exponer datos sensibles en el repositorio.