# Segmentador + CRM Comercial Instagram — versión en línea

Esta versión está lista para publicarse en GitHub Pages y guardar datos en Supabase.

## Archivos

- `index.html`: interfaz del CRM.
- `config.js`: credenciales públicas de Supabase.
- `supabase_schema.sql`: tablas y políticas de seguridad.

## Roles

- **admin**: ve carga de base, exportaciones, limpieza y configuración.
- **asesor**: no ve la parte superior de carga ni configuración. Solo consulta prospectos y registra gestiones.

## Pasos rápidos

1. Crea un proyecto en Supabase.
2. En Supabase > SQL Editor, ejecuta `supabase_schema.sql`.
3. En Supabase > Authentication > Users, crea tu usuaria admin y los asesores.
4. Copia el `user_id` de cada usuario y agrégalo a `public.app_users` con rol `admin` o `asesor`.
5. En Supabase > Project Settings > API, copia:
   - Project URL
   - anon/publishable key
6. Pega esos valores en `config.js`.
7. Sube `index.html`, `config.js` y `supabase_schema.sql` a un repositorio de GitHub.
8. Activa GitHub Pages en la rama `main` y carpeta `/root`.
9. Entra al sitio, inicia sesión como admin y carga la base Excel.

## Insertar usuarios autorizados

Después de crear los usuarios en Authentication, usa este ejemplo en SQL Editor:

```sql
insert into public.app_users(user_id, email, full_name, role)
values
('UUID_ADMIN', 'admin@empresa.com', 'Catherine Admin', 'admin'),
('UUID_ASESOR_1', 'asesor1@empresa.com', 'Asesor 1', 'asesor');
```

## Importante

Nunca pegues la `service_role key` en `config.js` ni en GitHub. Esta app usa la anon/publishable key y la seguridad se controla con Row Level Security.
