
CREATE OR REPLACE FUNCTION public.usar_credito(_monto numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION public.solicitar_tarjeta_credito()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$;
