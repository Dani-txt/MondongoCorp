CREATE OR REPLACE PACKAGE pkg_reportes IS
    -- Reporte de bonos por empleado específico
    PROCEDURE reporte_bonos_empleado(p_empleado_id NUMBER);

    -- Reporte de ventas por período
    PROCEDURE reporte_ventas_periodo(p_fecha_inicio DATE, p_fecha_fin DATE);

END pkg_reportes;
/

CREATE OR REPLACE PACKAGE BODY pkg_reportes IS

-- procedimiento para obtener bonos de un empleado en específico
PROCEDURE reporte_bonos_empleado(p_empleado_id NUMBER) IS
    CURSOR c_bonos IS
        SELECT e.p_nombre || ' ' || e.p_apellido AS nombre_empleado,
            b.tipo_bono,
            b.monto_bono,
            b.fecha_bono,
            v.total AS monto_venta,
            p.nombre AS producto
        FROM empleado e
        JOIN bono b ON e.id_empleado = b.empleado_id
        JOIN venta v ON b.venta_id = v.venta_id
        JOIN producto p ON v.id_producto = p.id_producto
        WHERE e.id_empleado = p_empleado_id
        ORDER BY b.fecha_bono DESC;
    
    v_existe_empleado NUMBER;
    v_total_bonos NUMBER := 0;
BEGIN
    -- Validación de ID de empleado
    IF p_empleado_id IS NULL OR p_empleado_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'El ID del empleado no puede ser NULL ni menor o igual a cero.');
    END IF;

    -- Validar existencia del empleado
    SELECT COUNT(*) INTO v_existe_empleado
    FROM empleado
    WHERE id_empleado = p_empleado_id;

    IF v_existe_empleado = 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'No existe el empleado con ID ' || p_empleado_id);
    END IF;

    DBMS_OUTPUT.PUT_LINE('REPORTE DE BONOS POR EMPLEADO');
    DBMS_OUTPUT.PUT_LINE('Empleado ID: ' || p_empleado_id);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    
    FOR rec IN c_bonos LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Empleado: ' || rec.nombre_empleado ||
            ', Producto: ' || rec.producto ||
            ', Bono: ' || rec.tipo_bono ||
            ', Monto: $' || rec.monto_bono ||
            ', Venta: $' || rec.monto_venta ||
            ', Fecha: ' || TO_CHAR(rec.fecha_bono, 'DD/MM/YYYY')
        );

        -- Acumular total
        v_total_bonos := v_total_bonos + rec.monto_bono;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total bonos: $' || v_total_bonos);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existen bonos asociados al empleado: ' || p_empleado_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en reporte_bonos_empleado: ' || SQLERRM);
        RAISE;
END reporte_bonos_empleado;


    -- reporte de ventas en un periodo de tiempo
    PROCEDURE reporte_ventas_periodo(p_fecha_inicio DATE, p_fecha_fin DATE) IS
        CURSOR c_ventas IS
            SELECT v.fecha_venta,
                e.p_nombre || ' ' || e.p_apellido AS vendedor,
                c.nombre AS cliente,
                p.nombre AS producto,
                v.cantidad,
                v.total,
                NVL(b.monto_bono, 0) AS bono,
                v.estado
            FROM venta v
            JOIN empleado e ON v.empleado_id = e.id_empleado
            JOIN cliente c ON v.cliente_id = c.id_cliente
            JOIN producto p ON v.id_producto = p.id_producto
            LEFT JOIN bono b ON v.venta_id = b.venta_id
            WHERE v.fecha_venta BETWEEN p_fecha_inicio AND p_fecha_fin
            ORDER BY v.fecha_venta DESC;
        v_total_ventas NUMBER := 0;
        v_total_bonos NUMBER := 0;
    BEGIN
        -- Validaciones de parámetros
        IF p_fecha_inicio IS NULL OR p_fecha_fin IS NULL THEN
            RAISE_APPLICATION_ERROR(-20200, 'Las fechas de inicio y fin son obligatorias.');
        ELSIF p_fecha_inicio > p_fecha_fin THEN
            RAISE_APPLICATION_ERROR(-20201, 'La fecha de inicio no puede ser mayor que la fecha fin.');
        END IF;

        DBMS_OUTPUT.PUT_LINE('REPORTE DE VENTAS POR PERÍODO');
        DBMS_OUTPUT.PUT_LINE('Desde: ' || TO_CHAR(p_fecha_inicio, 'DD/MM/YYYY') ||
            ' Hasta: ' || TO_CHAR(p_fecha_fin, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
        
        FOR rec IN c_ventas LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Fecha: ' || TO_CHAR(rec.fecha_venta, 'DD/MM/YYYY') ||
                ', Vendedor: ' || rec.vendedor ||
                ', Cliente: ' || rec.cliente ||
                ', Producto: ' || rec.producto ||
                ', Cantidad: ' || rec.cantidad ||
                ', Total: $' || rec.total ||
                ', Bono: $' || rec.bono ||
                ', Estado: ' || rec.estado
            );
            
            v_total_ventas := v_total_ventas + rec.total;
            v_total_bonos := v_total_bonos + rec.bono;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
        DBMS_OUTPUT.PUT_LINE('Total Ventas: $' || v_total_ventas);
        DBMS_OUTPUT.PUT_LINE('Total Bonos: $' || v_total_bonos);
        DBMS_OUTPUT.PUT_LINE('Cantidad Ventas: ' || c_ventas%ROWCOUNT);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No existen ventas en el período indicado.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en reporte_ventas_periodo: ' || SQLERRM);
            RAISE;
    END reporte_ventas_periodo;
END pkg_reportes;
/