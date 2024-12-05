-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 05-12-2024 a las 23:47:18
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sistema_gestión_clientes`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarCliente` (IN `p_cliente_id` INT, IN `p_nombre` VARCHAR(100), IN `p_apellido` VARCHAR(100), IN `p_email` VARCHAR(150), IN `p_telefono` VARCHAR(15), IN `p_direccion` VARCHAR(255), IN `p_categoria_producto` VARCHAR(100), IN `p_frecuencia_compra` INT)   BEGIN
    UPDATE Clientes
    SET nombre = p_nombre, apellido = p_apellido, email = p_email, telefono = p_telefono, direccion = p_direccion
    WHERE cliente_id = p_cliente_id;
    
    INSERT INTO Preferencias (cliente_id, categoria_producto, frecuencia_compra)
    VALUES (p_cliente_id, p_categoria_producto, p_frecuencia_compra)
    ON DUPLICATE KEY UPDATE categoria_producto = p_categoria_producto, frecuencia_compra = p_frecuencia_compra;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CalcularFidelidad` ()   BEGIN
    SELECT cliente_id, COUNT(*) AS num_compras, SUM(monto) AS total_gasto
    FROM Compras
    GROUP BY cliente_id
    HAVING COUNT(*) > 5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerarInformeVentas` (IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE)   BEGIN
    SELECT cliente_id, SUM(monto_total) AS total_ventas
    FROM Ventas
    WHERE fecha_venta BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY cliente_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarCliente` (IN `p_nombre` VARCHAR(100), IN `p_apellido` VARCHAR(100), IN `p_email` VARCHAR(150), IN `p_telefono` VARCHAR(15), IN `p_direccion` VARCHAR(255))   BEGIN
    INSERT INTO Clientes (nombre, apellido, email, telefono, direccion)
    VALUES (p_nombre, p_apellido, p_email, p_telefono, p_direccion);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alertas`
--

CREATE TABLE `alertas` (
  `cliente_id` int(11) NOT NULL,
  `tipo_alerta` varchar(100) NOT NULL,
  `fecha_alerta` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `cliente_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `Direccion` varchar(300) NOT NULL,
  `Fecha Registro` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `fecha_ultimo_contacto` datetime(6) NOT NULL,
  `Estado` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `cliente`
--
DELIMITER $$
CREATE TRIGGER `after_cliente_update` AFTER UPDATE ON `cliente` FOR EACH ROW BEGIN
    IF OLD.email != NEW.email OR OLD.telefono != NEW.telefono THEN
        INSERT INTO HistorialCambios (cliente_id, tipo_cambio, fecha_cambio)
        VALUES (NEW.cliente_id, 'cambio contacto', NOW());
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_client_inactive` AFTER UPDATE ON `cliente` FOR EACH ROW BEGIN
    IF DATEDIFF(CURRENT_DATE, NEW.fecha_ultimo_contacto) > 365 THEN
        -- Aquí se puede ejecutar una notificación o un registro de alerta.
        INSERT INTO Alertas (cliente_id, tipo_alerta, fecha_alerta)
        VALUES (NEW.cliente_id, 'Cliente Inactivo', NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `compra ID` int(11) NOT NULL,
  `cliente_Id` int(11) DEFAULT NULL,
  `Fecha Compra` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `Monto` decimal(10,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `compras`
--
DELIMITER $$
CREATE TRIGGER `alertar_patron_repetido` AFTER INSERT ON `compras` FOR EACH ROW BEGIN
    DECLARE cantidad INT;
    SELECT COUNT(*) INTO cantidad FROM Compras WHERE cliente_id = NEW.cliente_id AND fecha_compra > (CURRENT_DATE - INTERVAL 30 DAY);
    IF cantidad > 5 THEN
        -- Aquí se podría enviar una alerta sobre el patrón repetido de compras
        INSERT INTO Alertas (cliente_id, tipo_alerta, fecha_alerta)
        VALUES (NEW.cliente_id, 'Patrón de compra repetida', NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historialcambios`
--

CREATE TABLE `historialcambios` (
  `cliente_id` int(11) NOT NULL,
  `tipo_cambio` varchar(100) NOT NULL,
  `fecha_cambio` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `preferencias`
--

CREATE TABLE `preferencias` (
  `preferencias id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `categoria producto` varchar(100) NOT NULL,
  `frecuencia compra` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registrarcliente`
--

CREATE TABLE `registrarcliente` (
  `p_nombre` varchar(100) NOT NULL,
  `p_apellido` varchar(100) NOT NULL,
  `p_email` varchar(150) NOT NULL,
  `p_telefono` varchar(15) NOT NULL,
  `p_direccion` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `venta id` int(11) NOT NULL,
  `cliente id` int(11) NOT NULL,
  `monto total` decimal(10,0) NOT NULL,
  `fecha venta` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`cliente_id`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`compra ID`);

--
-- Indices de la tabla `preferencias`
--
ALTER TABLE `preferencias`
  ADD PRIMARY KEY (`preferencias id`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`venta id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `cliente_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `compra ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `preferencias`
--
ALTER TABLE `preferencias`
  MODIFY `preferencias id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `venta id` int(11) NOT NULL AUTO_INCREMENT;

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `verificar_clientes_inactivos` ON SCHEDULE EVERY 1 WEEK STARTS '2024-12-05 17:25:27' ON COMPLETION NOT PRESERVE ENABLE DO INSERT INTO Alertas (cliente_id, tipo_alerta, fecha_alerta)
    SELECT cliente_id, 'Cliente Inactivo', NOW()
    FROM Clientes
    WHERE DATEDIFF(CURRENT_DATE, fecha_ultimo_contacto) > 365$$

CREATE DEFINER=`root`@`localhost` EVENT `generar_reporte_mensual` ON SCHEDULE EVERY 1 MONTH STARTS '2024-12-05 17:27:01' ON COMPLETION NOT PRESERVE ENABLE DO CALL GenerarInformeVentas(CURRENT_DATE - INTERVAL 1 MONTH, CURRENT_DATE)$$

CREATE DEFINER=`root`@`localhost` EVENT `limpieza_anual` ON SCHEDULE EVERY 1 YEAR STARTS '2024-12-05 17:27:14' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM Clientes WHERE DATEDIFF(CURRENT_DATE, fecha_registro) > 3650$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
