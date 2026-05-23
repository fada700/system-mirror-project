CREATE OR REPLACE FUNCTION public.cobrar_impuestos_tick()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE r record; cobrado_total numeric := 0; n int := 0; debido numeric; tomar numeric; faltante numeric; owner uuid;
BEGIN
  -- Llamada solo desde cron / service_role (la ruta /api/public/cron-impuestos verifica apikey)
  owner := public.dueno_usuario_id();
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
      INSERT INTO movimientos(usuario_id, tipo, monto, descripcion) VALUES (r.id, 'impuesto'::tipo_movimiento, tomar, 'Impuesto (' || r.impuesto_pct || '%)');
      INSERT INTO ganancias_banco(concepto, usuario_id, monto) VALUES ('impuesto', r.id, tomar);
      IF owner IS NOT NULL THEN UPDATE usuarios SET saldo_banco = saldo_banco + tomar WHERE id = owner; END IF;
      cobrado_total := cobrado_total + tomar;
      n := n + 1;
    END IF;
  END LOOP;
  RETURN jsonb_build_object('procesados', n, 'cobrado_total', cobrado_total);
END $function$;