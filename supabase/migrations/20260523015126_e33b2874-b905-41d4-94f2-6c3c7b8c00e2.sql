
-- Tarjetas debito: deny direct INSERT/DELETE from clients (writes go via SECURITY DEFINER funcs / service role)
CREATE POLICY "Deny insert tarjetas_debito" ON public.tarjetas_debito FOR INSERT TO authenticated, anon WITH CHECK (false);
CREATE POLICY "Deny delete tarjetas_debito" ON public.tarjetas_debito FOR DELETE TO authenticated, anon USING (false);

-- Tarjetas credito: deny direct INSERT/UPDATE/DELETE from clients
CREATE POLICY "Deny insert tarjetas_credito" ON public.tarjetas_credito FOR INSERT TO authenticated, anon WITH CHECK (false);
CREATE POLICY "Deny update tarjetas_credito" ON public.tarjetas_credito FOR UPDATE TO authenticated, anon USING (false);
CREATE POLICY "Deny delete tarjetas_credito" ON public.tarjetas_credito FOR DELETE TO authenticated, anon USING (false);

-- Login codigos: deny all client access (only service role on the server reads/writes)
CREATE POLICY "Deny select login_codigos" ON public.login_codigos FOR SELECT TO authenticated, anon USING (false);
CREATE POLICY "Deny insert login_codigos" ON public.login_codigos FOR INSERT TO authenticated, anon WITH CHECK (false);
CREATE POLICY "Deny update login_codigos" ON public.login_codigos FOR UPDATE TO authenticated, anon USING (false);
CREATE POLICY "Deny delete login_codigos" ON public.login_codigos FOR DELETE TO authenticated, anon USING (false);
