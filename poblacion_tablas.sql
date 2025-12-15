-- Insertar empleados (incluyendo el extra en ventas)
INSERT INTO empleado (id_empleado, p_nombre, p_apellido, s_apellido, departamento, sueldo, fecha_contrato, run, email, activo)
VALUES (1, 'Juan', 'Pérez', 'Gómez', 'Ventas', 850000, DATE '2023-01-15', '12345678-9', 'juan.perez@empresa.cl', 'S');

INSERT INTO empleado (id_empleado, p_nombre, p_apellido, s_apellido, departamento, sueldo, fecha_contrato, run, email, activo)
VALUES (2, 'María', 'López', 'Sánchez', 'Administración', 950000, DATE '2022-03-20', '98765432-1', 'maria.lopez@empresa.cl', 'S');

INSERT INTO empleado (id_empleado, p_nombre, p_apellido, s_apellido, departamento, sueldo, fecha_contrato, run, email, activo)
VALUES (3, 'Carlos', 'González', 'Martínez', 'Ventas', 780000, DATE '2023-06-10', '11222333-4', 'carlos.gonzalez@empresa.cl', 'S');

-- Insertar clientes (incluyendo el cliente extra)
INSERT INTO cliente (id_cliente, nombre, run, email, telefono)
VALUES (1, 'Empresa ABC Ltda.', '12345678-0', 'contacto@empresaabc.cl', '+56912345678');

INSERT INTO cliente (id_cliente, nombre, run, email, telefono)
VALUES (2, 'Comercial XYZ SpA', '87654321-9', 'ventas@comercialxyz.cl', '+56987654321');

INSERT INTO cliente (id_cliente, nombre, run, email, telefono)
VALUES (3, 'Distribuidora Global S.A.', '55666777-8', 'info@distribuidoraglobal.cl', '+56955667788');

-- Insertar productos (incluyendo dos productos extra)
INSERT INTO producto (id_producto, nombre, descripcion, stock, precio, categoria, activo)
VALUES (1, 'Laptop Gamer Pro', 'Laptop gaming i7, 16GB RAM, RTX 4060', 10, 1299900, 'Tecnología', 'S');

INSERT INTO producto (id_producto, nombre, descripcion, stock, precio, categoria, activo)
VALUES (2, 'Monitor 24" LED', 'Monitor Full HD 144Hz, 1ms', 15, 249900, 'Tecnología', 'S');

INSERT INTO producto (id_producto, nombre, descripcion, stock, precio, categoria, activo)
VALUES (3, 'Teclado Mecánico RGB', 'Teclado mecánico switches blue', 20, 89900, 'Periféricos', 'S');

INSERT INTO producto (id_producto, nombre, descripcion, stock, precio, categoria, activo)
VALUES (4, 'Mouse Inalámbrico', 'Mouse ergonómico 2400DPI', 25, 45900, 'Periféricos', 'S');

INSERT INTO producto (id_producto, nombre, descripcion, stock, precio, categoria, activo)
VALUES (5, 'Tablet Digitalizadora', 'Tablet para diseño gráfico', 8, 189900, 'Tecnología', 'S');

COMMIT;