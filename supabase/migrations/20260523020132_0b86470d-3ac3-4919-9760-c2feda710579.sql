
-- Pozo del gobierno
ALTER TABLE public.config ADD COLUMN IF NOT EXISTS saldo_gobierno numeric NOT NULL DEFAULT 0;

-- pagar_multa: acreditar al pozo del gobierno
CREATE OR REPLACE FUNCTION public.pagar_multa(_multa_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
END $function$;

-- cobrar_impuestos_tick: acreditar al pozo del gobierno
CREATE OR REPLACE FUNCTION public.cobrar_impuestos_tick()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
END $function$;

-- reclamar_sueldo: descontar del pozo del gobierno
CREATE OR REPLACE FUNCTION public.reclamar_sueldo()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
END $function$;
