
-- op_depositar: validar limite tx + tope debito_max
CREATE OR REPLACE FUNCTION public.op_depositar(_monto numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$;

-- op_retirar: validar limite tx + tope cartera_max
CREATE OR REPLACE FUNCTION public.op_retirar(_monto numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$;

-- usar_credito: respetar credito_max de la membresia
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
  IF cred_max IS NULL OR cred_max <= 0 THEN RAISE EXCEPTION 'Tu membresia no permite credito'; END IF;
  lim_efectivo := LEAST(tc.limite, cred_max);
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

-- solicitar_tarjeta_credito: rechazar si la membresia no lo permite
CREATE OR REPLACE FUNCTION public.solicitar_tarjeta_credito()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE uid uuid := public.current_usuario_id(); tc tarjetas_credito%ROWTYPE; sol_id uuid; cred_max numeric;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  SELECT cm.credito_max INTO cred_max FROM usuarios u JOIN config_membresias cm ON cm.tipo = u.membresia WHERE u.id = uid;
  IF cred_max IS NULL OR cred_max <= 0 THEN RAISE EXCEPTION 'Tu membresia actual no permite credito. Mejora a Diamond o superior.'; END IF;
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
