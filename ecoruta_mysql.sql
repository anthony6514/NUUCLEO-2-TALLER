-- ============================================================
--  EcoRuta Experiencias  --  Base de Datos Relacional MySQL
--  Estudiante: [Tu Nombre]
-- ============================================================

DROP DATABASE IF EXISTS ecoruta_v2;
CREATE DATABASE ecoruta_v2
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE ecoruta_v2;

-- ============================================================
-- TABLAS PRINCIPALES
-- ============================================================

CREATE TABLE Proveedores (
    id_proveedor   INT          PRIMARY KEY AUTO_INCREMENT,
    nombre         VARCHAR(150) NOT NULL,
    region         VARCHAR(100) NOT NULL,
    tipo           ENUM('Comunidad','Cooperativa','Asociacion','Empresa Social') NOT NULL,
    representante  VARCHAR(100) NOT NULL,
    telefono       VARCHAR(20),
    email          VARCHAR(150) UNIQUE,
    activo         TINYINT(1)   DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE Turistas (
    id_turista      INT          PRIMARY KEY AUTO_INCREMENT,
    nombres         VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    documento       VARCHAR(20)  UNIQUE NOT NULL,
    correo          VARCHAR(150) UNIQUE NOT NULL,
    celular         VARCHAR(20),
    nacionalidad    VARCHAR(80),
    fecha_registro  DATE         NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Guias (
    id_guia         INT          PRIMARY KEY AUTO_INCREMENT,
    nombres         VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    cedula          VARCHAR(20)  UNIQUE NOT NULL,
    especialidad    VARCHAR(100) NOT NULL,
    idiomas         VARCHAR(150),
    celular         VARCHAR(20),
    estado          ENUM('Activo','Inactivo','Vacaciones') DEFAULT 'Activo'
) ENGINE=InnoDB;

CREATE TABLE Experiencias (
    id_experiencia    INT            PRIMARY KEY AUTO_INCREMENT,
    id_proveedor      INT            NOT NULL,
    titulo            VARCHAR(200)   NOT NULL,
    categoria         ENUM('Aventura','Cultural','Gastronomia','Agricola','Espiritual','Bienestar') NOT NULL,
    descripcion       TEXT,
    duracion_horas    DECIMAL(4,1)   NOT NULL,
    precio_persona    DECIMAL(10,2)  NOT NULL,
    cupo_maximo       INT            NOT NULL,
    cupo_disponible   INT            NOT NULL,
    ubicacion         VARCHAR(200),
    activa            TINYINT(1)     DEFAULT 1,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Experiencias_Guias (
    id_experiencia  INT  NOT NULL,
    id_guia         INT  NOT NULL,
    desde           DATE,
    hasta           DATE,
    PRIMARY KEY (id_experiencia, id_guia),
    FOREIGN KEY (id_experiencia) REFERENCES Experiencias(id_experiencia)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_guia) REFERENCES Guias(id_guia)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Reservas (
    id_reserva          INT    PRIMARY KEY AUTO_INCREMENT,
    id_turista          INT    NOT NULL,
    id_experiencia      INT    NOT NULL,
    fecha_solicitud     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_programada    DATE   NOT NULL,
    participantes       INT    NOT NULL,
    estado              ENUM('En espera','Aprobada','Rechazada','Finalizada','Cancelada') DEFAULT 'En espera',
    incluye_transporte  TINYINT(1) DEFAULT 0,
    incluye_alimentacion TINYINT(1) DEFAULT 0,
    incluye_hospedaje   TINYINT(1) DEFAULT 0,
    observaciones       VARCHAR(300),
    FOREIGN KEY (id_turista)     REFERENCES Turistas(id_turista)     ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_experiencia) REFERENCES Experiencias(id_experiencia) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Pagos (
    id_pago          INT            PRIMARY KEY AUTO_INCREMENT,
    id_reserva       INT            NOT NULL UNIQUE,
    monto_base       DECIMAL(10,2)  NOT NULL,
    monto_servicios  DECIMAL(10,2)  DEFAULT 0.00,
    monto_total      DECIMAL(10,2)  NOT NULL,
    forma_pago       ENUM('Efectivo','Tarjeta Debito','Tarjeta Credito','Transferencia','Nequi','Daviplata') NOT NULL,
    fecha_pago       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_pago      ENUM('Pendiente','Acreditado','Devuelto','Rechazado') DEFAULT 'Pendiente',
    referencia       VARCHAR(80),
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Valoraciones (
    id_valoracion   INT      PRIMARY KEY AUTO_INCREMENT,
    id_reserva      INT      NOT NULL,
    id_turista      INT      NOT NULL,
    puntaje         TINYINT  NOT NULL CHECK (puntaje BETWEEN 1 AND 5),
    titulo_resena   VARCHAR(120),
    resena          TEXT,
    recomienda      TINYINT(1) DEFAULT 1,
    fecha_resena    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_reserva)  REFERENCES Reservas(id_reserva)   ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_turista)  REFERENCES Turistas(id_turista)   ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Tabla de auditoría para cambios en reservas
CREATE TABLE Log_Reservas (
    id_log          INT          PRIMARY KEY AUTO_INCREMENT,
    id_reserva      INT          NOT NULL,
    estado_anterior VARCHAR(50),
    estado_nuevo    VARCHAR(50),
    accion          VARCHAR(50),
    usuario_bd      VARCHAR(100),
    fecha_log       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índice en correo de turistas para búsquedas rápidas por login
CREATE INDEX idx_turistas_correo     ON Turistas(correo);

-- Índice compuesto para filtrar reservas por estado y fecha programada
CREATE INDEX idx_reservas_estado_fecha ON Reservas(estado, fecha_programada);

-- ============================================================
-- DATOS: Proveedores
-- ============================================================

INSERT INTO Proveedores (nombre, region, tipo, representante, telefono, email) VALUES
('Asociación Wasi Pacha',        'Sierra Centro',      'Asociacion',      'Verónica Chimborazo', '+593 99 1234567', 'info@wasipacha.ec'),
('Colectivo Selva Viva',         'Amazonía Sur',       'Cooperativa',     'Héctor Grefa',        '+593 98 2345678', 'contacto@selvaviva.ec'),
('Red Comunitaria Manglares',    'Costa Norte',        'Comunidad',       'Dolores Arroyo',      '+593 97 3456789', 'red@manglares.ec'),
('Emprendimiento Páramo Alto',   'Sierra Norte',       'Empresa Social',  'Segundo Quilumba',    '+593 96 4567890', 'paramo@alto.ec'),
('Familia Chasqui Viajero',      'Andes Meridionales', 'Comunidad',       'Luz Hurtado',         '+593 95 5678901', 'chasqui@viajero.ec');

-- ============================================================
-- DATOS: Turistas
-- ============================================================

INSERT INTO Turistas (nombres, apellidos, documento, correo, celular, nacionalidad, fecha_registro) VALUES
('Sebastián',  'Naranjo Vega',    '1750432100', 'seba.naranjo@gmail.com',   '+593 99 8765432', 'Ecuatoriana',  '2025-01-10'),
('Fernanda',   'Ríos Castillo',   '0603891200', 'feri.rios@hotmail.com',    '+593 98 7654321', 'Ecuatoriana',  '2025-02-14'),
('Thomas',     'Becker',          'DE8821345',  'thomas.becker@mail.de',    '+49 151 33445566','Alemana',      '2025-03-05'),
('Valentina',  'Ruiz Moreno',     'CO9934512',  'vruizmoreno@outlook.com',  '+57 300 9988776', 'Colombiana',   '2025-04-18'),
('Kenji',      'Tanaka',          'JP5566778',  'kenji.tanaka@japan.jp',    '+81 90 44556677', 'Japonesa',     '2025-05-22'),
('Isabela',    'Ferreira Lima',   'BR3344556',  'isa.ferreira@uol.com.br',  '+55 11 99887766', 'Brasileña',    '2025-06-03');

-- ============================================================
-- DATOS: Guías
-- ============================================================

INSERT INTO Guias (nombres, apellidos, cedula, especialidad, idiomas, celular, estado) VALUES
('Mauricio',   'Tigse Caiza',   '0503456789', 'Etnobotánica y Plantas Medicinales', 'Español, Kichwa',          '+593 99 1112233', 'Activo'),
('Patricia',   'Grefa Shiguango','2100987654', 'Fauna Amazónica y Supervivencia',   'Español, Inglés, Shuar',   '+593 98 2223344', 'Activo'),
('Rodrigo',    'Arroyo Ponce',  '0801234567', 'Gastronomía y Pesca Artesanal',      'Español, Inglés',          '+593 97 3334455', 'Activo'),
('Norma',      'Quilumba Toapanta','1712345678','Textiles Andinos y Cosmovisión',   'Español, Kichwa, Inglés',  '+593 96 4445566', 'Activo'),
('Andrés',     'Hurtado Mora',  '0104567890', 'Senderismo de Alta Montaña',         'Español, Inglés, Alemán',  '+593 95 5556677', 'Activo');

-- ============================================================
-- DATOS: Experiencias
-- ============================================================

INSERT INTO Experiencias (id_proveedor, titulo, categoria, descripcion, duracion_horas, precio_persona, cupo_maximo, cupo_disponible, ubicacion) VALUES
(1, 'Ritual de Agradecimiento a la Pachamama',    'Espiritual',    'Ceremonia ancestral kichwa de ofrenda y conexión con la tierra, guiada por un yachak local.',                        5.0,  55.00, 8,  8,  'Comunidad Wasi Pacha, Cotopaxi'),
(2, 'Expedición Nocturna de Anfibios',             'Aventura',      'Recorrido científico-recreativo para observar ranas y reptiles en su hábitat natural nocturno.',                     3.5,  70.00, 6,  6,  'Cuenca del Río Pastaza, Pastaza'),
(3, 'Cocina Costera: Sabores del Manglar',         'Gastronomia',   'Taller práctico de preparación de ceviches, patacones y mariscos con técnicas de cocineros comunitarios.',           4.0,  40.00, 12, 12, 'Bahía de Atacames, Esmeraldas'),
(4, 'Tejido en Telar de Cintura',                  'Cultural',      'Aprende a tejer tapices andinos con hilos de lana de oveja teñidos con plantas naturales.',                          6.0,  50.00, 10, 10, 'Tabacundo, Pichincha'),
(5, 'Trekking al Mirador del Cóndor',              'Aventura',      'Senderismo de 12 km por el páramo hasta un mirador con vista panorámica a cuatro volcanes.',                         7.0,  65.00, 15, 15, 'Reserva Cayambe-Coca, Napo'),
(1, 'Siembra y Cosecha de Quinua Orgánica',        'Agricola',      'Participa activamente en el ciclo agrícola de la quinua con familias campesinas del altiplano.',                     4.5,  38.00, 10, 10, 'Saquisilí, Cotopaxi'),
(2, 'Construcción de Balsa Amazónica',             'Cultural',      'Aprende técnicas ancestrales de navegación amazónica: construcción de balsas y remos artesanales.',                  5.5,  80.00, 8,  8,  'Puerto Napo, Napo');

-- ============================================================
-- DATOS: Experiencias_Guías
-- ============================================================

INSERT INTO Experiencias_Guias (id_experiencia, id_guia, desde, hasta) VALUES
(1, 4, '2025-01-01', '2025-12-31'),
(2, 2, '2025-01-01', '2025-12-31'),
(3, 3, '2025-02-01', '2025-11-30'),
(4, 4, '2025-01-15', '2025-12-15'),
(5, 5, '2025-03-01', '2025-12-31'),
(6, 1, '2025-01-01', '2025-12-31'),
(7, 2, '2025-04-01', '2025-11-30');

-- ============================================================
-- DATOS: Reservas
-- ============================================================

INSERT INTO Reservas (id_turista, id_experiencia, fecha_solicitud, fecha_programada, participantes, estado, incluye_transporte, incluye_alimentacion, incluye_hospedaje, observaciones) VALUES
(1, 1, '2025-06-10 09:00:00', '2025-07-20', 2, 'Aprobada',   1, 1, 0, 'Solicitan guía en kichwa'),
(2, 3, '2025-06-12 14:30:00', '2025-08-05', 4, 'Aprobada',   1, 1, 0, 'Alergia a los camarones - turista 2'),
(3, 5, '2025-06-15 10:00:00', '2025-09-10', 1, 'En espera',  0, 0, 0, 'Viajero con equipo de fotografía'),
(4, 2, '2025-06-18 16:00:00', '2025-07-28', 3, 'Aprobada',   1, 0, 0, NULL),
(5, 4, '2025-06-20 08:30:00', '2025-08-15', 2, 'Aprobada',   0, 1, 0, 'Interés en técnicas de teñido natural'),
(6, 6, '2025-06-22 11:45:00', '2025-09-01', 3, 'En espera',  1, 1, 1, 'Grupo familiar con niños'),
(1, 7, '2025-06-25 13:00:00', '2025-10-05', 2, 'Aprobada',   1, 1, 1, 'Segunda visita del turista');

-- ============================================================
-- DATOS: Pagos
-- ============================================================

INSERT INTO Pagos (id_reserva, monto_base, monto_servicios, monto_total, forma_pago, fecha_pago, estado_pago, referencia) VALUES
(1, 110.00, 30.00, 140.00, 'Transferencia',    '2025-06-10 09:45:00', 'Acreditado',  'TRF-2025-0610-001'),
(2, 160.00, 40.00, 200.00, 'Tarjeta Credito',  '2025-06-12 15:10:00', 'Acreditado',  'TC-2025-0612-002'),
(3,  65.00,  0.00,  65.00, 'Nequi',            '2025-06-15 10:30:00', 'Pendiente',   'NQ-2025-0615-003'),
(4, 210.00, 25.00, 235.00, 'Transferencia',    '2025-06-18 16:40:00', 'Acreditado',  'TRF-2025-0618-004'),
(5, 100.00, 20.00, 120.00, 'Daviplata',        '2025-06-20 09:00:00', 'Acreditado',  'DV-2025-0620-005'),
(6, 114.00, 60.00, 174.00, 'Efectivo',         '2025-06-22 12:00:00', 'Pendiente',   NULL),
(7, 160.00, 50.00, 210.00, 'Tarjeta Debito',   '2025-06-25 13:30:00', 'Acreditado',  'TD-2025-0625-007');

-- ============================================================
-- DATOS: Valoraciones
-- ============================================================

INSERT INTO Valoraciones (id_reserva, id_turista, puntaje, titulo_resena, resena, recomienda, fecha_resena) VALUES
(1, 1, 5, 'Una experiencia transformadora',      'La ceremonia con la yachak fue profundamente emotiva. El equipo fue muy cálido y organizado.',           1, '2025-07-21 20:00:00'),
(2, 2, 4, 'Sabores únicos del océano',           'Los mariscos frescos y las técnicas de cocina artesanal sorprendieron a todo el grupo. Excelente.',       1, '2025-08-06 18:30:00'),
(4, 4, 5, 'Noche selvática inolvidable',         'Patricia conoce cada especie al dedillo. Ver las ranas fosforescentes fue mágico. Muy recomendada.',      1, '2025-07-29 21:00:00'),
(5, 5, 5, 'Arte textil que enamora',             'Norma explica con paciencia cada paso del telar. Me llevé mi propio tapiz terminado. Increíble.',         1, '2025-08-16 17:45:00'),
(7, 1, 5, 'La balsa fue el reto del año',        'Construir la balsa desde cero y navegar en ella fue la experiencia más auténtica de mi vida. 10/10.',     1, '2025-10-06 19:00:00'),
(1, 1, 4, 'Regresaré el próximo año',            'La organización logística mejoró respecto a lo prometido. El contenido cultural es excepcional.',         1, '2025-07-22 10:00:00');

-- ============================================================
-- VISTAS
-- ============================================================

-- Vista 1: Catálogo completo de experiencias con datos del proveedor
CREATE VIEW v_catalogo_experiencias AS
SELECT
    e.id_experiencia,
    e.titulo,
    e.categoria,
    e.duracion_horas,
    e.precio_persona,
    e.cupo_maximo,
    e.cupo_disponible,
    e.ubicacion,
    p.nombre        AS proveedor,
    p.region,
    p.tipo          AS tipo_proveedor,
    p.representante
FROM Experiencias e
INNER JOIN Proveedores p ON e.id_proveedor = p.id_proveedor
WHERE e.activa = 1;

-- Vista 2: Reservas activas con datos completos de turista y experiencia (multitabla)
CREATE VIEW v_reservas_activas AS
SELECT
    r.id_reserva,
    r.fecha_programada,
    r.participantes,
    r.estado,
    CONCAT(t.nombres, ' ', t.apellidos)  AS turista,
    t.correo                              AS correo_turista,
    t.nacionalidad,
    e.titulo                              AS experiencia,
    e.categoria,
    e.precio_persona,
    (r.participantes * e.precio_persona)  AS subtotal_base,
    p.nombre                              AS proveedor
FROM Reservas r
INNER JOIN Turistas     t ON r.id_turista     = t.id_turista
INNER JOIN Experiencias e ON r.id_experiencia = e.id_experiencia
INNER JOIN Proveedores  p ON e.id_proveedor   = p.id_proveedor
WHERE r.estado IN ('En espera', 'Aprobada');

-- Vista 3: Ingresos consolidados por proveedor (multitabla)
CREATE VIEW v_ingresos_proveedor AS
SELECT
    p.id_proveedor,
    p.nombre                            AS proveedor,
    p.region,
    COUNT(DISTINCT r.id_reserva)        AS total_reservas,
    SUM(pg.monto_total)                 AS ingresos_totales,
    AVG(pg.monto_total)                 AS ticket_promedio
FROM Proveedores p
INNER JOIN Experiencias e  ON p.id_proveedor   = e.id_proveedor
LEFT  JOIN Reservas     r  ON e.id_experiencia = r.id_experiencia
LEFT  JOIN Pagos        pg ON r.id_reserva     = pg.id_reserva
    AND pg.estado_pago = 'Acreditado'
GROUP BY p.id_proveedor, p.nombre, p.region;

-- Vista 4: Guías con sus experiencias asignadas (multitabla)
CREATE VIEW v_guias_asignados AS
SELECT
    g.id_guia,
    CONCAT(g.nombres, ' ', g.apellidos) AS guia,
    g.especialidad,
    g.idiomas,
    g.estado,
    e.titulo    AS experiencia_asignada,
    e.categoria,
    eg.desde,
    eg.hasta
FROM Guias g
LEFT JOIN Experiencias_Guias eg ON g.id_guia         = eg.id_guia
LEFT JOIN Experiencias       e  ON eg.id_experiencia = e.id_experiencia;

-- Vista 5: Ranking de experiencias por calificación promedio
CREATE VIEW v_ranking_experiencias AS
SELECT
    e.id_experiencia,
    e.titulo,
    e.categoria,
    COUNT(v.id_valoracion)  AS total_resenas,
    ROUND(AVG(v.puntaje),2) AS promedio_puntaje,
    SUM(v.recomienda)       AS total_recomendaciones
FROM Experiencias e
LEFT JOIN Reservas    r ON e.id_experiencia = r.id_experiencia
LEFT JOIN Valoraciones v ON r.id_reserva   = v.id_reserva
GROUP BY e.id_experiencia, e.titulo, e.categoria
ORDER BY promedio_puntaje DESC;

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger 1: Reducir cupo_disponible al aprobar una reserva
DELIMITER //
CREATE TRIGGER trg_reducir_cupo
AFTER UPDATE ON Reservas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Aprobada' AND OLD.estado != 'Aprobada' THEN
        UPDATE Experiencias
        SET cupo_disponible = cupo_disponible - NEW.participantes
        WHERE id_experiencia = NEW.id_experiencia;
    END IF;

    -- Restaurar cupo si se cancela una reserva que estaba aprobada
    IF NEW.estado = 'Cancelada' AND OLD.estado = 'Aprobada' THEN
        UPDATE Experiencias
        SET cupo_disponible = cupo_disponible + OLD.participantes
        WHERE id_experiencia = OLD.id_experiencia;
    END IF;
END//
DELIMITER ;

-- Trigger 2: Validar que participantes no supere cupo disponible
DELIMITER //
CREATE TRIGGER trg_validar_cupo
BEFORE INSERT ON Reservas
FOR EACH ROW
BEGIN
    DECLARE v_cupo INT;
    SELECT cupo_disponible INTO v_cupo
    FROM Experiencias
    WHERE id_experiencia = NEW.id_experiencia;

    IF NEW.participantes > v_cupo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay cupo suficiente para el número de participantes solicitado.';
    END IF;
END//
DELIMITER ;

-- Trigger 3: Registrar en Log_Reservas todo cambio de estado
DELIMITER //
CREATE TRIGGER trg_log_cambio_estado
AFTER UPDATE ON Reservas
FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado THEN
        INSERT INTO Log_Reservas (id_reserva, estado_anterior, estado_nuevo, accion, usuario_bd)
        VALUES (NEW.id_reserva, OLD.estado, NEW.estado, 'CAMBIO_ESTADO', USER());
    END IF;
END//
DELIMITER ;

-- Trigger 4: Calcular monto_total automáticamente antes de insertar un pago
DELIMITER //
CREATE TRIGGER trg_calcular_monto_total
BEFORE INSERT ON Pagos
FOR EACH ROW
BEGIN
    SET NEW.monto_total = NEW.monto_base + IFNULL(NEW.monto_servicios, 0);
END//
DELIMITER ;

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ============================================================

-- Procedimiento 1: Registrar una nueva reserva con validación de cupo
DELIMITER //
CREATE PROCEDURE sp_nueva_reserva(
    IN  p_id_turista          INT,
    IN  p_id_experiencia      INT,
    IN  p_fecha_programada    DATE,
    IN  p_participantes       INT,
    IN  p_transporte          TINYINT,
    IN  p_alimentacion        TINYINT,
    IN  p_hospedaje           TINYINT,
    IN  p_observaciones       VARCHAR(300),
    OUT p_id_reserva_nueva    INT,
    OUT p_mensaje             VARCHAR(200)
)
BEGIN
    DECLARE v_cupo INT;

    SELECT cupo_disponible INTO v_cupo
    FROM Experiencias
    WHERE id_experiencia = p_id_experiencia;

    IF v_cupo IS NULL THEN
        SET p_mensaje = 'Experiencia no encontrada.';
        SET p_id_reserva_nueva = 0;
    ELSEIF p_participantes > v_cupo THEN
        SET p_mensaje = CONCAT('Cupo insuficiente. Disponible: ', v_cupo);
        SET p_id_reserva_nueva = 0;
    ELSE
        INSERT INTO Reservas (
            id_turista, id_experiencia, fecha_programada, participantes,
            incluye_transporte, incluye_alimentacion, incluye_hospedaje, observaciones
        ) VALUES (
            p_id_turista, p_id_experiencia, p_fecha_programada, p_participantes,
            p_transporte, p_alimentacion, p_hospedaje, p_observaciones
        );
        SET p_id_reserva_nueva = LAST_INSERT_ID();
        SET p_mensaje = 'Reserva creada correctamente.';
    END IF;
END//
DELIMITER ;

-- Procedimiento 2: Confirmar pago y cambiar estado de reserva a Aprobada
DELIMITER //
CREATE PROCEDURE sp_confirmar_pago(
    IN p_id_reserva  INT,
    IN p_forma_pago  VARCHAR(50),
    IN p_referencia  VARCHAR(80)
)
BEGIN
    DECLARE v_monto_base      DECIMAL(10,2);
    DECLARE v_monto_servicios DECIMAL(10,2) DEFAULT 0;
    DECLARE v_participantes   INT;
    DECLARE v_precio          DECIMAL(10,2);
    DECLARE v_transporte      TINYINT;
    DECLARE v_alimentacion    TINYINT;
    DECLARE v_hospedaje       TINYINT;

    SELECT r.participantes, e.precio_persona,
           r.incluye_transporte, r.incluye_alimentacion, r.incluye_hospedaje
    INTO v_participantes, v_precio, v_transporte, v_alimentacion, v_hospedaje
    FROM Reservas r
    INNER JOIN Experiencias e ON r.id_experiencia = e.id_experiencia
    WHERE r.id_reserva = p_id_reserva;

    SET v_monto_base = v_participantes * v_precio;

    -- Tarifas fijas por servicio adicional por persona
    IF v_transporte   = 1 THEN SET v_monto_servicios = v_monto_servicios + (v_participantes * 10); END IF;
    IF v_alimentacion = 1 THEN SET v_monto_servicios = v_monto_servicios + (v_participantes * 15); END IF;
    IF v_hospedaje    = 1 THEN SET v_monto_servicios = v_monto_servicios + (v_participantes * 25); END IF;

    INSERT INTO Pagos (id_reserva, monto_base, monto_servicios, monto_total, forma_pago, estado_pago, referencia)
    VALUES (p_id_reserva, v_monto_base, v_monto_servicios,
            v_monto_base + v_monto_servicios, p_forma_pago, 'Acreditado', p_referencia);

    UPDATE Reservas SET estado = 'Aprobada' WHERE id_reserva = p_id_reserva;

    SELECT CONCAT('Pago registrado. Total: $', v_monto_base + v_monto_servicios) AS Resultado;
END//
DELIMITER ;

-- Procedimiento 3: Generar reporte de experiencias con bajo cupo (umbral configurable)
DELIMITER //
CREATE PROCEDURE sp_experiencias_bajo_cupo(
    IN p_umbral INT
)
BEGIN
    SELECT
        e.id_experiencia,
        e.titulo,
        e.categoria,
        e.cupo_maximo,
        e.cupo_disponible,
        ROUND((e.cupo_disponible / e.cupo_maximo) * 100, 1) AS porcentaje_libre,
        p.nombre AS proveedor
    FROM Experiencias e
    INNER JOIN Proveedores p ON e.id_proveedor = p.id_proveedor
    WHERE e.cupo_disponible <= p_umbral AND e.activa = 1
    ORDER BY e.cupo_disponible ASC;
END//
DELIMITER ;

-- Procedimiento 4: Cancelar reserva y registrar motivo en el log
DELIMITER //
CREATE PROCEDURE sp_cancelar_reserva(
    IN p_id_reserva INT,
    IN p_motivo     VARCHAR(300)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(50);

    SELECT estado INTO v_estado_actual
    FROM Reservas WHERE id_reserva = p_id_reserva;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reserva no encontrada.';
    ELSEIF v_estado_actual = 'Finalizada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede cancelar una reserva ya finalizada.';
    ELSEIF v_estado_actual = 'Cancelada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La reserva ya se encuentra cancelada.';
    ELSE
        UPDATE Reservas
        SET estado = 'Cancelada',
            observaciones = CONCAT(IFNULL(observaciones,''), ' | CANCELACIÓN: ', p_motivo)
        WHERE id_reserva = p_id_reserva;

        INSERT INTO Log_Reservas (id_reserva, estado_anterior, estado_nuevo, accion, usuario_bd)
        VALUES (p_id_reserva, v_estado_actual, 'Cancelada', 'CANCELACION_MANUAL', USER());

        SELECT 'Reserva cancelada correctamente.' AS Resultado;
    END IF;
END//
DELIMITER ;

-- ============================================================
-- ROLES Y USUARIOS
-- ============================================================

DROP ROLE IF EXISTS 'rol_gestor';
DROP ROLE IF EXISTS 'rol_consultor';

CREATE ROLE 'rol_gestor';
CREATE ROLE 'rol_consultor';

-- rol_gestor: acceso completo para operar la plataforma
GRANT SELECT, INSERT, UPDATE, DELETE ON ecoruta_v2.*       TO 'rol_gestor';
GRANT EXECUTE ON PROCEDURE ecoruta_v2.sp_nueva_reserva     TO 'rol_gestor';
GRANT EXECUTE ON PROCEDURE ecoruta_v2.sp_confirmar_pago    TO 'rol_gestor';
GRANT EXECUTE ON PROCEDURE ecoruta_v2.sp_cancelar_reserva  TO 'rol_gestor';
GRANT EXECUTE ON PROCEDURE ecoruta_v2.sp_experiencias_bajo_cupo TO 'rol_gestor';

-- rol_consultor: solo lectura y consultas de disponibilidad
GRANT SELECT ON ecoruta_v2.*  TO 'rol_consultor';
GRANT EXECUTE ON PROCEDURE ecoruta_v2.sp_experiencias_bajo_cupo TO 'rol_consultor';

DROP USER IF EXISTS 'gestor_ecoruta'@'localhost';
DROP USER IF EXISTS 'consultor_ecoruta'@'localhost';

CREATE USER 'gestor_ecoruta'@'localhost'   IDENTIFIED BY 'Gestor2025#';
CREATE USER 'consultor_ecoruta'@'localhost' IDENTIFIED BY 'Consultor2025#';

GRANT 'rol_gestor'    TO 'gestor_ecoruta'@'localhost';
GRANT 'rol_consultor' TO 'consultor_ecoruta'@'localhost';

SET DEFAULT ROLE ALL TO 'gestor_ecoruta'@'localhost';
SET DEFAULT ROLE ALL TO 'consultor_ecoruta'@'localhost';

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SHOW TABLES;
SHOW TRIGGERS;
SHOW PROCEDURE STATUS WHERE Db = 'ecoruta_v2';
