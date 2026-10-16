// ============================================================
//  EcoRuta Experiencias  --  Consultas MongoDB
//  Base de datos: ecoruta_v2
// ============================================================
// Para ejecutar: abrir MongoDB Shell (mongosh) y correr:
//   use ecoruta_v2
//   load("consultas_mongodb.js")
// O copiar cada bloque individualmente en mongosh / Compass
// ============================================================

use("ecoruta_v2");

// ============================================================
// PASO 1: Importar colecciones
// (Si usas mongoimport, ejecuta desde terminal:)
// mongoimport --db ecoruta_v2 --collection proveedores  --file proveedores.json  --jsonArray
// mongoimport --db ecoruta_v2 --collection experiencias --file experiencias.json --jsonArray
// mongoimport --db ecoruta_v2 --collection turistas     --file turistas.json     --jsonArray
// mongoimport --db ecoruta_v2 --collection reservas     --file reservas.json     --jsonArray
// ============================================================


// ============================================================
// CONSULTAS SIMPLES (5)
// ============================================================

// CONSULTA 1: Listar todas las experiencias de categoría "Aventura"
db.experiencias.find(
  { categoria: "Aventura" },
  { titulo: 1, duracion_horas: 1, precio_persona: 1, ubicacion: 1, _id: 0 }
);

// CONSULTA 2: Turistas con nacionalidad ecuatoriana registrados en 2025
db.turistas.find(
  {
    nacionalidad: "Ecuatoriana",
    fecha_registro: { $gte: "2025-01-01", $lte: "2025-12-31" }
  },
  { nombres: 1, apellidos: 1, correo: 1, fecha_registro: 1, _id: 0 }
);

// CONSULTA 3: Experiencias con precio_persona menor o igual a $50 y cupo mayor a 8
db.experiencias.find(
  {
    precio_persona: { $lte: 50 },
    cupo_maximo: { $gt: 8 }
  },
  { titulo: 1, precio_persona: 1, cupo_maximo: 1, categoria: 1, _id: 0 }
);

// CONSULTA 4: Reservas en estado "Aprobada" con pago acreditado
db.reservas.find(
  {
    estado: "Aprobada",
    "pago.estado_pago": "Acreditado"
  },
  {
    "turista.nombres": 1,
    "turista.apellidos": 1,
    "experiencia.titulo": 1,
    fecha_programada: 1,
    "pago.monto_total": 1,
    _id: 0
  }
);

// CONSULTA 5: Experiencias con al menos una valoración de puntaje 5 y que recomienden
db.experiencias.find(
  {
    "valoraciones": {
      $elemMatch: { puntaje: 5, recomienda: true }
    }
  },
  { titulo: 1, categoria: 1, promedio_puntaje: 1, _id: 0 }
);


// ============================================================
// CONSULTAS CON $lookup (3) — unen colecciones
// ============================================================

// LOOKUP 1: Reservas con datos completos del turista
//  (reservas → turistas)
db.reservas.aggregate([
  {
    $lookup: {
      from: "turistas",
      localField: "turista.id_turista",
      foreignField: "_id",
      as: "info_turista"
    }
  },
  { $unwind: "$info_turista" },
  {
    $project: {
      _id: 0,
      id_reserva: "$_id",
      fecha_programada: 1,
      participantes: 1,
      estado: 1,
      "pago.monto_total": 1,
      "pago.estado_pago": 1,
      turista_completo: {
        nombre: { $concat: ["$info_turista.nombres", " ", "$info_turista.apellidos"] },
        correo: "$info_turista.correo",
        nacionalidad: "$info_turista.nacionalidad"
      }
    }
  }
]);

// LOOKUP 2: Experiencias con datos completos del proveedor
//  (experiencias → proveedores)
db.experiencias.aggregate([
  {
    $lookup: {
      from: "proveedores",
      localField: "proveedor.id_proveedor",
      foreignField: "_id",
      as: "info_proveedor"
    }
  },
  { $unwind: "$info_proveedor" },
  {
    $project: {
      _id: 0,
      titulo: 1,
      categoria: 1,
      precio_persona: 1,
      cupo_maximo: 1,
      ubicacion: 1,
      proveedor_detalle: {
        nombre: "$info_proveedor.nombre",
        region: "$info_proveedor.region",
        tipo: "$info_proveedor.tipo",
        representante: "$info_proveedor.representante",
        email: "$info_proveedor.email"
      }
    }
  }
]);

// LOOKUP 3: Turistas con sus reservas y experiencias asociadas
//  (turistas → reservas → experiencias)
db.turistas.aggregate([
  {
    $lookup: {
      from: "reservas",
      localField: "_id",
      foreignField: "turista.id_turista",
      as: "mis_reservas"
    }
  },
  {
    $addFields: {
      total_reservas: { $size: "$mis_reservas" },
      total_gastado: { $sum: "$mis_reservas.pago.monto_total" }
    }
  },
  {
    $project: {
      _id: 0,
      turista: { $concat: ["$nombres", " ", "$apellidos"] },
      nacionalidad: 1,
      correo: 1,
      total_reservas: 1,
      total_gastado: 1,
      experiencias_reservadas: {
        $map: {
          input: "$mis_reservas",
          as: "r",
          in: {
            experiencia: "$$r.experiencia.titulo",
            fecha: "$$r.fecha_programada",
            estado: "$$r.estado",
            monto: "$$r.pago.monto_total"
          }
        }
      }
    }
  }
]);
