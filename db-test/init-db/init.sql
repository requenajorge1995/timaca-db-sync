CREATE DATABASE TestDB;
GO
USE TestDB;
GO

CREATE TABLE dbo.Requisicion (
    Numero INT PRIMARY KEY,
    FechaRequisicion DATE NOT NULL,
    Descripcion NVARCHAR(255),
    CuentaAux INT,
    fechaaprobacionGte DATE
);

CREATE TABLE dbo.DetalleRequisicion (
    Numero INT PRIMARY KEY,
    ID_Requisicion INT NOT NULL,
    material NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(255),
    FechaAsignada DATE,
    Comprador NVARCHAR(100),
    CONSTRAINT FK_DetalleRequisicion_Requisicion
        FOREIGN KEY (ID_Requisicion) REFERENCES dbo.Requisicion (Numero)
);

CREATE TABLE dbo.Ordenes (
    Numero INT PRIMARY KEY,
    ID_DetalleRequisicion INT NOT NULL,
    fecha DATE,
    FechaConformada DATE,
    FechaAprobada DATE,
    CONSTRAINT FK_Ordenes_DetalleRequisicion
        FOREIGN KEY (ID_DetalleRequisicion) REFERENCES dbo.DetalleRequisicion (Numero)
);

CREATE TABLE dbo.CuentasAux (
    ID_Cuenta INT PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL
);

CREATE TABLE dbo.DetalleOrdenes (
    Numero INT PRIMARY KEY,
    Numero_Orden INT NOT NULL,
    FechaEntrega DATE,
    CONSTRAINT FK_DetalleOrdenes_Ordenes
        FOREIGN KEY (Numero_Orden) REFERENCES dbo.Ordenes (Numero)
);

CREATE TABLE dbo.Recepcion (
    ID INT PRIMARY KEY,
    ID_DetalleOrdenes INT NOT NULL,
    Fecha DATE,
    CONSTRAINT FK_Recepcion_DetalleOrdenes
        FOREIGN KEY (ID_DetalleOrdenes) REFERENCES dbo.DetalleOrdenes (Numero)
);

INSERT INTO dbo.CuentasAux (ID_Cuenta, Nombre) VALUES
(101, N'Cuenta de Mantenimiento'),
(102, N'Cuenta de Producción'),
(103, N'Cuenta de Logística');

INSERT INTO dbo.Requisicion (Numero, FechaRequisicion, Descripcion, CuentaAux, fechaaprobacionGte) VALUES
(1, '2025-08-01', N'Compra de repuestos', 101, '2025-08-02'),
(2, '2025-08-05', N'Compra de insumos', 102, '2025-08-06'),
(3, '2025-09-10', N'Adquisición de herramientas', 101, '2025-09-12'),
(4, '2025-10-03', N'Compra de uniformes', 102, '2025-10-05'),
(5, '2025-11-15', N'Compra de equipos de seguridad', 103, '2025-11-17'),
(6, '2025-12-01', N'Compra de repuestos fin de año', 101, '2025-12-03');

INSERT INTO dbo.DetalleRequisicion (Numero, ID_Requisicion, material, descripcion, FechaAsignada, Comprador) VALUES
(11, 1, N'MAT-001', N'Tornillos de acero', '2025-08-03', N'Juan Pérez'),
(12, 1, N'MAT-002', N'Tuercas de acero', '2025-08-03', N'Juan Pérez'),
(21, 2, N'MAT-010', N'Guantes de seguridad', '2025-08-07', N'María López'),
(31, 3, N'MAT-020', N'Taladro industrial', '2025-09-13', N'Carlos Ruiz'),
(41, 4, N'MAT-030', N'Camisas de trabajo', '2025-10-06', N'María López'),
(42, 4, N'MAT-031', N'Pantalones de trabajo', '2025-10-06', N'María López'),
(51, 5, N'MAT-040', N'Casco de seguridad', '2025-11-18', N'Juan Pérez'),
(61, 6, N'MAT-050', N'Filtro de aceite', '2025-12-04', N'Carlos Ruiz');

INSERT INTO dbo.Ordenes (Numero, ID_DetalleRequisicion, fecha, FechaConformada, FechaAprobada) VALUES
(1001, 11, '2025-08-04', '2025-08-05', '2025-08-06'),
(1002, 12, '2025-08-04', '2025-08-05', '2025-08-06'),
(1003, 21, '2025-08-08', '2025-08-09', '2025-08-10'),
(1004, 31, '2025-09-14', '2025-09-15', '2025-09-16'),
(1005, 41, '2025-10-07', '2025-10-08', '2025-10-09'),
(1006, 42, '2025-10-07', '2025-10-08', '2025-10-09'),
(1007, 51, '2025-11-19', '2025-11-20', '2025-11-21'),
(1008, 61, '2025-12-05', '2025-12-06', '2025-12-07');

INSERT INTO dbo.DetalleOrdenes (Numero, Numero_Orden, FechaEntrega) VALUES
(5001, 1001, '2025-08-15'),
(5002, 1002, '2025-08-16'),
(5003, 1003, '2025-08-20'),
(5004, 1004, '2025-09-25'),
(5005, 1005, '2025-10-20'),
(5006, 1006, '2025-10-21'),
(5007, 1007, '2025-11-30'),
(5008, 1008, '2025-12-15');

INSERT INTO dbo.Recepcion (ID, ID_DetalleOrdenes, Fecha) VALUES
(9001, 5001, '2025-08-15'),
(9002, 5002, '2025-08-16'),
(9003, 5003, '2025-08-21'),
(9004, 5004, '2025-09-26'),
(9005, 5005, '2025-10-22'),
(9006, 5006, '2025-10-23'),
(9007, 5007, '2025-12-01'),
(9008, 5008, '2025-12-16');
