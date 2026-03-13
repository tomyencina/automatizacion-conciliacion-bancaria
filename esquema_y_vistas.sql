-- ==============================================================================
-- PROYECTO: Automatización de Conciliación Bancaria
-- DESCRIPCIÓN: Script de inicialización de la base de datos, tablas y vistas.
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS db_tesoreria_integral;
USE db_tesoreria_integral;

-- ==============================================================================
-- 1. CREACIÓN DE TABLAS DE DIMENSIÓN (Catálogos)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS dim_cuentas (
    id_cuenta INT PRIMARY KEY,
    nombre_cuenta VARCHAR(100) NOT NULL,
    tipo_cuenta VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS dim_conceptos (
    id_concepto INT PRIMARY KEY,
    nombre_concepto VARCHAR(100) NOT NULL,
    clasificacion VARCHAR(50)
);

-- ==============================================================================
-- 2. CREACIÓN DE TABLAS DE HECHOS (Movimientos)
-- ==============================================================================

-- Tabla que recibe los datos crudos del banco vía Python (ETL)
CREATE TABLE IF NOT EXISTS fact_extracto_banco (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_cuenta INT,
    fecha_banco DATE,
    descripcion_banco VARCHAR(255),
    monto_banco DECIMAL(15, 2),
    nro_referencia VARCHAR(100),
    estado_conciliacion VARCHAR(20) DEFAULT 'Pendiente',
    FOREIGN KEY (id_cuenta) REFERENCES dim_cuentas(id_cuenta)
);

-- Tabla que simula las registraciones contables de la empresa (Libro Mayor/Diario)
CREATE TABLE fact_movimientos (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    id_cuenta INT NOT NULL,
    id_concepto INT NOT NULL,
    monto DECIMAL (15, 2) NOT NULL,
    comprobante VARCHAR (50),
    detalle VARCHAR (255),
    estado_conciliacion VARCHAR (20) DEFAULT 'Pendiente',
    FOREIGN KEY (id_cuenta) REFERENCES dim_cuentas(id_cuenta),
    FOREIGN KEY (id_concepto) REFERENCES dim_conceptos(id_concepto);
);

-- ==============================================================================
-- 3. CREACIÓN DE VISTAS ANALÍTICAS (El motor de la conciliación)
-- ==============================================================================

-- VISTA A: Movimientos Conciliados (Match perfecto entre Banco y Libro)
CREATE OR REPLACE VIEW vw_movimientos_conciliados AS
SELECT 
    b.fecha_banco,
    b.descripcion_banco,
    b.monto_banco,
    l.fecha_contable,
    l.descripcion_asiento,
    'Conciliado' AS estado
FROM fact_extracto_banco b
INNER JOIN fact_libro_diario l 
    ON b.monto_banco = l.monto_contable 
    AND b.id_cuenta = l.id_cuenta
    -- Tolerancia de 3 días para contemplar el clearing bancario
    AND l.fecha_contable BETWEEN DATE_SUB(b.fecha_banco, INTERVAL 3 DAY) AND DATE_ADD(b.fecha_banco, INTERVAL 3 DAY);

-- VISTA B: Pendientes en Banco (Gastos/Ingresos no registrados en la contabilidad)
-- Ideal para detectar retenciones de SIRCREB, Impuesto al Cheque o comisiones.
CREATE OR REPLACE VIEW vw_pendientes_banco AS
SELECT 
    b.fecha_banco,
    b.descripcion_banco,
    b.monto_banco,
    b.nro_referencia
FROM fact_extracto_banco b
LEFT JOIN fact_libro_diario l 
    ON b.monto_banco = l.monto_contable 
    AND b.id_cuenta = l.id_cuenta
WHERE l.id_asiento IS NULL;

-- VISTA C: Pendientes en Libro (Partidas contables no reflejadas en el banco)
-- Ideal para detectar cheques emitidos y no cobrados, o transferencias demoradas.
CREATE OR REPLACE VIEW vw_pendientes_libro AS
SELECT 
    l.fecha_contable,
    l.descripcion_asiento,
    l.monto_contable
FROM fact_libro_diario l
LEFT JOIN fact_extracto_banco b 
    ON l.monto_contable = b.monto_banco 
    AND l.id_cuenta = b.id_cuenta
WHERE b.id_movimiento IS NULL;

-- ==============================================================================
-- 4. DATOS SEMILLA (Seed Data) - Solo para demostración del portfolio
-- ==============================================================================

INSERT INTO fact_movimientos (fecha, id_cuenta, id_concepto, monto, comprobante, detalle, estado_conciliacion)
VALUES 
('2026-03-09', 2, 3, -35000.00, 'OP-1024', 'Pago a Proveedor XYZ s/Factura', 'Pendiente'),
('2026-03-10', 2, 1, 250000.00, 'REC-0001', 'Cobro Lote Honorarios Cliente A', 'Pendiente'),
('2026-03-12', 2, 2, -45000.00, 'VEP-8854', 'Pago VEP AFIP Cargas Sociales', 'Pendiente'),

('2026-03-13', 2, 3, -150000.00, 'CHQ-554433', 'Pago a Proveedor - Cheque diferido', 'Pendiente'),
('2026-03-13', 2, 3, -8500.00, 'OP-1025', 'Anticipo Proveedor Insumos', 'Pendiente');