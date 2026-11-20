# Diseño de campos

- **Organización:** Aeropuerto Internacional de Mérida
- **Servicio que presta la app:** Registro de pasajeros
- **Departamento dueño de los datos:** Atención a pasajeros

## Campos del formulario

> Regla: si no puedes escribir la finalidad de un campo, ese campo no entra.

| Nombre técnico | Etiqueta en pantalla | Tipo | Finalidad | ¿Por qué es indispensable? |
|---|---|---|---|---|
| email | Correo electrónico | email | Identificar la cuenta y enviar avisos del servicio | Permite autenticar al usuario de forma única y enviar confirmaciones o alertas de vuelo |
| password | Contraseña | password | Proteger el acceso a la cuenta | Evita que terceros no autorizados accedan a la información del pasajero |
| nombre | Nombre completo | text | Identificar al pasajero en su reservación | Necesario para vincular la cuenta con la identidad del viajero y su pase de abordar |
| telefono | Teléfono celular | tel | Avisar cambios de puerta, retrasos o cancelaciones | Medio de contacto inmediato ante incidencias operativas de último minuto |
| fecha_nacimiento | Fecha de nacimiento | date | Verificar si el pasajero es menor de edad | Permite determinar si requiere acompañamiento especial o tarifas diferenciadas por edad |

## Lo que viaja al presionar "Enviar"

## Lo que viaja al presionar "Enviar"

1. **¿En qué forma aparece la contraseña en la petición? ¿Qué significan `%40` y `+` en el cuerpo de la petición?**
   La contraseña (`password=123456`) viaja en texto plano (sin cifrar) dentro del cuerpo codificado como `application/x-www-form-urlencoded`[cite: 7, 13]. En el cuerpo, `%40` representa el carácter `@` en codificación URL (hexadecimal ASCII `0x40`) y `+` representa los espacios entre palabras (por ejemplo, en `Sonia+Martinez+Perez`)[cite: 13].

2. **¿Qué líneas de la petición no escribiste tú? ¿Qué revela cada una sobre el usuario?**
   Encabezados generados automáticamente por el navegador como `Host` (`localhost:5000`), `Content-Length` (`121`), `Content-Type` (`application/x-www-form-urlencoded`), `User-Agent` (`Windows NT 10.0; Win64; x64` y `Google Chrome/158.0.0.0`), `sec-ch-ua-platform` (`"Windows"`), `sec-ch-ua-mobile` (`?0`) y `Accept-Language` (`es-MX,es;q=0.9,en-US;q=0.8...`)[cite: 13]. Revelan el sistema operativo, arquitectura de 64 bits, navegador y versión, si es equipo móvil o de escritorio, y preferencias de idioma/región[cite: 7, 13].

3. **¿Qué podría ver alguien conectado a la misma red?**
   Dado que la petición viaja por HTTP sin cifrar, alguien con acceso a la red podría leer en texto claro la ruta `/registro`, los encabezados del navegador y todos los datos del cuerpo del formulario (correo, contraseña, nombre, teléfono y fecha de nacimiento)[cite: 7, 13].