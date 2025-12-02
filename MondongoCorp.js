// Base de Datos NoSQL - MongoDB
// Empresa: MondongoCorp
// Descripción: Gestión de empleados, productos, ventas y bonos (proximamente)
// link: mongodb+srv://danunezd_db_user:<Aqui_va_la_contraseña_secreta>@cluster0.nithmyu.mongodb.net/

const database = 'MondongoCorp';

use('MondongoCorp');

// Más fácil y rápido crear las colecciones con validaciones directamente // No nos enseñaron así, pero uno aprende trucos bby
db.createCollection("empleados", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["_id", "nombre", "p_apellido", "departamento", "sueldo", "run", "activo", "fecha_contratacion"],
            properties: {
                _id: { bsonType: "int" },
                nombre: { bsonType: "string", minLength: 2, maxLength: 30 },
                p_apellido: { bsonType: "string", minLength: 2, maxLength: 30 },
                s_apellido: { bsonType: ["string", "null"], minLength: 2, maxLength: 30 },
                departamento: { bsonType: "string", minLength: 2, maxLength: 30 },
                sueldo: { bsonType: "number", minimum: 539000, maximum: 20000000 },
                run: { bsonType: "string", maxLength: 12 },
                email: { bsonType: ["string", "null"], maxLength: 100 },
                activo: { enum: ["S", "N"] },
                fecha_contratacion: { bsonType: "date" }
            }
        }
    },
    validationLevel: "strict"
});

db.createCollection("productos", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["_id", "nombre", "precio", "stock", "categoria", "activo"],
            properties: {
                _id: { bsonType: "int" },
                nombre: { bsonType: "string", minLength: 2, maxLength: 60 },
                descripcion: { bsonType: ["string", "null"], maxLength: 200 },
                precio: { bsonType: "number", minimum: 0 },
                stock: { bsonType: "int", minimum: 0 },
                categoria: { bsonType: "string", minLength: 2, maxLength: 50 },
                activo: { enum: ["S", "N"] }
            }
        }
    },
    validationLevel: "strict"
});

db.createCollection("ventas", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: [
                "_id",
                "fecha_venta",
                "estado",
                "cliente",
                "empleado",
                "productos",
                "subtotal",
                "impuesto",
                "total",
                "cantidad_total"
            ],
            properties: {
                _id: { bsonType: "int" },
                fecha_venta: { bsonType: "date" },
                estado: { enum: ["COMPLETADA", "CANCELADA", "PENDIENTE"] },
                cantidad_total: { bsonType: "int", minimum: 1 },
                cliente: {
                    bsonType: "object",
                    required: ["id_cliente", "nombre", "run"],
                    properties: {
                        id_cliente: { bsonType: "int" },
                        nombre: { bsonType: "string", minLength: 2, maxLength: 60 },
                        run: { bsonType: "string", maxLength: 12 },
                        email: { bsonType: ["string", "null"], maxLength: 100 },
                        telefono: { bsonType: ["string", "null"], maxLength: 20 }
                    }
                },
                empleado: {
                    bsonType: "object",
                    required: ["id_empleado", "nombre", "p_apellido", "departamento"],
                    properties: {
                        id_empleado: { bsonType: "int" },
                        nombre: { bsonType: "string", minLength: 2, maxLength: 30 },
                        p_apellido: { bsonType: "string", minLength: 2, maxLength: 30 },
                        s_apellido: { bsonType: ["string", "null"], maxLength: 30 },
                        departamento: { bsonType: "string", minLength: 2, maxLength: 30 }
                    }
                },
                productos: {
                    bsonType: "array",
                    minItems: 1,
                    items: {
                        bsonType: "object",
                        required: ["id_producto", "nombre", "precio", "cantidad"],
                        properties: {
                        id_producto: { bsonType: "int" },
                        nombre: { bsonType: "string", minLength: 2, maxLength: 60 },
                        precio: { bsonType: "number", minimum: 0 },
                        cantidad: { bsonType: "int", minimum: 1 }
                        }
                    }
                },
                subtotal: { bsonType: "number", minimum: 0 },
                impuesto: { bsonType: "number", minimum: 0 },
                total: { bsonType: "number", minimum: 0 },
                bono: {
                    bsonType: ["object", "null"],
                    properties: {
                        bono_id: { bsonType: "int" },
                        monto: { bsonType: "number" },
                        tipo: { bsonType: "string" }
                    }
                }
            }
        }
    },
    validationLevel: "strict"
});

db.createCollection("bonos", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["_id", "empleado_id", "venta_id", "monto_bono", "tipo_bono", "fecha_bono", "estado"],
            properties: {
                _id: { bsonType: "int" },
                empleado_id: { bsonType: "int" },
                venta_id: { bsonType: "int" },
                monto_bono: { bsonType: "number", minimum: 0 },
                tipo_bono: { bsonType: "string", minLength: 2 },
                fecha_bono: { bsonType: "date" },
                estado: { enum: ["ACTIVO", "ANULADO"] }
            }
        }
    },
    validationLevel: "strict"
});


//Esto no lo aplicamos ni tampoco nos han enseñado, peeeero info importante igual es:
// En escencia MongoDB busca en toda la colección antes de entegrar un resultado
// pero con los indices se puede ir directamente a la ubicación del dato solicitado
// Se generan indices en los campos más usados, por ejemplo en run de empleados,
// No lo hicimos, pero si fuese necesario, aquí está
//db.empleados.createIndex({ run: 1 }, { unique: true });
//db.productos.createIndex({ nombre: 1 });
//db.productos.createIndex({ categoria: 1 });
//db.ventas.createIndex({ fecha_venta: -1 });
//db.ventas.createIndex({ "empleado.id_empleado": 1 });
//db.bonos.createIndex({ empleado_id: 1 });
//db.bonos.createIndex({ venta_id: 1 });


// El CRUD Comienza acá

//Creando Empleados
db.empleados.insertMany([
    {
        _id: 1,
        nombre: "Juan",
        p_apellido: "Pérez",
        s_apellido: "Gómez",
        departamento: "Ventas",
        sueldo: 850000,
        run: "12345678-9",
        email: "juan.perez@empresa.cl",
        activo: "S",
        fecha_contratacion: ISODate("2023-01-15")
    },
    {
        _id: 2,
        nombre: "María",
        p_apellido: "López",
        s_apellido: "Sánchez",
        departamento: "Administración",
        sueldo: 950000,
        run: "98765432-1",
        email: "maria.lopez@empresa.cl",
        activo: "S",
        fecha_contratacion: ISODate("2022-03-20")
    }
]);


//Creando Productos
db.productos.insertMany([
    {
        _id: 1,
        nombre: "Laptop Gamer Pro",
        descripcion: "i7, 16GB, RTX 4060",
        precio: 1299900,
        categoria: "Tecnología",
        stock: 10,
        activo: "S"
    },
    {
        _id: 2,
        nombre: "Monitor 24 LED",
        descripcion: "Full HD 144Hz",
        precio: 249900,
        categoria: "Tecnología",
        stock: 15,
        activo: "S"
    }
]);

db.productos.insertOne({
    _id: 3,
    nombre: "Teclado Mecánico RGB",
    descripcion: "Switches azules, retroiluminación RGB",
    precio: 89900,
    categoria: "Accesorios",
    stock: 30,
    activo: "S"
});

//Creando Ventas
// Clientes existe dentro de las ventas pero no posee una colección propia
// esto porque no es una colección que se utilice de manera frecuente, en SQL existe proque debe haber una normalización de datos
// acá podría obtener a los clientes mediante consultas a las ventas directamente
db.ventas.insertOne({
    _id: 1,
    fecha_venta: ISODate("2024-09-15"),
    estado: "COMPLETADA",
    cantidad_total: 2,
    cliente: {
        id_cliente: 1,
        nombre: "Empresa ABC Ltda.",
        run: "12345678-0",
        email: "contacto@empresaabc.cl",
        telefono: "+56912345678"
    },
    empleado: {
        id_empleado: 1,
        nombre: "Juan",
        p_apellido: "Pérez",
        s_apellido: "Gómez",
        departamento: "Ventas"
    },
    productos: [
        {
            id_producto: 1,
            nombre: "Laptop Gamer Pro",
            precio: 1299900,
            cantidad: 2
        }
    ],
    subtotal: 1299900 * 2,
    impuesto: (1299900 * 2) * 0.19,
    total: (1299900 * 2) * 1.19,
    bono: null // No calculamos bonos aún
});



db.ventas.insertOne({
    _id: 2,
    fecha_venta: ISODate("2024-09-17"),
    estado: "COMPLETADA",
    cantidad_total: 1,
    cliente: {
        id_cliente: 3,
        nombre: "Distribuidora Global S.A.",
        run: "55666777-8",
        email: "info@distribuidoraglobal.cl",
        telefono: "+56955667788"
    },
    empleado: {
        id_empleado: 3,
        nombre: "Carlos",
        p_apellido: "González",
        s_apellido: "Martínez",
        departamento: "Ventas"
    },
    productos: [
        {
            id_producto: 3,
            nombre: "Teclado Mecánico RGB",
            precio: 89900,
            cantidad: 1
        }
    ],
    subtotal: 89900,
    impuesto: 89900 * 0.19,
    total: 89900 * 1.19,
    bono: null
});

//Buscando y actualizando (Read, Update)
//MondongoCorp no sabe que la venta 2 está relacionada al producto 3
//se lo tenemos que decir nosotros, entonces si queremos actualizar el stock
//Es necesario realizar dos pasos:
// 1ero obtener el producto de la venta
// 2do usar ese valor para actualizar el stock

//se busca la venta dos con un find sencillito
db.ventas.find(
    { _id: 2 },
    { productos: 1 }
).pretty();

//con el resultado del find, se actualiza el stock del producto
db.productos.updateOne(
    { _id: 3 },
    { $inc: { stock: -1 } }
);

//Lo mismo con la venta 1 y el producto 1
db.ventas.find(
    { _id: 1 },
    { productos: 1 }
).pretty();

db.productos.updateOne(
    { _id: 1 },
    { $inc: { stock: -2 } }
);

// Ahora la ultima funcionalidad del CRUD: Delete
//Probemos con el producto que no se ha comprado: el producto 2 (Monitor 24 LED)
db.productos.deleteOne(
    { _id: 2 }
);




