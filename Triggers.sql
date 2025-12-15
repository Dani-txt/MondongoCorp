-- Verificar existencia de triggers
SELECT trigger_name, table_name, table_owner, status
FROM all_triggers
WHERE trigger_name = 'TRG_AUDITORIA_BONOS'; --Nombre del trigger


-- Trigger de integridad de stock
CREATE OR REPLACE TRIGGER tr_valida_stock
    BEFORE UPDATE ON producto
    FOR EACH ROW
BEGIN
    IF :NEW.stock < 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Stock no puede ser negativo');
    END IF;
END;
/


