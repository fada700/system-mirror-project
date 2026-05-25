--
-- PostgreSQL database dump
--

\restrict 7FTU9ZtcXEimujfMcAdI4hx6lFwz1FZDkHqq2ucLibk4bOQFwunwl1RT2HYetAg

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = off;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET row_security = off;

--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('394fa15a-effe-4035-83f7-b51b2ac5bda0', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador', 'EMITIR_MULTA', 'multa', '3ec3c4ed-6be2-4cdb-96ff-e8075e338afd', 'eqo', '{"monto": 1000, "motivo": "putyrty"}', NULL, '2026-05-23 01:34:00.981648+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('0f1234c9-86e5-4c1c-bd53-c3bf8cc2e030', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador', 'EMITIR_MULTA', 'multa', '245f63ab-4f29-4f20-bc49-f856ee861402', 'eqo', '{"monto": 1000, "motivo": "putyrty"}', NULL, '2026-05-23 01:34:01.68658+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('66b8ae76-8f63-4843-af83-e0dd782cd1f5', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador', 'CANCELAR_MULTA', 'multa', '245f63ab-4f29-4f20-bc49-f856ee861402', 'eqo', '{"motivo": "anulada"}', NULL, '2026-05-23 01:34:29.53884+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('b353e17e-1994-470b-a68d-5e0ad946f383', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador', 'CANCELAR_MULTA', 'multa', '3ec3c4ed-6be2-4cdb-96ff-e8075e338afd', 'eqo', '{"motivo": "anulada"}', NULL, '2026-05-23 01:34:32.197706+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('17937163-a1cd-4779-83a8-8bf5ba21dc33', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador', 'EMITIR_MULTA', 'multa', 'f0c28484-a699-465d-8214-04a17129edcd', 'eqo', '{"monto": 100, "motivo": "Saltarse un semaforo el we"}', NULL, '2026-05-23 01:40:14.536464+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('f46b1aa9-74bb-44fe-a467-199985ebe33a', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador', 'EMITIR_MULTA', 'multa', 'c12add83-2463-4512-b45e-f0e6cc2e2d35', 'eqo', '{"monto": 100, "motivo": "Saltarse un semaforo el we"}', NULL, '2026-05-23 01:40:15.233324+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('3d844e68-322c-4d74-9b18-dd9ec91a4375', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador', 'CANCELAR_MULTA', 'multa', 'c12add83-2463-4512-b45e-f0e6cc2e2d35', 'eqo', '{"motivo": "anulada"}', NULL, '2026-05-23 01:40:19.813764+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('e91114c7-0823-46f9-91bd-9cbda7333286', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'AJUSTAR_SALDO', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"delta": 10000000, "cuenta": "banco", "motivo": ""}', NULL, '2026-05-23 01:42:59.717916+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('1ca2be4e-3ad1-404c-a66a-2d9f14d857c2', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "diamond", "costo": 350000}', NULL, '2026-05-23 01:43:33.145715+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('4a7cf4cd-8272-498b-bfc9-f47bbda7e503', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "ruby_plus", "costo": 600000}', NULL, '2026-05-23 01:44:08.780579+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('1b4a4386-58b0-48b8-a697-4d15c34d660f', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "basica", "costo": 0}', NULL, '2026-05-23 01:44:50.447864+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('80a3bc61-bf19-4239-b286-56eaa69683b5', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "gold", "costo": 75000}', NULL, '2026-05-23 01:45:10.441959+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('4fb415fa-d4c6-40d1-b85d-ef7829e20243', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'APROBAR_CREDITO', 'solicitud', '97c15a8b-4802-4ae3-8eec-4e31c3085cb9', 'eqo', '{"solicitud": "97c15a8b-4802-4ae3-8eec-4e31c3085cb9"}', NULL, '2026-05-23 01:47:35.976623+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('1b1c7b22-f83a-482c-9fa2-660e2958c9ea', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "zafiro", "costo": 125000}', NULL, '2026-05-23 01:51:45.846039+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('5c9dd0e0-5b7c-4afa-8bf4-c9371ba685e4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "esmeralda", "costo": 300000}', NULL, '2026-05-23 01:51:53.93001+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('76b77a84-9675-41aa-81c9-437b8fd15d6c', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "diamond", "costo": 350000}', NULL, '2026-05-23 01:52:02.053126+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('d1b85f79-6266-40b8-8319-aaf50285d329', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "ruby", "costo": 500000}', NULL, '2026-05-23 01:52:08.495814+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('3f0dafb0-2ac8-41ec-b3af-53ca075e0bf0', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "ruby_plus", "costo": 600000}', NULL, '2026-05-23 01:52:18.001166+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('c81bef39-d46e-48d7-b119-45c6df921b3d', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'EMITIR_MULTA', 'multa', '923cba64-2771-4d40-b1c4-fb6b25815bd0', 'eqo', '{"monto": 1000000, "motivo": "xdddd"}', NULL, '2026-05-23 02:34:32.413529+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('d437d5a7-e432-41e4-a541-7189963da539', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'EMITIR_MULTA', 'multa', 'edd1eb9a-71cc-4553-a5a7-25c6ad0c3cd8', 'eqo', '{"monto": 1000000, "motivo": "xdddd"}', NULL, '2026-05-23 02:34:32.494149+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('de33ccf9-d4e9-4b90-838d-1a965b741ef4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'CANCELAR_MULTA', 'multa', 'edd1eb9a-71cc-4553-a5a7-25c6ad0c3cd8', 'eqo', '{"motivo": "anulada"}', NULL, '2026-05-23 02:34:38.097602+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('e942b29e-5e84-4ed0-8aeb-1b46f6bd8782', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "gold", "costo": 75000}', NULL, '2026-05-23 02:35:20.509794+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('48d2468b-69a3-4cf9-b780-32ffa544ea4b', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "ruby_plus", "costo": 600000}', NULL, '2026-05-23 02:50:15.918915+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('080ad570-bf07-4fca-9a4a-4d7c2cafc6f4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "basica", "costo": 0}', NULL, '2026-05-24 23:33:15.84924+00');
INSERT INTO public.audit_logs (id, realizado_por_id, realizado_por_nombre, realizado_por_rol, accion, entidad, entidad_id, cliente_nombre, detalle, ip_address, fecha_hora) VALUES ('d18a68aa-18bd-4a34-b222-feec71f56239', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', 'usuario,admin,trabajador,policia', 'COMPRA_MEMBRESIA', 'usuario', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'eqo', '{"tipo": "ruby_plus", "costo": 600000}', NULL, '2026-05-24 23:33:38.978297+00');


--
-- Data for Name: config; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.config (id, dueno_discord_id, comision_porcentaje, interes_diario_porcentaje, costo_membresia_plus, costo_membresia_black, saldo_gobierno) VALUES (1, '1129157255137349752', 1.50, 5.00, 75000.00, 350000.00, 1000000);


--
-- Data for Name: config_membresias; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.config_membresias (tipo, costo, tx_diarias, tx_grandes_diarias, monto_grande, debito_max, cartera_max, credito_max, seguridad_antihackeo_pct, seguro_dinero_pct, nivel_soporte, role_id_discord, impuesto_pct, orden) VALUES ('diamond', 350000, 35, 25, 185000, 275000, 175000, 145000, 50, 60, 'vp', NULL, 15, 5);
INSERT INTO public.config_membresias (tipo, costo, tx_diarias, tx_grandes_diarias, monto_grande, debito_max, cartera_max, credito_max, seguridad_antihackeo_pct, seguro_dinero_pct, nivel_soporte, role_id_discord, impuesto_pct, orden) VALUES ('ruby', 500000, 45, 30, 185000, 450000, 350000, 175000, 100, 75, 'plus', NULL, 12, 6);
INSERT INTO public.config_membresias (tipo, costo, tx_diarias, tx_grandes_diarias, monto_grande, debito_max, cartera_max, credito_max, seguridad_antihackeo_pct, seguro_dinero_pct, nivel_soporte, role_id_discord, impuesto_pct, orden) VALUES ('ruby_plus', 600000, -1, 100, 250000, 1400000, 500000, 450000, 100, 100, 'plus_plus', NULL, 10, 7);
INSERT INTO public.config_membresias (tipo, costo, tx_diarias, tx_grandes_diarias, monto_grande, debito_max, cartera_max, credito_max, seguridad_antihackeo_pct, seguro_dinero_pct, nivel_soporte, role_id_discord, impuesto_pct, orden) VALUES ('basica', 0, 5, 2, 55000, 100000, 65000, 5000, 0, 0, 'normal', NULL, 25, 1);
INSERT INTO public.config_membresias (tipo, costo, tx_diarias, tx_grandes_diarias, monto_grande, debito_max, cartera_max, credito_max, seguridad_antihackeo_pct, seguro_dinero_pct, nivel_soporte, role_id_discord, impuesto_pct, orden) VALUES ('gold', 75000, 10, 5, 60000, 150000, 75000, 15000, 20, 40, 'vt', NULL, 22, 2);
INSERT INTO public.config_membresias (tipo, costo, tx_diarias, tx_grandes_diarias, monto_grande, debito_max, cartera_max, credito_max, seguridad_antihackeo_pct, seguro_dinero_pct, nivel_soporte, role_id_discord, impuesto_pct, orden) VALUES ('zafiro', 125000, 15, 10, 75000, 175000, 95000, 35000, 40, 45, 'vt', NULL, 20, 3);
INSERT INTO public.config_membresias (tipo, costo, tx_diarias, tx_grandes_diarias, monto_grande, debito_max, cartera_max, credito_max, seguridad_antihackeo_pct, seguro_dinero_pct, nivel_soporte, role_id_discord, impuesto_pct, orden) VALUES ('esmeralda', 300000, 25, 15, 100000, 200000, 115000, 75000, 45, 50, 'vp', NULL, 18, 4);


--
-- Data for Name: config_sueldos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.config_sueldos (role, monto, dias_periodo, activo) VALUES ('policia', 50000, 7, true);
INSERT INTO public.config_sueldos (role, monto, dias_periodo, activo) VALUES ('trabajador', 75000, 7, true);
INSERT INTO public.config_sueldos (role, monto, dias_periodo, activo) VALUES ('admin', 0, 7, false);


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuarios (id, discord_id, discord_username, discord_avatar_url, nombre, numero_cliente, saldo_cartera, saldo_banco, nip_hash, membresia, intentos_fallidos, bloqueado_hasta, fecha_registro, auth_user_id, estado_cuenta, clabe, impuestos_pendientes, ultimo_impuesto_en) VALUES ('04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'eqox_', 'https://cdn.discordapp.com/avatars/1129157255137349752/f8f98030ac35e8dbdb60fe3c9f029a98.png?size=256', 'eqo', 'BMX2443749', 0.00, 9000000.00, NULL, 'ruby_plus', 0, NULL, '2026-05-23 01:31:12.028695+00', 'ed872cdd-b251-406d-992c-97f9b37f336d', 'activa', '646180121127976334', 0, NULL);


--
-- Data for Name: ganancias_banco; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('654c6795-5e1b-40c5-a0e8-74fcb6eae3f6', 'multa', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 100.00, '2026-05-23 01:43:17.574291+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('61c185d4-2e55-45f1-8915-54a8f6ccb9ee', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 350000.00, '2026-05-23 01:43:33.145715+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('b982c81c-ecc0-44b2-8dc9-7eb9e86b6674', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 600000.00, '2026-05-23 01:44:08.780579+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('44c12344-4587-4210-b482-04d6ca67ae2d', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 75000.00, '2026-05-23 01:45:10.441959+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('e6e0d898-3d5f-4b85-bfeb-1d80cb8fd9c8', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 125000.00, '2026-05-23 01:51:45.846039+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('ebc1d48e-c41e-4a46-be0c-3a1bda39de36', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 300000.00, '2026-05-23 01:51:53.93001+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('807b3f90-5250-4980-8867-21ad81df977a', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 350000.00, '2026-05-23 01:52:02.053126+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('db25cfd6-7610-48e4-8f2b-85b2bc9f7636', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 500000.00, '2026-05-23 01:52:08.495814+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('ac60c495-e4cb-4ba5-9002-b4ac860ce107', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 600000.00, '2026-05-23 01:52:18.001166+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('92ef9178-0373-4dfa-92c5-2b403be1e66f', 'multa', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 1000000.00, '2026-05-23 02:34:46.865701+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('ec96474a-8005-44ac-813a-810ffadda124', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 75000.00, '2026-05-23 02:35:20.509794+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('7a1a053a-fa73-4fd5-ad64-42b39b23a4d9', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 600000.00, '2026-05-23 02:50:15.918915+00');
INSERT INTO public.ganancias_banco (id, concepto, usuario_id, monto, fecha) VALUES ('5b567290-1d72-440f-87d2-e79e13d8a0ba', 'compra_membresia', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 600000.00, '2026-05-24 23:33:38.978297+00');


--
-- Data for Name: membresias; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('c15ab30b-13d2-4b93-9e8d-82072dd0c6c2', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'diamond', '2026-05-23 01:43:33.145715+00', '2026-06-22 01:43:33.145715+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('7cdd287a-7f75-487e-afae-b6d849725b0b', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ruby_plus', '2026-05-23 01:44:08.780579+00', '2026-06-22 01:44:08.780579+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('0c756d94-7d80-4862-a763-2fdcab52a016', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'basica', '2026-05-23 01:44:50.447864+00', '2026-06-22 01:44:50.447864+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('23ed72ab-97ed-4c23-b24d-53c0355c7842', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'gold', '2026-05-23 01:45:10.441959+00', '2026-06-22 01:45:10.441959+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('699e3524-fc7b-41e8-9e9a-340237cd3b28', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'zafiro', '2026-05-23 01:51:45.846039+00', '2026-06-22 01:51:45.846039+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('a2d770d5-c341-426b-9533-7c56fdb29605', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'esmeralda', '2026-05-23 01:51:53.93001+00', '2026-06-22 01:51:53.93001+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('da0c2e76-684f-49c7-9cc0-9c0ec0bae893', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'diamond', '2026-05-23 01:52:02.053126+00', '2026-06-22 01:52:02.053126+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('6387e32f-54da-491d-9bbd-79a7d658e737', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ruby', '2026-05-23 01:52:08.495814+00', '2026-06-22 01:52:08.495814+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('38ac5f0a-60a4-4590-bb78-f07a51aaabe1', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ruby_plus', '2026-05-23 01:52:18.001166+00', '2026-06-22 01:52:18.001166+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('41ea466e-4113-48f4-ae27-60109def8aea', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'gold', '2026-05-23 02:35:20.509794+00', '2026-06-22 02:35:20.509794+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('42701c2e-21fb-4852-b3d8-818b7d766e52', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ruby_plus', '2026-05-23 02:50:15.918915+00', '2026-06-22 02:50:15.918915+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('4557273c-7849-44c1-9a47-7aa7004c9103', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'basica', '2026-05-24 23:33:15.84924+00', '2026-06-23 23:33:15.84924+00', true);
INSERT INTO public.membresias (id, usuario_id, tipo, fecha_inicio, fecha_renovacion, activa) VALUES ('a68b8928-5137-4e37-ba48-ddc167cef0df', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ruby_plus', '2026-05-24 23:33:38.978297+00', '2026-06-23 23:33:38.978297+00', true);


--
-- Data for Name: movimientos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('7475858d-20da-41a9-8d30-9d2538e15604', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'admin_dar', 10000000.00, 'Admin (banco)', NULL, '2026-05-23 01:42:59.717916+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('87159a9a-b941-44c5-a1ab-5810d74c7f17', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_multa', 100.00, 'Pago de multa: Saltarse un semaforo el we', NULL, '2026-05-23 01:43:17.574291+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('faa7bce2-55ec-4d49-9b85-197e629d1601', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 100.00, 'Ganancia: multa', NULL, '2026-05-23 01:43:17.574291+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('0a13e5c9-5bc3-41d3-b32f-33488f8817ec', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 350000.00, 'Compra membresia diamond', NULL, '2026-05-23 01:43:33.145715+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('0e966303-baf4-49db-af09-ed28ffa551c5', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 350000.00, 'Ingreso membresia diamond', NULL, '2026-05-23 01:43:33.145715+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('94190aa8-8d3b-41b2-be20-23f008477024', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 600000.00, 'Compra membresia ruby_plus', NULL, '2026-05-23 01:44:08.780579+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('b5a2b625-9940-4942-801b-4c9f0752c85b', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 600000.00, 'Ingreso membresia ruby_plus', NULL, '2026-05-23 01:44:08.780579+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('1fffb71c-7c5c-42cc-838f-3c085fc6262d', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 75000.00, 'Compra membresia gold', NULL, '2026-05-23 01:45:10.441959+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('13070622-ec49-4193-bd1a-dce3bae8c66c', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 75000.00, 'Ingreso membresia gold', NULL, '2026-05-23 01:45:10.441959+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('2d050224-5fdd-4fde-a6df-c57fb550fd64', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'admin_quitar', 75000.00, 'Sueldo pagado a trabajador', NULL, '2026-05-23 01:46:20.640045+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('4a8047b7-2979-4838-ab3b-3e13c4d86be4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'sueldo', 75000.00, 'Sueldo de trabajador', NULL, '2026-05-23 01:46:20.640045+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('319040b6-8948-4e1b-9714-1cf0354aea14', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:47:46.25931+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('d408d6c6-cc19-4313-acae-559a4c397530', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:47:48.634887+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('f993c13e-ffd9-4a7a-be95-7d618691c397', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:47:59.132058+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('e354b186-fe29-40ea-9a18-89e6e690cc67', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:01.538585+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('c6201348-0459-41ed-9d45-70d16b5b3482', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:03.784102+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('baeb2c72-c11d-40a7-851c-8c1cd52c8b23', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:09.589501+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('41119f59-2366-4c27-bd1b-a0c1cbb06686', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:12.771136+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('da55aaea-10a5-41c2-b959-ea6e421cb4e9', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:16.189209+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('803c7b4a-7b9b-43ff-94b7-0df22a23ed2b', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:18.352022+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('2368487c-f29e-4f0c-8627-929027188227', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:20.604034+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('4d9886a6-f59c-4f69-8d1b-616a417c47ca', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:22.650956+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('af394959-ecce-4ece-8ec4-8abf5deabf32', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:24.787547+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('1974d11e-c320-455c-b2a3-a5a7667895de', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:26.807899+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('300afbbe-5c6e-4324-8892-1da9084f762d', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:28.450644+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('c619a594-228d-4e6c-b266-f2856720a12e', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:30.13229+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('b8218ba0-c87f-4656-96c3-7bdff73f184c', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:32.13557+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('0079034e-e35a-405c-a2f6-c8ce2795e3f0', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:34.02453+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('853eba5e-90c4-4ada-a3f9-3055dfa3dd22', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:36.61759+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('95c9488a-a707-4b73-8b64-22ef3b785d49', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:38.613091+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('ac4da5f9-5cf1-47b2-afe1-efb7fea70c4c', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:40.661254+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('16fc2f4c-1594-4d73-bcfc-4f6140da581a', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'uso_credito', 5000.00, 'Uso de credito', NULL, '2026-05-23 01:48:45.769+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('be1a5041-35f3-4703-8b4a-3b842705bdaf', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_credito', 5000.00, 'Pago a tarjeta de credito', NULL, '2026-05-23 01:48:48.251164+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('1e771d80-4e47-4141-a7d3-4facaf67bdb4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 125000.00, 'Compra membresia zafiro', NULL, '2026-05-23 01:51:45.846039+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('0fb9501d-a259-4f98-b1aa-a5b932066c99', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 125000.00, 'Ingreso membresia zafiro', NULL, '2026-05-23 01:51:45.846039+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('4fb94b27-40c0-44f5-bd1b-1a464d5983f2', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 300000.00, 'Compra membresia esmeralda', NULL, '2026-05-23 01:51:53.93001+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('b3d731ec-3000-4e90-8984-2d3245b095f0', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 300000.00, 'Ingreso membresia esmeralda', NULL, '2026-05-23 01:51:53.93001+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('19db7342-13d3-4c03-8aa6-6d70cffbb5fb', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 350000.00, 'Compra membresia diamond', NULL, '2026-05-23 01:52:02.053126+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('dbb277fc-e3a6-45b6-b9e4-7a84827879c3', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 350000.00, 'Ingreso membresia diamond', NULL, '2026-05-23 01:52:02.053126+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('93dbc4bf-4ba4-451d-9bbd-1e34a4ee4df4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 500000.00, 'Compra membresia ruby', NULL, '2026-05-23 01:52:08.495814+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('7a12eb14-d64c-4675-81a7-73b9b5ec90d6', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 500000.00, 'Ingreso membresia ruby', NULL, '2026-05-23 01:52:08.495814+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('22db01e9-c64d-420e-83e4-b23dce309b69', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 600000.00, 'Compra membresia ruby_plus', NULL, '2026-05-23 01:52:18.001166+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('64aa373a-0413-4716-b50d-5b684a1d30a2', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 600000.00, 'Ingreso membresia ruby_plus', NULL, '2026-05-23 01:52:18.001166+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('eda2e0c9-4637-4c72-81e7-0712a6ee5067', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'pago_multa', 1000000.00, 'Pago de multa: xdddd', NULL, '2026-05-23 02:34:46.865701+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('7eb2cf1e-9224-4ef2-98c4-d6578d10966f', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 75000.00, 'Compra membresia gold', NULL, '2026-05-23 02:35:20.509794+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('76bfca28-7531-460e-ae68-d7520637d8b1', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 75000.00, 'Ingreso membresia gold', NULL, '2026-05-23 02:35:20.509794+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('48cd578e-bd7a-43ae-988f-1ffcdd0df95b', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 600000.00, 'Compra membresia ruby_plus', NULL, '2026-05-23 02:50:15.918915+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('08709b59-df71-4c0a-b802-23df46ac4da0', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 600000.00, 'Ingreso membresia ruby_plus', NULL, '2026-05-23 02:50:15.918915+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('ff742ba1-c54c-4c15-a19d-4240f287b084', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'compra_membresia', 600000.00, 'Compra membresia ruby_plus', NULL, '2026-05-24 23:33:38.978297+00');
INSERT INTO public.movimientos (id, usuario_id, tipo, monto, descripcion, contraparte_id, fecha) VALUES ('4d1143cb-b4c1-4ed3-b6d3-24e6a04f0538', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'ganancia_banco', 600000.00, 'Ingreso membresia ruby_plus', NULL, '2026-05-24 23:33:38.978297+00');


--
-- Data for Name: multas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.multas (id, usuario_id, policia_id, monto, motivo, estado, fecha_emision, fecha_pago, ultimo_recordatorio) VALUES ('245f63ab-4f29-4f20-bc49-f856ee861402', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 1000, 'putyrty', 'cancelada', '2026-05-23 01:34:01.68658+00', '2026-05-23 01:34:29.53884+00', NULL);
INSERT INTO public.multas (id, usuario_id, policia_id, monto, motivo, estado, fecha_emision, fecha_pago, ultimo_recordatorio) VALUES ('3ec3c4ed-6be2-4cdb-96ff-e8075e338afd', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 1000, 'putyrty', 'cancelada', '2026-05-23 01:34:00.981648+00', '2026-05-23 01:34:32.197706+00', NULL);
INSERT INTO public.multas (id, usuario_id, policia_id, monto, motivo, estado, fecha_emision, fecha_pago, ultimo_recordatorio) VALUES ('c12add83-2463-4512-b45e-f0e6cc2e2d35', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 100, 'Saltarse un semaforo el we', 'cancelada', '2026-05-23 01:40:15.233324+00', '2026-05-23 01:40:19.813764+00', NULL);
INSERT INTO public.multas (id, usuario_id, policia_id, monto, motivo, estado, fecha_emision, fecha_pago, ultimo_recordatorio) VALUES ('f0c28484-a699-465d-8214-04a17129edcd', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 100, 'Saltarse un semaforo el we', 'pagada', '2026-05-23 01:40:14.536464+00', '2026-05-23 01:43:17.574291+00', NULL);
INSERT INTO public.multas (id, usuario_id, policia_id, monto, motivo, estado, fecha_emision, fecha_pago, ultimo_recordatorio) VALUES ('edd1eb9a-71cc-4553-a5a7-25c6ad0c3cd8', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 1000000, 'xdddd', 'cancelada', '2026-05-23 02:34:32.494149+00', '2026-05-23 02:34:38.097602+00', NULL);
INSERT INTO public.multas (id, usuario_id, policia_id, monto, motivo, estado, fecha_emision, fecha_pago, ultimo_recordatorio) VALUES ('923cba64-2771-4d40-b1c4-fb6b25815bd0', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 1000000, 'xdddd', 'pagada', '2026-05-23 02:34:32.413529+00', '2026-05-23 02:34:46.865701+00', NULL);


--
-- Data for Name: notification_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('f7dfbea2-e0d6-466f-8e79-a3af64e22ea4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🚨 Nueva multa emitida
Monto: **$1,000.00**
Motivo: putyrty', 'enviado', NULL, '2026-05-23 01:34:01.465374+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('20564e3c-55f0-4c57-bd38-68b3a5b30ce2', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🚨 Nueva multa emitida
Monto: **$1,000.00**
Motivo: putyrty', 'enviado', NULL, '2026-05-23 01:34:02.085303+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('8ab87628-c5af-477c-b63d-f08994bc096c', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🚨 Nueva multa emitida
Monto: **$100.00**
Motivo: Saltarse un semaforo el we', 'enviado', NULL, '2026-05-23 01:40:15.074797+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('e75ff276-2862-4597-98db-ea51bab7becf', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🚨 Nueva multa emitida
Monto: **$100.00**
Motivo: Saltarse un semaforo el we', 'enviado', NULL, '2026-05-23 01:40:15.696008+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('e0bd952f-6482-4193-945f-c5eef0dbc349', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **diamond** está activa.', 'enviado', NULL, '2026-05-23 01:43:33.789069+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('173f246c-2d71-43e2-8fed-6889f21bdc56', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **ruby_plus** está activa.', 'enviado', NULL, '2026-05-23 01:44:09.220308+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('40450dc1-9ccc-4768-8119-3ffef47f85c3', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **basica** está activa.', 'enviado', NULL, '2026-05-23 01:44:50.889371+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('0fee3372-3ecd-4a24-a0d1-9fa214b3ffd4', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **gold** está activa.', 'enviado', NULL, '2026-05-23 01:45:10.987202+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('5979a155-5679-4282-8b0d-f5113900e471', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '💵 Sueldo cobrado
Recibiste **$75,000.00** por tu rol **trabajador**.', 'enviado', NULL, '2026-05-23 01:46:21.10074+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('cdeff00a-ea39-4e30-828d-878717beadb6', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'credito_aprobado', '✅ Tarjeta de crédito aprobada
Tu solicitud fue aprobada. Ya puedes ver tu tarjeta en la app.', 'enviado', NULL, '2026-05-23 01:47:36.503571+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('f582fe09-421b-405e-b18e-5d7faa5b2787', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **zafiro** está activa.', 'enviado', NULL, '2026-05-23 01:51:46.367636+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('053a734f-9b57-4a75-8710-f7e9b67d04d7', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **esmeralda** está activa.', 'enviado', NULL, '2026-05-23 01:51:54.428923+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('5791a855-c2cf-4af7-9c37-c470668f4f4a', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **diamond** está activa.', 'enviado', NULL, '2026-05-23 01:52:02.776704+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('100f49f2-80d6-4183-b86d-236b111696e1', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **ruby** está activa.', 'enviado', NULL, '2026-05-23 01:52:08.988801+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('1be1884f-432f-4ad1-ae20-993e0e392a99', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **ruby_plus** está activa.', 'enviado', NULL, '2026-05-23 01:52:18.781293+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('8f130026-ab65-4ee6-a315-be5fc461851b', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🚨 Nueva multa emitida
Monto: **$1,000,000.00**
Motivo: xdddd', 'enviado', NULL, '2026-05-23 02:34:32.927578+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('1e6beb4e-5895-4b51-8920-77ca77c5ac76', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🚨 Nueva multa emitida
Monto: **$1,000,000.00**
Motivo: xdddd', 'enviado', NULL, '2026-05-23 02:34:33.165151+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('bfbb7d95-8ee8-4477-8263-47e86ce5c4dc', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **gold** está activa.', 'enviado', NULL, '2026-05-23 02:35:21.009998+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('4c230612-4602-4d68-89be-027eec0f9fc2', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **ruby_plus** está activa.', 'enviado', NULL, '2026-05-23 02:50:16.435659+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('d7c2e6d1-df5f-4e67-9416-97afee401700', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **basica** está activa.', 'enviado', NULL, '2026-05-24 23:33:16.828241+00');
INSERT INTO public.notification_log (id, usuario_id, discord_user_id, tipo_notificacion, mensaje, estado, error, enviado_en) VALUES ('8ba4afce-34fe-4b87-b3c2-b8774a0227fe', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '1129157255137349752', 'transaccion', '🎖️ Membresía activada
Tu membresía **ruby_plus** está activa.', 'enviado', NULL, '2026-05-24 23:33:39.408505+00');


--
-- Data for Name: roles_usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roles_usuario (id, usuario_id, role) VALUES ('5837d530-1f78-4e2e-8a3c-1ad44e1d66fe', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'usuario');
INSERT INTO public.roles_usuario (id, usuario_id, role) VALUES ('070ea2ee-6872-464e-ba00-5456134b5ebe', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'admin');
INSERT INTO public.roles_usuario (id, usuario_id, role) VALUES ('23feda42-f94f-4d32-8c7f-a15bbb87e2ac', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'trabajador');
INSERT INTO public.roles_usuario (id, usuario_id, role) VALUES ('76573993-436b-4b51-823b-36d476de4c90', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'policia');


--
-- Data for Name: solicitudes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.solicitudes (id, usuario_id, tipo, estado, fecha, resuelta_en, resuelta_por) VALUES ('97c15a8b-4802-4ae3-8eec-4e31c3085cb9', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'tarjeta_credito', 'aprobada', '2026-05-23 01:44:37.635681+00', '2026-05-23 01:47:35.976623+00', '04d8609d-2e39-490f-b826-3d7b7ccd8353');


--
-- Data for Name: sueldos_reclamados; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sueldos_reclamados (id, usuario_id, role, monto, fecha) VALUES ('ae11cd03-cead-49f2-be53-8473237ac827', '04d8609d-2e39-490f-b826-3d7b7ccd8353', 'trabajador', 75000, '2026-05-23 01:46:20.640045+00');


--
-- Data for Name: tarjetas_credito; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tarjetas_credito (id, usuario_id, numero, cvv, vencimiento, limite, saldo_usado, nivel, estado, fecha_uso, fecha_limite_pago, dias_vencidos, pagos_a_tiempo, score, fecha_corte) VALUES ('a784b682-10a7-4146-97c9-74ab144039a1', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '5248259303929208', '748', '10/30', 5000.00, 0.00, 1, 'activa', NULL, NULL, 0, 11, 100, '2026-05-23 01:47:46.25931+00');


--
-- Data for Name: tarjetas_debito; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tarjetas_debito (id, usuario_id, numero, cvv, vencimiento, congelada, creada_en, estado) VALUES ('d5999f11-a67d-47ed-9ff7-50a2b8da1434', '04d8609d-2e39-490f-b826-3d7b7ccd8353', '4651568330618529', '267', '02/30', false, '2026-05-23 01:31:12.028695+00', 'activa');


--
-- PostgreSQL database dump complete
--

\unrestrict 7FTU9ZtcXEimujfMcAdI4hx6lFwz1FZDkHqq2ucLibk4bOQFwunwl1RT2HYetAg

