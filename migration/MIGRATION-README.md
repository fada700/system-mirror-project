# Migración: Lovable Cloud → Supabase propio

Esta carpeta contiene todo lo necesario para mover tu backend a un proyecto Supabase tuyo.

## Resumen del inventario

- **9 enums** personalizados
- **16 tablas** en `public` (~135 filas en total)
- **29 funciones** PL/pgSQL (`SECURITY DEFINER`)
- **2 triggers** en `public.usuarios`
- **0 buckets** de storage
- **1 usuario** en `auth.users`
- **0 Edge Functions** (toda la lógica server vive como TanStack server functions en el código de la app — NO se migra al nuevo Supabase, sigue en Cloudflare)

## Archivos

| Archivo | Contenido |
|---|---|
| `migration-schema.sql` | Enums, tablas, índices, FKs, funciones, triggers, RLS y policies |
| `migration-data.sql` | INSERTs de los datos actuales (`pg_dump --data-only --inserts`) |
| `MIGRATION-README.md` | Este checklist |

> Nota: `login_codigos` se excluyó del dump de datos (códigos OTP efímeros, no tiene sentido migrarlos).
> Nota: `auth.users` NO se incluye — recrearás el usuario a mano (acordamos esto).

---

## Checklist paso a paso

### 1. Crear el proyecto nuevo en supabase.com

1. Ve a https://supabase.com/dashboard → **New project**
2. Anota: nombre, región, **password de la base de datos** (¡guárdala!)
3. Espera ~2 min a que el proyecto quede ACTIVE_HEALTHY
4. Copia estos valores (los necesitarás luego):
   - `Project URL`            → Settings → API → Project URL
   - `anon` (publishable) key → Settings → API
   - `service_role` key       → Settings → API → Reveal
   - Connection string        → Settings → Database → URI (modo Transaction)

### 2. Cargar el schema

En el dashboard nuevo: **SQL Editor → New query** y pega `migration-schema.sql` completo. Ejecuta.

Si todo va bien verás "Success. No rows returned". Si falla, revisa que no quede ninguna línea `\restrict` o `CREATE SCHEMA public` (ya las limpié, pero por si acaso).

### 3. Cargar los datos

**IMPORTANTE:** El trigger `trg_crear_tarjeta_debito` se dispara al insertar `usuarios` y crearía duplicados. Hay que desactivar triggers durante la carga.

En el SQL Editor del proyecto nuevo, ejecuta en este orden:

```sql
-- 3a. Desactivar triggers de la tabla usuarios
ALTER TABLE public.usuarios DISABLE TRIGGER ALL;
```

Luego pega y ejecuta `migration-data.sql` completo.

```sql
-- 3b. Reactivar triggers
ALTER TABLE public.usuarios ENABLE TRIGGER ALL;
```

### 4. Recrear el usuario de auth

Tienes **1 usuario** con `auth_user_id = ed872cdd-b251-406d-992c-97f9b37f336d` (Discord: `eqox_`).

Como acordamos, lo recreamos:

a) Dashboard nuevo → **Authentication → Users → Add user → Create new user**. Usa el email que ya tenías; ponle un password temporal.

b) Copia el **nuevo UUID** que te genere Supabase.

c) En el SQL Editor:

```sql
UPDATE public.usuarios
SET auth_user_id = '<NUEVO_UUID_AQUI>'
WHERE discord_id = '1129157255137349752';
```

### 5. Configurar OAuth de Discord

Dashboard nuevo → **Authentication → Providers → Discord → Enable**.

Pega tu `DISCORD_CLIENT_ID` y `DISCORD_CLIENT_SECRET` (los mismos que ya tenías).

Copia el **Callback URL** que muestra Supabase (algo como `https://<ref>.supabase.co/auth/v1/callback`) y agrégalo en:
- Discord Developer Portal → tu app → OAuth2 → Redirects

### 6. Configurar Site URL y Redirect URLs

Dashboard → **Authentication → URL Configuration**:
- **Site URL:** la URL de producción de tu app (tu dominio en Cloudflare).
- **Redirect URLs:** agrega todas las URLs donde corra (preview, producción, localhost si pruebas en local).

### 7. (Opcional) Recrear cron jobs

Si en Lovable Cloud tenías `pg_cron` programado para `cobrar_impuestos_tick()` o recordatorios de crédito, recréalo:

Dashboard → **Database → Extensions** → activa `pg_cron`. Luego:

```sql
SELECT cron.schedule(
  'cobrar-impuestos',
  '0 0 * * *',  -- todos los días a medianoche; ajusta a tu gusto
  $$ SELECT public.cobrar_impuestos_tick(); $$
);
```

Alternativa: como ya tienes `src/routes/api/public/cron-impuestos.ts` y `cron-credit-reminders.ts` en el código de la app, puedes llamarlos desde un cron externo (Cloudflare Cron Triggers, GitHub Actions, etc.).

### 8. Verificar

En el SQL Editor del proyecto nuevo:

```sql
SELECT 'usuarios' tabla, count(*) FROM public.usuarios
UNION ALL SELECT 'movimientos', count(*) FROM public.movimientos
UNION ALL SELECT 'membresias', count(*) FROM public.membresias
UNION ALL SELECT 'audit_logs', count(*) FROM public.audit_logs
UNION ALL SELECT 'config_membresias', count(*) FROM public.config_membresias;
```

Conteo esperado: usuarios=1, movimientos=50, membresias=13, audit_logs=25, config_membresias=7.

---

## FASE 3 — Conectar el código al nuevo proyecto

**No la ejecutes todavía.** Cuando hayas terminado los pasos 1-8 y verificado que la base nueva responde, vuelve al chat con:

- `NEW_SUPABASE_URL` (algo como `https://abcdef.supabase.co`)
- `NEW_SUPABASE_ANON_KEY`
- `NEW_SUPABASE_SERVICE_ROLE_KEY`

Y yo me encargo de:

1. Actualizar `src/integrations/supabase/client.ts` para apuntar al nuevo proyecto (en realidad, basta con cambiar las env vars — el archivo no se toca).
2. Actualizar las env vars en Cloudflare Worker (Settings → Variables and Secrets):
   - `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
   - Las `VITE_*` se inyectan al build, así que también las pondré en el archivo de configuración del despliegue.
3. Re-agregar los secrets de Discord (`DISCORD_BOT_TOKEN`, `DISCORD_CLIENT_ID`, `DISCORD_CLIENT_SECRET`) en el entorno del Worker.

---

## Cómo desconectar Lovable Cloud sin perder los datos originales

**NO desconectes nada todavía.** El proyecto antiguo seguirá vivo y con los datos hasta que tú decidas borrarlo. Recomendación:

1. Termina toda la FASE 3.
2. Prueba a fondo el sitio publicado apuntando al Supabase nuevo durante al menos unos días.
3. Cuando estés 100% seguro, en Lovable: **Connectors → Lovable Cloud → Disable Cloud**.
   ⚠️ Esto **NO se puede revertir** y eliminará la base de datos del proyecto antiguo. Por eso esperamos.
4. Si quieres respaldo extra antes de ese paso, ejecuta otro `pg_dump` completo del proyecto antiguo y guárdalo aparte.

---

## Cosas que NO se migran automáticamente

| Item | Qué hacer |
|---|---|
| Password hash de `auth.users` | Recreado a mano (paso 4) |
| OAuth Discord | Configurar manualmente (paso 5) |
| Cron jobs | Recrear con `pg_cron` (paso 7) |
| Secrets del Worker (Discord, etc.) | Re-agregar en Cloudflare (FASE 3) |
| `login_codigos` (OTP efímeros) | Se ignoran intencionalmente |

## Cosas que NO existen en este proyecto (te las menciono para que no te preocupes)

- Edge Functions → 0
- Storage buckets → 0
- `LOVABLE_API_KEY` / Lovable AI → el código NO lo usa
