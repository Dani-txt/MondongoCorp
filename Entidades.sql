CREATE TABLE cliente (
    id_cliente NUMBER(4) NOT NULL,
    nombre VARCHAR2(60) NOT NULL,
    run VARCHAR2(12) NOT NULL,
    email VARCHAR2(100),
    telefono VARCHAR2(20),
    fecha_registro DATE DEFAULT SYSDATE
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY (id_cliente);
ALTER TABLE cliente ADD CONSTRAINT cliente_run_uk UNIQUE (run);

CREATE TABLE empleado (
    id_empleado NUMBER(4) NOT NULL,
    p_nombre VARCHAR2(30) NOT NULL,
    p_apellido VARCHAR2(30) NOT NULL,
    s_apellido VARCHAR2(30),
    departamento VARCHAR2(30) NOT NULL,
    sueldo NUMBER(9) NOT NULL,
    fecha_contrato DATE NOT NULL,
    run VARCHAR2(12) NOT NULL,
    email VARCHAR2(100),
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N'))
);

ALTER TABLE empleado ADD CONSTRAINT empleado_pk PRIMARY KEY (id_empleado);
ALTER TABLE empleado ADD CONSTRAINT empleado_run_uk UNIQUE (run);

CREATE TABLE producto (
    id_producto NUMBER(4) NOT NULL,
    nombre VARCHAR2(60) NOT NULL,
    descripcion VARCHAR2(200),
    stock NUMBER(6) NOT NULL,
    precio NUMBER(10,2) NOT NULL,
    categoria VARCHAR2(50),
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N'))
);

ALTER TABLE producto ADD CONSTRAINT producto_pk PRIMARY KEY (id_producto);

CREATE TABLE venta (
    venta_id NUMBER NOT NULL,
    empleado_id NUMBER(4) NOT NULL,
    cliente_id NUMBER(4) NOT NULL,
    id_producto NUMBER(4) NOT NULL,
    fecha_venta DATE NOT NULL,
    cantidad NUMBER(4) NOT NULL,
    subtotal NUMBER(10,2) NOT NULL,
    impuesto NUMBER(10,2) NOT NULL,
    total NUMBER(10,2) NOT NULL,
    estado VARCHAR2(20) DEFAULT 'COMPLETADA' CHECK (estado IN ('COMPLETADA', 'CANCELADA', 'PENDIENTE'))
);

ALTER TABLE venta ADD CONSTRAINT venta_pk PRIMARY KEY (venta_id);

CREATE TABLE bono (
    bono_id NUMBER NOT NULL,
    empleado_id NUMBER(4) NOT NULL,
    venta_id NUMBER,
    monto_bono NUMBER(10,2) NOT NULL,
    tipo_bono VARCHAR2(50) NOT NULL,
    fecha_bono DATE NOT NULL,
    descripcion VARCHAR2(200),
    estado VARCHAR2(20) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'PAGADO', 'CANCELADO'))
);

ALTER TABLE bono ADD CONSTRAINT bono_pk PRIMARY KEY (bono_id);

-- Constraints de Foreign Keys
ALTER TABLE venta
ADD CONSTRAINT venta_empleado_fk FOREIGN KEY (empleado_id)
REFERENCES empleado(id_empleado);

ALTER TABLE venta
ADD CONSTRAINT venta_cliente_fk FOREIGN KEY (cliente_id)
REFERENCES cliente(id_cliente);

ALTER TABLE venta
ADD CONSTRAINT producto_venta_fk FOREIGN KEY (id_producto)
REFERENCES producto(id_producto);

ALTER TABLE bono
ADD CONSTRAINT bono_empleado_fk FOREIGN KEY (empleado_id)
REFERENCES empleado(id_empleado);

ALTER TABLE bono
ADD CONSTRAINT bono_venta_fk FOREIGN KEY (venta_id)
REFERENCES venta(venta_id);

-- CREAR LAS SECUENCIAS para los id
CREATE SEQUENCE venta_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE bono_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE detalle_venta_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE cliente_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE empleado_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE producto_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

