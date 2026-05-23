CREATE OR REPLACE FUNCTION public.admin_ajustar_saldo(_usuario_id uuid, _delta numeric, _cuenta text, _motivo text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
END $function$;