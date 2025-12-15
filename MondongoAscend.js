const database = 'MondongoAscendDB';

use(database);

// Coleccion y validacion de Pedidos
db.createCollection('Pedidos', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: [
                "pedido_id",
                "venta_id",
                "cliente",
                "productos",
                "despacho",
                "estado_pedido"
            ],
            properties: {
                pedido_id: { bsonType: "int" },
                venta_id: { bsonType: "int" },

                cliente: {
                    bsonType: "object",
                    required: ["id_cliente", "razon_social"],
                    properties: {
                        id_cliente: { bsonType: "int" },
                        razon_social: { bsonType: "string", minLength: 2, maxLength: 100 }
                    }
                },

                productos: {
                    bsonType: "array",
                    minItems: 1,
                    items: {
                        bsonType: "object",
                        required: ["id_producto", "nombre", "cantidad"],
                        properties: {
                            id_producto: { bsonType: "int" },
                            nombre: { bsonType: "string", minLength: 2, maxLength: 100 },
                            cantidad: { bsonType: "int", minimum: 1 }
                        }
                    }
                },

                despacho: {
                    bsonType: "object",
                    required: ["direccion", "transportista", "estado"],
                    properties: {
                        direccion: { bsonType: "string", minLength: 5, maxLength: 255 },
                        transportista: { bsonType: "string", minLength: 2, maxLength: 100 },
                        estado: { enum: ["PREPARADO", "EN_RUTA", "ENTREGADO"] },
                        tracking: {
                            bsonType: "array",
                            items: {
                                bsonType: "object",
                                required: ["fecha", "estado"],
                                properties: {
                                    fecha: { bsonType: "date" },
                                    estado: { enum: ["PREPARADO", "DESPACHADO", "ENTREGADO"] }
                                }
                            }
                        }
                    }
                },

                estado_pedido: {
                    enum: ["EN_PROCESO", "COMPLETADO", "CANCELADO"]
                }
            }
        }
    },
    validationLevel: "strict"
});

// CRUD

// Insertar pedidos
db.Pedidos.insertMany([
    {
        pedido_id: 372,
        venta_id: 1,
        cliente: {
            id_cliente: 2,
            razon_social: "Comercial XYZ SpA"
        },
        productos: [
            { id_producto: 1, nombre: "Laptop Gamer Pro", cantidad: 3 }
        ],
        despacho: {
            direccion: "Centro de Distribución Santiago",
            transportista: "Chilexpress",
            estado: "EN_RUTA",
            tracking: [
                { fecha: ISODate("2025-10-24"), estado: "PREPARADO" },
                { fecha: ISODate("2025-10-25"), estado: "DESPACHADO" }
            ]
        },
        estado_pedido: "EN_PROCESO"
    },

    {
        pedido_id: 373,
        venta_id: 2,
        cliente: {
            id_cliente: 3,
            razon_social: "Distribuidora Global S.A."
        },
        productos: [
            { id_producto: 1, nombre: "Laptop Gamer Pro", cantidad: 4 }
        ],
        despacho: {
            direccion: "Bodega Norte",
            transportista: "Starken",
            estado: "ENTREGADO",
            tracking: [
                { fecha: ISODate("2025-10-26"), estado: "PREPARADO" },
                { fecha: ISODate("2025-10-27"), estado: "DESPACHADO" },
                { fecha: ISODate("2025-10-28"), estado: "ENTREGADO" }
            ]
        },
        estado_pedido: "COMPLETADO"
    },

    {
        pedido_id: 374,
        venta_id: 3,
        cliente: {
            id_cliente: 1,
            razon_social: "Empresa ABC Ltda."
        },
        productos: [
            { id_producto: 2, nombre: "Monitor 24\" LED", cantidad: 2 }
        ],
        despacho: {
            direccion: "Sucursal Empresa ABC",
            transportista: "Bluexpress",
            estado: "EN_RUTA",
            tracking: [
                { fecha: ISODate("2025-10-24"), estado: "PREPARADO" }
            ]
        },
        estado_pedido: "EN_PROCESO"
    }
]);

// Obtener pedidos
db.Pedidos.find().pretty();

// Obtener un pedido específico
db.Pedidos.find({ pedido_id: 372 }).pretty();

//Buscar pedidso en ruta
db.Pedidos.find(
    { "despacho.estado": "EN_RUTA" }
).pretty();

// Cambiar el estado de un pedido
db.Pedidos.updateOne(
    { pedido_id: 372 },
    { $set: { estado_pedido: "COMPLETADO" } }
);

// Eliminar un pedido
db.Pedidos.deleteOne({ pedido_id: 372 });
