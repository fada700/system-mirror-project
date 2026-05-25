--
-- PostgreSQL database dump
--

\restrict oLdS7fMnnycPHfh5Rs7b4CpZ7hJDM7V4c1Nsap5cVNc2YdUuvf7SH1wFRBVyep4

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: app_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'trabajador',
    'usuario',
    'policia'
);


--
-- Name: estado_credito; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_credito AS ENUM (
    'sin_solicitar',
    'pendiente',
    'activa',
    'bloqueada',
    'rechazada',
    'cerrada'
);


--
-- Name: estado_cuenta_general; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_cuenta_general AS ENUM (
    'activa',
    'congelada',
    'cerrada'
);


--
-- Name: estado_multa; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_multa AS ENUM (
    'pendiente',
    'pagada',
    'cancelada'
);


--
-- Name: estado_notificacion; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_notificacion AS ENUM (
    'enviado',
    'fallido'
);


--
-- Name: estado_solicitud; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_solicitud AS ENUM (
    'pendiente',
    'aprobada',
    'rechazada'
);


--
-- Name: estado_tarjeta_debito; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_tarjeta_debito AS ENUM (
    'activa',
    'congelada',
    'cerrada'
);


--
-- Name: tipo_membresia; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_membresia AS ENUM (
    'basica',
    'gold',
    'zafiro',
    'esmeralda',
    'diamond',
    'ruby',
    'ruby_plus'
);


--
-- Name: tipo_movimiento; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_movimiento AS ENUM (
    'deposito',
    'retiro',
    'transferencia_enviada',
    'transferencia_recibida',
    'comision',
    'pago_credito',
    'uso_credito',
    'interes_credito',
    'membresia',
    'admin_dar',
    'admin_quitar',
    'condonacion',
    'ganancia_banco',
    'multa',
    'pago_multa',
    'sueldo',
    'impuesto',
    'compra_membresia'
);


--
-- Name: abrir_credito_manual(uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.abrir_credito_manual(_usuario_id uuid, _limite numeric, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE; tc tarjetas_credito%ROWTYPE; num text; ncvv text; venc text;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  IF _limite IS NULL OR _limite <= 0 OR _limite > 10000000 THEN RAISE EXCEPTION 'Limite invalido'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  num  := '5' || lpad((floor(random()*999999999999999)::bigint)::text, 15, '0');
  ncvv := lpad((floor(random()*999)::int)::text, 3, '0');
  venc := lpad((floor(random()*12)::int + 1)::text, 2, '0') || '/' || to_char(now() + interval '4 years', 'YY');
  SELECT * INTO tc FROM tarjetas_credito WHERE usuario_id = u.id FOR UPDATE;
  IF tc.id IS NULL THEN
    INSERT INTO tarjetas_credito(usuario_id, estado, numero, cvv, vencimiento, limite) VALUES (u.id, 'activa', num, ncvv, venc, _limite);
  ELSE
    UPDATE tarjetas_credito SET estado='activa', numero=num, cvv=ncvv, vencimiento=venc, limite=_limite WHERE id = tc.id;
  END IF;
  PERFORM public.log_audit('ABRIR_CREDITO','tarjeta_credito', u.id, u.nombre, jsonb_build_object('motivo', _motivo, 'limite', _limite));
END $$;


--
-- Name: abrir_debito_manual(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.abrir_debito_manual(_usuario_id uuid, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE; td tarjetas_debito%ROWTYPE; num text; ncvv text; venc text;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  SELECT * INTO td FROM tarjetas_debito WHERE usuario_id = u.id FOR UPDATE;
  IF td.id IS NOT NULL AND td.estado <> 'cerrada' THEN RAISE EXCEPTION 'Ya tiene tarjeta debito activa'; END IF;
  num  := '4' || lpad((floor(random()*999999999999999)::bigint)::text, 15, '0');
  ncvv := lpad((floor(random()*999)::int)::text, 3, '0');
  venc := lpad((floor(random()*12)::int + 1)::text, 2, '0') || '/' || to_char(now() + interval '4 years', 'YY');
  IF td.id IS NULL THEN
    INSERT INTO tarjetas_debito(usuario_id, numero, cvv, vencimiento, estado, congelada) VALUES (u.id, num, ncvv, venc, 'activa', false);
  ELSE
    UPDATE tarjetas_debito SET numero=num, cvv=ncvv, vencimiento=venc, estado='activa', congelada=false WHERE id = td.id;
  END IF;
  PERFORM public.log_audit('ABRIR_DEBITO','tarjeta_debito', u.id, u.nombre, jsonb_build_object('motivo', _motivo));
END $$;


--
-- Name: admin_ajustar_saldo(uuid, numeric, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_ajustar_saldo(_usuario_id uuid, _delta numeric, _cuenta text, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE;
BEGIN
  IF NOT public.has_role('admin') THEN RAISE EXCEPTION 'Solo admin'; END IF;
  IF _delta = 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  IF _cuenta NOT IN ('banco','cartera') THEN RAISE EXCEPTION 'Cuenta invalida'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id FOR UPDATE;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  IF _cuenta = 'banco' THEN
    IF u.saldo_banco + _delta < 0 THEN RAISE EXCEPTION 'Saldo banco quedaria negativo'; END IF;
    UPDATE usuarios SET saldo_banco = saldo_banco + _delta WHERE id = u.id;
  ELSE
    IF u.saldo_cartera + _delta < 0 THEN RAISE EXCEPTION 'Saldo cartera quedaria negativo'; END IF;
    UPDATE usuarios SET saldo_cartera = saldo_cartera + _delta WHERE id = u.id;
  END IF;
  INSERT INTO movimientos(usuario_id, tipo, monto, descripcion)
    VALUES (u.id,
            (CASE WHEN _delta > 0 THEN 'admin_dar' ELSE 'admin_quitar' END)::tipo_movimiento,
            abs(_delta),
            'Admin (' || _cuenta || ')' || CASE WHEN _motivo IS NOT NULL AND length(_motivo)>0 THEN ' - '||_motivo ELSE '' END);
  PERFORM public.log_audit('AJUSTAR_SALDO','usuario', u.id, u.nombre, jsonb_build_object('cuenta', _cuenta, 'delta', _delta, 'motivo', _motivo));
END $$;


--
-- Name: ajustar_limite_credito(uuid, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajustar_limite_credito(_usuario_id uuid, _nuevo_limite numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  IF _nuevo_limite < 0 OR _nuevo_limite > 10000000 THEN RAISE EXCEPTION 'Limite invalido'; END IF;
  UPDATE tarjetas_credito SET limite = _nuevo_limite WHERE usuario_id = _usuario_id;
END; $$;


--
-- Name: aprobar_tarjeta_credito(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.aprobar_tarjeta_credito(_solicitud_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE staff uuid := public.current_usuario_id(); s solicitudes%ROWTYPE; tc tarjetas_credito%ROWTYPE; u usuarios%ROWTYPE; num text; ncvv text; venc text;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO s FROM solicitudes WHERE id = _solicitud_id FOR UPDATE;
  IF s.id IS NULL THEN RAISE EXCEPTION 'Solicitud no encontrada'; END IF;
  IF s.tipo <> 'tarjeta_credito' THEN RAISE EXCEPTION 'Tipo no es tarjeta_credito (%)', s.tipo; END IF;
  IF s.estado <> 'pendiente' THEN RAISE EXCEPTION 'Solicitud ya resuelta (%)', s.estado; END IF;
  num  := '5' || lpad((floor(random()*999999999999999)::bigint)::text, 15, '0');
  ncvv := lpad((floor(random()*999)::int)::text, 3, '0');
  venc := lpad((floor(random()*12)::int + 1)::text, 2, '0') || '/' || to_char(now() + interval '4 years', 'YY');
  SELECT * INTO tc FROM tarjetas_credito WHERE usuario_id = s.usuario_id FOR UPDATE;
  IF tc.id IS NULL THEN
    INSERT INTO tarjetas_credito(usuario_id, estado, numero, cvv, vencimiento, limite) VALUES (s.usuario_id, 'activa', num, ncvv, venc, 5000);
  ELSE
    UPDATE tarjetas_credito SET estado='activa', numero=num, cvv=ncvv, vencimiento=venc, limite = COALESCE(NULLIF(limite,0), 5000) WHERE id = tc.id;
  END IF;
  UPDATE solicitudes SET estado='aprobada', resuelta_por=staff, resuelta_en=now() WHERE id=s.id;
  SELECT * INTO u FROM usuarios WHERE id = s.usuario_id;
  PERFORM public.log_audit('APROBAR_CREDITO','solicitud', s.id, u.nombre, jsonb_build_object('solicitud', s.id));
END;
$$;


--
-- Name: cancelar_multa(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cancelar_multa(_multa_id uuid, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE m multas%ROWTYPE; u usuarios%ROWTYPE;
BEGIN
  IF NOT (public.has_role('policia') OR public.has_role('admin')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO m FROM multas WHERE id = _multa_id FOR UPDATE;
  IF m.id IS NULL THEN RAISE EXCEPTION 'Multa no encontrada'; END IF;
  IF m.estado <> 'pendiente' THEN RAISE EXCEPTION 'Multa ya resuelta'; END IF;
  UPDATE multas SET estado='cancelada', fecha_pago=now() WHERE id = m.id;
  SELECT * INTO u FROM usuarios WHERE id = m.usuario_id;
  PERFORM public.log_audit('CANCELAR_MULTA','multa', m.id, u.nombre, jsonb_build_object('motivo', _motivo));
END $$;


--
-- Name: cerrar_cuenta(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cerrar_cuenta(_usuario_id uuid, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE; antes public.estado_cuenta_general;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id FOR UPDATE;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  IF u.estado_cuenta = 'cerrada' THEN RAISE EXCEPTION 'La cuenta ya esta cerrada'; END IF;
  antes := u.estado_cuenta;
  UPDATE usuarios SET estado_cuenta = 'cerrada' WHERE id = u.id;
  UPDATE tarjetas_debito SET estado = 'cerrada', congelada = true WHERE usuario_id = u.id;
  UPDATE tarjetas_credito SET estado = 'cerrada' WHERE usuario_id = u.id;
  PERFORM public.log_audit('CERRAR_CUENTA','usuario', u.id, u.nombre,
    jsonb_build_object('motivo', _motivo, 'antes', antes, 'despues', 'cerrada'));
END $$;


--
-- Name: check_limite_transaccion(uuid, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_limite_transaccion(_usuario_id uuid, _monto numeric) RETURNS void
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE; cfg config_membresias%ROWTYPE; tx_hoy int; tx_grandes_hoy int;
BEGIN
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id;
  SELECT * INTO cfg FROM config_membresias WHERE tipo = u.membresia;
  IF cfg.tipo IS NULL THEN RETURN; END IF;
  SELECT count(*), count(*) FILTER (WHERE monto >= cfg.monto_grande)
    INTO tx_hoy, tx_grandes_hoy
    FROM movimientos
    WHERE usuario_id = _usuario_id
      AND tipo IN ('transferencia_enviada','retiro','deposito')
      AND fecha >= date_trunc('day', now());
  IF cfg.tx_diarias >= 0 AND tx_hoy >= cfg.tx_diarias THEN
    RAISE EXCEPTION 'Limite diario de transacciones alcanzado (% / membresia %)', cfg.tx_diarias, u.membresia;
  END IF;
  IF _monto >= cfg.monto_grande AND tx_grandes_hoy >= cfg.tx_grandes_diarias THEN
    RAISE EXCEPTION 'Limite de transacciones grandes alcanzado (% / membresia %)', cfg.tx_grandes_diarias, u.membresia;
  END IF;
END $$;


--
-- Name: cobrar_impuestos_tick(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cobrar_impuestos_tick() RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE r record; cobrado_total numeric := 0; n int := 0; debido numeric; tomar numeric; faltante numeric;
BEGIN
  FOR r IN
    SELECT u.id, u.saldo_banco, u.impuestos_pendientes, c.impuesto_pct
    FROM usuarios u JOIN config_membresias c ON c.tipo = u.membresia
    WHERE u.estado_cuenta = 'activa'
      AND (u.ultimo_impuesto_en IS NULL OR (now() - u.ultimo_impuesto_en) >= interval '6 days')
  LOOP
    debido := round((r.saldo_banco * r.impuesto_pct / 100)::numeric, 2);
    IF debido <= 0 THEN
      UPDATE usuarios SET ultimo_impuesto_en = now() WHERE id = r.id;
      CONTINUE;
    END IF;
    tomar := LEAST(debido, r.saldo_banco);
    faltante := debido - tomar;
    UPDATE usuarios SET saldo_banco = saldo_banco - tomar,
      impuestos_pendientes = impuestos_pendientes + faltante,
      ultimo_impuesto_en = now() WHERE id = r.id;
    IF tomar > 0 THEN
      INSERT INTO movimientos(usuario_id, tipo, monto, descripcion)
        VALUES (r.id, 'impuesto'::tipo_movimiento, tomar, 'Impuesto (' || r.impuesto_pct || '%)');
      INSERT INTO ganancias_banco(concepto, usuario_id, monto) VALUES ('impuesto', r.id, tomar);
      UPDATE public.config SET saldo_gobierno = saldo_gobierno + tomar WHERE id = 1;
      cobrado_total := cobrado_total + tomar;
      n := n + 1;
    END IF;
  END LOOP;
  RETURN jsonb_build_object('procesados', n, 'cobrado_total', cobrado_total);
END $$;


--
-- Name: comprar_membresia(public.tipo_membresia); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.comprar_membresia(_tipo public.tipo_membresia) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); u usuarios%ROWTYPE; cfg config_membresias%ROWTYPE; owner uuid;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  SELECT * INTO cfg FROM config_membresias WHERE tipo = _tipo;
  IF cfg.tipo IS NULL THEN RAISE EXCEPTION 'Membresia invalida'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = uid FOR UPDATE;
  IF u.estado_cuenta <> 'activa' THEN RAISE EXCEPTION 'Cuenta no activa'; END IF;
  IF u.membresia = _tipo THEN RAISE EXCEPTION 'Ya tienes esta membresia'; END IF;
  IF cfg.costo > 0 THEN
    IF u.saldo_banco < cfg.costo THEN RAISE EXCEPTION 'Saldo banco insuficiente'; END IF;
    UPDATE usuarios SET saldo_banco = saldo_banco - cfg.costo WHERE id = uid;
    INSERT INTO movimientos(usuario_id, tipo, monto, descripcion) VALUES (uid, 'compra_membresia'::tipo_movimiento, cfg.costo, 'Compra membresia ' || _tipo::text);
    owner := public.dueno_usuario_id();
    IF owner IS NOT NULL THEN
      UPDATE usuarios SET saldo_banco = saldo_banco + cfg.costo WHERE id = owner;
      INSERT INTO ganancias_banco(concepto, usuario_id, monto) VALUES ('compra_membresia', uid, cfg.costo);
      INSERT INTO movimientos(usuario_id, tipo, monto, descripcion) VALUES (owner, 'ganancia_banco'::tipo_movimiento, cfg.costo, 'Ingreso membresia ' || _tipo::text);
    END IF;
  END IF;
  UPDATE usuarios SET membresia = _tipo WHERE id = uid;
  INSERT INTO membresias(usuario_id, tipo, fecha_inicio, fecha_renovacion, activa)
    VALUES (uid, _tipo, now(), now() + interval '30 days', true);
  PERFORM public.log_audit('COMPRA_MEMBRESIA','usuario', uid, u.nombre, jsonb_build_object('tipo', _tipo, 'costo', cfg.costo));
  RETURN jsonb_build_object('tipo', _tipo, 'role_id_discord', cfg.role_id_discord);
END $$;


--
-- Name: condonar_deuda(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.condonar_deuda(_usuario_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE deuda numeric;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT saldo_usado INTO deuda FROM tarjetas_credito WHERE usuario_id = _usuario_id FOR UPDATE;
  IF deuda IS NULL OR deuda <= 0 THEN RAISE EXCEPTION 'Sin deuda que condonar'; END IF;
  UPDATE tarjetas_credito SET saldo_usado = 0, fecha_uso = NULL, fecha_limite_pago = NULL, dias_vencidos = 0,
    estado = CASE WHEN estado='bloqueada' THEN 'activa' ELSE estado END WHERE usuario_id = _usuario_id;
  INSERT INTO movimientos(usuario_id, tipo, monto, descripcion) VALUES (_usuario_id, 'condonacion', deuda, 'Deuda condonada');
END; $$;


--
-- Name: congelar_cuenta(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.congelar_cuenta(_usuario_id uuid, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id FOR UPDATE;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  IF u.estado_cuenta = 'cerrada' THEN RAISE EXCEPTION 'Cuenta cerrada, no se puede congelar'; END IF;
  UPDATE usuarios SET estado_cuenta = 'congelada' WHERE id = u.id;
  UPDATE tarjetas_debito SET estado = 'congelada', congelada = true WHERE usuario_id = u.id;
  PERFORM public.log_audit('CONGELAR_CUENTA','usuario', u.id, u.nombre,
    jsonb_build_object('motivo', _motivo, 'antes', u.estado_cuenta, 'despues', 'congelada'));
END $$;


--
-- Name: crear_tarjeta_debito_inicial(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crear_tarjeta_debito_inicial() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE num TEXT; cvv TEXT; venc TEXT;
BEGIN
  num := '4' || lpad((floor(random()*999999999999999)::bigint)::text, 15, '0');
  cvv := lpad((floor(random()*999)::int)::text, 3, '0');
  venc := lpad((floor(random()*12)::int + 1)::text, 2, '0') || '/' || to_char(now() + interval '4 years', 'YY');
  INSERT INTO public.tarjetas_debito(usuario_id, numero, cvv, vencimiento) VALUES (NEW.id, num, cvv, venc);
  INSERT INTO public.roles_usuario(usuario_id, role) VALUES (NEW.id, 'usuario');
  INSERT INTO public.tarjetas_credito(usuario_id, estado) VALUES (NEW.id, 'sin_solicitar');
  RETURN NEW;
END;
$$;


--
-- Name: current_usuario_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_usuario_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
$$;


--
-- Name: descongelar_cuenta(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.descongelar_cuenta(_usuario_id uuid, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id FOR UPDATE;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  IF u.estado_cuenta <> 'congelada' THEN RAISE EXCEPTION 'Cuenta no esta congelada'; END IF;
  UPDATE usuarios SET estado_cuenta = 'activa' WHERE id = u.id;
  UPDATE tarjetas_debito SET estado = 'activa', congelada = false WHERE usuario_id = u.id;
  PERFORM public.log_audit('DESCONGELAR_CUENTA','usuario', u.id, u.nombre,
    jsonb_build_object('motivo', _motivo, 'antes','congelada','despues','activa'));
END $$;


--
-- Name: dueno_usuario_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dueno_usuario_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT u.id FROM public.usuarios u
  JOIN public.config c ON c.id = 1
  WHERE u.discord_id = c.dueno_discord_id
  LIMIT 1
$$;


--
-- Name: emitir_multa(uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.emitir_multa(_usuario_id uuid, _monto numeric, _motivo text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE staff uuid := public.current_usuario_id(); mid uuid; u usuarios%ROWTYPE;
BEGIN
  IF NOT (public.has_role('policia') OR public.has_role('admin')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  IF _motivo IS NULL OR length(trim(_motivo)) < 3 THEN RAISE EXCEPTION 'Motivo requerido'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  INSERT INTO multas(usuario_id, policia_id, monto, motivo) VALUES (_usuario_id, staff, _monto, _motivo) RETURNING id INTO mid;
  PERFORM public.log_audit('EMITIR_MULTA','multa', mid, u.nombre, jsonb_build_object('monto', _monto, 'motivo', _motivo));
  RETURN mid;
END $$;


--
-- Name: generar_clabe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generar_clabe() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE c text;
BEGIN
  LOOP
    c := '6461801' || lpad((floor(random()*99999999999)::bigint)::text, 11, '0');
    EXIT WHEN NOT EXISTS (SELECT 1 FROM public.usuarios WHERE clabe = c);
  END LOOP;
  RETURN c;
END $$;


--
-- Name: generar_numero_cliente(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generar_numero_cliente() RETURNS text
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE num TEXT;
BEGIN
  num := 'BMX' || lpad((floor(random()*9999999)::int)::text, 7, '0');
  RETURN num;
END;
$$;


--
-- Name: has_role(public.app_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_role(_role public.app_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.roles_usuario r
    JOIN public.usuarios u ON u.id = r.usuario_id
    WHERE u.auth_user_id = auth.uid() AND r.role = _role
  )
$$;


--
-- Name: log_audit(text, text, uuid, text, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_audit(_accion text, _entidad text, _entidad_id uuid, _cliente_nombre text, _detalle jsonb) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE staff_id uuid; staff_nombre text; staff_rol text;
BEGIN
  staff_id := public.current_usuario_id();
  IF staff_id IS NOT NULL THEN
    SELECT nombre INTO staff_nombre FROM usuarios WHERE id = staff_id;
    SELECT string_agg(role::text, ',') INTO staff_rol FROM roles_usuario WHERE usuario_id = staff_id;
  END IF;
  INSERT INTO audit_logs(realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle)
  VALUES (staff_id, staff_nombre, staff_rol, _accion, _entidad, _entidad_id, _cliente_nombre, COALESCE(_detalle, '{}'::jsonb));
END $$;


--
-- Name: marcar_recordatorio_multa(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.marcar_recordatorio_multa(_multa_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF NOT (public.has_role('policia') OR public.has_role('admin')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  UPDATE multas SET ultimo_recordatorio = now() WHERE id = _multa_id;
END $$;


--
-- Name: op_depositar(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.op_depositar(_monto numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); cartera numeric; banco numeric; est public.estado_cuenta_general; tope numeric;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  PERFORM public.check_limite_transaccion(uid, _monto);
  SELECT saldo_cartera, saldo_banco, estado_cuenta INTO cartera, banco, est FROM usuarios WHERE id = uid FOR UPDATE;
  IF est <> 'activa' THEN RAISE EXCEPTION 'Cuenta no activa (%)', est; END IF;
  IF cartera < _monto THEN RAISE EXCEPTION 'Saldo insuficiente en cartera'; END IF;
  SELECT cm.debito_max INTO tope FROM usuarios u JOIN config_membresias cm ON cm.tipo = u.membresia WHERE u.id = uid;
  IF tope IS NOT NULL AND tope > 0 AND (banco + _monto) > tope THEN
    RAISE EXCEPTION 'Excede tu tope de debito (%). Mejora tu membresia.', tope;
  END IF;
  UPDATE usuarios SET saldo_cartera = saldo_cartera - _monto, saldo_banco = saldo_banco + _monto WHERE id = uid;
  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES (uid, 'deposito', _monto, 'Deposito a cuenta');
END;
$$;


--
-- Name: op_retirar(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.op_retirar(_monto numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); banco numeric; cartera numeric; est public.estado_cuenta_general; tope numeric;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  PERFORM public.check_limite_transaccion(uid, _monto);
  SELECT saldo_banco, saldo_cartera, estado_cuenta INTO banco, cartera, est FROM usuarios WHERE id = uid FOR UPDATE;
  IF est <> 'activa' THEN RAISE EXCEPTION 'Cuenta no activa (%)', est; END IF;
  IF banco < _monto THEN RAISE EXCEPTION 'Saldo insuficiente en banco'; END IF;
  SELECT cm.cartera_max INTO tope FROM usuarios u JOIN config_membresias cm ON cm.tipo = u.membresia WHERE u.id = uid;
  IF tope IS NOT NULL AND tope > 0 AND (cartera + _monto) > tope THEN
    RAISE EXCEPTION 'Excede tu tope de cartera (%). Mejora tu membresia.', tope;
  END IF;
  UPDATE usuarios SET saldo_banco = saldo_banco - _monto, saldo_cartera = saldo_cartera + _monto WHERE id = uid;
  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES (uid, 'retiro', _monto, 'Retiro a cartera');
END;
$$;


--
-- Name: op_transferir(text, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.op_transferir(_destino_numero text, _monto numeric, _concepto text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); destino usuarios%ROWTYPE; origen usuarios%ROWTYPE; pct numeric; comision numeric; total numeric;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  PERFORM public.check_limite_transaccion(uid, _monto);
  SELECT * INTO destino FROM usuarios WHERE numero_cliente = _destino_numero OR clabe = _destino_numero;
  IF destino.id IS NULL THEN RAISE EXCEPTION 'Cliente destino no existe'; END IF;
  IF destino.id = uid THEN RAISE EXCEPTION 'No puedes transferirte a ti mismo'; END IF;
  IF destino.estado_cuenta <> 'activa' THEN RAISE EXCEPTION 'Cuenta destino no activa'; END IF;
  SELECT comision_porcentaje INTO pct FROM config WHERE id = 1;
  pct := COALESCE(pct, 0);
  comision := round((_monto * pct / 100)::numeric, 2);
  total := _monto + comision;
  SELECT * INTO origen FROM usuarios WHERE id = uid FOR UPDATE;
  IF origen.estado_cuenta <> 'activa' THEN RAISE EXCEPTION 'Tu cuenta no esta activa'; END IF;
  IF origen.saldo_banco < total THEN RAISE EXCEPTION 'Saldo insuficiente. Necesitas %', total; END IF;
  UPDATE usuarios SET saldo_banco = saldo_banco - total WHERE id = uid;
  UPDATE usuarios SET saldo_banco = saldo_banco + _monto WHERE id = destino.id;
  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion, contraparte_id)
    VALUES (uid, 'transferencia_enviada', _monto, 'A ' || destino.nombre || ' (' || destino.numero_cliente || ')' || CASE WHEN _concepto IS NOT NULL AND length(_concepto)>0 THEN ' - '||_concepto ELSE '' END, destino.id);
  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion, contraparte_id)
    VALUES (destino.id, 'transferencia_recibida', _monto, 'De ' || origen.nombre || ' (' || origen.numero_cliente || ')' || CASE WHEN _concepto IS NOT NULL AND length(_concepto)>0 THEN ' - '||_concepto ELSE '' END, uid);
  IF comision > 0 THEN
    INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES (uid, 'comision', comision, 'Comision por transferencia');
    PERFORM public.registrar_ganancia('comision_transferencia', uid, comision);
  END IF;
  RETURN jsonb_build_object('monto', _monto, 'comision', comision, 'total', total, 'destino_nombre', destino.nombre, 'destino_numero', destino.numero_cliente, 'destino_id', destino.id);
END $$;


--
-- Name: pagar_credito(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pagar_credito(_monto numeric) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); tc tarjetas_credito%ROWTYPE; u usuarios%ROWTYPE; pago numeric; liquidada boolean := false;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  SELECT * INTO tc FROM tarjetas_credito WHERE usuario_id = uid FOR UPDATE;
  IF tc.id IS NULL OR tc.saldo_usado <= 0 THEN RAISE EXCEPTION 'No tienes deuda'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = uid FOR UPDATE;
  pago := LEAST(_monto, tc.saldo_usado);
  IF u.saldo_banco < pago THEN RAISE EXCEPTION 'Saldo insuficiente en banco'; END IF;
  UPDATE usuarios SET saldo_banco = saldo_banco - pago WHERE id = uid;
  UPDATE tarjetas_credito SET saldo_usado = saldo_usado - pago WHERE id = tc.id;
  INSERT INTO movimientos(usuario_id, tipo, monto, descripcion) VALUES (uid, 'pago_credito', pago, 'Pago a tarjeta de credito');
  IF (tc.saldo_usado - pago) <= 0 THEN
    liquidada := true;
    UPDATE tarjetas_credito SET fecha_uso = NULL, fecha_limite_pago = NULL, dias_vencidos = 0,
      pagos_a_tiempo = pagos_a_tiempo + 1, score = LEAST(100, score + 5),
      estado = CASE WHEN estado='bloqueada' THEN 'activa' ELSE estado END WHERE id = tc.id;
  END IF;
  RETURN jsonb_build_object('pagado', pago, 'liquidada', liquidada);
END; $$;


--
-- Name: pagar_multa(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pagar_multa(_multa_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); m multas%ROWTYPE; u usuarios%ROWTYPE;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  SELECT * INTO m FROM multas WHERE id = _multa_id FOR UPDATE;
  IF m.id IS NULL THEN RAISE EXCEPTION 'Multa no encontrada'; END IF;
  IF m.usuario_id <> uid THEN RAISE EXCEPTION 'No es tu multa'; END IF;
  IF m.estado <> 'pendiente' THEN RAISE EXCEPTION 'Multa ya resuelta'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = uid FOR UPDATE;
  IF u.saldo_banco < m.monto THEN RAISE EXCEPTION 'Saldo banco insuficiente'; END IF;
  UPDATE usuarios SET saldo_banco = saldo_banco - m.monto WHERE id = uid;
  UPDATE multas SET estado='pagada', fecha_pago=now() WHERE id = m.id;
  INSERT INTO movimientos(usuario_id, tipo, monto, descripcion)
    VALUES (uid, 'pago_multa'::tipo_movimiento, m.monto, 'Pago de multa: ' || m.motivo);
  -- Al pozo del gobierno (no al dueno)
  UPDATE public.config SET saldo_gobierno = saldo_gobierno + m.monto WHERE id = 1;
  INSERT INTO public.ganancias_banco(concepto, usuario_id, monto) VALUES ('multa', uid, m.monto);
END $$;


--
-- Name: proximo_sueldo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.proximo_sueldo() RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); v_role public.app_role; v_monto numeric; v_dias int; ultimo timestamptz;
BEGIN
  IF uid IS NULL THEN RETURN NULL; END IF;
  SELECT r.role, c.monto, c.dias_periodo INTO v_role, v_monto, v_dias
  FROM roles_usuario r JOIN config_sueldos c ON c.role = r.role
  WHERE r.usuario_id = uid AND c.activo = true AND c.monto > 0
  ORDER BY c.monto DESC LIMIT 1;
  IF v_role IS NULL THEN RETURN NULL; END IF;
  SELECT max(fecha) INTO ultimo FROM sueldos_reclamados WHERE usuario_id = uid AND role = v_role;
  RETURN jsonb_build_object('role', v_role, 'monto', v_monto, 'dias_periodo', v_dias, 'ultimo', ultimo,
    'disponible', ultimo IS NULL OR (now() - ultimo) >= (v_dias || ' days')::interval,
    'proximo', CASE WHEN ultimo IS NULL THEN now() ELSE ultimo + (v_dias || ' days')::interval END);
END $$;


--
-- Name: reabrir_cuenta(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reabrir_cuenta(_usuario_id uuid, _motivo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE u usuarios%ROWTYPE; antes public.estado_cuenta_general;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id FOR UPDATE;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  IF u.estado_cuenta = 'activa' THEN RAISE EXCEPTION 'La cuenta ya esta activa'; END IF;
  antes := u.estado_cuenta;
  UPDATE usuarios SET estado_cuenta = 'activa' WHERE id = u.id;
  UPDATE tarjetas_debito SET estado = 'activa', congelada = false WHERE usuario_id = u.id;
  PERFORM public.log_audit('REABRIR_CUENTA','usuario', u.id, u.nombre,
    jsonb_build_object('motivo', _motivo, 'antes', antes, 'despues', 'activa'));
END $$;


--
-- Name: rechazar_tarjeta_credito(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rechazar_tarjeta_credito(_solicitud_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE staff uuid := public.current_usuario_id(); s solicitudes%ROWTYPE;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO s FROM solicitudes WHERE id = _solicitud_id FOR UPDATE;
  IF s.id IS NULL OR s.tipo <> 'tarjeta_credito' THEN RAISE EXCEPTION 'Solicitud invalida'; END IF;
  IF s.estado <> 'pendiente' THEN RAISE EXCEPTION 'Solicitud ya resuelta'; END IF;
  UPDATE tarjetas_credito SET estado='rechazada' WHERE usuario_id = s.usuario_id;
  UPDATE solicitudes SET estado='rechazada', resuelta_por=staff, resuelta_en=now() WHERE id=s.id;
END; $$;


--
-- Name: reclamar_sueldo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reclamar_sueldo() RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); v_role public.app_role; v_monto numeric; v_dias int; ultimo timestamptz; pozo numeric;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  SELECT r.role, c.monto, c.dias_periodo INTO v_role, v_monto, v_dias
  FROM roles_usuario r JOIN config_sueldos c ON c.role = r.role
  WHERE r.usuario_id = uid AND c.activo = true AND c.monto > 0
  ORDER BY c.monto DESC LIMIT 1;
  IF v_role IS NULL THEN RAISE EXCEPTION 'No tienes un rol con sueldo asignado'; END IF;
  SELECT max(fecha) INTO ultimo FROM sueldos_reclamados WHERE usuario_id = uid AND role = v_role;
  IF ultimo IS NOT NULL AND (now() - ultimo) < (v_dias || ' days')::interval THEN
    RAISE EXCEPTION 'Aun no puedes reclamar. Proximo: %', (ultimo + (v_dias || ' days')::interval);
  END IF;
  SELECT saldo_gobierno INTO pozo FROM public.config WHERE id = 1 FOR UPDATE;
  IF pozo IS NULL OR pozo < v_monto THEN RAISE EXCEPTION 'Gobierno sin fondos suficientes'; END IF;
  UPDATE public.config SET saldo_gobierno = saldo_gobierno - v_monto WHERE id = 1;
  UPDATE usuarios SET saldo_banco = saldo_banco + v_monto WHERE id = uid;
  INSERT INTO movimientos(usuario_id, tipo, monto, descripcion)
    VALUES (uid, 'sueldo'::tipo_movimiento, v_monto, 'Sueldo de ' || v_role::text || ' (gobierno)');
  INSERT INTO sueldos_reclamados(usuario_id, role, monto) VALUES (uid, v_role, v_monto);
  RETURN jsonb_build_object('monto', v_monto, 'role', v_role, 'proximo', now() + (v_dias || ' days')::interval);
END $$;


--
-- Name: registrar_ganancia(text, uuid, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.registrar_ganancia(_concepto text, _usuario uuid, _monto numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE owner_id uuid;
BEGIN
  IF _monto IS NULL OR _monto <= 0 THEN RETURN; END IF;
  INSERT INTO public.ganancias_banco(concepto, usuario_id, monto) VALUES (_concepto, _usuario, _monto);
  owner_id := public.dueno_usuario_id();
  IF owner_id IS NOT NULL THEN
    UPDATE public.usuarios SET saldo_banco = saldo_banco + _monto WHERE id = owner_id;
    INSERT INTO public.movimientos(usuario_id, tipo, monto, descripcion)
      VALUES (owner_id, 'ganancia_banco', _monto, 'Ganancia: ' || _concepto);
  END IF;
END; $$;


--
-- Name: set_dueno_banco(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_dueno_banco(_discord_id text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE clean text := NULLIF(trim(_discord_id), '');
BEGIN
  IF NOT public.has_role('admin') THEN RAISE EXCEPTION 'Solo admin'; END IF;
  IF clean IS NULL THEN UPDATE config SET dueno_discord_id = NULL WHERE id = 1; RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM usuarios WHERE discord_id = clean) THEN RAISE EXCEPTION 'Ese Discord ID no esta registrado en el banco'; END IF;
  UPDATE config SET dueno_discord_id = clean WHERE id = 1;
END; $$;


--
-- Name: solicitar_tarjeta_credito(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.solicitar_tarjeta_credito() RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); tc tarjetas_credito%ROWTYPE; sol_id uuid;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  SELECT * INTO tc FROM tarjetas_credito WHERE usuario_id = uid;
  IF tc.id IS NULL THEN
    INSERT INTO tarjetas_credito(usuario_id, estado) VALUES (uid, 'pendiente') RETURNING id INTO tc.id;
  ELSE
    IF tc.estado IN ('pendiente','activa') THEN RAISE EXCEPTION 'Ya tienes una solicitud o tarjeta activa'; END IF;
    UPDATE tarjetas_credito SET estado='pendiente' WHERE id = tc.id;
  END IF;
  INSERT INTO solicitudes(usuario_id, tipo, estado) VALUES (uid, 'tarjeta_credito', 'pendiente') RETURNING id INTO sol_id;
  RETURN sol_id;
END;
$$;


--
-- Name: toggle_tarjeta_debito(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.toggle_tarjeta_debito() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); nuevo boolean;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  UPDATE tarjetas_debito SET congelada = NOT congelada WHERE usuario_id = uid RETURNING congelada INTO nuevo;
  RETURN nuevo;
END; $$;


--
-- Name: usar_credito(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.usar_credito(_monto numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid := public.current_usuario_id(); tc tarjetas_credito%ROWTYPE; disponible numeric; est public.estado_cuenta_general; cred_max numeric; lim_efectivo numeric;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  SELECT estado_cuenta INTO est FROM usuarios WHERE id = uid;
  IF est <> 'activa' THEN RAISE EXCEPTION 'Cuenta no activa'; END IF;
  SELECT * INTO tc FROM tarjetas_credito WHERE usuario_id = uid FOR UPDATE;
  IF tc.id IS NULL OR tc.estado <> 'activa' THEN RAISE EXCEPTION 'No tienes tarjeta de credito activa'; END IF;
  SELECT cm.credito_max INTO cred_max FROM usuarios u JOIN config_membresias cm ON cm.tipo = u.membresia WHERE u.id = uid;
  lim_efectivo := LEAST(tc.limite, COALESCE(NULLIF(cred_max,0), tc.limite));
  disponible := lim_efectivo - tc.saldo_usado;
  IF _monto > disponible THEN RAISE EXCEPTION 'Excede tu limite disponible (%)', disponible; END IF;
  UPDATE tarjetas_credito SET saldo_usado = saldo_usado + _monto,
    fecha_uso = COALESCE(fecha_uso, now()),
    fecha_corte = COALESCE(fecha_corte, now()),
    fecha_limite_pago = COALESCE(fecha_limite_pago, now() + interval '6 days') WHERE id = tc.id;
  UPDATE usuarios SET saldo_banco = saldo_banco + _monto WHERE id = uid;
  INSERT INTO movimientos(usuario_id, tipo, monto, descripcion) VALUES (uid, 'uso_credito', _monto, 'Uso de credito');
END;
$$;


--
-- Name: usuarios_set_clabe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.usuarios_set_clabe() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN IF NEW.clabe IS NULL THEN NEW.clabe := public.generar_clabe(); END IF; RETURN NEW; END $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    realizado_por_id uuid,
    realizado_por_nombre text,
    realizado_por_rol text,
    accion text NOT NULL,
    entidad text,
    entidad_id uuid,
    cliente_nombre text,
    detalle jsonb DEFAULT '{}'::jsonb NOT NULL,
    ip_address text,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.config (
    id integer DEFAULT 1 NOT NULL,
    dueno_discord_id text,
    comision_porcentaje numeric(5,2) DEFAULT 1.5 NOT NULL,
    interes_diario_porcentaje numeric(5,2) DEFAULT 5.0 NOT NULL,
    costo_membresia_plus numeric(14,2) DEFAULT 75000 NOT NULL,
    costo_membresia_black numeric(14,2) DEFAULT 350000 NOT NULL,
    saldo_gobierno numeric DEFAULT 0 NOT NULL,
    CONSTRAINT singleton CHECK ((id = 1))
);


--
-- Name: config_membresias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.config_membresias (
    tipo public.tipo_membresia NOT NULL,
    costo numeric DEFAULT 0 NOT NULL,
    tx_diarias integer DEFAULT 5 NOT NULL,
    tx_grandes_diarias integer DEFAULT 2 NOT NULL,
    monto_grande numeric DEFAULT 55000 NOT NULL,
    debito_max numeric DEFAULT 100000 NOT NULL,
    cartera_max numeric DEFAULT 65000 NOT NULL,
    credito_max numeric DEFAULT 0 NOT NULL,
    seguridad_antihackeo_pct integer DEFAULT 0 NOT NULL,
    seguro_dinero_pct integer DEFAULT 0 NOT NULL,
    nivel_soporte text DEFAULT 'normal'::text NOT NULL,
    role_id_discord text,
    impuesto_pct numeric DEFAULT 20 NOT NULL,
    orden integer DEFAULT 0 NOT NULL
);


--
-- Name: config_sueldos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.config_sueldos (
    role public.app_role NOT NULL,
    monto numeric DEFAULT 0 NOT NULL,
    dias_periodo integer DEFAULT 7 NOT NULL,
    activo boolean DEFAULT true NOT NULL
);


--
-- Name: ganancias_banco; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ganancias_banco (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    concepto text NOT NULL,
    usuario_id uuid,
    monto numeric(14,2) NOT NULL,
    fecha timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: login_codigos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_codigos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    discord_id text NOT NULL,
    codigo_hash text NOT NULL,
    intentos integer DEFAULT 0 NOT NULL,
    expira_en timestamp with time zone NOT NULL,
    usado boolean DEFAULT false NOT NULL,
    creado_en timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: membresias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membresias (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    tipo public.tipo_membresia NOT NULL,
    fecha_inicio timestamp with time zone DEFAULT now() NOT NULL,
    fecha_renovacion timestamp with time zone NOT NULL,
    activa boolean DEFAULT true NOT NULL
);


--
-- Name: movimientos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movimientos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    tipo public.tipo_movimiento NOT NULL,
    monto numeric(14,2) NOT NULL,
    descripcion text NOT NULL,
    contraparte_id uuid,
    fecha timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: multas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.multas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    policia_id uuid,
    monto numeric NOT NULL,
    motivo text NOT NULL,
    estado public.estado_multa DEFAULT 'pendiente'::public.estado_multa NOT NULL,
    fecha_emision timestamp with time zone DEFAULT now() NOT NULL,
    fecha_pago timestamp with time zone,
    ultimo_recordatorio timestamp with time zone,
    CONSTRAINT multas_monto_check CHECK ((monto > (0)::numeric))
);


--
-- Name: notification_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    discord_user_id text,
    tipo_notificacion text NOT NULL,
    mensaje text NOT NULL,
    estado public.estado_notificacion DEFAULT 'enviado'::public.estado_notificacion NOT NULL,
    error text,
    enviado_en timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: roles_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles_usuario (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    role public.app_role NOT NULL
);


--
-- Name: solicitudes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solicitudes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    tipo text NOT NULL,
    estado public.estado_solicitud DEFAULT 'pendiente'::public.estado_solicitud NOT NULL,
    fecha timestamp with time zone DEFAULT now() NOT NULL,
    resuelta_en timestamp with time zone,
    resuelta_por uuid
);


--
-- Name: sueldos_reclamados; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sueldos_reclamados (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    role public.app_role NOT NULL,
    monto numeric NOT NULL,
    fecha timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tarjetas_credito; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tarjetas_credito (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    numero text,
    cvv text,
    vencimiento text,
    limite numeric(14,2) DEFAULT 5000 NOT NULL,
    saldo_usado numeric(14,2) DEFAULT 0 NOT NULL,
    nivel integer DEFAULT 1 NOT NULL,
    estado public.estado_credito DEFAULT 'sin_solicitar'::public.estado_credito NOT NULL,
    fecha_uso timestamp with time zone,
    fecha_limite_pago timestamp with time zone,
    dias_vencidos integer DEFAULT 0 NOT NULL,
    pagos_a_tiempo integer DEFAULT 0 NOT NULL,
    score integer DEFAULT 50 NOT NULL,
    fecha_corte timestamp with time zone
);


--
-- Name: tarjetas_debito; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tarjetas_debito (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    numero text NOT NULL,
    cvv text NOT NULL,
    vencimiento text NOT NULL,
    congelada boolean DEFAULT false NOT NULL,
    creada_en timestamp with time zone DEFAULT now() NOT NULL,
    estado public.estado_tarjeta_debito DEFAULT 'activa'::public.estado_tarjeta_debito NOT NULL
);


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    discord_id text NOT NULL,
    discord_username text NOT NULL,
    discord_avatar_url text,
    nombre text NOT NULL,
    numero_cliente text NOT NULL,
    saldo_cartera numeric(14,2) DEFAULT 0 NOT NULL,
    saldo_banco numeric(14,2) DEFAULT 0 NOT NULL,
    nip_hash text,
    membresia public.tipo_membresia DEFAULT 'basica'::public.tipo_membresia NOT NULL,
    intentos_fallidos integer DEFAULT 0 NOT NULL,
    bloqueado_hasta timestamp with time zone,
    fecha_registro timestamp with time zone DEFAULT now() NOT NULL,
    auth_user_id uuid,
    estado_cuenta public.estado_cuenta_general DEFAULT 'activa'::public.estado_cuenta_general NOT NULL,
    clabe text,
    impuestos_pendientes numeric DEFAULT 0 NOT NULL,
    ultimo_impuesto_en timestamp with time zone,
    CONSTRAINT usuarios_saldo_banco_nonneg CHECK ((saldo_banco >= (0)::numeric)),
    CONSTRAINT usuarios_saldo_cartera_nonneg CHECK ((saldo_cartera >= (0)::numeric))
);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: config_membresias config_membresias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.config_membresias
    ADD CONSTRAINT config_membresias_pkey PRIMARY KEY (tipo);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- Name: config_sueldos config_sueldos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.config_sueldos
    ADD CONSTRAINT config_sueldos_pkey PRIMARY KEY (role);


--
-- Name: ganancias_banco ganancias_banco_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ganancias_banco
    ADD CONSTRAINT ganancias_banco_pkey PRIMARY KEY (id);


--
-- Name: login_codigos login_codigos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_codigos
    ADD CONSTRAINT login_codigos_pkey PRIMARY KEY (id);


--
-- Name: membresias membresias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membresias
    ADD CONSTRAINT membresias_pkey PRIMARY KEY (id);


--
-- Name: movimientos movimientos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimientos
    ADD CONSTRAINT movimientos_pkey PRIMARY KEY (id);


--
-- Name: multas multas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multas
    ADD CONSTRAINT multas_pkey PRIMARY KEY (id);


--
-- Name: notification_log notification_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_pkey PRIMARY KEY (id);


--
-- Name: roles_usuario roles_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_usuario
    ADD CONSTRAINT roles_usuario_pkey PRIMARY KEY (id);


--
-- Name: roles_usuario roles_usuario_usuario_id_role_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_usuario
    ADD CONSTRAINT roles_usuario_usuario_id_role_key UNIQUE (usuario_id, role);


--
-- Name: solicitudes solicitudes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitudes
    ADD CONSTRAINT solicitudes_pkey PRIMARY KEY (id);


--
-- Name: sueldos_reclamados sueldos_reclamados_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sueldos_reclamados
    ADD CONSTRAINT sueldos_reclamados_pkey PRIMARY KEY (id);


--
-- Name: tarjetas_credito tarjetas_credito_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjetas_credito
    ADD CONSTRAINT tarjetas_credito_pkey PRIMARY KEY (id);


--
-- Name: tarjetas_credito tarjetas_credito_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjetas_credito
    ADD CONSTRAINT tarjetas_credito_usuario_id_key UNIQUE (usuario_id);


--
-- Name: tarjetas_debito tarjetas_debito_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjetas_debito
    ADD CONSTRAINT tarjetas_debito_pkey PRIMARY KEY (id);


--
-- Name: tarjetas_debito tarjetas_debito_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjetas_debito
    ADD CONSTRAINT tarjetas_debito_usuario_id_key UNIQUE (usuario_id);


--
-- Name: usuarios usuarios_auth_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_auth_user_id_key UNIQUE (auth_user_id);


--
-- Name: usuarios usuarios_discord_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_discord_id_key UNIQUE (discord_id);


--
-- Name: usuarios usuarios_numero_cliente_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_numero_cliente_key UNIQUE (numero_cliente);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_entidad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_entidad_id_idx ON public.audit_logs USING btree (entidad_id);


--
-- Name: audit_logs_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_fecha_idx ON public.audit_logs USING btree (fecha_hora DESC);


--
-- Name: audit_logs_realizado_por_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_realizado_por_idx ON public.audit_logs USING btree (realizado_por_id);


--
-- Name: idx_audit_logs_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_fecha ON public.audit_logs USING btree (fecha_hora DESC);


--
-- Name: idx_audit_logs_realizado_por; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_realizado_por ON public.audit_logs USING btree (realizado_por_id);


--
-- Name: idx_ganancias_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ganancias_fecha ON public.ganancias_banco USING btree (fecha DESC);


--
-- Name: idx_login_codigos_discord; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_login_codigos_discord ON public.login_codigos USING btree (discord_id, creado_en DESC);


--
-- Name: idx_movimientos_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimientos_fecha ON public.movimientos USING btree (fecha DESC);


--
-- Name: idx_movimientos_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimientos_usuario ON public.movimientos USING btree (usuario_id, fecha DESC);


--
-- Name: idx_movimientos_usuario_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimientos_usuario_fecha ON public.movimientos USING btree (usuario_id, fecha DESC);


--
-- Name: idx_multas_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_multas_estado ON public.multas USING btree (estado);


--
-- Name: idx_multas_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_multas_usuario ON public.multas USING btree (usuario_id, estado);


--
-- Name: idx_notification_log_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_log_usuario ON public.notification_log USING btree (usuario_id, enviado_en DESC);


--
-- Name: idx_solicitudes_estado_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_solicitudes_estado_fecha ON public.solicitudes USING btree (estado, fecha DESC);


--
-- Name: idx_sueldos_usuario_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sueldos_usuario_fecha ON public.sueldos_reclamados USING btree (usuario_id, role, fecha DESC);


--
-- Name: idx_tarjetas_credito_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tarjetas_credito_usuario ON public.tarjetas_credito USING btree (usuario_id);


--
-- Name: idx_tarjetas_debito_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tarjetas_debito_usuario ON public.tarjetas_debito USING btree (usuario_id);


--
-- Name: idx_usuarios_discord_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_discord_id ON public.usuarios USING btree (discord_id);


--
-- Name: idx_usuarios_numero_cliente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_numero_cliente ON public.usuarios USING btree (numero_cliente);


--
-- Name: movimientos_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX movimientos_fecha_idx ON public.movimientos USING btree (fecha DESC);


--
-- Name: movimientos_usuario_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX movimientos_usuario_idx ON public.movimientos USING btree (usuario_id);


--
-- Name: notif_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notif_fecha_idx ON public.notification_log USING btree (enviado_en DESC);


--
-- Name: notif_usuario_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notif_usuario_idx ON public.notification_log USING btree (usuario_id);


--
-- Name: usuarios_clabe_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usuarios_clabe_unique ON public.usuarios USING btree (clabe) WHERE (clabe IS NOT NULL);


--
-- Name: usuarios trg_crear_tarjeta_debito; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_crear_tarjeta_debito AFTER INSERT ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.crear_tarjeta_debito_inicial();


--
-- Name: usuarios trg_usuarios_clabe; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_usuarios_clabe BEFORE INSERT ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.usuarios_set_clabe();


--
-- Name: ganancias_banco ganancias_banco_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ganancias_banco
    ADD CONSTRAINT ganancias_banco_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- Name: membresias membresias_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membresias
    ADD CONSTRAINT membresias_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: movimientos movimientos_contraparte_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimientos
    ADD CONSTRAINT movimientos_contraparte_id_fkey FOREIGN KEY (contraparte_id) REFERENCES public.usuarios(id);


--
-- Name: movimientos movimientos_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimientos
    ADD CONSTRAINT movimientos_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: roles_usuario roles_usuario_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_usuario
    ADD CONSTRAINT roles_usuario_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: solicitudes solicitudes_resuelta_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitudes
    ADD CONSTRAINT solicitudes_resuelta_por_fkey FOREIGN KEY (resuelta_por) REFERENCES public.usuarios(id);


--
-- Name: solicitudes solicitudes_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitudes
    ADD CONSTRAINT solicitudes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: tarjetas_credito tarjetas_credito_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjetas_credito
    ADD CONSTRAINT tarjetas_credito_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: tarjetas_debito tarjetas_debito_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjetas_debito
    ADD CONSTRAINT tarjetas_debito_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: config Admin edita config; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admin edita config" ON public.config FOR UPDATE USING (public.has_role('admin'::public.app_role));


--
-- Name: roles_usuario Admin gestiona roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admin gestiona roles" ON public.roles_usuario USING (public.has_role('admin'::public.app_role)) WITH CHECK (public.has_role('admin'::public.app_role));


--
-- Name: usuarios Admin inserta usuarios; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admin inserta usuarios" ON public.usuarios FOR INSERT WITH CHECK (public.has_role('admin'::public.app_role));


--
-- Name: audit_logs Admin ve audit; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admin ve audit" ON public.audit_logs FOR SELECT USING (public.has_role('admin'::public.app_role));


--
-- Name: solicitudes Crear solicitudes propias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Crear solicitudes propias" ON public.solicitudes FOR INSERT WITH CHECK ((usuario_id = public.current_usuario_id()));


--
-- Name: login_codigos Deny delete login_codigos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny delete login_codigos" ON public.login_codigos FOR DELETE TO authenticated, anon USING (false);


--
-- Name: tarjetas_credito Deny delete tarjetas_credito; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny delete tarjetas_credito" ON public.tarjetas_credito FOR DELETE TO authenticated, anon USING (false);


--
-- Name: tarjetas_debito Deny delete tarjetas_debito; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny delete tarjetas_debito" ON public.tarjetas_debito FOR DELETE TO authenticated, anon USING (false);


--
-- Name: login_codigos Deny insert login_codigos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny insert login_codigos" ON public.login_codigos FOR INSERT TO authenticated, anon WITH CHECK (false);


--
-- Name: tarjetas_credito Deny insert tarjetas_credito; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny insert tarjetas_credito" ON public.tarjetas_credito FOR INSERT TO authenticated, anon WITH CHECK (false);


--
-- Name: tarjetas_debito Deny insert tarjetas_debito; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny insert tarjetas_debito" ON public.tarjetas_debito FOR INSERT TO authenticated, anon WITH CHECK (false);


--
-- Name: login_codigos Deny select login_codigos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny select login_codigos" ON public.login_codigos FOR SELECT TO authenticated, anon USING (false);


--
-- Name: login_codigos Deny update login_codigos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny update login_codigos" ON public.login_codigos FOR UPDATE TO authenticated, anon USING (false);


--
-- Name: tarjetas_credito Deny update tarjetas_credito; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Deny update tarjetas_credito" ON public.tarjetas_credito FOR UPDATE TO authenticated, anon USING (false);


--
-- Name: tarjetas_debito Editar tarjeta propia; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Editar tarjeta propia" ON public.tarjetas_debito FOR UPDATE USING ((usuario_id = public.current_usuario_id()));


--
-- Name: config Lectura config staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Lectura config staff" ON public.config FOR SELECT USING ((public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: roles_usuario Lectura roles propios o admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Lectura roles propios o admin" ON public.roles_usuario FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role)));


--
-- Name: ganancias_banco Staff ve ganancias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Staff ve ganancias" ON public.ganancias_banco FOR SELECT USING ((public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: usuarios Usuarios editan su propio perfil; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios editan su propio perfil" ON public.usuarios FOR UPDATE USING (((auth_user_id = auth.uid()) OR public.has_role('admin'::public.app_role)));


--
-- Name: usuarios Usuarios ven su propio perfil; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios ven su propio perfil" ON public.usuarios FOR SELECT USING (((auth_user_id = auth.uid()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: tarjetas_credito Ver credito propio o staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Ver credito propio o staff" ON public.tarjetas_credito FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: membresias Ver membresias propias o staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Ver membresias propias o staff" ON public.membresias FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: movimientos Ver movimientos propios o staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Ver movimientos propios o staff" ON public.movimientos FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: notification_log Ver notifs propias o admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Ver notifs propias o admin" ON public.notification_log FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role)));


--
-- Name: solicitudes Ver solicitudes propias o staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Ver solicitudes propias o staff" ON public.solicitudes FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: tarjetas_debito Ver tarjeta propia o staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Ver tarjeta propia o staff" ON public.tarjetas_debito FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- Name: config_membresias admin edita config_membresias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "admin edita config_membresias" ON public.config_membresias USING (public.has_role('admin'::public.app_role)) WITH CHECK (public.has_role('admin'::public.app_role));


--
-- Name: config_sueldos admin edita config_sueldos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "admin edita config_sueldos" ON public.config_sueldos USING (public.has_role('admin'::public.app_role)) WITH CHECK (public.has_role('admin'::public.app_role));


--
-- Name: audit_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: config; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.config ENABLE ROW LEVEL SECURITY;

--
-- Name: config_membresias; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.config_membresias ENABLE ROW LEVEL SECURITY;

--
-- Name: config_sueldos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.config_sueldos ENABLE ROW LEVEL SECURITY;

--
-- Name: ganancias_banco; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ganancias_banco ENABLE ROW LEVEL SECURITY;

--
-- Name: config_membresias lectura config_membresias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "lectura config_membresias" ON public.config_membresias FOR SELECT USING (true);


--
-- Name: config_sueldos lectura config_sueldos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "lectura config_sueldos" ON public.config_sueldos FOR SELECT USING (true);


--
-- Name: login_codigos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.login_codigos ENABLE ROW LEVEL SECURITY;

--
-- Name: membresias; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.membresias ENABLE ROW LEVEL SECURITY;

--
-- Name: movimientos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.movimientos ENABLE ROW LEVEL SECURITY;

--
-- Name: multas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.multas ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notification_log ENABLE ROW LEVEL SECURITY;

--
-- Name: roles_usuario; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.roles_usuario ENABLE ROW LEVEL SECURITY;

--
-- Name: solicitudes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.solicitudes ENABLE ROW LEVEL SECURITY;

--
-- Name: sueldos_reclamados; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sueldos_reclamados ENABLE ROW LEVEL SECURITY;

--
-- Name: tarjetas_credito; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tarjetas_credito ENABLE ROW LEVEL SECURITY;

--
-- Name: tarjetas_debito; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tarjetas_debito ENABLE ROW LEVEL SECURITY;

--
-- Name: usuarios; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

--
-- Name: multas ver multas propias o staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "ver multas propias o staff" ON public.multas FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role) OR public.has_role('policia'::public.app_role)));


--
-- Name: sueldos_reclamados ver sueldos propios o staff; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "ver sueldos propios o staff" ON public.sueldos_reclamados FOR SELECT USING (((usuario_id = public.current_usuario_id()) OR public.has_role('admin'::public.app_role) OR public.has_role('trabajador'::public.app_role)));


--
-- PostgreSQL database dump complete
--

\unrestrict oLdS7fMnnycPHfh5Rs7b4CpZ7hJDM7V4c1Nsap5cVNc2YdUuvf7SH1wFRBVyep4

