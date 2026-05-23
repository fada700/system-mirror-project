
DO $$ BEGIN
  CREATE TYPE public.estado_multa AS ENUM ('pendiente','pagada','cancelada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

ALTER TYPE public.tipo_movimiento ADD VALUE IF NOT EXISTS 'multa';
ALTER TYPE public.tipo_movimiento ADD VALUE IF NOT EXISTS 'pago_multa';
ALTER TYPE public.tipo_movimiento ADD VALUE IF NOT EXISTS 'sueldo';
ALTER TYPE public.tipo_movimiento ADD VALUE IF NOT EXISTS 'impuesto';
ALTER TYPE public.tipo_movimiento ADD VALUE IF NOT EXISTS 'compra_membresia';
