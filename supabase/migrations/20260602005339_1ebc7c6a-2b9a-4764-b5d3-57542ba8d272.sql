
INSERT INTO public.config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

UPDATE public.config_membresias SET costo = 175000 WHERE tipo = 'esmeralda';
UPDATE public.config_membresias SET costo = 200000 WHERE tipo = 'diamond';
UPDATE public.config_membresias SET costo = 275000 WHERE tipo = 'ruby';
UPDATE public.config_membresias SET costo = 450000 WHERE tipo = 'ruby_plus';

GRANT EXECUTE ON FUNCTION public.op_depositar(numeric) TO authenticated;
GRANT EXECUTE ON FUNCTION public.op_retirar(numeric) TO authenticated;
GRANT EXECUTE ON FUNCTION public.op_transferir(text, numeric, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_tarjeta_debito() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_ajustar_saldo(uuid, numeric, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_dueno_banco(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.comprar_membresia(public.tipo_membresia) TO authenticated;
GRANT EXECUTE ON FUNCTION public.aprobar_tarjeta_credito(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.rechazar_tarjeta_credito(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.solicitar_tarjeta_credito() TO authenticated;
GRANT EXECUTE ON FUNCTION public.usar_credito(numeric) TO authenticated;
GRANT EXECUTE ON FUNCTION public.pagar_credito(numeric) TO authenticated;
GRANT EXECUTE ON FUNCTION public.abrir_credito_manual(uuid, numeric, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.abrir_debito_manual(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.ajustar_limite_credito(uuid, numeric) TO authenticated;
GRANT EXECUTE ON FUNCTION public.congelar_cuenta(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.descongelar_cuenta(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cerrar_cuenta(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.reabrir_cuenta(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.emitir_multa(uuid, numeric, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancelar_multa(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.pagar_multa(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.reclamar_sueldo() TO authenticated;
GRANT EXECUTE ON FUNCTION public.condonar_deuda(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.proximo_sueldo() TO authenticated;
GRANT EXECUTE ON FUNCTION public.marcar_recordatorio_multa(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.op_depositar(_monto numeric)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE uid uuid := public.current_usuario_id(); cartera numeric; est public.estado_cuenta_general;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  SELECT saldo_cartera, estado_cuenta INTO cartera, est FROM usuarios WHERE id = uid FOR UPDATE;
  IF est <> 'activa' THEN RAISE EXCEPTION 'Cuenta no activa (%)', est; END IF;
  IF cartera < _monto THEN RAISE EXCEPTION 'Saldo insuficiente en cartera'; END IF;
  UPDATE usuarios SET saldo_cartera = saldo_cartera - _monto, saldo_banco = saldo_banco + _monto WHERE id = uid;
  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES (uid, 'deposito', _monto, 'Deposito a cuenta');
END $$;

CREATE OR REPLACE FUNCTION public.op_retirar(_monto numeric)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE uid uuid := public.current_usuario_id(); banco numeric; est public.estado_cuenta_general;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  SELECT saldo_banco, estado_cuenta INTO banco, est FROM usuarios WHERE id = uid FOR UPDATE;
  IF est <> 'activa' THEN RAISE EXCEPTION 'Cuenta no activa (%)', est; END IF;
  IF banco < _monto THEN RAISE EXCEPTION 'Saldo insuficiente en banco'; END IF;
  UPDATE usuarios SET saldo_banco = saldo_banco - _monto, saldo_cartera = saldo_cartera + _monto WHERE id = uid;
  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES (uid, 'retiro', _monto, 'Retiro a cartera');
END $$;

CREATE OR REPLACE FUNCTION public.op_transferir(_destino_numero text, _monto numeric, _concepto text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  uid uuid := public.current_usuario_id();
  destino usuarios%ROWTYPE; origen usuarios%ROWTYPE;
  pct numeric; comision numeric; total numeric;
  tope_destino numeric; espacio numeric; monto_real numeric; excedente numeric := 0;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'No autenticado'; END IF;
  IF _monto IS NULL OR _monto <= 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  PERFORM public.check_limite_transaccion(uid, _monto);
  SELECT * INTO destino FROM usuarios WHERE numero_cliente = _destino_numero OR clabe = _destino_numero;
  IF destino.id IS NULL THEN RAISE EXCEPTION 'Cliente destino no existe'; END IF;
  IF destino.id = uid THEN RAISE EXCEPTION 'No puedes transferirte a ti mismo'; END IF;
  IF destino.estado_cuenta <> 'activa' THEN RAISE EXCEPTION 'Cuenta destino no activa'; END IF;

  SELECT cm.debito_max INTO tope_destino FROM config_membresias cm WHERE cm.tipo = destino.membresia;
  IF tope_destino IS NOT NULL AND tope_destino > 0 THEN
    espacio := GREATEST(0, tope_destino - destino.saldo_banco);
    monto_real := LEAST(_monto, espacio);
  ELSE
    monto_real := _monto;
  END IF;
  excedente := _monto - monto_real;

  IF monto_real <= 0 THEN
    RETURN jsonb_build_object('monto', 0, 'comision', 0, 'total', 0,
      'destino_nombre', destino.nombre, 'destino_numero', destino.numero_cliente,
      'destino_id', destino.id, 'excedente', _monto);
  END IF;

  SELECT comision_porcentaje INTO pct FROM config WHERE id = 1;
  pct := COALESCE(pct, 0);
  comision := round((monto_real * pct / 100)::numeric, 2);
  total := monto_real + comision;

  SELECT * INTO origen FROM usuarios WHERE id = uid FOR UPDATE;
  IF origen.estado_cuenta <> 'activa' THEN RAISE EXCEPTION 'Tu cuenta no esta activa'; END IF;
  IF origen.saldo_banco < total THEN RAISE EXCEPTION 'Saldo insuficiente. Necesitas %', total; END IF;

  UPDATE usuarios SET saldo_banco = saldo_banco - total WHERE id = uid;
  UPDATE usuarios SET saldo_banco = saldo_banco + monto_real WHERE id = destino.id;

  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion, contraparte_id)
    VALUES (uid, 'transferencia_enviada', monto_real,
      'A ' || destino.nombre || ' (' || destino.numero_cliente || ')'
      || CASE WHEN _concepto IS NOT NULL AND length(_concepto)>0 THEN ' - '||_concepto ELSE '' END
      || CASE WHEN excedente > 0 THEN ' (devuelto: ' || excedente || ')' ELSE '' END,
      destino.id);
  INSERT INTO movimientos (usuario_id, tipo, monto, descripcion, contraparte_id)
    VALUES (destino.id, 'transferencia_recibida', monto_real,
      'De ' || origen.nombre || ' (' || origen.numero_cliente || ')'
      || CASE WHEN _concepto IS NOT NULL AND length(_concepto)>0 THEN ' - '||_concepto ELSE '' END, uid);
  IF comision > 0 THEN
    INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES (uid, 'comision', comision, 'Comision por transferencia');
    PERFORM public.registrar_ganancia('comision_transferencia', uid, comision);
  END IF;
  RETURN jsonb_build_object('monto', monto_real, 'comision', comision, 'total', total,
    'destino_nombre', destino.nombre, 'destino_numero', destino.numero_cliente,
    'destino_id', destino.id, 'excedente', excedente);
END $$;

CREATE OR REPLACE FUNCTION public.admin_ajustar_saldo(_usuario_id uuid, _delta numeric, _cuenta text, _motivo text, _confirm boolean DEFAULT true)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE u usuarios%ROWTYPE; tope numeric; espacio numeric; monto_real numeric; excedente numeric := 0;
BEGIN
  IF NOT public.has_role('admin') THEN RAISE EXCEPTION 'Solo admin'; END IF;
  IF _delta = 0 THEN RAISE EXCEPTION 'Monto invalido'; END IF;
  IF _cuenta NOT IN ('banco','cartera') THEN RAISE EXCEPTION 'Cuenta invalida'; END IF;
  SELECT * INTO u FROM usuarios WHERE id = _usuario_id FOR UPDATE;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Usuario no encontrado'; END IF;
  monto_real := abs(_delta);

  IF _delta > 0 THEN
    SELECT CASE WHEN _cuenta = 'banco' THEN cm.debito_max ELSE cm.cartera_max END
      INTO tope FROM config_membresias cm WHERE cm.tipo = u.membresia;
    IF tope IS NOT NULL AND tope > 0 THEN
      espacio := GREATEST(0, tope - (CASE WHEN _cuenta = 'banco' THEN u.saldo_banco ELSE u.saldo_cartera END));
      IF monto_real > espacio THEN
        excedente := monto_real - espacio;
        monto_real := espacio;
      END IF;
    END IF;

    IF excedente > 0 AND NOT _confirm THEN
      RETURN jsonb_build_object('requiere_confirmacion', true, 'tope', tope,
        'espacio', COALESCE(espacio, 0), 'excedente', excedente,
        'monto_solicitado', abs(_delta), 'cuenta', _cuenta);
    END IF;

    IF monto_real > 0 THEN
      IF _cuenta = 'banco' THEN
        UPDATE usuarios SET saldo_banco = saldo_banco + monto_real WHERE id = u.id;
      ELSE
        UPDATE usuarios SET saldo_cartera = saldo_cartera + monto_real WHERE id = u.id;
      END IF;
      INSERT INTO movimientos(usuario_id, tipo, monto, descripcion)
        VALUES (u.id, 'admin_dar'::tipo_movimiento, monto_real,
          'Admin (' || _cuenta || ')'
          || CASE WHEN _motivo IS NOT NULL AND length(_motivo)>0 THEN ' - '||_motivo ELSE '' END
          || CASE WHEN excedente > 0 THEN ' (recorte: ' || excedente || ' descartado)' ELSE '' END);
    END IF;
  ELSE
    IF _cuenta = 'banco' THEN
      IF u.saldo_banco - monto_real < 0 THEN RAISE EXCEPTION 'Saldo banco quedaria negativo'; END IF;
      UPDATE usuarios SET saldo_banco = saldo_banco - monto_real WHERE id = u.id;
    ELSE
      IF u.saldo_cartera - monto_real < 0 THEN RAISE EXCEPTION 'Saldo cartera quedaria negativo'; END IF;
      UPDATE usuarios SET saldo_cartera = saldo_cartera - monto_real WHERE id = u.id;
    END IF;
    INSERT INTO movimientos(usuario_id, tipo, monto, descripcion)
      VALUES (u.id, 'admin_quitar'::tipo_movimiento, monto_real,
        'Admin (' || _cuenta || ')' || CASE WHEN _motivo IS NOT NULL AND length(_motivo)>0 THEN ' - '||_motivo ELSE '' END);
  END IF;
  PERFORM public.log_audit('AJUSTAR_SALDO','usuario', u.id, u.nombre,
    jsonb_build_object('cuenta', _cuenta, 'delta', _delta, 'acreditado', monto_real, 'excedente', excedente, 'motivo', _motivo));
  RETURN jsonb_build_object('acreditado', monto_real, 'excedente', excedente, 'tope', tope, 'requiere_confirmacion', false);
END $$;

GRANT EXECUTE ON FUNCTION public.admin_ajustar_saldo(uuid, numeric, text, text, boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.comprar_membresia(_tipo public.tipo_membresia)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE uid uuid := public.current_usuario_id(); u usuarios%ROWTYPE; cfg config_membresias%ROWTYPE; owner uuid;
  tope numeric; saldo_dueno numeric; espacio numeric; monto_real numeric;
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
    INSERT INTO ganancias_banco(concepto, usuario_id, monto) VALUES ('compra_membresia', uid, cfg.costo);
    owner := public.dueno_usuario_id();
    IF owner IS NOT NULL THEN
      SELECT u2.saldo_banco, cm.debito_max INTO saldo_dueno, tope
        FROM usuarios u2 JOIN config_membresias cm ON cm.tipo = u2.membresia
        WHERE u2.id = owner FOR UPDATE;
      IF tope IS NOT NULL AND tope > 0 THEN
        espacio := GREATEST(0, tope - saldo_dueno);
        monto_real := LEAST(cfg.costo, espacio);
      ELSE
        monto_real := cfg.costo;
      END IF;
      IF monto_real > 0 THEN
        UPDATE usuarios SET saldo_banco = saldo_banco + monto_real WHERE id = owner;
        INSERT INTO movimientos(usuario_id, tipo, monto, descripcion) VALUES (owner, 'ganancia_banco'::tipo_movimiento, monto_real, 'Ingreso membresia ' || _tipo::text);
      END IF;
    END IF;
  END IF;
  UPDATE membresias SET activa = false WHERE usuario_id = uid AND activa = true;
  UPDATE usuarios SET membresia = _tipo WHERE id = uid;
  INSERT INTO membresias(usuario_id, tipo, fecha_inicio, fecha_renovacion, activa)
    VALUES (uid, _tipo, now(), now() + interval '30 days', true);
  PERFORM public.log_audit('COMPRA_MEMBRESIA','usuario', uid, u.nombre, jsonb_build_object('tipo', _tipo, 'costo', cfg.costo));
  RETURN jsonb_build_object('tipo', _tipo, 'role_id_discord', cfg.role_id_discord);
END $$;

CREATE OR REPLACE FUNCTION public.aprobar_tarjeta_credito(_solicitud_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE staff uuid := public.current_usuario_id();
  s solicitudes%ROWTYPE; tc tarjetas_credito%ROWTYPE; u usuarios%ROWTYPE;
  num text; ncvv text; venc text; lim numeric;
BEGIN
  IF NOT (public.has_role('admin') OR public.has_role('trabajador')) THEN RAISE EXCEPTION 'No autorizado'; END IF;
  SELECT * INTO s FROM solicitudes WHERE id = _solicitud_id FOR UPDATE;
  IF s.id IS NULL THEN RAISE EXCEPTION 'Solicitud no encontrada'; END IF;
  IF s.tipo <> 'tarjeta_credito' THEN RAISE EXCEPTION 'Tipo no es tarjeta_credito (%)', s.tipo; END IF;
  IF s.estado <> 'pendiente' THEN RAISE EXCEPTION 'Solicitud ya resuelta (%)', s.estado; END IF;
  SELECT * INTO u FROM usuarios WHERE id = s.usuario_id;
  SELECT credito_max INTO lim FROM config_membresias WHERE tipo = u.membresia;
  lim := COALESCE(NULLIF(lim,0), 5000);
  num  := '5' || lpad((floor(random()*999999999999999)::bigint)::text, 15, '0');
  ncvv := lpad((floor(random()*999)::int)::text, 3, '0');
  venc := lpad((floor(random()*12)::int + 1)::text, 2, '0') || '/' || to_char(now() + interval '4 years', 'YY');
  SELECT * INTO tc FROM tarjetas_credito WHERE usuario_id = s.usuario_id FOR UPDATE;
  IF tc.id IS NULL THEN
    INSERT INTO tarjetas_credito(usuario_id, estado, numero, cvv, vencimiento, limite) VALUES (s.usuario_id, 'activa', num, ncvv, venc, lim);
  ELSE
    UPDATE tarjetas_credito SET estado='activa', numero=num, cvv=ncvv, vencimiento=venc, limite = lim WHERE id = tc.id;
  END IF;
  UPDATE solicitudes SET estado='aprobada', resuelta_por=staff, resuelta_en=now() WHERE id=s.id;
  PERFORM public.log_audit('APROBAR_CREDITO','solicitud', s.id, u.nombre, jsonb_build_object('solicitud', s.id, 'limite', lim));
END $$;
