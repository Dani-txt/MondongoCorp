CREATE OR REPLACE PACKAGE pkg_venta IS
    -- Tipos para configuración de bonos
    TYPE rangos_t IS VARRAY(5) OF NUMBER;
    TYPE porcentajes_t IS VARRAY(5) OF NUMBER;
    
    -- Configuración de bonos
    v_rangos_venta rangos_t := rangos_t(20000, 50000, 100000, 200000, NULL);
    v_porcentajes_bono porcentajes_t := porcentajes_t(0.05, 0.10, 0.15, 0.20, 0.25);
    
    -- Procedimiento principal para procesar ventas
    PROCEDURE procesar_venta(
        p_empleado_id IN NUMBER,
        p_cliente_id IN NUMBER,
        p_producto_id IN NUMBER,
        p_fecha_venta IN DATE DEFAULT SYSDATE,
        p_cantidad IN NUMBER
    );
    
END pkg_ventas;
/

CREATE OR REPLACE PACKAGE BODY pkg_ventas IS

    -- Función privada tipo filtro para verificar empleado de ventas
    FUNCTION empleado_ventas(p_id_empleado NUMBER) RETURN BOOLEAN IS
        v_departamento empleado.departamento%TYPE;
    BEGIN
        -- Validación del parámetro de entrada
        IF p_id_empleado IS NULL OR p_id_empleado <= 0 THEN
            RETURN FALSE;
        END IF;

        SELECT departamento INTO v_departamento
        FROM empleado
        WHERE id_empleado = p_id_empleado
        AND activo = 'S';
        
        RETURN (UPPER(v_departamento) LIKE '%VENTAS%');
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN FALSE;
    END empleado_ventas;

    -- Función privada para calcular bono
    FUNCTION calcular_bono(p_monto NUMBER) RETURN NUMBER IS
        v_porcentaje NUMBER := 0;
        v_bono NUMBER := 0;
    BEGIN

        -- Validación del parámetro de entrada
        IF p_monto IS NULL OR p_monto <= 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'El monto debe ser mayor que cero.');
        END IF;

        -- Determinar el porcentaje de bono según los rangos
        FOR i IN 1..v_rangos_venta.COUNT LOOP
            IF v_rangos_venta(i) IS NULL AND p_monto >= v_rangos_venta(i-1) THEN
                v_porcentaje := v_porcentajes_bono(i);
                EXIT;
            ELSIF i = 1 AND p_monto <= v_rangos_venta(i) THEN
                v_porcentaje := v_porcentajes_bono(i);
                EXIT;
            ELSIF i > 1 AND p_monto > v_rangos_venta(i-1) AND p_monto <= v_rangos_venta(i) THEN
                v_porcentaje := v_porcentajes_bono(i);
                EXIT;
            END IF;
        END LOOP;
        
        v_bono := ROUND(p_monto * v_porcentaje, 2);
        RETURN v_bono;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calcular_bono;

    -- Procedimiento para reducir stock
    PROCEDURE reducir_stock_producto(p_producto_id NUMBER, p_cantidad NUMBER) IS
        v_stock_actual producto.stock%TYPE;
    BEGIN
        -- Validaciones de parámetros de entrada
        IF p_producto_id IS NULL OR p_producto_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'ID de producto inválido.');
        ELSIF p_cantidad IS NULL OR p_cantidad <= 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'La cantidad debe ser mayor que cero.');
        END IF;

        -- Verificar stock disponible
        SELECT stock INTO v_stock_actual
        FROM producto
        WHERE id_producto = p_producto_id
        AND activo = 'S';
        
        IF v_stock_actual < p_cantidad THEN
            RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente. Stock actual: ' || v_stock_actual);
        END IF;
        
        -- Reducir stock
        UPDATE producto
        SET stock = stock - p_cantidad
        WHERE id_producto = p_producto_id;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Producto no encontrado o inactivo');
    END reducir_stock_producto;

    -- Procedimiento principal, procesamiento de las ventas
    PROCEDURE procesar_venta(
        p_empleado_id IN NUMBER,
        p_cliente_id IN NUMBER,
        p_producto_id IN NUMBER,
        p_fecha_venta IN DATE DEFAULT SYSDATE,
        p_cantidad IN NUMBER
    ) IS
        v_venta_id NUMBER;
        v_bono NUMBER := 0;
        v_tipo VARCHAR2(30);
        v_subtotal NUMBER;
        v_impuesto NUMBER;
        v_total NUMBER;
        v_precio_producto producto.precio%TYPE;
    BEGIN
        -- Validaciones de parámetros de entrada
        IF p_empleado_id IS NULL OR p_empleado_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Empleado ID inválido.');
        ELSIF p_cliente_id IS NULL OR p_cliente_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Cliente ID inválido.');
        ELSIF p_producto_id IS NULL OR p_producto_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20013, 'Producto ID inválido.');
        ELSIF p_cantidad IS NULL OR p_cantidad <= 0 THEN
            RAISE_APPLICATION_ERROR(-20014, 'Cantidad debe ser mayor que cero.');
        END IF;


        -- Obtener precio del producto
        SELECT precio INTO v_precio_producto
        FROM producto
        WHERE id_producto = p_producto_id
        AND activo = 'S';
        
        -- Calcular montos de la venta
        v_subtotal := ROUND(v_precio_producto * p_cantidad, 2);
        v_impuesto := ROUND(v_subtotal * 0.19, 2);
        v_total := v_subtotal + v_impuesto;
        
        -- Validaciones iniciales
        IF v_total <= 0 THEN
            v_tipo := 'INVALIDA';
        ELSIF NOT empleado_ventas(p_empleado_id) THEN
            v_tipo := 'NO_PERTENECE_A_VENTAS';
        ELSE
            -- Calcular bono usando función privada
            v_bono := calcular_bono(v_total);
            v_tipo := 'BONO_VENTA';
        END IF;
        
        -- Reducir stock del producto
        reducir_stock_producto(p_producto_id, p_cantidad);
        
        -- Insertar venta
        INSERT INTO venta (
            venta_id, empleado_id, cliente_id, fecha_venta,
            subtotal, impuesto, total, estado, id_producto, cantidad
        ) VALUES (
            venta_seq.NEXTVAL, p_empleado_id, p_cliente_id, SYSDATE,
            v_subtotal, v_impuesto, v_total, 'COMPLETADA', p_producto_id, p_cantidad
        ) RETURNING venta_id INTO v_venta_id;
        
        -- Insertar bono (solo si es válido)
        IF v_tipo = 'BONO_VENTA' THEN
            INSERT INTO bono (
                bono_id, empleado_id, venta_id, monto_bono, tipo_bono, fecha_bono, estado
            ) VALUES (
                bono_seq.NEXTVAL, p_empleado_id, v_venta_id, v_bono,
                v_tipo, SYSDATE, 'ACTIVO'
            );
            
            DBMS_OUTPUT.PUT_LINE('Venta procesada: ID=' || v_venta_id || ', Bono calculado: $' || v_bono);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Venta procesada: ID=' || v_venta_id || ', Estado: ' || v_tipo);
        END IF;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error procesando venta: ' || SQLERRM);
            RAISE;
    END procesar_venta;

END pkg_venta;
/