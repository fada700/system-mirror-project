
REVOKE EXECUTE ON FUNCTION public.crear_tarjeta_debito_inicial() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.current_usuario_id() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.has_role(public.app_role) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.current_usuario_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_role(public.app_role) TO authenticated;

DROP POLICY IF EXISTS "Admin inserta usuarios" ON public.usuarios;
CREATE POLICY "Admin inserta usuarios" ON public.usuarios
  FOR INSERT WITH CHECK (public.has_role('admin'));
