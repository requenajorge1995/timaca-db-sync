CREATE DATABASE TimacaSis
GO
USE TimacaSis
GO

CREATE TABLE REQUISICION (
    numero VARCHAR(20) PRIMARY KEY,
    fecharequisicion SMALLDATETIME NOT NULL,
    descripcion VARCHAR(500),
    motivo VARCHAR(200),
    fechaaprobacionGte SMALLDATETIME,
    FechaAsignada SMALLDATETIME,
    comprador VARCHAR(100),
    estatus VARCHAR(10) DEFAULT 'ACT'
)

CREATE TABLE DETALLEREQUISICION (
    numero VARCHAR(20),
    material VARCHAR(50),
    descripcion VARCHAR(500),
    CuentaAux VARCHAR(20),
    OC VARCHAR(20),
    estatus VARCHAR(10) DEFAULT 'ACT',
    FOREIGN KEY (numero) REFERENCES REQUISICION(numero)
)

CREATE TABLE PROVEEDORES (
    RIF VARCHAR(20) PRIMARY KEY,
    Nombre VARCHAR(200),
    dir1 VARCHAR(300)
)

CREATE TABLE ORDENES (
    numero VARCHAR(20) PRIMARY KEY,
    Proveedor VARCHAR(20),
    Fecha SMALLDATETIME,
    FechaAprobada SMALLDATETIME,
    Fechaconformada SMALLDATETIME,
    nombrecomprador VARCHAR(100),
    FOREIGN KEY (Proveedor) REFERENCES PROVEEDORES(RIF)
)

CREATE TABLE DETALLEORDENES (
    numero VARCHAR(20),
    material VARCHAR(50),
    FechaEntrega SMALLDATETIME,
    FOREIGN KEY (numero) REFERENCES ORDENES(numero)
)

CREATE TABLE RECEPCION (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fecha SMALLDATETIME,
    dctoaso VARCHAR(20),
    estatus VARCHAR(10)
)

CREATE TABLE CuentasAux (
    CtaAux VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(200)
)

INSERT INTO PROVEEDORES VALUES 
('J-12345678-9', 'Suministros Técnicos CA', 'Av. Principal 123, Caracas'),
('V-87654321-0', 'Materiales Industriales SRL', 'Zona Industrial, Valencia'),
('J-11111111-1', 'Equipos y Herramientas SA', 'Calle Comercio 456, Maracaibo')

INSERT INTO CuentasAux VALUES 
('CTA001', 'Gastos de Oficina'),
('CTA002', 'Materiales de Construcción'),
('CTA003', 'Equipos de Seguridad')

INSERT INTO REQUISICION VALUES 
('REQ-2024-001', '2024-01-15', 'Materiales para proyecto Alpha', 'Urgente', '2024-01-16', '2024-01-17', 'Juan Pérez', 'ACT'),
('REQ-2024-002', '2024-02-10', 'Equipos de seguridad industrial', 'Normal', '2024-02-11', '2024-02-12', 'María García', 'ACT'),
('REQ-2024-003', '2024-03-05', 'Suministros de oficina', 'Baja', '2024-03-06', '2024-03-07', 'Carlos López', 'ACT')

INSERT INTO DETALLEREQUISICION VALUES 
('REQ-2024-001', 'MAT001', 'Cemento Portland 50kg', 'CTA002', 'OC-2024-001', 'ACT'),
('REQ-2024-001', 'MAT002', 'Varillas de hierro 12mm', 'CTA002', 'OC-2024-001', 'ACT'),
('REQ-2024-002', 'SEG001', 'Cascos de seguridad', 'CTA003', 'OC-2024-002', 'ACT'),
('REQ-2024-002', 'SEG002', 'Chaleco reflectivo', 'CTA003', 'OC-2024-002', 'ACT'),
('REQ-2024-003', 'OFF001', 'Papel bond tamaño carta', 'CTA001', NULL, 'ACT')

INSERT INTO ORDENES VALUES 
('OC-2024-001', 'V-87654321-0', '2024-01-18', '2024-01-19', '2024-02-15', 'Ana Rodríguez'),
('OC-2024-002', 'J-11111111-1', '2024-02-13', '2024-02-14', NULL, 'Pedro Martínez')

INSERT INTO DETALLEORDENES (numero, material, FechaEntrega) VALUES 
('OC-2024-001', 'MAT001', '2024-02-01'),
('OC-2024-001', 'MAT002', '2024-02-01'),
('OC-2024-002', 'SEG001', '2024-02-20'),
('OC-2024-002', 'SEG002', '2024-02-20')

INSERT INTO RECEPCION (fecha, dctoaso, estatus) VALUES 
('2024-02-02', 'OC-2024-001', 'FI'),
('2024-02-21', 'OC-2024-002', 'FI')

GO
